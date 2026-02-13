function MTe = toa_gaussnewton(FP, K, re)
%TOA_GAUSSNEWTON position estimation based on measured ranges
% Gauss-Newton method
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

% Initial estimate for the position (e.g., the origin)
MTe = [0; 0];

% Maximum iterations and tolerance
max_iters = 100;
tolerance = 1e-6;

for iter = 1:max_iters
    % Compute Jacobian and residuals
    J = zeros(K, 2);
    r = zeros(K, 1);
    for i = 1:K
        xi = FP(1, i);
        yi = FP(2, i);
        ri = re(i);

        % Current estimate of distance
        r_est = sqrt((MTe(1) - xi)^2 + (MTe(2) - yi)^2);
        J(i, :) = [(MTe(1) - xi) / r_est, (MTe(2) - yi) / r_est];
        r(i) = ri - r_est;
    end

    % Update position
    delta = (J.' * J)^(-1) * J.' * r;
    MTe = MTe + delta;

    % Check for convergence
    if norm(delta) < tolerance
        break;
    end
end
end
