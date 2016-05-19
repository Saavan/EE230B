#header

#rem #---------------------------------------------------------------------#
#rem #   LAYOUT
#rem #---------------------------------------------------------------------#

set Domain @CUT@


icwb filename= "SRAM_lyt.mac" scale=1e-3
#rem # Loading of the "TCAD Layout" file. # scaling all coordinates from nm to um.

set Domains [icwb list domains]
#rem # Query utility: Listing all simulation domain names found in the "TCAD Layout" file.
LogFile "icwb: LDomains -> $Domains"

set LNames  [icwb list layerNames]
#rem # Query utility: Listing all layer names found in the "TCAD Layout" file.
LogFile "icwb: LNames -> $LNames"

set LIDs     [icwb list layerIDs]
#rem # Query utility: Listing all layer IDs found in the "TCAD Layout" file.
LogFile "icwb: LIDs -> $LIDs"

icwb domain= $Domain

icwb stretch name= "${Domain}_L" value=@<(lgate-0.030)>@


set DIM [icwb dimension]
#rem # Query utility: Returns the dimension of the selected simulation domain.
LogFile "icwb: dimension -> $DIM"

#rem # Query utility: Returns the boundaries of the 2D simulation domain
set Ymin [icwb bbox left]
set Ymax [icwb bbox right]
LogFile "icwb: Domain boundaries -> $Ymin $Ymax"

set Ymid [expr ($Ymax-$Ymin)/2.0]

set CNode @node@
#endheader

# unified Coordinate system
math coord.ucs

AdvancedCalibration

pdbSet ImplantData Extrude 1
pdbSet InfoDefault 1
pdbSet Oxide_Silicon Boundary BoundaryCondition ThreePhaseSegregation

pdbSet ImplantData ResistSkip 1

# Initial Boundary
fset Xbot 10
fset Xtop 0


#rem #---------------------------------------------------------------------#
#rem #   PARAMETERS
#rem #---------------------------------------------------------------------#
fset PolyPitch 0.1125
fset GateThick 0.035
fset PolyReox 0.0025
fset Tox 0.0006
fset THF 0.00256
fset Lsp @Lspacer@
fset NMOS_recess 0.003
fset Sub Silicon

fset debug 0
fset Lg    @lgate@

# Meshing parameter
fset f     1.0


#-------------------------------------#
#rem# LASER Parameter (Fast Ramp)
#-------------------------------------#
fset LASER_AMBIENT_TEMP_degC @LaserTemp@
fset LASER_DURATION_ms @LaserDuration@


#--------------------------------------#
## Initial Boundary
#--------------------------------------#

line x location= $Xtop tag= top
line x location= $Xbot tag= bottom
line y location= $Ymin tag= left
line y location= $Ymid tag= right

region $Sub substrate xlo= top xhi= bottom ylo= left yhi= right 
init concentration= 5e15 field= Boron wafer.orient= 100 !DelayFullD

## Meshing settings
# -------------------------------------------------------------------- #
pdbSet Grid SnMesh min.normal.size 0.001/$f
pdbSet Grid SnMesh normal.growth.ratio.2d 1.7

# -------------------------------------------------------------------- #

icwb.create.mask name= Active layer.name= "Active" polarity= positive
refinebox name= WellVt mask= Active \
    extend= 0.004 extrusion.min= 0.0 extrusion.max= 0.4 \
    xrefine= "0.05/$f"  yrefine= "$PolyPitch/(8.0*$f)" all add

 
# --- well and channel implantation and annealing ---
deposit material= {Oxide} type= isotropic  rate= {1.0} time= 0.005


# Background dopant implantation


#implant Boron dose= 2e+13 energy= 300.0 tilt= 0.0  
#implant Boron dose= 2e+13 energy= 200.0 tilt= 0.0  
#implant Boron dose= 1e+13 energy=  70.0 tilt= 0.0  
#implant Boron dose= 1e+13 energy=  25.0 tilt= 0.0 
strip Photoresist

# -------------------------------------------------------------------- #
SetPlxList { Boron_Implant Arsenic_Implant Phosphorus_Implant }
WritePlx n@node@_well_imp.plx y= $Ymid
# -------------------------------------------------------------------- #
temp_ramp name= well time= 1.8<s>  temp= 600.0  ramprate= 250.0000
temp_ramp name= well time= 20.0<s> temp= 1050.0 ramprate= 0.0000
temp_ramp name= well time= 5.0<s>  temp= 1050.0 ramprate= -90.0000

####diffuse temp_ramp=well 

strip Oxide 


# Delta Implant

##implant Arsenic dose= @DeltaDose@ energy= @DeltaEnergy@ tilt = 0 mult.rot=2

# ------------------------------------
#split @Poly@
# ------------------------------------

## ---------- Dummy gate oxidation --------------------------------------
##deposit material= {Oxide} type= isotropic  rate= {1.0} time= $Tox


##---------------High-k MetalGate -----------
deposit HfO2 thickness= $THF<um>
mater add name= TiN new.like= Nitride

deposit TiN thickness= 0.005



# ---- poly silicon deposition and etching ----
icwb.create.mask layer.name= "POLY" name= POLY info= 1 polarity= negative
deposit material= {Poly} type= anisotropic  thickness= $GateThick+$Tox+0.005 mask= POLY


etch material= {Poly}  type= cmp coord= -$GateThick-$Tox


etch TiN thickness= 0.05  type= anisotropic
etch HfO2 thickness= 0.02 type= anisotropic 


etch material= {Oxide} type= anisotropic rate= {$Tox} time= 2.0 
strip Photoresist


## ---------- reoxidation -----------------------------------------
deposit material= {Oxide} type= isotropic  rate= {1.0} time= $PolyReox


## ---------- PolyReox spacer etching --------------------------------
etch material= {Oxide} type= anisotropic rate= $PolyReox*1.5 time= 1


# -------------------------------------------------------------------- #
SetPlxList { Boron_Implant Arsenic_Implant }
WritePlx n@node@_haloimp.plx y= [expr $Ymid-($Lg/2.0-0.01)]
# -------------------------------------------------------------------- #

#split @Ext@
# -------------------------------------------------------------------- #

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

# --- source/drain extension implantation ---
implant Arsenic dose= @DrainDose@ energy= @DrainEnergy@ tilt= @DrainTilt@

# -------------------------------------------------------------------- #
SetPlxList { Boron_Implant Arsenic_Implant }
WritePlx n@node@_extimp.plx y= [expr $Ymid-($Lg/2.0-0.01)]
# -------------------------------------------------------------------- #


#split @SD@
# ------------------------------------

## ---------- side wall spacer -----------------------------------
deposit material= {Oxide} type= isotropic rate= {1.0} time= 0.002
deposit material= {Nitride} type= isotropic rate= {1.0} time= $Lsp
etch material= {Nitride} type= anisotropic rate= 1.6*$Lsp time= 1.0
etch material= {Oxide}   type= anisotropic rate= 0.0015 time= 1.5 



## ---------- NMOS recess -----------------------

etch material= $Sub type= isotropic rate= 0.001 time= 1.0 


strip Photoresist

# --- natural through-oxide from cleaning step ---
deposit material= {Oxide} type= isotropic  rate= {1.0} time= 0.002

# --- source/drain(HDD)-implantation ---

implant Arsenic dose= 2.0e15 energy= 3.0 tilt=8.0 info= 1 mult.rot = 2

# --- halo implantation ---
# -------------------------------------------------------------------- #
implant BF2 dose= @HaloDose@ energy= @HaloEnergy@ tilt= @HaloTilt@ rotation= 0 mult.rot=4 

# -------------------------------------------------------------------- #


## -------Spike+laser annealing-----------------
##
temp_ramp name= spike time= 1<s> temp= 600 ramprate= 350.0
temp_ramp name= spike time= 0.5<s> temp= 950 ramprate= 0.0000
temp_ramp name= spike time= 1<s> temp= 950 ramprate= -350.0000

## No more spike anneal!
## #if "@SpikeAnneal@" == "y"
##diffuse temp_ramp=spike
## #endif

pdbSet Diffuse minT 500.0
pdbSet Heat WaferThickness 500



# ---- light source ----
pdbSet Heat Fluence 8.65
pdbSet Heat Pulse 0.11
pdbSet Heat Intensity.Model Gaussian


# ---- update heat generation rate ----
pdbSet Heat UpdateHeatRate 1



diffuse laser temp= $LASER_AMBIENT_TEMP_degC time= $LASER_DURATION_ms<ms> info= 1 write.temp.file= n@node@_LATemp

 
# -------------------------------------------------------------------- #
SetPlxList { BTotal AsTotal }
WritePlx n@node@_anneal.plx y= [expr $Ymid-($Lg/2.0-0.01)]
# -------------------------------------------------------------------- #

#split @Backend@
# ------------------------------------

## ---------- Contact Silicidation -----------------------
etch material= {Oxide} type= anisotropic rate= {0.008} time= 1.0
etch material= {Oxide} type= isotropic   rate= {0.002} time= 1.4

##database for NiSi formation

pdbSet NickelSilicide Silicon ORS 0
pdbSet Grid MinimumVelocity  1e-12
pdbSet Mechanics SilicidationCorrection { 1 }
pdbSet Grid NativeLayerThickness 1.5e-7
pdbSet NickelSilicide Grid perp.add.dist 2e-7

###To controll NiSi growth and Reaction kinetics with Silicon and polySilicon Only...
pdbSet NickelSilicide Silicon Dstar { {[Arr 0.02  1.6]} }

pdbSet NickelSilicide_Silicon Silicon Expansion.Ratio 1.0
pdbSet NickelSilicide_Silicon Silicon Density.Grow 2.5e22
pdbSet Nickel_NickelSilicide  Silicon Expansion.Ratio 1.0
pdbSet Nickel_NickelSilicide  Silicon Density.Grow 3.5e22

pdbSet NickelSilicide_Silicon SilicidationTripleDistance 20e-7
pdbSet Nickel_NickelSilicide SilicidationTripleDistance 20e-7

pdbSet NickelSilicide_Silicon SilicidationTripleFactor 0

# To Stop Poly-silicidation
reaction name= poly_silicidation_ni delete

etch material= {Silicon} type= isotropic rate= {0.0005} time= 1.0

pdbSetBoolean Silicon Mechanics UpdateStrain 0
deposit Nickel type= isotropic thickness= 0.015



diffuse time= 0.5<s> temp= 500<C> minT= 300<C> stress.relax
strip Nickel
    


#split @Mesh@
# -------------------------------------------------------------------- #
# Re-Meshing for Device Simulation
# -------------------------------------------------------------------- #

strip Oxynitride
# -- Remove Poly 
strip PolySilicon

# Truncate bottom
transform cut min= {-0.5 -10 -10} max= {0.5 1.0 1.0}

##---------------Remeshing for device simulation--------##
# clear the process simulation mesh
refinebox clear
refinebox !keep.lines
line clear

# Doping based refinement
pdbSet Grid Adaptive 1
# reset default settings for adaptive meshing
pdbSet Grid AdaptiveField Refine.Abs.Error 1e37
pdbSet Grid AdaptiveField Refine.Rel.Error 1e10
pdbSet Grid AdaptiveField Refine.Target.Length 100.0

# Set high quality delaunay meshes
pdbSet Grid sMesh 1
pdbSet Grid SnMesh DelaunayType boxmethod
pdbSet Grid SnMesh CoplanarityAngle 179
pdbSet Grid SnMesh MaxPoints 500000
pdbSet Grid SnMesh MaxNeighborRatio 1e6

# Set the interface spacing
pdbSet Grid SnMesh min.normal.size 0.01
pdbSet Grid SnMesh normal.growth.ratio.2d 8.0
pdbSet Grid SnMesh max.box.angle.2d 179


refinebox interface.materials= $Sub


# Mesh Multiplication factor for device
set fd @MeshMultiply@
# Refinement strategy
 
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

# Contacts

##icwb.contact.mask layer.name= "Drain_N1"  name= drain  point NickelSilicide x= $NMOS_recess+0.0025 adjacent.material= $Sub
##icwb.contact.mask layer.name= "Source_N1" name= source point NickelSilicide x= $NMOS_recess+0.0025 adjacent.material= $Sub
##icwb.contact.mask layer.name= "Gate_N1"   name= gate   point TiNitride x= -$THF-$Tox-0.004 replace

contact bottom name= Substrate $Sub

contact name = "source" box NickelSilicide adjacent.material = Gas xlo = -0.005 xhi = 0.005 ylo = 0 yhi = 0.015
contact name = "drain" box NickelSilicide adjacent.material = Gas xlo = -0.005 xhi = 0.005 ylo = 0.085 yhi = 0.1
contact name = "gate" box TiNitride adjacent.material = Gas xlo = 0.0 xhi = -0.02 ylo = 0.04 yhi = 0.06 

struct tdr= n@node@ !gas
exit
