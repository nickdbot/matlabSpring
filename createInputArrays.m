
smallImpulseArray = zeros(1024,1);
smallImpulseArray(1,1) = 1;

largeImpulseArray = zeros(2*44100,1);
largeImpulseArray(1,1) = 1;

%[music,fs] = audioread('21.wav');

%oneSecondMusic = music(7323750:7323750+44099,1);

whiteNoise = 2*rand(44100,1)-1;
t = 1:44100;
t = t';
sineWave500 = sin(2*pi*t*500/44100);