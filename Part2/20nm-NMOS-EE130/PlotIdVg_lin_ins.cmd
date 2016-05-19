#----------------------------------------------------------------------#
#set IdLin  x
#set VtLin x

set N     @node@
set i     @node:index@
set Lg    @Lgate@
set Vd    @Vdlin@
set Vg    @VDD@
set Type  @Type@
puts "Gate Length: $Lg um"

set ID "$Type"
set N   ${Type}_${N}

#- Automatic alternating color assignment tied to node index
#----------------------------------------------------------------------#
set COLORS  [list green blue red orange magenta violet brown]
set NCOLORS [llength $COLORS]
set color   [lindex  $COLORS [expr $i%$NCOLORS]]

#- INSPECT IdVg plotting
#----------------------------------------------------------------------#
# Plotting Id vs Vg curves
gr_setTitleAttr "IdVg Lg=$Lg Vd=$Vd"

proj_load  IdVg_@plot@ PLT($N)

cv_createDS IdVg($N) \
 "PLT($N) gate OuterVoltage" "PLT($N) drain TotalCurrent" y
cv_abs IdVg($N) y
cv_setCurveAttr IdVg($N) "IdVg $ID" \
  $color solid 2 none 3 defcolor 1 defcolor

gr_setAxisAttr X  {Gate Voltage (V)}     16  {} {} black 1 14 0 5 0
gr_setAxisAttr Y  {Drain Current (A/um)} 16  {} {} black 1 14 0 5 1

#- Extraction
#----------------------------------------------------------------------#
load_library EXTRACT

#- Extracting Value at given X
#----------------------------------------------------------------------#
proc ExtractValue { PrintName CURVE Vfix Io } {
  set Iolog [expr log10($Io)]
  cv_log10Scale $CURVE LOG y
  set Idmin [cv_compute "vecmin(<LOG>)" A A A A ]
  if { $Idmin < $Iolog } {
    set Vti [cv_compute "vecvalx(<LOG>, $Iolog)" A A A A ]
    ft_scalar $PrintName [format %.5f $Vti]
    puts "Vti (Vg at Io=[format %.5e $Io]): [format %.5f $Vti] V"
  } else {
    ft_scalar $PrintName *x*
    puts "Vti (Vg at Io=[format %.5e $Io]): leakage current higher than Io!"
  }
  puts ""
  cv_delete LOG
  
  set VALUE [cv_compute "vecvaly(<$CURVE>,$Vti+$Vfix)" A A A A ]
  ft_scalar $PrintName [format %.3e $VALUE] 
  puts "$PrintName: [format %.3e $VALUE]"  
  puts ""
  return $VALUE

}



#- Defining current level for Vti extraction
#----------------------------------------------------------------------#
set Io    [expr 100e-9/$Lg] ; # [A/um]
if { $Type == "nMOS" } { set SIGN 1.0 } else { set SIGN -1.0 }

set VtLin   [ExtractVti   VtLin IdVg($N) $Io]
set IdLin [ExtractMax   IdLin  IdVg($N)]

