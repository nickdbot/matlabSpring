%spring reverb impulse response test

input = zeros(44100,1);
len = length(input);
output = zeros(len,1);
input(1,1) = 1;
input(440,1) = 1;
blockSize = 100; %please god make this a number that divides evenly into 44100
blockAmount = len/blockSize;


for i = 1:blockAmount
  
  %output((i-1)*blockSize+1:blockSize*i,1) = springLowFreqDelayLine(input((i-1)*blockSize+1:blockSize*i,1),5,5.3,80,0.61,0.05,44100);
  output((i-1)*blockSize+1:blockSize*i,1) = springLowFreqDelayLine(musicin((i-1)*blockSize+1:blockSize*i,1),5,5.3,80,0.61,0.05,44100);
end