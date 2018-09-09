function output = allpassHighS(input,spring)
  
    spring.outHighAPF(1,1) = input*spring.ahigh + spring.zhigh(1,1); %first APF
    spring.zhigh(1,1) = input - spring.outHighAPF(1,1)*spring.ahigh;
    
    for n = 2:spring.NUM_APF_HIGH
      spring.outHighAPF(n,1) = spring.outHighAPF(n-1,1)*spring.ahigh + spring.zhigh(n,1);
      spring.zhigh(n,1) = spring.outHighAPF(n-1,1) - spring.outHighAPF(n,1)*spring.ahigh;
    end
    
    output = spring.outHighAPF(spring.NUM_APF_HIGH,1);  
  
end