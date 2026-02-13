# 📡 Radio Navigation & Radar Systems – MATLAB Portfolio

This repository contains MATLAB implementations of fundamental radar signal processing and radio navigation algorithms.

The project covers radar waveform modeling, time-based localization, nonlinear estimation methods, and Kalman filter-based target tracking.  

All algorithms were implemented from first principles using matrix-based numerical methods.

---

## 🧭 Repository Structure

The project is organized into the following modules:

### 📡 CWRadar
Continuous-Wave radar simulation for Doppler-based velocity estimation.

### 📡 FMCWRadar
Frequency-Modulated Continuous-Wave radar for range estimation using beat frequency analysis.

### 📍 TOA
Time-of-Arrival localization using:
- Analytical solutions
- Least squares estimation
- Gauss-Newton optimization

### 📍 TDOA
Time-Difference-of-Arrival localization including:
- Hyperbolic positioning
- Nonlinear least squares
- Iterative Gauss-Newton solver

### 🎯 Tracking
Radar-based target tracking using a discrete-time Kalman filter with a constant velocity motion model.

Each folder contains its own detailed documentation and implementation description.

---

## 🧠 Concepts Covered

- Radar signal modeling
- Doppler processing
- FMCW range estimation
- Hyperbolic positioning
- Nonlinear optimization (Gauss-Newton)
- Linear least squares
- State-space modeling
- Kalman filtering
- Statistical estimation theory

---

## 🛠 Technologies

- MATLAB
- Matrix-based numerical computation
- Simulation-based validation

---

## ▶ How to Use

Navigate into a module folder and run the main simulation script in MATLAB.

Example:

```matlab
tracking
