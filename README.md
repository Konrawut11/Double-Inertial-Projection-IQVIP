# Double Inertial Projection Method for IQVIP

This repository contains the MATLAB source code for the numerical experiments presented in our research on the **Double Inertial Projection Method** for solving **Inverse Quasi-Variational Inequality Problems (IQVIP)**.

## Description
The provided scripts reproduce the comparative numerical results for Example 1 and Example 2, demonstrating the efficiency of the proposed **Algorithm 1** against existing state-of-the-art methods.

## Directory Structure
*   **/Example_1**: Contains the implementation for Example 1, comparing Algorithm 1 with TV Algorithm 5.
    *   **Main script:** `DriverEx1.m`
    *   **Parameters:** $L = 2.2$, $\mu = 2$, and $\gamma = 2$.
*   **/Example_2**: Contains the implementation for Example 2, comparing Algorithm 1 with HTV Algorithm 25 (Hai et al., 2026).
    *   **Main script:** `DriverEx2.m`
    *   **Parameters:** $L = 2.31$, $\mu = 2$, and $\gamma = 2$.

## Requirements
*   MATLAB (R2020a or later recommended)
*   No additional toolboxes are required.

## How to Run
1. Download or clone this repository.
2. Open MATLAB and navigate to the folder of the example you wish to test.
3. Run the respective main script:
    *   For Example 1, run `DriverEx1.m`
    *   For Example 2, run `DriverEx2.m`
4. The output will display the **number of iterations** and **CPU time** for various initial points as presented in the manuscript.

## Parameters and Verification
The parameters in these scripts have been configured to satisfy the convergence conditions of the theorems presented in the paper:
*   **Example 1:** The matrix $M$ yields eigenvalues $\lambda_1 = 2$ and $\lambda_2 = 2.2$, resulting in $L = 2.2$ and $\mu = 2$.
*   **Example 2:** The symmetric part of matrix $M$ is $\text{diag}(2.3, 2)$, ensuring $\mu = 2$. The spectral norm is approximately $2.3043$, with $L$ taken as $2.31$.
