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
x_i[k] = O[k]e^{j\omega_{fs}k}
$$
The sample's length is 0.5s, $\omega_{fs} = 2\pi fs$, and $e^{j\omega_{fs}k} = \cos (\omega_{fs}k) + i \sin (\omega_{fs}k) $. So when we get $a + bi$ from the file, 
$$
O[k] = \frac{a}{\cos(\omega_{fs}\cdot k)} = \frac{b}{\sin(\omega_{fs}\cdot k)}
$$
