# SI100B DOA Project

---

[TOC]

---

## Module 1: Narrow-band DoA estimation

We load `Observations_nb.mat` from filesystem and initialize variables `X, fs`

Considering the input figures are complex, which comes from:
$$
x_i[k] = \sum_{p}a_i(\theta_p)\cdot s_p[k] + n_i[k]
$$
Decompose it into two parts:
$$
x_i[k] = O[k]e^{j\omega k}
$$
However, we don't know $\omega$, but performing $\sum_{k = 1}^{5000}O[k]e^{j\omega k}$ can get $FFT(\omega)$'s value.