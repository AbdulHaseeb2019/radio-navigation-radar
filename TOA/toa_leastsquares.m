function MTe = toa_leastsquares(FP, K, re)
%TOA_LEASTSQUARES position estimation based on measured ranges
% least squares method
%   MTe estimated poisition of the MT, 
%       column vector with x and y coordinate
%   FP  coordinates of the fixed points,
%       first row x coordinates,
%       second row y coordinates
%   K   number of FPs to be used, may be smaller than the
%       given number of fixed point coordinates and ranges
%   re  estimated ranges, column vector

% ADD YOUR CODE HERE
% Extract the first K fixed points
FP = FP(:, 1:K);
re = re(1:K);

% Select the first fixed point as reference
x1 = FP(1, 1);
y1 = FP(2, 1);
r1 = re(1);

% Preallocate matrices
A = zeros(K-1, 2);
b = zeros(K-1, 1);

% Construct the linear system
for i = 2:K
    xi = FP(1, i);
    yi = FP(2, i);
    ri = re(i);

    % Fill matrix A and vector b
    A(i-1, :) = 2 * [xi - x1, yi - y1];
    b(i-1) = xi^2 - x1^2 + yi^2 - y1^2 - ri^2 + r1^2 ;
end

% Solve the least squares problem
MTe = (A.'*A)^(-1)*A.'*b;

end
