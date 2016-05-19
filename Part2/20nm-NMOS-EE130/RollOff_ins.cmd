#if @RollOff@ == 0
#noexec
#endif
#----------------------------------------------------------------------#
# Plots threshold voltages (VtiLin,VtiSat) and DIBL as well as 
# drain current levels (IdLin, IdSat, Ioff) 
# and the subthershold voltage swing as function of gate length
#----------------------------------------------------------------------#
#setdep @previous@

global CURVES
set CURVES  [list]

set N @node@
set TargetType @Type@ ;# nMOS or pMOS

set ID "$TargetType"
set Types   [list @Type:all@]
set Lgs     [list @lgate:all@]

set Vtgms   [list @Vtgm:all@]
set VtiLins [list @VtiLin:all@]
set VtiSats [list @VtiSat:all@]

set IdLins  [list @IdLin:all@]
set IdSats  [list @IdSat:all@]
set Ioffs   [list @Ioff:all@]

set SSlins  [list @SSlin:all@]
set SSsats  [list @SSsat:all@]

set gmLins  [list @gmLin:all@]
set gmSats  [list @gmSat:all@]

set Vdd     @Vdd@
set Vdlin   @Vdlin@

set XMIN   "0.03"
set XMAX   "1.0"

#----------------------------------------------------------------------#
source FILTER_TABEL_ins.lib
#----------------------------------------------------------------------#
set NAME  "Vtgm($N)"
set LABEL "Vtgm $TargetType"
CallPlot $NAME $LABEL $Lgs $Vtgms $TargetType $Types blue solid

gr_setAxisAttr X {Gate Length (um)} {16} $XMIN $XMAX black 1 14 0 5 1
gr_setAxisAttr Y {Vt (V)}           {16} {}   {}     black 1 14 0 5 0

NEXT
#----------------------------------------------------------------------#
set NAME  "VtiLin($N)"
set LABEL "VtiLin $TargetType"
CallPlot $NAME $LABEL $Lgs $VtiLins $TargetType $Types blue solid

set NAME  "VtiSat($N)"
set LABEL "VtiSat $TargetType"
CallPlot $NAME $LABEL $Lgs $VtiSats $TargetType $Types red solid

cv_createWithFormula DIBL($N) \
  "(<VtiLin($N)>-<VtiSat($N)>)/($Vdd-$Vdlin)" A A A A
cv_display DIBL($N) y2
cv_setCurveAttr DIBL($N) "DIBL $TargetType" \
 black solid 2 none 7 defcolor 1 defcolor
lappend CURVES DIBL($N)

gr_setAxisAttr X  {Gate Length (um)} {16} $XMIN $XMAX black 1 14 0 5 1
gr_setAxisAttr Y  {Vt (V)}           {16} {}   {}     black 1 14 0 5 0
gr_setAxisAttr Y2 {DIBL (V/V)}       {16} {}   {}     black 1 14 0 5 0

NEXT
#----------------------------------------------------------------------#
set NAME  "IdLin($N)"
set LABEL "IdLin $TargetType"
CallPlot $NAME $LABEL $Lgs $IdLins $TargetType $Types blue solid

set NAME  "IdSat($N)"
set LABEL "IdSat $TargetType"
CallPlot $NAME $LABEL $Lgs $IdSats $TargetType $Types red solid

gr_setAxisAttr X {Gate Length (um)}     {16} $XMIN $XMAX black 1 14 0 5 1
gr_setAxisAttr Y {Drain Current (A/um)} {16} {}    {}  black 1 14 0 5 0
gr_mappedAxis  Y2 0
NEXT
#----------------------------------------------------------------------#
set NAME  "Ioff($N)"
set LABEL "Ioff $TargetType"
CallPlot $NAME $LABEL $Lgs $Ioffs $TargetType $Types blue solid

gr_setAxisAttr X {Gate Length (um)}     {16} $XMIN $XMAX black 1 14 0 5 1
gr_setAxisAttr Y {Drain Current (A/um)} {16} {}    {}  black 1 14 0 5 1

NEXT
#----------------------------------------------------------------------#
set NAME  "IoffIon($N)"
set LABEL "Ioff $TargetType"
CallPlot $NAME $LABEL $IdSats $Ioffs $TargetType $Types blue solid

gr_setAxisAttr X {Ion  (A/um)} {16} {}      {} black 1 14 0 5 0
gr_setAxisAttr Y {Ioff (A/um)} {16} {1e-11} {} black 1 14 0 5 1

NEXT
#----------------------------------------------------------------------#
set NAME  "SSlin($N)"
set LABEL "SSlin $TargetType"
CallPlot $NAME $LABEL $Lgs $SSlins $TargetType $Types blue solid

set NAME  "SSsat($N)"
set LABEL "SSsat $TargetType"
CallPlot $NAME $LABEL $Lgs $SSsats $TargetType $Types red solid

gr_setAxisAttr X {Gate Length (um)}      {16} $XMIN $XMAX black 1 14 0 5 1
gr_setAxisAttr Y {Subth. Swing (mV/dec)} {16} {}    {}  black 1 14 0 5 0

NEXT
#----------------------------------------------------------------------#
set NAME  "gmLin($N)"
set LABEL "gmLin $TargetType"
CallPlot $NAME $LABEL $Lgs $gmLins $TargetType $Types blue solid

set NAME  "gmSat($N)"
set LABEL "gmSat $TargetType"
CallPlot $NAME $LABEL $Lgs $gmSats $TargetType $Types red solid

gr_setAxisAttr X {Gate Length (um)}     {16} $XMIN $XMAX black 1 14 0 5 1
gr_setAxisAttr Y {Trans. Cond. (S/dec)} {16} {}    {}  black 1 14 0 5 0
