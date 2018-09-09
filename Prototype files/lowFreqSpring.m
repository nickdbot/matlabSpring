function output = lowFreqSpring(input,fC,fs)

persistent springStruct = struct(... %when moving to c/c++, define all temp values as pointers, move to header
  'NUM_APF',0,... %temp value
  'BLOCK_SIZE',0,... %temp value
  'K', 0,... %temp value
  'K1', 0,... %temp value
  'd', 0,... %temp value
  'dlyAPF', 1,...
  'a1', 0.75,... 
  'a2', 0,... %temp value
  %Filter states
  'z1', 0,... %temp value
  'z2', 0,... %temp value
  'zK1', 0,... %temp value
  'v', 0,... %temp value
  'outAPF', 0,... %temp value
  'initStatus', 0); 


if !(springStruct.initStatus)
  springStruct.NUM_APF = 3;
  springStruct.BLOCK_SIZE = length(input);

  springStruct.K = fs/(2*fC); %fs is sampling frequency, fC is cutoff freq for low chirp resp
  springStruct.K1 = round(springStruct.K) - 1; %used in APF structure
  springStruct.d = springStruct.K-springStruct.K1; %used in APF structure

  %springStruct.dlyAPF = 1; %integer for indexing delay lines of APFs (zK1)

  %springStruct.a1 = 0.75; %from pg. 549, just a useful number they give
  springStruct.a2 = (1-springStruct.d)/(1+springStruct.d); %where d = K-K1

  %filter states
  springStruct.z1 = zeros(springStruct.NUM_APF,1); %first delay
  springStruct.z2 = zeros(springStruct.NUM_APF,1); %second delay  
  springStruct.zK1 = zeros(springStruct.NUM_APF,springStruct.K1); %delay line of length K1
  springStruct.v = zeros(springStruct.NUM_APF,1); %intermediate APF output to be added to x(n)
  springStruct.outAPF = zeros(springStruct.BLOCK_SIZE,1); %this might need to be made into a single 
  springStruct.initStatus = 1;                             %variable rather than a matrix, depending on stuff after APFs
end

  x = input;
                               
for springStruct.inIndex = 1:springStruct.BLOCK_SIZE
  if (springStruct.dlyAPF>springStruct.K1) springStruct.dlyAPF = 1;
  endif %reset delay line index if it exceeds K1  
  n = 1;
  %First APF structure
  springStruct.v(n,1) = springStruct.z2(n,1) + springStruct.z1(n,1)*springStruct.a2;
  springStruct.z2(n,1) = springStruct.z1(n,1);
  springStruct.z1(n,1) = springStruct.zK1(n,springStruct.dlyAPF) - springStruct.z1(n,1)*springStruct.a2;
  springStruct.zK1(n,springStruct.dlyAPF) = x(springStruct.inIndex,1)-springStruct.a1*springStruct.v(n,1);  

  
  for n = 2:springStruct.NUM_APF %optimized APF lines with one less multiplication
    springStruct.v(n,1) = springStruct.z2(n,1) + springStruct.z1(n,1)*springStruct.a2;
    springStruct.z2(n,1) = springStruct.z1(n,1);
    springStruct.z1(n,1) = springStruct.zK1(n,springStruct.dlyAPF) - springStruct.z1(n,1)*springStruct.a2;
    springStruct.zK1(n,springStruct.dlyAPF) = springStruct.a1*(springStruct.zK1(n-1,springStruct.dlyAPF)-springStruct.v(n))+springStruct.v(n-1);
    
  end
 
  springStruct.outAPF(springStruct.inIndex,1) = springStruct.a1*springStruct.zK1(n,springStruct.dlyAPF)+springStruct.v(n,1);
  
  springStruct.dlyAPF = springStruct.dlyAPF+1; %increment delay line index
end

output = springStruct.outAPF;

end
