


File {
   * input files:
   Grid=   "n607_fps.tdr"
   Piezo=   "n607_fps.tdr"
   Parameters= "pp611_des.par"
   * output files:
   Plot=    "n611_des.tdr"
   Current= "n611_des.plt"
   Output=  "n611_des.log"
}

Electrode {
   { Name= "source"    Voltage= 0.0 Resistor= 40 }
   { Name= "drain"     Voltage= 0.0 Resistor= 40 }
   { Name= "gate"      Voltage= 0.0 Workfunction= 4.2
}
   { Name= "Substrate" Voltage= 0.0 }
}

Physics {
   Fermi
   Hydrodynamic  
   Mobility (
      DopingDependence
      Enormal (
       IALMob(AutoOrientation)
       Lombardi_highk     # Used for remote phonon scattering (RPS)
      )
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
  Digits= 3
  Notdamped= 100
  Iterations= 25
  ExitOnFailure
  TensorGridAniso
  * Please uncomment if you have 4 CPUs or more
  Number_of_Threads= 4  
  
  Surface "s1" (
  MaterialInterface= "HfO2/Oxide" 
  )  
  
}

Solve {
*- Creating initial guess:
   Coupled(Iterations= 1000 LineSearchDamping= 1e-8){ Poisson eQuantumPotential
 } 
   Coupled { Poisson Electron 
 }
   Coupled { Poisson Electron 
 }

*- Ramp to drain to Vd
   Quasistationary( 
      InitialStep= 1e-2 Increment= 1.25 
      MinStep= 1e-6 MaxStep= 0.2 
      Goal { Name="drain" Voltage=0.05
 } 
   ){ Coupled { Poisson Electron 
 } } 

*- Vg sweep 
   NewCurrentFile="IdVg_" 
   Quasistationary( 
      DoZero 
      InitialStep= 1e-3 Increment= 1.25 
      MinStep= 1e-6 MaxStep= 0.04
      Goal { Name="gate" Voltage=0.85
 } 
   ){ Coupled { Poisson Electron 
 } 
      CurrentPlot( Time=(Range=(0 1) Intervals= 30)  )
   }
}



