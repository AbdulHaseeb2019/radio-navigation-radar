# 🎯 FMCW Radar Target Tracking – Kalman Filter

This module implements range–velocity tracking of a pedestrian using a discrete-time Kalman filter.

The state-space model is derived from FMCW radar measurement equations and a constant-velocity motion assumption.

---

## 🧩 State Vector

The state consists of:

x = [ r
      v ]

where:
- r = range (m)
- v = radial velocity (m/s)

---

## 🚶 Kinematic Model (Process Model)

A constant-velocity model is assumed, with acceleration modeled as process noise.

Discrete-time state transition:

x_{k+1} = F x_k + w_k

State transition matrix:

F = [1  t
     0  1]

Acceleration is not explicitly included in the state.  
Instead, it is modeled as zero-mean white noise with variance σ_a².

The resulting process noise covariance:

Q = σ_a² * [ t^4/4   t^3/2
             t^3/2   t^2 ]

This corresponds to the standard continuous white acceleration model.

### Effect of σ_a (Acceleration Assumption)

- Larger σ_a → larger Q → faster response to motion changes, but noisier estimates  
- Smaller σ_a → smoother estimates, but increased lag during maneuvers  

In this implementation, σ_a is treated as a tuning parameter.

---

## 📡 Measurement Model

The measurement vector consists of frequency shifts from:

- one down-chirp
- one up-chirp

z = [ f_down
      f_up ]

The observation equation:

z = H x + v

Observation matrix:

H = [  2k/c0   -2f0/c0
      -2k/c0   -2f0/c0 ]

where:
- k = FMCW sweep rate
- f0 = carrier frequency
- c0 = speed of light

---

## 🔊 Measurement Noise

Measurement noise covariance:

R = diag([1/T², 1/T²])

where T is the measurement duration.

Thus, longer integration time reduces frequency estimation variance.

---

## 🔁 Kalman Filter Implementation

For each iteration:

### 1) Prediction

x_pred = F * x_prev  
P_pred = F * P_prev * F' + Q  

### 2) Update

K = P_pred * H' * inv(H * P_pred * H' + R)  
x_est = x_pred + K * (z - H * x_pred)  
P = (I - K * H) * P_pred  

The updated state becomes the prediction for the next iteration.

---

## 📈 Results

<p align="center">
  <img src="Results.png" width="800">
</p>

<p align="center">
  <em>Figure 1: Exemplary trajectories without and with tracking.</em>
</p>

The Kalman filter significantly reduces noise in the range and velocity estimates and provides a smooth, physically consistent trajectory compared to raw frequency-based estimates.

---

## ▶ How to Run

Run:

tracking

Tested with:
- scenario15.h5

---

## 📚 Concepts Demonstrated

- State-space modeling
- Continuous white acceleration process model
- FMCW measurement linearization
- Kalman filtering
- Noise covariance tuning
- Radar-based target tracking
