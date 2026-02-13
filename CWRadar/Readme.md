# 📡 Continuous Wave (CW) Radar – Doppler Processing

This module implements Doppler frequency estimation using a Continuous Wave (CW) radar model.

The objective is to extract a target’s radial velocity from sampled complex baseband radar data using spectral analysis in MATLAB.

---

## 🎯 Problem Description

After stretch processing, the received complex radar signal is sampled in time.  
The Doppler frequency shift caused by target motion is estimated using the discrete Fourier transform (FFT).

The estimated Doppler frequency is then converted into target velocity.

---

## 🔍 Signal Processing Steps

1. Plot complex time-domain signal (real & imaginary parts)
2. Compute FFT of sampled data
3. Apply zero-padding (oversampling ratio = 8)
4. Apply `fftshift` for spectrum centering
5. Compute magnitude-squared spectrum
6. Identify Doppler peak
7. Convert Doppler frequency to velocity

---

## 🧠 Key DSP Concepts

### Spectral Leakage

Since the FFT operates on a finite number of samples, the signal is effectively multiplied by a rectangular window.

This causes energy spreading across frequency bins if the signal frequency does not align exactly with a DFT bin.

---

### Zero Padding & Frequency Resolution

Zero-padding (oversampling factor 8) increases the density of frequency samples.

Important:
- It does **not** increase true resolution
- It improves interpolation of the spectral peak
- It makes Doppler estimation more precise visually

---

### Periodic Spectrum

Sampling in time leads to periodicity in the frequency domain.

The discrete spectrum repeats with period equal to the sampling frequency.

---

### Effect of `fftshift`

`fftshift` rearranges FFT output so that:

- Zero frequency appears in the center
- Negative frequencies are on the left
- Positive frequencies are on the right

For even-length FFT:
- Half of the samples correspond to negative frequencies
- Half correspond to positive frequencies

Frequency bins are located at:

f = k * (Fs / N)

where:
- Fs = sampling frequency
- N = FFT length (after zero padding)

---

## 📈 Results

Example magnitude-squared spectrum:

![CW Radar Spectrum](Results.png)

Observations:

- A strong peak appears at the Doppler frequency.
- A peak at zero frequency exists due to DC components or residual stationary clutter.
- A small mirrored peak appears at the negative Doppler frequency due to spectral symmetry.

---

## 🚗 Doppler to Velocity Conversion

The Doppler frequency is related to radial velocity by:

v = (f_D * λ) / 2

where:
- f_D = Doppler frequency
- λ = radar wavelength

Manual verification of measured files:
- DopplerTarget10kmhbackward.h5
- train.h5

Estimated velocities matched expected motion within measurement tolerance.

---

## 🛠 Implementation

Main script:
