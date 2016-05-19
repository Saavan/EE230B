
!( 
if { "@Type@"  == "nMOS" } {
  set SIGN   1.0  
  set DG     "eQuantumPotential"
  set EQN0   "Poisson eQuantumPotential Electron Hole"
  set EQNS   "Poisson eQuantumPotential Electron Hole "
} else {
  set SIGN   -1.0
  set DG     "hQuantumPotential"
  set EQN0   "Poisson hQuantumPotential Electron Hole"
  set EQNS   "Poisson hQuantumPotential Electron Hole "
}
)!

File {
   * input files:
   Grid=   "@tdr@"
   Parameter="@parameter@"
   * output files:
   Plot=   "@tdrdat@"
   Current="@plot@"
   Output= "@log@"
}

Electrode {
   { Name="source"    Voltage= 0.0 DistResist=1e-9 }
   { Name="drain"     Voltage= 0.0 DistResist=1e-9 }
   { Name="gate"      Voltage= 0.0 Workfunction=@WorkFunction@ }
   { Name="substrate" Voltage= 0.0 }
}

Physics{
   Fermi
   Hydrodynamic
   EffectiveIntrinsicDensity( OldSlotboom )     
}

Physics (Material="Silicon"){
   Fermi
   Hydrodynamic  
   Mobility (
      DopingDependence
      Enormal ()
     HighFieldSaturation  
   )
  
   Recombination (
	Band2Band
	SRH(DopingDependence)
	eAvalanche(CarrierTempDrive)
	hAvalanche(Eparallel)
   ) 
  
}

Plot{
*--Density and Currents, etc
   eDensity hDensity
   TotalCurrent/Vector eCurrent/Vector hCurrent/Vector
   eMobility hMobility
   eVelocity hVelocity
   eQuasiFermi hQuasiFermi

*--Temperature
*   Temperature

*--Fields and charges
   ElectricField/Vector Potential SpaceCharge

*--Doping Profiles
   Doping DonorConcentration AcceptorConcentration

*--Generation/Recombination
   SRH Band2Band * Auger
   * AvalancheGeneration eAvalancheGeneration hAvalancheGeneration

*--Driving forces
   eGradQuasiFermi/Vector hGradQuasiFermi/Vector
   eEparallel hEparallel eENormal hENormal

*--Band structure/Composition
   BandGap
   BandGapNarrowing
   Affinity
   ConductionBand ValenceBand
   eQuantumPotential hQuantumPotential

*--Gate Tunneling 
   * eBarrierTunneling hBarrierTunneling  BarrierTunneling
   * eDirectTunnel hDirectTunnel
}



Math {
   Extrapolate
   Derivative
   Notdamped=50
   Iterations=20
   RelErrControl
   ExitOnFailure
   Method=ILS
   NumberofThreads=1
}

Solve {
*- Creating initial guess:
   Coupled(Iterations= 100 LineSearchDamping= 1e-4){ Poisson !(puts $DG)! } 
   Coupled { !(puts $EQN0)! }
   Save ( FilePrefix = "n@node@_init" )

*- Ramp to gate to Vgs1
   Quasistationary( 
      InitialStep= 1e-3 Increment= 1.5 
      MinStep= 1e-7 MaxStep= 0.1 
      Goal { Name="gate" Voltage=!(puts [expr $SIGN*@Vgs1@])! } 
   ){ Coupled { !(puts $EQNS)! } } 

*- Vds sweep 
   NewCurrentFile="IdVd1_" 
   Quasistationary( 
      DoZero 
      InitialStep= 1e-3 Increment= 1.2 
      MinStep= 1e-7 MaxStep= 0.04
      Goal { Name="drain" Voltage=!(puts [expr $SIGN*@VDD@])! } 
   ){ Coupled { !(puts $EQNS)! } 
      CurrentPlot( Time=(Range=(0 1) Intervals= 30)  )
   }
   
*- Ramp to gate to Vgs2
   Load ( FilePrefix = "n@node@_init" )
   Quasistationary( 
      InitialStep= 1e-3 Increment= 1.5 
      MinStep= 1e-7 MaxStep= 0.1 
      Goal { Name="gate" Voltage=!(puts [expr $SIGN*@Vgs2@])! } 
   ){ Coupled { !(puts $EQNS)! } } 

*- Vds sweep 
   NewCurrentFile="IdVd2_" 
   Quasistationary( 
      DoZero 
      InitialStep= 1e-3 Increment= 1.2 
      MinStep= 1e-7 MaxStep= 0.05
      Goal { Name="drain" Voltage=!(puts [expr $SIGN*@VDD@])! } 
   ){ Coupled { !(puts $EQNS)! } 
      CurrentPlot( Time=(Range=(0 1) Intervals= 30)  )
   }

*- Ramp to gate to Vgs3
   Load ( FilePrefix = "n@node@_init" )
   Quasistationary( 
      InitialStep= 1e-3 Increment= 1.5 
      MinStep= 1e-7 MaxStep= 0.1 
      Goal { Name="gate" Voltage=!(puts [expr $SIGN*@Vgs3@])! } 
   ){ Coupled { !(puts $EQNS)! } } 

*- Vds sweep 
   NewCurrentFile="IdVd3_" 
   Quasistationary( 
      DoZero 
      InitialStep= 1e-3 Increment= 1.2 
      MinStep= 1e-7 MaxStep= 0.05
      Goal { Name="drain" Voltage=!(puts [expr $SIGN*@VDD@])! } 
   ){ Coupled { !(puts $EQNS)! } 
      CurrentPlot( Time=(Range=(0 1) Intervals= 30)  )
   }

*- Ramp to gate to Vgs4
   Load ( FilePrefix = "n@node@_init" )
   Quasistationary( 
      InitialStep= 1e-3 Increment= 1.5 
      MinStep= 1e-7 MaxStep= 0.1 
      Goal { Name="gate" Voltage=!(puts [expr $SIGN*@Vgs4@])! } 
   ){ Coupled { !(puts $EQNS)! } } 

*- Vds sweep 
   NewCurrentFile="IdVd4_" 
   Quasistationary( 
      DoZero 
      InitialStep= 1e-3 Increment= 1.2 
      MinStep= 1e-7 MaxStep= 0.05
      Goal { Name="drain" Voltage=!(puts [expr $SIGN*@VDD@])! } 
   ){ Coupled { !(puts $EQNS)! } 
      CurrentPlot( Time=(Range=(0 1) Intervals= 30)  )
   }
}


