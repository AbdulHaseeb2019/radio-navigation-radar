function MTe = tdoa_gaussnewton(FP, K, dre)
%TDOA_GAUSSNEWTON position estimation based on measured range differences
% Gauss-Newton series method
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

% Initial estimate for the position
MTe = [0; 0]; % Initial guess (e.g., origin)

% Maximum iterations and tolerance
max_iters = 100;
tolerance = 1e-6;

for iter = 1:max_iters
    % Compute Jacobian and residuals
    J = zeros(K-1, 2);
    r = zeros(K-1, 1);
    for i = 2:K
        x_i = FP(1, i);
        y_i = FP(2, i);
        x_1 = FP(1, 1);
        y_1 = FP(2, 1);

        % Current estimate of distances
        r_i = sqrt((MTe(1) - x_i)^2 + (MTe(2) - y_i)^2);
        r_1 = sqrt((MTe(1) - x_1)^2 + (MTe(2) - y_1)^2);

        % Jacobian
        J(i-1, :) = [(MTe(1) - x_i) / r_i - (MTe(1) - x_1) / r_1, ...
                     (MTe(2) - y_i) / r_i - (MTe(2) - y_1) / r_1];
        
        % Residuals
        r(i-1) = dre(i-1) - (r_i - r_1);
    end

    % Update position
    delta = (J.' * J)^(-1)* J' * r;
    MTe = MTe + delta;

    % Check for convergence
    if norm(delta) < tolerance
        break;
    end
end
