function output = HlpLow(input,spring)

output = zeros(spring.BLOCK_SIZE,1);  

for i = 1:spring.BLOCK_SIZE
  output(i,1) = spring.aLP*input(i,1) + (1-spring.aLP)*spring.prevValLP;
  spring.prevValLP = output(i,1);
end

end