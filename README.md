# Dynamic Causal Modeling of Low-Density Resting-State EEG in Long-Term Meditation Practitioners

**MATLAB code and resting-state data for Dynamic Causal Modeling (DCM) and PEB analysis of resting-state EEG in long-term meditation practitioners (focus on DMN & SN).**

This repository contains the EEG resting-state data and the Matlab source code used for the effective connectivity analyses presented in the research paper:

> **Dynamic Causal Modeling of Low-Density Resting-State EEG in Long-Term Meditation Practitioners**
> *Rho, G., et al.*

The shared code implements a hierarchical **Dynamic Causal Modeling (DCM)** and **Parametric Empirical Bayes (PEB)** analysis to investigate how long-term meditation practice modulates extrinsic connectivity within the **Default Mode Network (DMN)** and the **Salience Network (SN)**.

## Prerequisites

To run these scripts, the following are required:

1. **MATLAB** (tested on version **v2021b**).
2. **SPM12 (Statistical Parametric Mapping)**:
   * **Important:** The analysis was validated using **SPM12 version v7771**. We strongly recommend using this specific version to ensure exact reproducibility of the results.
3. **Input Data**:
   * Anonymized pre-processed EEG data must be located in a folder named `spm_datasets_anon`.
   * The data consists of `.mat` and `.dat` pair of files (SPM format) corresponding to **5 minutes of resting-state recordings** using a low-density 19-channels EEG cap.

## Project Structure

The scripts assume the following directory structure. Please ensure your local environment matches this layout:

```text
Project_Root/
├── spm_datasets_anon/       # Input: Pre-processed single-subject .mat files
├── scripts/                 # Source code (this repository)
│   ├── fit_GMC_models_pipeline.m
│   ├── DCM_CSD_defineModels_DMN.m
│   ├── DCM_CSD_defineModels_SN.m
│   ├── fit_DCMs_DMN.m
│   ├── fit_DCMs_SN.m
│   ├── reFit_DCMs_DMN.m
│   ├── reFit_DCMs_SN.m
│   ├── PEBanalysis_DMN.m
│   └── PEBanalysis_SN.m
└── models/                  # Output: Generated automatically during analysis
    ├── DMN/
    └── SN/
```

## Usage & Workflow

The analysis is performed in a hierarchical manner, moving from single-subject model inversion to group-level inference (refer to the paper for theoretical details).

### 1. Level 1: Single-Subject DCM Definition & Fitting

The master script `fit_GMC_models_pipeline.m` orchestrates the entire first level of analysis for both networks (DMN and SN).

This script sequentially executes:

1. **Model Definition (`DCM_CSD_defineModels_*.m`):** Creates the DCM structures, defines the spatial models, and organizes subjects into Group Causal Modelling (GCM) files.
2. **Initial Fitting (`fit_DCMs_*.m`):** Inverts the models using Cross-Spectral Densities (CSDs) on the resting-state data.
3. **Re-Fitting (`reFit_DCMs_*.m`):** Re-inverts the models using the posterior estimates from the initial fit as priors (empirical Bayes). This step ensures robust convergence and mitigates the local minima problem of the negative free-energy cost function.

### 2. Level 2 & 3: Group Analysis (PEB)

Once the single-subject models are fitted (saved in `models/*/fitted_adjusted`), the group-level analysis is performed using:
* `PEBanalysis_DMN.m`
* `PEBanalysis_SN.m`

These scripts handle the hierarchical modeling described in the paper. You can switch between the analysis levels by modifying the flags at the beginning of the scripts:

#### Level 2: Temporal Fluctuations
Set `fitPEBs = 1`.
This step fits a PEB model over the single-subject windows to estimate the effect of temporal fluctuations on connectivity within the resting-state session.

#### Level 3: Effect of Meditation Experience
Set `fitPEBofPEBs = 1`.
This step takes the results from Level 2 (the single-subject PEBs) and fits a "PEB of PEBs". It infers how group-level factors (specifically, the level of meditation experience) modulate the parameters estimated at the lower level (i.e., the baseline connectivity strength and its temporal fluctuations).

## Reference

If you use this code, the methodology, or the resting-state datasets in your research, please cite the original paper:

> Rho, G., Bossi, F., Norbu, N., Kechok, J., Sherab, N., Soepa, J., Thakchoe, J., Greco, A., Scilingo, E. P., Vanello, N., Neri, B., & Callara, A. L. "Dynamic Causal Modeling of Low-Density Resting-State EEG in Long-Term Meditation Practitioners".
