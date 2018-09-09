function output = HeqLowS(input,spring)
  
  output = spring.A0*input + spring.delay1
  spring.delay1 = spring.delay2 -spring.aEQ1*output;
  spring.delay2 = -spring.aEQ2*output - spring.A0*input;
  
end