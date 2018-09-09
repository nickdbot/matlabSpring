function result = plotFreqResp(input,topFreq)
  
  tab = 1;
  for i = 1:44100
    if (isinf(input(i,1))) 
      result(tab,1) = i;
      tab = tab+1;
    end
  end
  fft_in = 20*log10(fft(input));
  plot(1:topFreq,fft_in(1:topFreq,1));
  
end