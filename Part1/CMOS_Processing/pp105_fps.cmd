
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

set CNode 105
init tdr=n104

deposit material= {Oxide} type= isotropic rate= {1.0} time= 0.002
deposit material= {Nitride} type= isotropic rate= {1.0} time= $Lsp
etch material= {Nitride} type= anisotropic rate= 1.6*$Lsp time= 1.0
etch material= {Oxide}   type= anisotropic rate= 0.0015 time= 1.5 





etch material= $Sub type= isotropic rate= 0.001 time= 1.0 


strip Photoresist

deposit material= {Oxide} type= isotropic  rate= {1.0} time= 0.002


implant Arsenic dose= 2.0e15 energy= 3.0 tilt=3.0 info= 1 mult.rot = 2

implant BF2 dose= 65000000000000.0 energy= 10 tilt= 60 rotation= 0 mult.rot=4 



temp_ramp name= spike time= 1<s> temp= 600 ramprate= 350.0
temp_ramp name= spike time= 0.5<s> temp= 950 ramprate= 0.0000
temp_ramp name= spike time= 1<s> temp= 950 ramprate= -350.0000


pdbSet Diffuse minT 500.0
pdbSet Heat WaferThickness 500



pdbSet Heat Fluence 8.65
pdbSet Heat Pulse 0.11
pdbSet Heat Intensity.Model Gaussian


pdbSet Heat UpdateHeatRate 1



diffuse laser temp= $LASER_AMBIENT_TEMP_degC time= $LASER_DURATION_ms<ms> info= 1 write.temp.file= n105_LATemp

 
SetPlxList { BTotal AsTotal }
WritePlx n105_anneal.plx y= [expr $Ymid-($Lg/2.0-0.01)]

struct tdr=n105

