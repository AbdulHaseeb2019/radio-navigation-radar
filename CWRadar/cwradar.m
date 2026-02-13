% Doppler radar
%
% This program runs in an endless loop and is terminated by 
% closing the figure window or pressing a key.

close all;
clear;

c0=299792458; % speed of light
f0=24.125e9; % center frequency

% range of frequency shifts shown in the figure
fmax=5000; % maximum frequency shift

% ENTER YOUR SETUP HERE
file='train.h5'; % FILE NAME FOR RECORDING AND PLAYBACK OF MEASUREMENT DATA
mode='cwfile'; % FOR AVAILABLE MODES SEE STARTSTREAMING.M

% create figure window
keypressed=false;
figure('WindowKeyPressFcn',@terminate,'DeleteFcn',@terminate);

% start streaming of radar sensor data
sensor=startstreaming(mode,file);
fs=sensor.fs; % sampling rate
fmax=min(fs/2,fmax); % frequency range

% read complex raw ADC values from sensor
radc = getframe(sensor);

% Time vector
t = (0:numel(radc)-1) / fs;

% read complex raw adc values from sensor
first=true;
radc=getframe(sensor);
while ~keypressed&~isempty(radc)
    radc=radc-mean(radc); % cancel DC offset
    radc=radc/max(abs(radc)); % normalization
    L=numel(radc); % samples in time domain, should be equal to sensor.L

    % ADD YOUR CODE HERE

    % Plot raw time-domain data
    subplot(3, 1, 1);
    plot(t, real(radc), 'b', t, imag(radc), 'r');
    title('Raw Time-Domain Signal');
    xlabel('Time (s)');
    ylabel('Amplitude');
    legend('Real Part', 'Imaginary Part');
    grid on;

    % Compute FFT with oversampling ratio of 8
    oversampling = 8;
    N = L * oversampling; % FFT size
    freqs = linspace(-fs / 2, fs / 2, N); % Frequency axis
    spectrum = abs(fftshift(fft(radc, N))).^2; % Magnitude squared spectrum

    % Normalize spectrum power
    %P_total = sum(spectrum); % Total power
    spectrum_normalized = spectrum / max(spectrum); % Normalize

    % Plot magnitude squared spectrum
    subplot(3, 1, 2:3);
    plot(freqs, spectrum_normalized);
    title('Normalized Magnitude Squared Spectrum');
    xlabel('Frequency (Hz)');
    ylabel('Normalized Power');
    xlim([-fmax fmax]);
    grid on;

    drawnow;

    % Read next frame
    radc=getframe(sensor); % read complex raw adc values from sensor
end

% stop streaming of radar sensor data
stopstreaming(sensor);

function terminate(src,event)
   assignin('base','keypressed',true);
end
