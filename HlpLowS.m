function output = HlpLowS(input,spring) 

  output = spring.aLP*input + (1-spring.aLP)*spring.prevValLP;
  spring.prevValLP = output;

end