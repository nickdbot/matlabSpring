function output = highFreqSpring(input)
  
  persistent springStruct = struct(... %when moving to c/c++, define all temp values as pointers, move to header
    'NUM_APF',0,... %temp value
    'BLOCK_SIZE',0,... %temp value
    'ahigh', -0.6,... 
    %Filter states
    'zhigh', 0,...
    'outHighAPF',0,...
    'initStatus', 0); 
  
  if !(springStruct.initStatus)
    springStruct.NUM_APF = 80;
    springStruct.BLOCK_SIZE = length(input);
    springStruct.zhigh = zeros(springStruct.NUM_APF,1); %delay value for each single order APF
    springStruct.outHighAPF = zeros(springStruct.NUM_APF,1);
  end

  for i = 1:springStruct.BLOCK_SIZE
    springStruct.outHighAPF(1,1) = input(i,1)*springStruct.ahigh + springStruct.zhigh(1,1); %first APF
    springStruct.zhigh(1,1) = input(i,1) - springStruct.outHighAPF(1,1)*springStruct.ahigh;
    
    for n = 2:springStruct.NUM_APF
      springStruct.outHighAPF(n,1) = springStruct.outHighAPF(n-1,1)*springStruct.ahigh + springStruct.zhigh(n,1);
      springStruct.zhigh(n,1) = springStruct.outHighAPF(n-1,1) - springStruct.outHighAPF(n,1)*springStruct.ahigh;
    end
    
    output(i,1) = springStruct.outHighAPF(springStruct.NUM_APF,1);  
  end
  
end