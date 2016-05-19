
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

set CNode 603
init tdr=n601



deposit HfO2 thickness= $THF<um>
mater add name= TiN new.like= Nitride

deposit TiN thickness= 0.005



icwb.create.mask layer.name= "POLY" name= POLY info= 1 polarity= negative
deposit material= {Poly} type= anisotropic  thickness= $GateThick+$Tox+0.005 mask= POLY


etch material= {Poly}  type= cmp coord= -$GateThick-$Tox


etch TiN thickness= 0.05  type= anisotropic
etch HfO2 thickness= 0.02 type= anisotropic 


etch material= {Oxide} type= anisotropic rate= {$Tox} time= 2.0 
strip Photoresist


deposit material= {Oxide} type= isotropic  rate= {1.0} time= $PolyReox


etch material= {Oxide} type= anisotropic rate= $PolyReox*1.5 time= 1


SetPlxList { Boron_Implant Arsenic_Implant }
WritePlx n603_haloimp.plx y= [expr $Ymid-($Lg/2.0-0.01)]

struct tdr=n603

