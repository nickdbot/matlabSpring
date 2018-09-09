%spring reverb modules test

function output = fuck(input,spring)
  
  %outputFin = zeros(spring.BLOCK_SIZE,1);
  blockAmount = ceil(length(input)/spring.BLOCK_SIZE);
  len = length(input);
  
  tempIn = zeros(blockAmount*spring.BLOCK_SIZE,1);
  tempIn(1:len,1) = input;
  input = tempIn;  

  output = zeros(len,1);  
 
for i = 1:blockAmount
  
  output((i-1)*spring.BLOCK_SIZE+1:spring.BLOCK_SIZE*i,1) = ...
    HeqLow(input((i-1)*spring.BLOCK_SIZE+1:spring.BLOCK_SIZE*i,1),spring);

    %spring.delay1
    %spring.delay2
end

end