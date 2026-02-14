# 🎯 FMCW Radar Target Tracking – Kalman Filter (Range & Radial Velocity)

This module implements a **Hidden Markov Model (state-space model)** and a **Kalman filter** to track a pedestrian using measurements from an **FMCW radar**.

The tracked state consists of **range** and **radial velocity**, while the observations are the detected **frequency shifts** from the **down-chirp** and **up-chirp**.

---

## 🎯 Objective

- Design a **kinematic model** (state transition + process noise covariance)
- Design a **measurement model** (observation matrix + observation noise covariance)
- Implement a full **Kalman filter loop** (prediction + update) in MATLAB
- Evaluate how assumed **typical pedestrian acceleration** affects tracking quality

---

## 🧩 State-Space Model

### State Vector

The state captures the target’s motion along the radar line-of-sight:

\[
\mathbf{x}_k = \begin{bmatrix} r_k \\ v_k \end{bmatrix}
\]

where:
- \(r_k\) is the range (m)
- \(v_k\) is the radial velocity (m/s)

---

## 🚶 Kinematic Model (Process Model)

A **piecewise constant acceleration** assumption is used.

This is commonly modeled as a constant-velocity transition with acceleration treated as process noise:

\[
\mathbf{x}_{k+1} = \mathbf{F}\mathbf{x}_k + \mathbf{w}_k
\]

- \(\mathbf{F}\) is the state transition matrix
- \(\mathbf{w}_k\) is process noise representing unmodeled acceleration

The assumed **typical pedestrian acceleration** directly influences the process noise covariance \(\mathbf{Q}\):

- **Higher assumed acceleration** → larger \(\mathbf{Q}\) → filter reacts faster but is noisier
- **Lower assumed acceleration** → smaller \(\mathbf{Q}\) → smoother tracking but may lag behind maneuvers

---

## 📡 Measurement Model (Observation Model)

Each iteration uses frequency shift measurements from:
- one **down-chirp**
- one **up-chirp**

Observation vector:

\[
\mathbf{z}_k = \begin{bmatrix} f_{\text{down},k} \\ f_{\text{up},k} \end{bmatrix}
\]

Measurement equation:

\[
\mathbf{z}_k = \mathbf{H}\mathbf{x}_k + \mathbf{v}_k
\]

- \(\mathbf{H}\) maps range/velocity to the measured chirp frequency shifts
- \(\mathbf{v}_k\) is observation noise with covariance \(\mathbf{R}\)

**Observation noise variance is assumed inversely proportional to measurement duration**, i.e. longer integration time improves frequency estimation quality.

---

## 🔁 Kalman Filter Implementation

The Kalman filter step is executed once per iteration:

1. **Prediction**
   - Predict state \(\hat{\mathbf{x}}_{k|k-1}\)
   - Predict covariance \(\mathbf{P}_{k|k-1}\)

2. **Update (Correction)**
   - Compute Kalman gain \(\mathbf{K}_k\)
   - Update state \(\hat{\mathbf{x}}_{k|k}\)
   - Update covariance \(\mathbf{P}_{k|k}\)

---

## 📈 Results

<p align="center">
  <img src="Results.png" width="800">
</p>

<p align="center">
  <em>Figure 1: Exemplary trajectories without and with tracking.</em>
</p>

The Kalman filter reduces measurement noise and stabilizes the estimated trajectory compared to raw (unfiltered) detections.

---

## ▶ How to Run

Run the main script:

```matlab
tracking
