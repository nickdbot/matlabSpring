function output = springHighFreqDelayLine(input,echoTime,fs)
  
  persistent spring = struct(...
    'BLOCK_SIZE',0,...
    'delayTimeHigh',0,...
    'LHigh',0,...
    'delayLHigh',0,...
    'dlyLHighIndex',0,...
    
    %for noise/LPF
    'aLPFHigh',0,...
    'LPFPrevValH',0,...
    'gmodHigh',0,...
    
    %for initialization
    'initStatus',0);

  if(!spring.initStatus) %initialize everything

    spring.BLOCK_SIZE = length(input);
    spring.delayTimeHigh = echoTime/2.3; %make prime to echo time of LowFreq structure
    spring.LHigh = round(fs*spring.delayTimeHigh); %delay time = echotime - group delay @ DC from APF
  
    %initialize delay line
    spring.delayLHigh = zeros(spring.LHigh,1);
    spring.dlyLHighIndex = 1; 
    
    %noise generation and filtering for delay line modulation
    fC = 100; %filter cutoff value in Hz
    spring.aLPFHigh = (2*pi*fC/fs)/(2*pi*fC/fs+1); %lowpass coefficient
    spring.LPFPrevValH = 0; 
    spring.gmodHigh = 50;
    
    spring.initStatus = 1;
  end
  
  for i = 1:spring.BLOCK_SIZE
  
    %reset delay line indices if they exceed delay times
    if(spring.dlyLHighIndex > spring.LHigh) spring.dlyLHighIndex = 1;
    end
  
    %lowpass the noise signal
    Mh = spring.gmodHigh*rand; %noise value to modulate L0 with (aka to be subtracted from L0 index)
    Mh = spring.aLPFHigh*Mh + (1-spring.aLPFHigh)*spring.LPFPrevValH;
    spring.LPFPrevValH = Mh;
    
    %calculate modulated L0 output to be used for tempVal and Lecho
    Ih = floor(Mh);
    frach = Mh-Ih;
    
    if(spring.dlyLHighIndex-Ih-1 < 1) inVal = spring.delayLHigh(spring.dlyLHighIndex-Ih-1+spring.LHigh,1); %with this, variable Ih can NEVER exceed L0 value (not that it should anyway)
    else inVal = spring.delayLHigh(spring.dlyLHighIndex-Ih-1,1);
    end
    if(spring.dlyLHighIndex-Ih < 1) inVal2 = spring.delayLHigh(spring.dlyLHighIndex-Ih+spring.LHigh);
    else inVal2 = spring.delayLHigh(spring.dlyLHighIndex-Ih);
    end
    
    output(i,1) = frach*inVal + (1-frach)*inVal2; %linear interpolation equation
    spring.delayLHigh(spring.dlyLHighIndex,1) = input(i,1);
  
    %increment delay indices
    spring.dlyLHighIndex = spring.dlyLHighIndex + 1;
  
  end
  
end