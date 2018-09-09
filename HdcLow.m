function output = HdcLow(input,spring)

output = zeros(spring.BLOCK_SIZE,1);

for i = 1:spring.BLOCK_SIZE
  output(i,1) = input(i,1) - spring.prevInVal + spring.Rdc*spring.prevOutVal;
  spring.prevInVal = input(i,1);
  spring.prevOutVal = output(i,1);
end
  
end