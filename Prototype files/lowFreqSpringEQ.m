function lowFreqSpringEQ(input,fpeak,Keq,bandwidth,fs) %Keq = floor(K)

persistent springEQStruct = struct(...
  'BLOCK_SIZE', 0,... %temp value
  'B', 0,... 
  'R', 0,... %temp value
  'costheta', 0,... %temp value
  'A0', 0,... %temp value
  'aEQ1', 0,... %temp value
  'aEQ2', 0,... %temp value
  'Keq', 0,... %??
  'fpeak', 0,... %??
  'initStatus', 0); 

if (!springEQStruct.initStatus)
  springEQStruct.BLOCK_SIZE = length(input);
  output = zeros(BLOCK_SIZE,1);
  springEQStruct.B = bandwidth;
  springEQStruct.R = 1 - (pi*springEQStruct.B*springEQStruct.Keq/fs);
  springEQStruct.costheta = (1+springEQStruct.R^2)/(2*springEQStruct.R)*cos(2*pi*fpeak*Keq/fs);
  springEQStruct.A0 = 1-springEQStruct.R^2;
  springEQStruct.aEQ1 = -2*springEQStruct.R*springEQStruct.costheta;
  springEQStruct.aEQ2 = springEQStruct.R^2;
  output(1,1) = input(1,1);
  springEQStruct.initStatus = 1;
end

for i = 2:BLOCK_SIZE
  output(i,1) = input(i,1); %you gotta rethink all this shit
end

end

B = zeros(1,2*Keq);
A = zeros(1,2*Keq); %how are you going to get the previous val from prev func call?

output = filter(B,A,input);