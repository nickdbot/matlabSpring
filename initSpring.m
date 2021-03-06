%init spring
smallImpulseArray = zeros(1024,1);
smallImpulseArray(1,1) = 1;

largeImpulseArray = zeros(2*44100,1);
largeImpulseArray(1,1) = 1;

%[music,fs] = audioread('21.wav');

%oneSecondMusic = music(7323750:7323750+44099,1);

whiteNoise = 2*rand(44100,1)-1;
t = 1:44100;
t = t';
sineWave500 = sin(2*pi*t*500/44100);

clear spring

spring = struct(... %when moving to c/c++, define all temp values as pointers, move to header
  'BLOCK_SIZE',1024,... 
  'fs',44100,...
  'initStatus',1,...

%for allpassLow.m  
  'NUM_APF_LOW',0,... %temp value
  'fCChirp',4000,... %Hz
  'K', 0,... %temp value
  'K1', 0,... %temp value
  'd', 0,... %temp value
  'dlyAPF', 1,...
  'a1', 0.75,... 
  'a2', 0,... %temp value
  %Filter states
  'z1', 0,... %temp value
  'z2', 0,... %temp value
  'zK1', 0,... %temp value
  'v', 0,... %temp value
  'outAPF', 0,... %temp value

%for allpassHigh.m
  'NUM_APF_HIGH',0,...
  'ahigh', -0.6,... 
  %Filter states
  'zhigh', 0,...
  'outHighAPF',0,...

%for HdcLow.m
  'Rdc', 0.995,...
  'prevOutVal', 0,...
  'prevInVal', 0,...
  
%for HeqLow.m
  'Keq',0,...
  'B',0,...
  'fpeak',0,...
  'delayLine1',0,...
  'delayLine2',0,...
  'delayIndex',0,...
  'R',0,...
  'poleAngle',0,...
  'aEQ1',0,...
  'aEQ2',0,...
  'A0',0,...
  
%for HlpLow
  'aLP', 0,...
  'fC',0,...
  'prevValLP', 0,...
  
%for MTDLHigh.m
  'delayTimeHigh',0,...
  'LHigh',0,...
  'delayLHigh',0,...
  'dlyLHighIndex',0,...
  %for noise/LPF
  'aLPFHigh',0,...
  'LPFPrevValH',0,...
  'gmodHigh',0,...

%for MTDLLow.m
  'Nripple',0,...
  'echoTime',0,...
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
  'aLPF',0,...
  'LPFPrevVal',0,...
  'gmod',0,...
  
  %structural states
  'c1',0,...
  'c2',0,...
  'gDry',0,...
  'gHigh',0.01,...
  'gLow',1,...
  'gHf',-0.4,...
  'gLf',-0.4,...
  'cHOut',0,...
  'cLOut',0,...
  'APFLout',0,...
  'APFHIn',0,...
  'HeqOut',0,...
  'HdcOut',0,...
  'MTDLout',0,...
  'DLHout',0);

%if (spring.initStatus)
  %spring.BLOCK_SIZE = length(input);

  %for allpassLow.m
    spring.NUM_APF_LOW = 80;
    spring.K = spring.fs/(2*spring.fCChirp); %fs is sampling frequency, fC is cutoff freq for low chirp resp
    spring.K1 = round(spring.K) - 1; %used in APF structure
    spring.d = spring.K-spring.K1; %used in APF structure

    %spring.dlyAPF = 1; %integer for indexing delay lines of APFs (zK1)

    %spring.a1 = 0.75; %from pg. 549, just a useful number they give
    spring.a2 = (1-spring.d)/(1+spring.d); %where d = K-K1

    %filter states
    spring.z1 = zeros(spring.NUM_APF_LOW,1); %first delay
    spring.z2 = zeros(spring.NUM_APF_LOW,1); %second delay  
    spring.zK1 = zeros(spring.NUM_APF_LOW,spring.K1 + 1); %delay line of length K1
    spring.v = zeros(spring.NUM_APF_LOW,1); %intermediate APF output to be added to x(n)
    spring.outAPF = zeros(spring.BLOCK_SIZE,1); %this might need to be made into a single 
  
  %for allpassHigh.m
    spring.NUM_APF_HIGH = 100;
    spring.zhigh = zeros(spring.NUM_APF_HIGH,1); %delay value for each single order APF
    spring.outHighAPF = zeros(spring.NUM_APF_HIGH,1);
  
  %for HeqLow.m
    spring.Keq = floor(spring.K);
    spring.B = 130;
    spring.fpeak = 95;
    spring.R = 1 - (pi*spring.B*spring.Keq/spring.fs);
    spring.poleAngle = (1+spring.R^2)/(2*spring.R)*cos(2*pi*spring.fpeak*spring.Keq/spring.fs);
    spring.aEQ1 = -2*spring.R*(spring.poleAngle);
    spring.aEQ2 = spring.R^2;
    spring.A0 = (1-spring.aEQ2)/2;
    
    spring.delayOuIndex = 1;
    
    spring.delayLine1 = zeros(spring.Keq,1);
    spring.delayLine2 = zeros(spring.Keq,1);
  
  %for HlpLow.m
    spring.fC = 4000;
    spring.aLP = (2*pi*spring.fC/spring.fs)/(2*pi*spring.fC/spring.fs+1);

  %for MTDLLow.m
    spring.echoTime = 0.050; %echo time in ms
    spring.Nripple = 5; %number of desired ripples
    spring.L = round(spring.fs*spring.echoTime-spring.K*spring.NUM_APF_LOW*(1-spring.a1)/(1+spring.a1)); %delay time = echotime - group delay @ DC from APF
    spring.Lecho = round(spring.L/5); %pre-echo time (about 1/5 of total delay)
    spring.Lripple = round(2*spring.K*spring.Nripple); %tbh i don't know what this does. it's the ripple filter delay time
    spring.L0 = spring.L-spring.Lripple-spring.Lecho; %L0 = L - Lripple - Lecho

    % -v-v-v-v- initialize delay lines and indices -v-v-v-v-
    spring.delayL0 = zeros(spring.L0,1);
    spring.dlyL0Index = 1; 
    spring.delayLecho = zeros(spring.Lecho,1);
    spring.dlyLechoIndex = 1;
    spring.delayLripple = zeros(spring.Lripple,1);
    spring.dlyLrippleIndex = 1; 

    spring.gecho = 0.1; %echo delay feedforward gain 
    spring.gripple = 0.65; %ripple delay feedforward gain
    
    %noise generation and filtering for delay line modulation
    fCnoise = 100; %filter cutoff value in Hz
    spring.aLPF = (2*pi*fCnoise/spring.fs)/(2*pi*fCnoise/spring.fs+1); %lowpass coefficient
    spring.LPFPrevVal = 0; 
    spring.gmod = 12; 
  
  %for MTDLHigh.m
    spring.delayTimeHigh = (spring.echoTime/2.3); %make prime to echo time of LowFreq structure
    spring.LHigh = round(spring.fs*spring.delayTimeHigh); %delay time = echotime - group delay @ DC from APF
  
    %initialize delay line
    spring.delayLHigh = zeros(spring.LHigh,1);
    spring.dlyLHighIndex = 1; 
    
    %noise generation and filtering for delay line modulation
    %fCnoise = 100; %filter cutoff value in Hz
    spring.aLPFHigh = (2*pi*fCnoise/spring.fs)/(2*pi*fCnoise/spring.fs+1); %lowpass coefficient
    spring.LPFPrevValH = 0; 
    spring.gmodHigh = 12;
  
  %don't initialize again
    spring.initStatus = 0;
  
%end

