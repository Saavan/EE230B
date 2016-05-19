#if @IdVd@ == 0
#noexec
#endif

!( 
  set SIGN   1.0
  set Vddp    @<Vdd>@  
  set DG      "eQuantumPotential"
  set cTemp   ""
  set WF     4.2
  set EQN0   "Poisson Electron "
  set EQNS   "Poisson Electron "
)!

File {
   * input files:
   Grid=    "@tdr@"
   Piezo=   "@tdr@"
   Parameter= "@parameter@"
   * output files:
   Plot=   "@tdrdat@"
   Current="@plot@"
   Output= "@log@"
}

Electrode {
   { Name= "source"    Voltage= 0.0 Resistor= 40 }
   { Name= "drain"     Voltage= 0.0 Resistor= 40 }
   { Name= "gate"      Voltage= 0.0 Workfunction= !(puts $WF)! }
   { Name= "Substrate" Voltage= 0.0 }
}


Physics {
   Fermi
   Hydrodynamic 
   eQuantumPotential(density) hQuantumPotential(density)
   Mobility (
      DopingDependence
      Enormal (
       IALMob(AutoOrientation)
       Lombardi_highk     # Used for remote phonon scattering (RPS)
      )
     HighFieldSaturation  
   )
  
   EffectiveIntrinsicDensity(OldSlotboom)
   eMultivalley(MLDA kpDOS -density)
   hMultivalley(MLDA kpDOS -density)
   Recombination (
	Band2Band
	SRH(DopingDependence)
	eAvalanche(CarrierTempDrive)
	hAvalanche(Eparallel)
   ) 
  
}



Plot{
  eDensity hDensity
  TotalCurrent/Vector eCurrent/Vector hCurrent/Vector
  eMobility hMobility
  eVelocity hVelocity
  eQuasiFermi hQuasiFermi
  eTemperature hTemperature Temperature 
  ElectricField/Vector Potential SpaceCharge
  Doping DonorConcentration AcceptorConcentration
  SRH Band2Band 
  AvalancheGeneration eAvalancheGeneration hAvalancheGeneration
  eGradQuasiFermi/Vector hGradQuasiFermi/Vector
  eEparallel hEparallel eENormal hENormal
  BandGap 
  BandGapNarrowing
  Affinity
  ConductionBand ValenceBand
  eBarrierTunneling hBarrierTunneling * BarrierTunneling
  eTrappedCharge  hTrappedCharge
  eGapStatesRecombination hGapStatesRecombination
  eDirectTunnel hDirectTunnel
}

Math {
  Extrapolate
  Derivatives
  RelErrControl
  Digits= 5  
  Notdamped= 100
  Iterations= 25
  ExitOnFailure
  
  * Please uncomment if you have 4 CPUs or more
  Number_of_Threads= 4
 
  Surface "s1" (
  MaterialInterface="HfO2/Oxide"
  )
  
}

Solve {
*- Creating initial guess:
   Coupled(Iterations= 1000 LineSearchDamping= 1e-8){ Poisson !(puts $DG)! } 
   Coupled { !(puts $EQN0)! }
   Coupled { !(puts $EQNS)! }

#-- Ramp gate to Vdd/2
  Quasistationary( 
    InitialStep= 1e-2 Increment= 1.45
    MinStep= 1e-6 MaxStep= 0.05 
    Goal { Name= "gate" Voltage= @Vg1@ } 
  ){ Coupled { !(puts $EQN0)!} }
  Save ( FilePrefix= "n@node@_Vg1" )

  #-- Ramp gate to Vdd 
  Quasistationary( 
    InitialStep= 1e-2 Increment= 1.45
    MinStep= 1e-6 MaxStep= 0.05 
    Goal { Name= "gate" Voltage= @Vg2@ } 
  ){ Coupled { !(puts $EQN0)! } }
  Save ( FilePrefix= "n@node@_Vg2" )

  #-- Vd sweep for Vg=Vdd/2
  NewCurrentFile= "IdVd_Vg1" 
  Load ( FilePrefix= "n@node@_Vg1" )
  Quasistationary( 
    DoZero 
    InitialStep= 1e-2 Increment= 1.45
    MinStep= 1e-8 MaxStep= 0.05 
    Goal { Name= "drain" Voltage= !(puts $Vddp)! } 
  ){ Coupled { !(puts $EQNS)! } }

  #-- Vd sweep for Vg=Vdd
  NewCurrentFile= "IdVd_Vg2" 
  Load ( FilePrefix= "n@node@_Vg2" )
  Quasistationary( 
    DoZero 
    InitialStep= 1e-2 Increment= 1.45
    MinStep= 1e-8 MaxStep= 0.05
    Goal { Name= "drain" Voltage= !(puts $Vddp)! } 
  ){ Coupled { !(puts $EQNS)! } }
  
}


