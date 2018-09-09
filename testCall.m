%spring reverb modules test

function outFin = testCall(input,spring)
  
  len = length(input);
  outFin = zeros(1:len,1);

  for i = 1:len

    outFin(i,1) = input(i,1)*spring.gDry + spring.cHOut*spring.gHigh + spring.cLOut*spring.gLow;
    
    %low freq section
    spring.cLOut = HlpLowS(spring.HeqOut,spring);
    spring.HeqOut = HeqLowS(spring.APFLout,spring);
    spring.APFLout = allpassLowS(spring.HdcOut,spring);
    spring.MTDLLout = spring.gLf*MTDLLowS(spring.APFLout,spring);
    spring.HdcOut = input(i,1) + spring.c1*spring.cHOut - spring.MTDLLout;
    
    %high freq section
    spring.cHOut = allpassHighS(spring.APFHIn,spring);
    spring.DLHout = spring.gHf * MTDLHighS(spring.cHOut,spring);
    spring.APFHIn = input(i,1) + spring.c2*spring.cLOut - spring.DLHout;
    

  end
  
end