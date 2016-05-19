
#if @CV@ == 0
#noexec
#endif
#----------------------------------------------------------------------#
#set CgM x
#set Cg0 x
#set CgP x

set N     @node@
set i     @node:index@
set Lg    @lgate@
set Type  @CUT@
set Vdd   @Vdd@

puts ""
puts "Gate Length: $Lg um \n"

set ID "$Type"
set N  ${Type}_${N}

#- Automatic alternating color assignment tied to node index
#----------------------------------------------------------------------#
set COLORS  [list green blue red orange magenta violet brown]
set NCOLORS [llength $COLORS]
set color   [lindex  $COLORS [expr $i%$NCOLORS]]
set sym     none

#----------------------------------------------------------------------#
lib::SetInfoDef 1

echo "##############################"
echo "plotting C-V curves"
echo "##############################"
load_file @acplot@ -name AC($N)

if {[lsearch [list_plots] Plot_CV] == -1} {
	create_plot -1d -name Plot_CV
}
select_plots Plot_CV

create_curve -name Cgg($N) -dataset AC($N) -axisX "v(g)" -axisY "c(g,g)"
create_curve -name CdgTmp($N) -dataset AC($N) -axisX "v(g)" -axisY "c(d,g)"
create_curve -name Cdg($N) -function "abs(<CdgTmp($N)>)"
create_curve -name CsgTmp($N) -dataset AC($N) -axisX "v(g)" -axisY "c(s,g)"
create_curve -name Csg($N) -function "abs(<CsgTmp($N)>)"
create_curve -name Ccg($N) -function "<Csg($N)>+<Cdg($N)>"

create_curve -name CbgTmp($N) -dataset AC($N) -axisX "v(g)" -axisY "c(b,g)"
create_curve -name Cbg($N) -function "abs(<CbgTmp($N)>)"

remove_curves "CsgTmp($N) Csg($N) CdgTmp($N) Cdg($N) CbgTmp($N)"
set_curve_prop Cgg($N) -label "Cgg ($ID Lg=$Lg)" \
	-color $color -line_style solid -line_width 3
set_curve_prop Ccg($N) -label "Ccg ($ID Lg=$Lg)" \
	-color $color -line_style dash -line_width 3
set_curve_prop Cbg($N) -label "Cbg ($ID Lg=$Lg)" \
	-color $color -line_style dot -line_width 3
	
set_plot_prop -title "C-V Curves" -title_font_size 16 -show_legend
set_axis_prop -axis x -title {Gate Voltage [V]} \
	-title_font_size 16 -scale_font_size 14 
set_axis_prop -axis y -title {Capacitance [F/<greek>m</greek>m]} \
	-title_font_size 16 -scale_font_size 14 
set_legend_prop -font_size 12 -location bottom_left -font_att bold

#- Extraction
#----------------------------------------------------------------------#
puts "#########################################"
puts "extracting parameters from C-V curve"
puts "#########################################"
#- Accessing data sets and converting data to Tcl lists for parameter extraction
#----------------------------------------------------------------------#
set Vgs  [get_curve_data Cgg($N) -plot Plot_CV -axisX]
set Cggs [get_curve_data Cgg($N) -plot Plot_CV -axisY]

ext::ExtractValue -out CggM -name "CgM" -x $Vgs -y $Cggs -xo [expr -1.0*$Vdd]
ext::ExtractValue -out Cgg0 -name "Cg0" -x $Vgs -y $Cggs -xo 0.0
ext::ExtractValue -out CggP -name "CgP" -x $Vgs -y $Cggs -xo $Vdd

echo "CgM is [format %.3e $CggM] F/um"
echo "Cg0 is [format %.3e $Cgg0] F/um"
echo "CgP is [format %.3e $CggP] F/um"

