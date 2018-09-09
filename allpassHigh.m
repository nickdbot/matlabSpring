function output = allpassHigh(input,spring)
  
  output = zeros(spring.BLOCK_SIZE,1);
  
  for i = 1:spring.BLOCK_SIZE
    spring.outHighAPF(1,1) = input(i,1)*spring.ahigh + spring.zhigh(1,1); %first APF
    spring.zhigh(1,1) = input(i,1) - spring.outHighAPF(1,1)*spring.ahigh;
    
    for n = 2:spring.NUM_APF_HIGH
      spring.outHighAPF(n,1) = spring.outHighAPF(n-1,1)*spring.ahigh + spring.zhigh(n,1);
      spring.zhigh(n,1) = spring.outHighAPF(n-1,1) - spring.outHighAPF(n,1)*spring.ahigh;
    end
    
    output(i,1) = spring.outHighAPF(spring.NUM_APF_HIGH,1);  
  end
  
end