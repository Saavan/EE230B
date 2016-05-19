
#---------------------------------------------------------------------#
#   LAYOUT
#---------------------------------------------------------------------#

set Domain SIM2N


icwb filename= "SRAM_lyt.mac" scale=1e-3
# Loading of the "TCAD Layout" file. # scaling all coordinates from nm to um.

set Domains [icwb list domains]
# Query utility: Listing all simulation domain names found in the "TCAD Layout" file.
LogFile "icwb: LDomains -> $Domains"

set LNames  [icwb list layerNames]
# Query utility: Listing all layer names found in the "TCAD Layout" file.
LogFile "icwb: LNames -> $LNames"

set LIDs     [icwb list layerIDs]
# Query utility: Listing all layer IDs found in the "TCAD Layout" file.
LogFile "icwb: LIDs -> $LIDs"

icwb domain= $Domain

icwb stretch name= "${Domain}_L" value=-0.01


set DIM [icwb dimension]
# Query utility: Returns the dimension of the selected simulation domain.
LogFile "icwb: dimension -> $DIM"

# Query utility: Returns the boundaries of the 2D simulation domain
set Ymin [icwb bbox left]
set Ymax [icwb bbox right]
LogFile "icwb: Domain boundaries -> $Ymin $Ymax"

set Ymid [expr ($Ymax-$Ymin)/2.0]

set CNode 101

math coord.ucs

AdvancedCalibration

pdbSet ImplantData Extrude 1
pdbSet InfoDefault 1
pdbSet Oxide_Silicon Boundary BoundaryCondition ThreePhaseSegregation

pdbSet ImplantData ResistSkip 1

fset Xbot 10
fset Xtop 0


#---------------------------------------------------------------------#
#   PARAMETERS
#---------------------------------------------------------------------#
fset PolyPitch 0.1125
fset GateThick 0.035
fset PolyReox 0.0025
fset Tox 0.0006
fset THF 0.00256
fset Lsp 0.016
fset NMOS_recess 0.003
fset Sub Silicon

fset debug 0
fset Lg    0.02

fset f     1.0


# LASER Parameter (Fast Ramp)
fset LASER_AMBIENT_TEMP_degC 300
fset LASER_DURATION_ms 0.4



line x location= $Xtop tag= top
line x location= $Xbot tag= bottom
line y location= $Ymin tag= left
line y location= $Ymid tag= right

region $Sub substrate xlo= top xhi= bottom ylo= left yhi= right 
init concentration= 5e15 field= Boron wafer.orient= 100 !DelayFullD

pdbSet Grid SnMesh min.normal.size 0.001/$f
pdbSet Grid SnMesh normal.growth.ratio.2d 1.7


icwb.create.mask name= Active layer.name= "Active" polarity= positive
refinebox name= WellVt mask= Active \
    extend= 0.004 extrusion.min= 0.0 extrusion.max= 0.4 \
    xrefine= "0.05/$f"  yrefine= "$PolyPitch/(8.0*$f)" all add

 
deposit material= {Oxide} type= isotropic  rate= {1.0} time= 0.005




strip Photoresist

SetPlxList { Boron_Implant Arsenic_Implant Phosphorus_Implant }
WritePlx n101_well_imp.plx y= $Ymid
temp_ramp name= well time= 1.8<s>  temp= 600.0  ramprate= 250.0000
temp_ramp name= well time= 20.0<s> temp= 1050.0 ramprate= 0.0000
temp_ramp name= well time= 5.0<s>  temp= 1050.0 ramprate= -90.0000

diffuse temp_ramp=well 

strip Oxide 




struct tdr=n101

