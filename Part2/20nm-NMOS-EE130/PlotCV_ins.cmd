#if @CV@ == 0
#noexec
#endif
#set CgM x
#set Cg0 x
#set CgP x

set N     @node@
set i     @node:index@
set Lg    @lgate@
set Type  @Type@
set Vdd   @Vdd@
puts "Gate Length: $Lg"

set ID "$Type"
set N  ${Type}_${N}

#- Automatic alternating color assignment tied to node index
#----------------------------------------------------------------------#
set COLORS  [list green blue red orange magenta violet brown]
set NCOLORS [llength $COLORS]
set color   [lindex  $COLORS [expr $i%$NCOLORS]]
set sym     none

#- INSPECT
#----------------------------------------------------------------------#
# Plotting gate capacitance curves
gr_setTitleAttr "CV Lg=$Lg"

proj_load  @acplot@ AC(${N})

cv_createDS Cgg($N) "AC($N) NO_NODE v(g)" "AC($N) NO_NODE c(g,g)" y
cv_setCurveAttr Cgg($N) "Cgg $ID" \
 $color solid 2 $sym 7 defcolor 1 defcolor

cv_createDS Cdg($N) "AC($N) NO_NODE v(g)" "AC($N) NO_NODE c(d,g)" y
cv_abs Cdg($N) y
cv_createDS Csg($N) "AC($N) NO_NODE v(g)" "AC($N) NO_NODE c(s,g)" y
cv_abs Csg($N) y

cv_createWithFormula Ccg($N) "<Csg($N)>+<Cdg($N)>" A A A A
cv_display Ccg($N) y
cv_setCurveAttr Ccg($N) "Ccg $ID" \
  $color dashed 3 $sym 7 defcolor 1 defcolor

cv_delete Csg($N)
cv_delete Cdg($N)

cv_createDS Cbg($N) "AC($N) NO_NODE v(g)" "AC($N) NO_NODE c(b,g)" y
cv_abs Cbg($N) y
cv_setCurveAttr Cbg($N) "Cbg $ID" \
 $color dotted 3 $sym 7 defcolor 1 defcolor

gr_setAxisAttr X {Gate Voltage (V)}    16 {} {} black 1 14 0 5 0
gr_setAxisAttr Y {Capacitance  (F/um)} 16 {} {} black 1 14 0 5 0

#- Extraction
#----------------------------------------------------------------------#
#--> source EXTRACT.tcl
load_library EXTRACT

set CggM [ExtractValue "CgM" Cgg($N) [expr -1.0*$Vdd]]
set Cgg0 [ExtractValue "Cg0" Cgg($N) 0.0]
set CggP [ExtractValue "CgP" Cgg($N) $Vdd]


