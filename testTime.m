%test time

tic
for i = 1:100
  out1 = allpassLowS(1,spring);
end
toc

tic
for i = 1:100
  out2 = allpassLow(1,spring);
end
toc

out1 == out2