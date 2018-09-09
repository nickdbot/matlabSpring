function output = springDCBlock(input,fs)

persistent springDCBStruct = struct('BLOCK_SIZE', 0,...
'R', 0.995,...
'prevOutVal', 0,...
'prevInVal', 0,...
'initStatus', 0);

if (!springDCBStruct.initStatus)
  springDCBStruct.BLOCK_SIZE = length(input);
end

output = zeros(springDCBStruct.BLOCK_SIZE,1);

for i = 1:springDCBStruct.BLOCK_SIZE
  output(i,1) = input(i,1) - springDCBStruct.prevInVal + springDCBStruct.R*springDCBStruct.prevOutVal;
  springDCBStruct.prevInVal = input(i,1);
  springDCBStruct.prevOutVal = output(i,1);
end
  
end