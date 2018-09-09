function output = runPlot(M,Ty,out);

if M == 'c' && Ty == 'freq'
  fileID = fopen('impulse.txt','r');
  fs = 44100;
  imp = fscanf(fileID,'%f');
  fclose(fileID);
  len = length(imp);
  freqArray = fs/2*linspace(0,1,len/2+1);
  Ffft = 20*log10(abs(fft(imp)));
  [~,t] = max(Ffft);
  t = t*fs/len
  amp = (Ffft(1:len/2+1));
  semilogx(freqArray,amp);
  output = imp;
  
elseif M == 'm' && Ty == 'freq'

  fs = 44100;
  imp = out;
  len = length(imp);
  freqArray = fs/2*linspace(0,1,len/2+1);
  Ffft = 20*log10(abs(fft(imp)));
  [~,t] = max(Ffft);
  t = t*fs/len
  amp = (Ffft(1:len/2+1));
  semilogx(freqArray,amp);
  output = imp;
  
elseif M == 'c' && Ty == 'spec'
  fileID = fopen('impulse.txt','r');
  fs = 44100;
  imp = fscanf(fileID,'%f');
  [~,ind] = max(imp);
  ind
  fclose(fileID);
  specgram(imp/max(imp));
  output = imp;

else

  specgram(out);
  output = out;

end