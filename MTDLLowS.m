function output = MTDLLowS(input,spring) 
%L = total delay len, Lecho = preecho len, Lripple = ripple filter len
%Nripple = number of ripples in delay desired
%K, NUM_APF_LOW, a1: ALL from lowFreqSpring calculation, NUM_APF_LOW is num allpasses in lowFreqSpring
  
  %reset delay line indices if they exceed delay times
  if(spring.dlyL0Index > spring.L0) spring.dlyL0Index = 1;
  end
  if(spring.dlyLechoIndex > spring.Lecho) spring.dlyLechoIndex = 1;
  end
  if(spring.dlyLrippleIndex > spring.Lripple) spring.dlyLrippleIndex = 1;
  end
  
  %lowpass the noise signal
  M = spring.gmod*rand; %noise value to modulate L0 with (aka to be subtracted from L0 index)
  M = spring.aLPF*M + (1-spring.aLPF)*spring.LPFPrevVal;
  spring.LPFPrevVal = M;
  
  %calculate modulated L0 output to be used for tempVal and Lecho
  I = floor(M);
  frac = M-I;
  
  %wrap indices around circular buffer of L0 if modulated index goes below 0
  if(spring.dlyL0Index+I > spring.L0) inVal = spring.delayL0(spring.dlyL0Index+I-spring.L0,1); %with this, variable I can NEVER exceed L0 value (not that it should anyway)
  else inVal = spring.delayL0(spring.dlyL0Index+I,1);
  end
  if(spring.dlyL0Index+I+1 > spring.L0) inVal2 = spring.delayL0(spring.dlyL0Index+I+1-spring.L0);
  else inVal2 = spring.delayL0(spring.dlyL0Index+I+1);
  end
  L0Output = frac*inVal + (1-frac)*inVal2; %linear interpolation equation
  
  %tempVal = Lecho + L0*gecho
  %tempVal = spring.delayLecho(spring.dlyLechoIndex,1) + spring.delayL0(spring.dlyL0Index,1)*spring.gecho;
  tempVal = spring.delayLecho(spring.dlyLechoIndex,1) + L0Output*spring.gecho;
  
  %output = gripple*(Lecho + L0*gecho) + Lripple
  output = spring.gripple*tempVal + spring.delayLripple(spring.dlyLrippleIndex,1);
  
  %Lripple = Lecho + L0*gecho
  spring.delayLripple(spring.dlyLrippleIndex,1) = tempVal;
  
  %Lecho = L0
  spring.delayLecho(spring.dlyLechoIndex,1) = spring.delayL0(spring.dlyL0Index,1);
  
  %L0 = input
  spring.delayL0(spring.dlyL0Index,1) = input;
  
  %increment delay indices
  spring.dlyL0Index = spring.dlyL0Index + 1;
  spring.dlyLechoIndex = spring.dlyLechoIndex + 1;
  spring.dlyLrippleIndex = spring.dlyLrippleIndex +1;


end