function x=kalman(y,t,f0,k)
%KALMAN Kalman filter step
% range-velocity tracking using a Kalman filter
%   x           estimated range and velocity
%   y           observed frequency shifts in down-chirp and up-chirp
%   t           sampling interval
%   f0          center frequency
%   k           sweep rate

% save prediciton for the next Kalman filter step
persistent xpred Rxxpred

% initialize prediction
if isempty(xpred)
    xpred=[10; 0];
end

% initialize correlation matrix of the prediction
if isempty(Rxxpred)
    Rxxpred=[20^2 0;0 2^2]; % size of scenario and typical velocity
end

c0=299792458; % speed of light
g=9.80665; % gravity

% ADD YOUR CODE HERE
% Process noise covariance
sigma_a = 100; % Typical pedestrian acceleration in m/s^2
Q = sigma_a^2 * [t^4/4, t^3/2; t^3/2, t^2];

% State transition matrix
F = [1, t; 0, 1];

% Predict step
xpred = F * xpred;
Rxxpred = F * Rxxpred * F.' + Q;

% Observation matrix
H = [2 * k / c0, -2 * f0 / c0; -2 * k / c0, -2 * f0 / c0];

% Measurement noise covariance
T = t; % Assuming measurement duration equals sampling interval
R = diag([1 / T, 1 / T]).^2;

% Kalman gain
K = Rxxpred * H.' / (H * Rxxpred * H.' + R);

% Update step
xpred = xpred + K * (y - H * xpred);
Rxxpred = (eye(2) - K * H) * Rxxpred;

% Output estimated state
x = xpred;

end
