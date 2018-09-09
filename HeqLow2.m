function output = HeqLow2(input,spring)
%suggested values: Keq = 5, B = 100ish, fpeak = 95

  output = zeros(spring.BLOCK_SIZE,1);
%{
  for i = 1:spring.BLOCK_SIZE
    if(spring.delay1Index > spring.Keq) spring.delay1Index = 1;
    
    if(spring.delay2Index > spring.Keq) spring.delay2Index = 1;
    
    output(i,1) = spring.A0*input(i,1) + spring.delay1(spring.delay1Index,1);
    spring.delay1(spring.delay1Index,1) = spring.delay2(spring.delay1Index,1) - spring.aEQ1*output(i,1);
    spring.delay2(spring.delay2Index,1) = -spring.aEQ2*output(i,1) - spring.A0*input(i,0);
    
    spring.delay1Index = spring.delay1Index + 1;
    spring.delay2Index = spring.delay2Index + 1;
  end

end
%}
%unused stretched filter
  
  for i = 1:spring.BLOCK_SIZE
    if(spring.delayIndex > spring.Keq) spring.delayIndex = 1;
    end
    output(i,1) = spring.A0*input(i,1) + spring.delayLine1(spring.delayIndex,1);
    spring.delayLine1(spring.delayIndex,1) = spring.delayLine2(spring.delayIndex,1) + -spring.aEQ1*output(i,1);
    spring.delayLine2(spring.delayIndex,1) = -spring.aEQ2*output(i,1) - spring.A0*input(i,1);
    
    spring.delayIndex = spring.delayIndex + 1;
  end
  
end