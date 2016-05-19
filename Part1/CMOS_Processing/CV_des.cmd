#if @CV@ == 0
#noexec
#endif

*----------------------------------------------------------------------
Device MOS {
*----------------------------------------------------------------------
File {
   * input files:
   Grid=    "@tdr@"
   Piezo=   "@tdr@" 
   Parameter= "@parameter@"
   * output files:
   Plot=    "@tdrdat@"
   Current= "@plot@"
   
}

Electrode {
   { Name= "source"    Voltage= 0.0 Resistor= 40 }
   { Name= "drain"     Voltage= 0.0 Resistor= 40 }
   { Name= "gate"      Voltage= 0.0 }
   { Name= "Substrate" Voltage= 0.0 }
}


Physics {Fermi}

Physics (Material="Silicon") {
        eQuantumPotential(density) hQuantumPotential(density)
	Mobility (
	  Enormal (
	    IALMob(AutoOrientation)
	    Lombardi_highk     # Used for remote phonon scattering (RPS)
	    
	    NegInterfaceCharge (SurfaceName="s1")  # Used for remote Coulomb scattering (RCS) and remote dipole scattering (RDS)
	    PosInterfaceCharge (SurfaceName="s1")  # Used for RCS and RDS
		  )
	  HighFieldSaturation
	  
	  )
  
  EffectiveIntrinsicDensity(OldSlotboom)
  eMultivalley(MLDA kpDOS -density)
  hMultivalley(MLDA kpDOS -density)
  
  Piezo (
     Model (
	Mobility (
		saturationfactor=0.0
		eSubband(Doping EffectiveMass Scattering(MLDA) -RelChDir110)
		hSubband(Doping EffectiveMass Scattering(MLDA))
		
		)
	DOS(eMass hMass)
	DeformationPotential(Minimum ekp hkp)
	)
      )
      
}

*----------------------------------------------------------------------
} * End of Device
*----------------------------------------------------------------------

File {
   Output= "@log@"
   ACExtract= "@acplot@"
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
  *--Stress related data
   StressXX StressYY StressZZ StressXY StressXZ StressYZ
   
}

Math {
  Extrapolate
  Derivatives
  RelErrControl
  Digits= 5  
  Notdamped= 100
  Iterations= 25
  ExitOnFailure 
  TensorGridAniso
  StressMobilityDependence = TensorFactor
  RelTermMinDensity= 2e8
  DrForceRefDens= 1e12
  * Please uncomment if you have 4 CPUs or more
  *Number_of_Threads= 4
  
  Surface "s1" (
  MaterialInterface="HfO2/Oxide"
  )
  
}

System { 
  MOS mos (drain=d source=s gate=g Substrate=b) 

  Vsource_pset vd ( d 0 ){ dc = 0 } 
  Vsource_pset vs ( s 0 ){ dc = 0 } 
  Vsource_pset vg ( g 0 ){ dc = 0 } 
  Vsource_pset vb ( b 0 ){ dc = 0 }
} 


Solve {
#- Creating initial guess:
   Coupled(Iterations= 1000 LineSearchDamping= 1e-8){ Poisson eQuantumPotential hQuantumPotential } 
   Coupled{ Poisson eQuantumPotential hQuantumPotential Electron Hole } 

   Quasistationary( 
      InitialStep= 1e-2 Increment= 1.5 
      MinStep= 1e-5 MaxStep= 0.1 
      Goal { Parameter= vg.dc Voltage= !(puts [expr -1.5*@Vdd@])! } 
   ){ Coupled { Poisson eQuantumPotential hQuantumPotential Electron Hole } }

#- Vb sweep for Vd=0.0
   NewCurrentFile="" 
   Quasistationary( 
      DoZero 
      InitialStep= 1e-2 Increment= 1.5 
      MinStep= 1e-5 MaxStep= 0.04
      Goal { Parameter= vg.dc Voltage=!(puts [expr 1.5*@Vdd@])! } 
   ){ ACCoupled ( 
       StartFrequency= 1e6 EndFrequency= 1e6 NumberOfPoints= 1 Decade 
       Node(d s g b) Exclude(vd vs vg vb) 
       ACCompute (Time= (Range = (0 1)  Intervals= 30)) 
      ){ Poisson eQuantumPotential hQuantumPotential Electron Hole } 
   }
}

