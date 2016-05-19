#if @IdVg_lin@ == 0
#noexec
#endif
#----------------------------------------------------------------------#
#set Vtgm   x
#set VtiLin x
#set IdLin  x
#set SSlin  x
#set gmLin  x
#----------------------------------------------------------------------#
lib::SetInfoDef 1
#----------------------------------------------------------------------#
set N     @node@
set i     @node:index@
set Lg    @lgate@
set Vd    @Vdlin@
set Vg    @Vdd@
set Type  @CUT@
puts ""
puts "Gate Length: $Lg um \n"

set ID "$Type"
set N   ${Type}_${N}

#- Automatic alternating color assignment tied to node index
#----------------------------------------------------------------------#
set COLORS  [list green blue red orange magenta violet brown]
set NCOLORS [llength $COLORS]
set color   [lindex  $COLORS [expr $i%$NCOLORS]]

#- Plotting IdVg
#----------------------------------------------------------------------#
echo "#########################################"
echo "Plotting Id-Vg (lin) curve"
echo "#########################################"
load_file IdVg_@plot@ -name PLT_Lin($N)

if {[lsearch [list_plots] Plot_IdVg] == -1} {
	create_plot -1d -name Plot_IdVg
}
select_plots Plot_IdVg

set Vgs [get_variable_data "gate OuterVoltage" -dataset PLT_Lin($N)]
set Ids [get_variable_data "drain TotalCurrent" -dataset PLT_Lin($N)]
ext::AbsList -out absIds -x $Ids ;# Compute absolute value of drain currents
create_variable -name absId -dataset PLT_Lin($N) -values $absIds

create_curve -name IdVgLin($N) -dataset PLT_Lin($N) \
	-axisX "gate OuterVoltage" -axisY "absId"
	
set_curve_prop IdVgLin($N) -label "IdVg(Lin) ($ID Lg=$Lg Vd=$Vd)" \
	-color $color -line_style solid -line_width 3
	 
set_plot_prop -title "I<sub>d</sub>-V<sub>gs</sub> Curve" -title_font_size 16 -show_legend
set_axis_prop -axis x -title {Gate Voltage [V]} \
	-title_font_size 16 -scale_font_size 14 -type linear 
set_axis_prop -axis y -title {Drain Current [A/<greek>m</greek>m]} \
	-title_font_size 16 -scale_font_size 14 -type log
set_legend_prop -font_size 12 -location bottom_right -font_att bold

#- Extraction
#----------------------------------------------------------------------#
echo "#########################################"
echo "Extracting parameters from Id-Vg (lin) curve"
echo "#########################################"

#- Defining current level for Vti extraction
#----------------------------------------------------------------------#
set Io    [expr 100e-9/$Lg] ; # [A/um]
if { $Type == "SIM2N" } { set SIGN 1.0 } else { set SIGN -1.0 }

ext::ExtractVtgm     -out Vt     -name "Vtgm"   -v $Vgs -i $absIds 
ext::ExtractVti      -out Vti  	 -name "VtiLin" -v $Vgs -i $absIds  -io $Io 
ext::ExtractExtremum -out Idmax  -name "IdLin"  -x $Vgs -y $absIds -type "max"
ext::ExtractSS       -out SS     -name "SSlin"  -v $Vgs -i $absIds -vo [expr $SIGN*1e-2]
ext::ExtractGm       -out gm     -name "gmLin"  -v $Vgs -i $absIds 

echo "Vt (Max gm method) is [format %.3g $Vt] V"
echo "Vti (Vg at Io= [format %.3e $Io] A/um) is [format %.3f $Vti] V"
echo "Max IdLin is [format %.3e $Idmax] A/um"
echo "SSlin is [format %.3f $SS] mV/dec"
echo "Max gm is [format %.3e $gm] S/um"

