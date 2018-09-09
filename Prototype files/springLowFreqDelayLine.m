function output = springLowFreqDelayLine(input,Nripple,K,M,a1,echoTime,fs) 
%L = total delay len, Lecho = preecho len, Lripple = ripple filter len
%Nripple = number of ripples in delay desired
%K, M, a1: ALL from lowFreqSpring calculation, M is num allpasses in lowFreqSpring

%{

persistent springLFDLStruct = struct(...
'BLOCK_SIZE',0,...
'L0',0,...
'Lripple',0,...
'Lecho',0,...
'L',0,...
'gecho',0,...
'gripple',0,...
'delayEcho',0,...
'delayRipple',0,...
'delayLine',0,...
'delayIndex',0,...
'initStatus',0);

if (!springLFDLStruct.initStatus)
  springLFDLStruct.BLOCK_SIZE = length(input);
  springLFDLStruct.gecho = 0.1;
  springLFDLStruct.gripple = 0.5;
  springLFDLStruct.L = round(fs*echoTime-K*M*(1-a1)/(1+a1));
  springLFDLStruct.Lecho = round(springLFDLStruct.L/5);
  springLFDLStruct.Lripple = round(2*K*Nripple);
  springLFDLStruct.L0 = springLFDLStruct.L-springLFDLStruct.Lripple-springLFDLStruct.Lecho;
  springLFDLStruct.delayIndex = 1;
  springLFDLStruct.delayL0 = springLFDLStruct.L - springLFDLStruct.L0;
  springLFDLStruct.delayEcho = springLFDLStruct.L - springLFDLStruct.L0 - springLFDLStruct.Lecho;
  springLFDLStruct.delayRipple = springLFDLStruct.L - springLFDLStruct.L0 - springLFDLStruct.Lecho - springLFDLStruct.Lripple;
  springLFDLStruct.delayLine = zeros(springLFDLStruct.L,1);
  springLFDLStruct.initStatus = 1;
end

for i=1:springLFDLStruct.BLOCK_SIZE
  
  if (springLFDLStruct.delayIndex > springLFDLStruct.L) springLFDLStruct.delayIndex = 1;
  end
  L0Tap = mod(springLFDLStruct.delayIndex + springLFDLStruct.delayL0 - 1, springLFDLStruct.L) + 1;
  echoTap = mod(springLFDLStruct.delayIndex + springLFDLStruct.delayEcho - 1, springLFDLStruct.L) + 1;
  rippleTap = mod(springLFDLStruct.delayIndex + springLFDLStruct.delayRipple -1 , springLFDLStruct.L) + 1;
  %outTap = mod(springLFDLStruct.delayIndex-1, springLFDLStruct.L)+1;

  springLFDLStruct.delayLine(rippleTap,1) = springLFDLStruct.delayLine(L0Tap,1)*springLFDLStruct.gecho + springLFDLStruct.delayLine(echoTap,1); 
  output(i,1) = springLFDLStruct.delayLine(echoTap,1)*springLFDLStruct.gripple + springLFDLStruct.delayLine(springLFDLStruct.delayRipple,1);
  springLFDLStruct.delayLine(springLFDLStruct.delayIndex,1) = input(i,1);
  
  springLFDLStruct.delayIndex = springLFDLStruct.delayIndex + 1;

end

%}

persistent springLFDLStruct = struct(...
'BLOCK_SIZE',0,...
'L0',0,...
'Lripple',0,...
'Lecho',0,...
'L',0,...
'gecho',0,...
'gripple',0,...
'delayL0',0,...
'delayLecho',0,...
'delayLripple',0,...
'dlyL0Index',0,...
'dlyLechoIndex',0,...
'dlyLrippleIndex',0,...

%for noise/LPF
'M',0,...
'aLPF',0,...
'LPFPrevVal',0,...
'gmod',0,...

%for 
'initStatus',0);

if(!springLFDLStruct.initStatus) %initialize everything

  springLFDLStruct.BLOCK_SIZE = length(input)
  springLFDLStruct.L = round(fs*echoTime-K*M*(1-a1)/(1+a1)); %delay time = echotime - group delay @ DC from APF
  springLFDLStruct.Lecho = round(springLFDLStruct.L/5); %pre-echo time (about 1/5 of total delay)
  springLFDLStruct.Lripple = round(2*K*Nripple); %tbh i don't know what this does. it's the ripple filter delay time
  springLFDLStruct.L0 = springLFDLStruct.L-springLFDLStruct.Lripple-springLFDLStruct.Lecho; %L0 = L - Lripple - Lecho

  % -v-v-v-v- initialize delay lines and indices -v-v-v-v-
  springLFDLStruct.delayL0 = zeros(springLFDLStruct.L0,1);
  springLFDLStruct.dlyL0Index = 1; 
  springLFDLStruct.delayLecho = zeros(springLFDLStruct.Lecho,1);
  springLFDLStruct.dlyLechoIndex = 1;
  springLFDLStruct.delayLripple = zeros(springLFDLStruct.Lripple,1);
  springLFDLStruct.dlyLrippleIndex = 1; 

  springLFDLStruct.gecho = 0.1; %echo delay feedforward gain 
  springLFDLStruct.gripple = 0.65; %ripple delay feedforward gain
  tempVal = 0; %value for easier reading (represents node after z^-Lecho sum)
  
  %noise generation and filtering for delay line modulation
  fC = 100; %filter cutoff value in Hz
  springLFDLStruct.aLPF = (2*pi*fC/fs)/(2*pi*fC/fs+1); %lowpass coefficient
  springLFDLStruct.LPFPrevVal = 0; 
  springLFDLStruct.gmod = 12;
  
  springLFDLStruct.initStatus = 1;
end

output = zeros(springLFDLStruct.BLOCK_SIZE,1);

for i = 1:springLFDLStruct.BLOCK_SIZE
  
  %reset delay line indices if they exceed delay times
  if(springLFDLStruct.dlyL0Index > springLFDLStruct.L0) springLFDLStruct.dlyL0Index = 1;
  end
  if(springLFDLStruct.dlyLechoIndex > springLFDLStruct.Lecho) springLFDLStruct.dlyLechoIndex = 1;
  end
  if(springLFDLStruct.dlyLrippleIndex > springLFDLStruct.Lripple) springLFDLStruct.dlyLrippleIndex = 1;
  end
  
  %lowpass the noise signal
  M = springLFDLStruct.gmod*rand; %noise value to modulate L0 with (aka to be subtracted from L0 index)
  M = springLFDLStruct.aLPF*M + (1-springLFDLStruct.aLPF)*springLFDLStruct.LPFPrevVal;
  springLFDLStruct.LPFPrevVal = M;
  
  %calculate modulated L0 output to be used for tempVal and Lecho
  I = floor(M);
  frac = M-I;
  
  %wrap indices around circular buffer of L0 if modulated index goes below 0
  if(springLFDLStruct.dlyL0Index-I-1 < 1) inVal = springLFDLStruct.delayL0(springLFDLStruct.dlyL0Index-I-1+springLFDLStruct.L0,1); %with this, variable I can NEVER exceed L0 value (not that it should anyway)
  else inVal = springLFDLStruct.delayL0(springLFDLStruct.dlyL0Index-I-1,1);
  end
  if(springLFDLStruct.dlyL0Index-I < 1) inVal2 = springLFDLStruct.delayL0(springLFDLStruct.dlyL0Index-I+springLFDLStruct.L0);
  else inVal2 = springLFDLStruct.delayL0(springLFDLStruct.dlyL0Index-I);
  end
  L0Output = frac*inVal + (1-frac)*inVal2; %linear interpolation equation
  
  %tempVal = Lecho + L0*gecho
  %tempVal = springLFDLStruct.delayLecho(springLFDLStruct.dlyLechoIndex,1) + springLFDLStruct.delayL0(springLFDLStruct.dlyL0Index,1)*springLFDLStruct.gecho;
  tempVal = springLFDLStruct.delayLecho(springLFDLStruct.dlyLechoIndex,1) + L0Output*springLFDLStruct.gecho;
  
  %output = gripple*(Lecho + L0*gecho) + Lripple
  output(i,1) = springLFDLStruct.gripple*tempVal + springLFDLStruct.delayLripple(springLFDLStruct.dlyLrippleIndex,1);
  
  %Lripple = Lecho + L0*gecho
  springLFDLStruct.delayLripple(springLFDLStruct.dlyLrippleIndex,1) = tempVal;
  
  %Lecho = L0
  springLFDLStruct.delayLecho(springLFDLStruct.dlyLechoIndex,1) = springLFDLStruct.delayL0(springLFDLStruct.dlyL0Index,1);
  
  %L0 = input
  springLFDLStruct.delayL0(springLFDLStruct.dlyL0Index,1) = input(i,1);
  
  %increment delay indices
  springLFDLStruct.dlyL0Index = springLFDLStruct.dlyL0Index + 1;
  springLFDLStruct.dlyLechoIndex = springLFDLStruct.dlyLechoIndex + 1;
  springLFDLStruct.dlyLrippleIndex = springLFDLStruct.dlyLrippleIndex +1;
end


end