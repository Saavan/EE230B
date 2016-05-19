
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

set CNode 443
init tdr=n442

strip Oxynitride
strip PolySilicon

transform cut min= {-0.5 -10 -10} max= {0.5 1.0 1.0}

refinebox clear
refinebox !keep.lines
line clear

pdbSet Grid Adaptive 1
pdbSet Grid AdaptiveField Refine.Abs.Error 1e37
pdbSet Grid AdaptiveField Refine.Rel.Error 1e10
pdbSet Grid AdaptiveField Refine.Target.Length 100.0

pdbSet Grid sMesh 1
pdbSet Grid SnMesh DelaunayType boxmethod
pdbSet Grid SnMesh CoplanarityAngle 179
pdbSet Grid SnMesh MaxPoints 500000
pdbSet Grid SnMesh MaxNeighborRatio 1e6

pdbSet Grid SnMesh min.normal.size 0.01
pdbSet Grid SnMesh normal.growth.ratio.2d 8.0
pdbSet Grid SnMesh max.box.angle.2d 179


refinebox interface.materials= $Sub


set fd 2.0
 
refinebox name= DA mask= Active \
  extend= 0.01 extrusion.min= -0.05 extrusion.max= 0.2 \
  refine.fields= { NetActive} def.max.asinhdiff= 0.5 \
  refine.max.edge= "0.01/$fd  $PolyPitch/(8*$fd)" refine.min.edge= \
  "0.002/$fd $PolyPitch/(32*$fd)" adaptive $Sub add

refinebox name= DE mask= EXT \
   extend= 0.005 extrusion.min= -0.0 extrusion.max= 0.025 \
   xrefine= "0.002/$fd"  yrefine= "0.005/$fd" $Sub add info= 1

icwb.create.mask name= Device_Channel layer.name= "POLY" polarity= positive
refinebox name= DC mask= Device_Channel \
  extend= 0.025 extrusion.min= -0.001 extrusion.max= 0.02 \
  refine.fields= { NetActive} def.max.asinhdiff= 1.0 \
  refine.max.edge= "0.0025/$fd   $PolyPitch/(64*$fd)" refine.min.edge= \
  "0.001/$fd  $PolyPitch/(128*$fd)" adaptive $Sub add
  
refinebox name= DeviceIF mask= Device_Channel \
  extend= 0.01 extrusion.min= -0.001 extrusion.max= 0.004 \
  min.normal.size= 0.0002/$fd normal.growth.ratio= 1.1  \
  interface.materials= {Silicon Oxide} $Sub add

refinebox name= PDeviceIF mask= Device_Channel \
  extend= 0.025 extrusion.min= -0.025 extrusion.max= 0.0 \
  min.normal.size= 0.0002/$fd normal.growth.ratio= 1.2  \
  interface.materials= {Silicon Nitride} $Sub add
                   
icwb.create.mask name= SDN layer.name= "Source_N1" polarity= positive 
refinebox name= nsd mask= SDN \
   extend= 0.01 extrusion.min= -0.0 extrusion.max= 0.08 \
   xrefine= "0.005/$fd"  yrefine= "0.005/$fd" $Sub add
     
icwb.create.mask name= SDP layer.name= "Source_P1" polarity= positive
refinebox name= psd mask= SDP \
   extend= 0.01 extrusion.min= -0.025 extrusion.max= 0.08 \
   xrefine= "0.005/$fd"  yrefine= "0.005/$fd" $Sub add
   
grid remesh info= 1

transform reflect right



contact bottom name= Substrate $Sub

contact name = "source" box NickelSilicide adjacent.material = Gas xlo = -0.005 xhi = 0.005 ylo = 0 yhi = 0.015
contact name = "drain" box NickelSilicide adjacent.material = Gas xlo = -0.005 xhi = 0.005 ylo = 0.085 yhi = 0.1
contact name = "gate" box TiNitride adjacent.material = Gas xlo = 0.0 xhi = -0.02 ylo = 0.04 yhi = 0.06 

struct tdr= n443 !gas
exit

