function MTe = tdoa_leastsquares(FP, K, dre)
%TDOA_LEASTSQUARES position estimation based on measured range differences
% least squares method
%   MTe estimated poisition of the MT, 
%       column vector with x and y coordinate
%   FP  coordinates of the fixed points,
%       first row x coordinates,
%       second row y coordinates
%   K   number of FPs to be used, not all the given 
%       fixed point coordinates and range differences may be used
%   dre estimated range differences, column vector

% ADD YOUR CODE HERE
% Extract the first K fixed points
FP = FP(:, 1:K);
dre = dre(1:K-1); % Use K-1 range differences

% Preallocate matrices
A = zeros(K-1, 2);
b = zeros(K-1, 1);

% Construct the linear system
for i = 2:K
    x_i = FP(1, i);
    y_i = FP(2, i);
    x_1 = FP(1, 1);
    y_1 = FP(2, 1);

    % Fill matrix A and vector b
    A(i-1, :) = 2 * [x_i - x_1, y_i - y_1];
    b(i-1) =  x_i^2 + y_i^2 - x_1^2 - y_1^2 - dre(i-1)^2;
end

% Solve the least squares problem
MTe = (A.' * A)^(-1) * A.' * b;

end
