function output = HdcLowS(input,spring)

  output = input - spring.prevInVal + spring.Rdc*spring.prevOutVal;
  spring.prevInVal = input;
  spring.prevOutVal = output;
  
end