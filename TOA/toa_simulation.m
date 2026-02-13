% simulation of TOA localization in 2D-scenarios

close all;
clear;

% SELECT YOUR SCENARIO HERE

% scenario 1
FP = [0 -sqrt(3)/2 sqrt(3)/2; 1 -0.5 -0.5]; % each column contains the coordinates of one FP
K = 3; % number of FPs which are used for loacalization
MT = [0; 0]; % true position of the MT

% % scenario 2
%FP = [1/sqrt(2) -1/sqrt(2) -1/sqrt(2) 1/sqrt(2); 1/sqrt(2) 1/sqrt(2) -1/sqrt(2) -1/sqrt(2)]; % each column contains the coordinates of one FP
%K = 4; % number of FPs which are used for loacalization
%MT = [0; 0]; % true position of the MT

% % scenario 3
%FP = [1 1/sqrt(2) 0 -1/sqrt(2) -1 -1/sqrt(2) 0 1/sqrt(2);  0 1/sqrt(2) 1 1/sqrt(2) 0 -1/sqrt(2) -1 -1/sqrt(2)]; % each column contains the coordinates of one FP
%K = 8; % number of FPs which are used for loacalization
%MT = [0; 0]; % true position of the MT

% % scenario 4
%alpha = pi/8;
%FP = [-1 1 cos(alpha); 0 0 sin(alpha)]; % each column contains the coordinates of one FP
%K = 3; % number of FPs which are used for loacalization
%MT = [0; 0]; % true position of the MT

%sigma = 0; % NO MEASUREMENT NOISE
sigma = 0.001; % STANDARD DEVIATION OF MEASUREMENT NOISE
N = 10000; % number of trials

% SELECT TOA ESTIMATOR HERE
%toa = @toa_leastsquares;
toa = @toa_gaussnewton;

% draw the scenario
figure;
plot(FP(1, 1:K), FP(2, 1:K), 'or');
hold on,
plot(MT(1), MT(2), 'ob');
axis equal;
axis([-1.5 1.5 -1.5 1.5]);
xlabel('x');
ylabel('y');
title('TOA');

r = sqrt(sum((FP-repmat(MT, 1, size(FP, 2))).^2)); % vector with the true ranges
rangecircles(FP(:, 1:K), r);

M = 0; % number of position fixes
square_error = 0; % sum square error

for n = 1:N
    re = r+sigma*randn(1, size(FP, 2)); % estimated ranges

    % TOA estimation
    MTe = toa(FP, K, re);
        
    % draw all position fixes
    plot(MTe(1, :), MTe(2, :), 'xb');
    
    M = M+size(MTe, 2);
    square_error = square_error+trace((MTe-repmat(MT, 1, size(MTe, 2))).'*(MTe-repmat(MT, 1, size(MTe, 2))));
    
end

% calculate the root mean square error
RMSE = sqrt(square_error/M);

% calculate the DOP under the assumption of unbiased estimates
DOP = RMSE/sigma
