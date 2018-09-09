function outFin = runSpring(input,spring)
  
  len = length(input);
  outFin = zeros(1:len,1);

  %initialize variables outside of loop
  HdcIn = 0;
  I = 0;
  Ih = 0;
  M = 0;
  Mh = 0;
  frac = 0;
  frach = 0;
  inVal = 0;
  inVal2 = 0;
  tempVal = 0;
  
  for i = 1:len

    outFin(i,1) = input(i,1)*spring.gDry + spring.cHOut*spring.gHigh + spring.cLOut*spring.gLow;
    
%low freq section
    %spring.cLOut = HlpLowS(spring.HeqOut,spring);
    spring.cLOut = spring.aLP*spring.HeqOut + (1-spring.aLP)*spring.prevValLP;
    spring.prevValLP = spring.cLOut;
    %---------------------------------------------------------------------------

    %spring.HeqOut = HeqLowS(spring.APFLout,spring);
    spring.HeqOut = spring.A0*spring.APFLout + spring.delay1;
    spring.delay1 = spring.delay2 -spring.aEQ1*spring.HeqOut;
    spring.delay2 = -spring.aEQ2*spring.HeqOut - spring.A0*spring.APFLout;
    %---------------------------------------------------------------------------
    
    %spring.APFLout = allpassLowS(spring.HdcOut,spring);
    if (spring.dlyAPF>spring.K1) spring.dlyAPF = 1;
    endif %reset delay line index if it exceeds K1  
    n = 1;
    %First APF structure
    spring.v(n,1) = spring.z2(n,1) + spring.z1(n,1)*spring.a2;
    spring.z2(n,1) = spring.z1(n,1);
    spring.z1(n,1) = spring.zK1(n,spring.dlyAPF) - spring.z1(n,1)*spring.a2;
    spring.zK1(n,spring.dlyAPF) = spring.HdcOut-spring.a1*spring.v(n,1);  

    
    for n = 2:spring.NUM_APF_LOW %optimized APF lines with one less multiplication
      spring.v(n,1) = spring.z2(n,1) + spring.z1(n,1)*spring.a2;
      spring.z2(n,1) = spring.z1(n,1);
      spring.z1(n,1) = spring.zK1(n,spring.dlyAPF) - spring.z1(n,1)*spring.a2;
      spring.zK1(n,spring.dlyAPF) = spring.a1*(spring.zK1(n-1,spring.dlyAPF)-spring.v(n))+spring.v(n-1);
      
    end
   
    spring.APFLout = spring.a1*spring.zK1(n,spring.dlyAPF)+spring.v(n,1);
    spring.dlyAPF = spring.dlyAPF+1; %increment delay line index
    %---------------------------------------------------------------------------
 
    %spring.MTDLLout = spring.gLf*MTDLLowS(spring.APFLout,spring);
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
    
      %output = spring.gLf*(gripple*(Lecho + L0*gecho) + Lripple)
    spring.MTDLLout = spring.gLf*(spring.gripple*tempVal + spring.delayLripple(spring.dlyLrippleIndex,1));
    
      %Lripple = Lecho + L0*gecho
    spring.delayLripple(spring.dlyLrippleIndex,1) = tempVal;
    
      %Lecho = L0
    spring.delayLecho(spring.dlyLechoIndex,1) = spring.delayL0(spring.dlyL0Index,1);
    
      %L0 = input
    spring.delayL0(spring.dlyL0Index,1) = spring.APFLout;
    
      %increment delay indices
    spring.dlyL0Index = spring.dlyL0Index + 1;
    spring.dlyLechoIndex = spring.dlyLechoIndex + 1;
    spring.dlyLrippleIndex = spring.dlyLrippleIndex +1;
    %---------------------------------------------------------------------------

    %spring.HdcOut = HdcLowS(input(i,1) + spring.c1*spring.cHOut - spring.MTDLLout);
    HdcIn = input(i,1) + spring.c1*spring.cHOut - spring.MTDLLout;
    spring.HdcOut = HdcIn - spring.prevInVal + spring.Rdc*spring.prevOutVal;
    spring.prevInVal = HdcIn;
    spring.prevOutVal = spring.HdcOut;
    %---------------------------------------------------------------------------

%high freq section
    %spring.cHOut = allpassHighS(spring.APFHIn,spring);
    spring.outHighAPF(1,1) = spring.APFHIn*spring.ahigh + spring.zhigh(1,1); %first APF
    spring.zhigh(1,1) = spring.APFHIn - spring.outHighAPF(1,1)*spring.ahigh;
    
    for n = 2:spring.NUM_APF_HIGH
      spring.outHighAPF(n,1) = spring.outHighAPF(n-1,1)*spring.ahigh + spring.zhigh(n,1);
      spring.zhigh(n,1) = spring.outHighAPF(n-1,1) - spring.outHighAPF(n,1)*spring.ahigh;
    end
    
    spring.cHOut = spring.outHighAPF(spring.NUM_APF_HIGH,1);  
    %---------------------------------------------------------------------------    

    %spring.DLHout = spring.gHf * MTDLHighS(spring.cHOut,spring);
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
    
    spring.DLHout = spring.gHf*(frach*inVal + (1-frach)*inVal2); %linear interpolation equation
    spring.delayLHigh(spring.dlyLHighIndex,1) = spring.cHOut;
  
    %increment delay indices
    spring.dlyLHighIndex = spring.dlyLHighIndex + 1;
    %---------------------------------------------------------------------------  
    
    spring.APFHIn = input(i,1) + spring.c2*spring.cLOut - spring.DLHout;

  end
  
end