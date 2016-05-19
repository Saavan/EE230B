
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

set CNode 276
init tdr=n275

icwb.create.mask name= EXT layer.name= "Mesh_EXT" polarity= positive
refinebox name= ExtImp mask= EXT \
  extend= 0.005 extrusion.min= -0.001 extrusion.max= 0.05 \
  xrefine= " 0.001/$f 0.006/$f"  yrefine= " 0.006/$f " all add

refinebox name= ExtXY mask= EXT \
  extend= 0.007 extrusion.min= -0.001 extrusion.max= 0.01 \
  xrefine= " 0.001/$f "  yrefine= " 0.001/$f " all add
  
refinebox name= ExtIF mask= Active \
  extend= 0.0 extrusion.min= -$Tox extrusion.max= 0.01 \
  min.normal.size= 0.0004/$f normal.growth.ratio= 2.0 \
  interface.materials= {Silicon Oxide} all add

 

  
grid remesh

implant Arsenic dose= 5e13 energy= 0.2 tilt= 3

SetPlxList { Boron_Implant Arsenic_Implant }
WritePlx n276_extimp.plx y= [expr $Ymid-($Lg/2.0-0.01)]


struct tdr=n276

