function output = HeqLow(input,spring)
%suggested values: Keq = 5, B = 100ish, fpeak = 95

  output = zeros(spring.BLOCK_SIZE,1);

  for i = 1:spring.BLOCK_SIZE
    output(i,1) = spring.A0*input(i,1) + spring.delay1;
    spring.delay1 = spring.delay2 -spring.aEQ1*output(i,1);
    spring.delay2 = -spring.aEQ2*output(i,1) - spring.A0*input(i,1);
  end

end

%unused stretched filter
  
%  for i = 1:BLOCK_SIZE
%    if(delayIndex > Keq) delayIndex = 1;
%    end
%    output(i,1) = A0*input(i,1) + delayLine1(delayIndex,1);
%    delayLine1(delayIndex,1) = delayLine2(delayIndex,1) + -aEQ1*output(i,1);
%    delayLine2(delayIndex,1) = -aEQ2*output(i,1) - A0*input(i,1);
%    
%    delayIndex = delayIndex + 1;
%  end
  