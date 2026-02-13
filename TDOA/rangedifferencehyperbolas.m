function rangedifferencehyperbolas(FP, dr)
%RANGEDIFFERENCEHYPERBOLAS draw hyperbolas of constant range difference
%   FP  coordinates of the FPs
%   dr  range differences

maxy = 10; % significantly larger than the y-dimension of the scenario

yy = linspace(-maxy, maxy, 1000);
for k = 2:size(FP, 2)
    
    % first calculate hyperbola with both focal points on the
    % x-axis and symmetrical with respect to the y-axis
    a = dr(k-1)/2; 
    b = sqrt(((FP(1, k)-FP(1, 1))^2+(FP(2, k)-FP(2, 1))^2)/4-a^2);
    
    if dr(k-1)>0
        xx = -sqrt(a^2*(1+yy.^2/b^2));
    else
        xx = sqrt(a^2*(1+yy.^2/b^2));
    end
        
    % now turn the hyperbola by a suitable angle alpha and shift it
    alpha = atan2(FP(2, k)-FP(2, 1), FP(1, k)-FP(1, 1));
    x = cos(alpha)*xx-sin(alpha)*yy+(FP(1, k)+FP(1, 1))/2;
    y = sin(alpha)*xx+cos(alpha)*yy+(FP(2, k)+FP(2, 1))/2;
    plot(x, y, '-m');    
end;

end
