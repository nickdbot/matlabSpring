function output = firstChirpEQ(input, Keq, B, fpeak, fs)

%suggested values: Keq = 5, B = 100ish, fpeak = 95
  persistent spring = struct(
    'BLOCK_SIZE',0,...
    %'output',0,...
    'delay1',0,...
    'delay2',0,...
    'R',0,...
    'poleAngle',0,...
    'aEQ1',0,...
    'aEQ2',0,...
    'A0',0,...
    'initStatus',0);
  
  
  if(!spring.initStatus)
    spring.BLOCK_SIZE = length(input);
    %spring.output = zeros(spring.BLOCK_SIZE,1);

    %delayLine1 = zeros(Keq,1);
    %delayLine2 = zeros(Keq,1);
    %delayIndex = 1; %delay lines are equal in length, so same index variable can be used for both  
  
    %delay1 = 0;
    %delay2 = 0;
  
    spring.R = 1 - (pi*B*Keq/fs);
    spring.poleAngle = (1+spring.R^2)/(2*spring.R)*cos(2*pi*fpeak*Keq/fs);
    spring.aEQ1 = -2*spring.R*(spring.poleAngle);
    spring.aEQ2 = spring.R^2;
    spring.A0 = (1-spring.aEQ2)/2;
  end
  
  output = zeros(spring.BLOCK_SIZE,1);

  for i = 1:spring.BLOCK_SIZE
    output(i,1) = spring.A0*input(i,1) + spring.delay1;
    spring.delay1 = spring.delay2 + -spring.aEQ1*output(i,1);
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
  