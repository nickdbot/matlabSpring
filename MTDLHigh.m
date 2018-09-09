function output = MTDLHigh(input,spring)
  
  output = zeros(spring.BLOCK_SIZE,1);
  
  for i = 1:spring.BLOCK_SIZE
  
    %reset delay line indices if they exceed delay times
    if(spring.dlyLHighIndex > spring.LHigh) spring.dlyLHighIndex = 1;
    end
  
    %lowpass the noise signal
    Mh = spring.gmodHigh*rand; %noise value to modulate L0 with (aka to be subtracted from L0 index)
    Mh = spring.aLPFHigh*Mh + (1-spring.aLPFHigh)*spring.LPFPrevValH;
    spring.LPFPrevValH = Mh;
    
    %calculate modulated output 
    Ih = floor(Mh);
    frach = Mh-Ih;
    
    if(spring.dlyLHighIndex+Ih > spring.LHigh) inVal = spring.delayLHigh(spring.dlyLHighIndex+Ih-spring.LHigh,1); %with this, variable Ih can NEVER exceed LHigh value (not that it should anyway)
    else inVal = spring.delayLHigh(spring.dlyLHighIndex+Ih,1);
    end
    if(spring.dlyLHighIndex+Ih+1 > spring.LHigh) inVal2 = spring.delayLHigh(spring.dlyLHighIndex+Ih+1-spring.LHigh);
    else inVal2 = spring.delayLHigh(spring.dlyLHighIndex+Ih);
    end
    
    output(i,1) = frach*inVal + (1-frach)*inVal2; %linear interpolation equation
    spring.delayLHigh(spring.dlyLHighIndex,1) = input(i,1);
  
    %increment delay indices
    spring.dlyLHighIndex = spring.dlyLHighIndex + 1;
  
  end
  
end