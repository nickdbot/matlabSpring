function output = spect(input,windowsize,overlap)

IN_SIZE = length(input);
wind = ones(windowsize,1);

%create window
for i = 1:overlap
  wind(i,1) = i/overlap;
end
for i = windowsize-overlap:windowsize
  wind(i,1) = (IN_SIZE-i-1)/overlap+overlap;
end

plot(1:windowsize,wind(1:windowsize))

%for i=1:IN_SIZE
  
%end