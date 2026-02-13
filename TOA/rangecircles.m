function rangecircles(FP, r)
%RANGECIRCLES draw circles of constant range
%   FP  coordinates of the FPs
%   r   ranges

phi = linspace(0, 2*pi, 1000);
for k = 1:size(FP, 2)
    x = FP(1, k)+r(k)*cos(phi);
    y = FP(2, k)+r(k)*sin(phi);
    plot(x, y, '-m');
end;

end
