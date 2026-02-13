% FMCW radar
%
% This program runs in an endless loop and is terminated by 
% closing the figure window or pressing a key.

close all;
clear;

c0=299792458; % speed of light
f0=24.125e9; % center frequency

% search range of absolute frequency shifts of targets
fmin=500; % minimum frequency shift
fmax=2000; % maximum frequency shift

% ENTER YOUR SETUP HERE
file='scenario15.h5'; % FILE NAME FOR RECORDING AND PLAYBACK OF MEASUREMENT DATA
mode='fmcwfile'; % FOR AVAILABLE MODES SEE STARTSTREAMING.M

% create figure window
keypressed=false;
figure('WindowKeyPressFcn',@terminate,'DeleteFcn',@terminate);

% start streaming of radar sensor data
sensor=startstreaming(mode,file);
fs=sensor.fs; % sampling rate
k=sensor.k; % sweep rate
t=sensor.L*2/fs; % duration of one triangle
fmax=min(fs/2,fmax); % frequency range

% Hann window
hann_window = hann(sensor.L);

% Frequency axis for FFT
freqs = linspace(-fs / 2, fs / 2, sensor.L * 2);

% read complex raw adc values from sensor
first=true;
radc=getframe(sensor); % first column down-chirp, second column up-chirp
while ~keypressed&~isempty(radc)
    radc=radc-mean(radc,1); % cancel DC offsets
%     radc=mti(radc); % ACTIVATE SINGLE CANCELLER HERE
    L=size(radc,1); % samples in time domain, should be equal to sensor.L

    % ADD YOUR CODE HERE
    %freqs = linspace(-fs / 2, fs / 2, sensor.L * 2);

    % Apply Hann window and compute FFT
    downchirp = radc(:, 1) .* hann_window;
    upchirp = radc(:, 2) .* hann_window;

    % Compute magnitude squared spectra
    spectrum_down = abs(fftshift(fft(downchirp, sensor.L * 2))).^2;
    spectrum_up = abs(fftshift(fft(upchirp, sensor.L * 2))).^2;

    % Normalize spectra by their respective maximum values
    spectrum_down = spectrum_down / max(spectrum_down);
    spectrum_up = spectrum_up / max(spectrum_up);

    % Mask unwanted frequencies
    %mask = (freqs < fmin | freqs > fmax); % Mask low and high frequencies
    mask = ( abs(freqs) < fmin ) | ( abs(freqs) > fmax );
    spectrum_down(mask) = 0;
    spectrum_up(mask) = 0;

    % Plot spectra
    subplot(2, 1, 1);
    plot(freqs, spectrum_down);
    title('Down-Chirp Spectrum');
    xlabel('Frequency (Hz)');
    ylabel('Normalized Signal Power');
    xlim([-fmax fmax])
    grid on;

    subplot(2, 1, 2);
    plot(freqs, spectrum_up);
    title('Up-Chirp Spectrum');
    xlabel('Frequency (Hz)');
    ylabel('Normalized signal power');
    xlim([-fmax fmax])
    grid on;

    % Detect target frequency shifts
    [~, idx_down] = max(spectrum_down);
    [~, idx_up] = max(spectrum_up);

    fd = freqs(idx_down); % Down-chirp frequency shift
    fu = freqs(idx_up); % Up-chirp frequency shift

    % Compute range and velocity
    range = (fd - fu) * c0 / (4 * k);
    velocity = (fu + fd) * c0 / (2 * f0);

    % Display results
    %disp(['Range: ', num2str(range, '%.2f'), ' m']);
    %disp(['Velocity: ', num2str(velocity, '%.2f'), ' m/s']);

    drawnow;

    % Read next frame
   
    radc=getframe(sensor); % read complex raw adc values from sensor
end

% stop streaming of radar sensor data
stopstreaming(sensor);

function terminate(src,event)
   assignin('base','keypressed',true);
end
