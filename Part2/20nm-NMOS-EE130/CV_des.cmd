#if @CV@ == 0
#noexec
#endif

*----------------------------------------------------------------------
Device MOS {
*----------------------------------------------------------------------
File {
   * input files:
   Grid=   "@tdr@"
   Parameter="@parameter@"
   * output files:
   Plot=   "@tdrdat@"
   Current="@plot@"
}

Electrode {
   { Name="source"    Voltage= 0.0 Resistor= 40 }
   { Name="drain"     Voltage= 0.0 Resistor= 40 }
   { Name="gate"      Voltage= 0.0 }
   { Name="substrate" Voltage= 0.0 }
}

Physics{  
   EffectiveIntrinsicDensity( OldSlotboom )     
}

Physics(Material="Silicon"){
   eQuantumPotential hQuantumPotential
   Mobility(
      PhuMob
      HighFieldSaturation
      Enormal
   )
   Recombination(
      SRH( DopingDependence )
      Band2Band
   )           
}

*----------------------------------------------------------------------
} * End of Device
*----------------------------------------------------------------------

File {
   Output= "@log@"
   ACExtract= "@acplot@"
}

Insert= "PlotSection_des.cmd"
Insert= "MathSection_des.cmd"

System { 
  MOS mos (drain=d source=s gate=g substrate=b) 

  Vsource_pset vd ( d 0 ){ dc= 0 } 
  Vsource_pset vs ( s 0 ){ dc= 0 } 
  Vsource_pset vg ( g 0 ){ dc= 0 } 
  Vsource_pset vb ( b 0 ){ dc= 0 }
} 


Solve {
#- Creating initial guess:
   Coupled(Iterations= 100 LineSearchDamping= 1e-4){ 
      Poisson eQuantumPotential hQuantumPotential } 
   Coupled{ Poisson eQuantumPotential hQuantumPotential Electron Hole } 

   Quasistationary( 
      InitialStep= 1e-2 Increment= 1.35 
      MinStep= 1e-5 MaxStep= 0.1 
      Goal { Parameter= vg.dc Voltage=!(puts [expr -1.5*@Vdd@])! } 
   ){ Coupled { Poisson eQuantumPotential hQuantumPotential Electron Hole } }

#- Vb sweep for Vd=0.0
   NewCurrentFile="" 
   Quasistationary( 
      DoZero 
      InitialStep= 1e-2 Increment= 1.35 
      MinStep= 1e-5 MaxStep= 0.04
      Goal { Parameter= vg.dc Voltage=!(puts [expr 1.5*@Vdd@])! } 
   ){ ACCoupled ( 
       StartFrequency= 1e6 EndFrequency= 1e6 NumberOfPoints= 1 Decade 
       Node(d s g b) Exclude(vd vs vg vb) 
       ACCompute (Time= (Range= (0 1)  Intervals= 30)) 
      ){ Poisson eQuantumPotential hQuantumPotential Electron Hole } 
   }
}

