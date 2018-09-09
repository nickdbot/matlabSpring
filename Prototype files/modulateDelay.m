%delayline mod

function output = modulateDelay(input, gmod, fs)
  
  LINE_SIZE = length(input);
  fC = 50; %hertz
  %t = 1:LINE_SIZE; for testing
  %t = t'; for testing
  M = gmod*rand(LINE_SIZE,1);  %when porting this you have to make this a loop; make negative so M is never accessing future data
  %gmod*(sin(2*pi*t*4/fs)+1); for testing
  LPFPrevVal = 0;
  a = (2*pi*fC/fs)/(2*pi*fC/fs+1);
  
  persistent tempDelay = zeros(LINE_SIZE,1);
  
  %lowpass filter for noise
  
  for i = 1:LINE_SIZE
    M(i,1) = a*M(i,1) + (1-a)*LPFPrevVal;
    LPFPrevVal = M(i,1);
  end
  
  %modulate delay
  
  %   input:
  %   [0][1][2][1][0][0][0]
  %   1  2  3  4  5  6  ^dlyIndex = 7
  %
  % if M = 4.12, I = 4, frac = 0.12 -> looking for value at "index" 7-4.12 = 2.88 (should equal 1.88)
  % input(dlyIndex-I) = input(3) = 2
  % input(dlyIndex-I-1) = input(2) = 1
  % value = frac*input(i-I-1) + (1-frac)*input(i-I) = 0.12*1 + 0.88*2 = 1.88
  
    %split M into I.frac -> I = floor(M); frac = M-I; 
    %need two input values: input(dlyIndex-I) and input(dlyIndex-I-1)
    %calculate output(i,1) = frac*input(i-I-1) + (1-frac)*input(i-I);

  for i = 1:LINE_SIZE
    I = floor(M(i,1));
    frac = M(i,1)-I;
    
    tempDelay(i,1) = input(i,1); %place input into temp array to allow access of previous input values using circular buffer wraparound
    
    if(i-I-1 < 1) inVal = tempDelay(i-I-1+LINE_SIZE); %with this, variable I can NEVER exceed LINE_SIZE value (not that it should anyway)
    else inVal = tempDelay(i-I-1);
    end
    if(i-I < 1) inVal2 = tempDelay(i-I+LINE_SIZE);
    else inVal2 = tempDelay(i-I);
    end
    output(i,1) = frac*inVal + (1-frac)*inVal2; %linear interpolation equation
  end

end