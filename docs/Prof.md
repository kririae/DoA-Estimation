In MATLAB, function FFT will perform
$$
Y[k] = \sum_{j = 1}^{n}{X[j]}e^{-i 2\pi(j - 1)(k - 1)/n}
$$
Thus, in case that, we let the original signal $X[j] = e^{i 2 \pi f \cdot (j - 1) / f_s}$, $Y[k \rightarrow f_s]$ can be
$$
Y[k] = \sum_{j = 1}^{n}{e^{i 2 \pi (j - 1)\big[\frac{f}{f_s} - \frac{k - 1}{n}\big]}}
$$
The function's modulus can reach its peak when k equals to some number. 

Let $u = \frac{f}{f_s} - \frac{k - 1}{n}$, using Euler's formula to transform it into ($u \neq 0$)
$$
\mathrm{Re}\{ Y[k] \} = \sum_{j = 1}^n{\cos[ 2 \pi u \cdot (j - 1)]} = \frac{1}{2}(\csc(\pi \cdot u) \sin[(2n - 1)\pi \cdot u] + 1) \\
\mathrm{Im}\{ Y[k] \} = \sum_{j = 1}^n{\sin[ 2 \pi u \cdot (j - 1)]} = \frac{1}{2}\csc(\pi \cdot u)(\cos(\pi \cdot u) - \cos[(2n - 1)\pi \cdot u])
$$
(Ignore some detailed calculation)When u is not big enough, the modulus of $Y[k]$ is easy  to calculate, however, when $u \to 0$, the figure goes up quickly(considering the graph of $\csc$).

That's when $Y[k] = n$
$$
\frac{f}{f_s} = \frac{k - 1}{n} \Rightarrow f = \frac{(k - 1)f_s}{n}
$$
And, in FFT equation, let $f = f_c$, we have $(k - 1) = \dfrac{n f_c}{f_s}$, bring it and we get
$$
Y[\dfrac{n f_c}{f_s} + 1] =  n
$$
