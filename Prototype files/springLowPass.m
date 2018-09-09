function output = springLowPass(input, fC, fs)

persistent springLPFStruct = struct('BLOCK_SIZE', 0,...
'a', 0,...
'prevVal', 0,...
'initStatus', 0);

if (!springLPFStruct.initStatus)
  springLPFStruct.BLOCK_SIZE = length(input);
  springLPFStruct.a = (2*pi*fC/fs)/(2*pi*fC/fs+1);
  springLPFStruct.initStatus = 1;
end

output = zeros(springLPFStruct.BLOCK_SIZE,1);  

for i = 1:springLPFStruct.BLOCK_SIZE
  output(i,1) = springLPFStruct.a*input(i,1) + (1-springLPFStruct.a)*springLPFStruct.prevVal;
  springLPFStruct.prevVal = output(i,1);
end

end