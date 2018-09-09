function output = allpassLowS(input,spring)
                               
  if (spring.dlyAPF>(spring.K1 + 1)) spring.dlyAPF = 1;
  endif %reset delay line index if it exceeds K1  
  n = 1;
  %First APF structure
  spring.v(n,1) = spring.z2(n,1) + spring.z1(n,1)*spring.a2;
  spring.z2(n,1) = spring.z1(n,1);
  spring.z1(n,1) = spring.zK1(n,spring.dlyAPF) - spring.z1(n,1)*spring.a2;
  spring.zK1(n,spring.dlyAPF) = input-spring.a1*spring.v(n,1);  

  
  for n = 2:spring.NUM_APF_LOW %optimized APF lines with one less multiplication
    spring.v(n,1) = spring.z2(n,1) + spring.z1(n,1)*spring.a2;
    spring.z2(n,1) = spring.z1(n,1);
    spring.z1(n,1) = spring.zK1(n,spring.dlyAPF) - spring.z1(n,1)*spring.a2;
    spring.zK1(n,spring.dlyAPF) = spring.a1*(spring.zK1(n-1,spring.dlyAPF)-spring.v(n))+spring.v(n-1);
    
  end
 
  output = spring.a1*spring.zK1(n,spring.dlyAPF)+spring.v(n,1);
  
  spring.dlyAPF = spring.dlyAPF+1; %increment delay line index

end
