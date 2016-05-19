
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

set CNode 442
init tdr=n441

etch material= {Oxide} type= anisotropic rate= {0.008} time= 1.0
etch material= {Oxide} type= isotropic   rate= {0.002} time= 1.4


pdbSet NickelSilicide Silicon ORS 0
pdbSet Grid MinimumVelocity  1e-12
pdbSet Mechanics SilicidationCorrection { 1 }
pdbSet Grid NativeLayerThickness 1.5e-7
pdbSet NickelSilicide Grid perp.add.dist 2e-7

pdbSet NickelSilicide Silicon Dstar { {[Arr 0.02  1.6]} }

pdbSet NickelSilicide_Silicon Silicon Expansion.Ratio 1.0
pdbSet NickelSilicide_Silicon Silicon Density.Grow 2.5e22
pdbSet Nickel_NickelSilicide  Silicon Expansion.Ratio 1.0
pdbSet Nickel_NickelSilicide  Silicon Density.Grow 3.5e22

pdbSet NickelSilicide_Silicon SilicidationTripleDistance 20e-7
pdbSet Nickel_NickelSilicide SilicidationTripleDistance 20e-7

pdbSet NickelSilicide_Silicon SilicidationTripleFactor 0

reaction name= poly_silicidation_ni delete

etch material= {Silicon} type= isotropic rate= {0.0005} time= 1.0

pdbSetBoolean Silicon Mechanics UpdateStrain 0
deposit Nickel type= isotropic thickness= 0.015



diffuse time= 0.5<s> temp= 500<C> minT= 300<C> stress.relax
strip Nickel
    


struct tdr=n442

