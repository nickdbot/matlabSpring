function output = HeqLow2S(input,spring)
  
  if(spring.delay1Index > spring.Keq) spring.delay1Index = 1;
  
  if(spring.delay2Index > spring.Keq) spring.delay2Index = 1;
  
  output = spring.A0*input + spring.delay1(spring.delay1Index,1);
  spring.delay1(spring.delay1Index,1) = spring.delay2(spring.delay1Index,1) -spring.aEQ1*output;
  spring.delay2(spring.delay2Index,1) = -spring.aEQ2*output - spring.A0*input;
  
  spring.delay1Index = spring.delay1Index + 1;
  spring.delay2Index = spring.delay2Index + 1;
  
end