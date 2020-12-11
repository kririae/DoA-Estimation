$\renewcommand{\ul}{\underline}$

# DOA Estimation

[TOC]

## BASIC

Multiple Signal Classification algorithm.

基础要求是，$P < J$，源数目必须小于麦克风数目。



首先，得弄清楚信号的表示形式，我们讲信号本身 $A(t)$ 缠绕在 

$$
s(t) = A(t) e^{j(\omega_c t + \phi(t))}
$$

$\phi(t)$ 是相位。根据 Narrowband 的性质，$A(t)$ 和 $\phi(t)$ 变化的速度都远低于 $e^{j\omega_ct}$，则可以看作
$$
A(t - \tau) \approx A(t) \; \text{and} \; \phi(t - \tau) \approx \phi(t)
$$
则若对 $s(t)$ 进行一次时移，则 
$$
s(t - \tau) = A(t - \tau) e^{j\omega_c(t - \tau)}e^{j\phi(t - \tau)} \approx A(t)e^{j\omega_c(t - \tau) \phi(t)} = e^{-j\omega_c\tau}\cdot s(t)
$$

即 Time delay ≈ Phase shift (for narrowband)



然后，对基础的麦克风进行建模

对于每个麦克风的位置，为 $\ul{p_i} = (-d_{st}+(i - 1)d, 0)^{T}$，对于我们的数据，$d = 2.5\times 10^{-2}m, d_{st} = -3.75 \times 10^{-2}m$

然后有一个与y轴的角度$\theta$，可以得出一个方向向量 $\ul{v} = (\sin \theta, \cos \theta)^{T}$

将这俩相乘，得到的是其对于 **中心点** 的 time delay，是一个关于$\theta$和$c$的函数，$\tau_i$可能为负数
$$
\tau_i = \dfrac{\ul{v}^{t}\ul{p_i}}{c} = (i - 1)\frac{d \sin\theta}{c} - \frac{d_{st} \sin \theta}{c}
$$
我们定义 $s[k, \ul{p_i}]$ 是第$i$个麦克风收到的离散时间信号，则
$$
s[k, \ul{p_i}] = s[k] \cdot e^{-j\omega\tau_i} = s[k]\cdot a_i(\omega, \theta)
$$
为解答为何将 $e^{-j\omega\tau_i}$ 定义为 $a_i(\omega, \theta)$ 的问题，不妨将其写为展开
$$
a_i(\omega, \theta) = e^{-j\omega\tau_i} = \cdots \\
= e^{-j\frac{2\pi}{\lambda}(i - 1) (d \sin\theta - d_{st} \sin \theta)}
$$
 而因为是对窄带音频的处理，$\omega$已知，$c$已知，则可写为 $a_i(\theta)$，即变量只有$\theta$



然后是正式的处理了，我们得到的每个麦克风的音频，处理出来，就是

$$
\ul{x}[k] = (x_1[k], x_2[k], x_3[k], \cdots, x_J[k])^t \\
\ul{n}[k] = (n_1[k], n_2[k], n_3[k], \cdots, n_J[k])^t \\
\ul{a}(\theta) = (a_1(\theta), a_2(\theta), a_3(\theta), \cdots, a_J(\theta))^t
$$

于是，运算得到
$$
\ul{x}[k] = \ul{a}(\theta)\cdot s[k] + \ul{n}[k]
$$
其中 $s[k]$ 是声源发出的，也是除开噪音期望得到的。而我们假设噪音与其无关。（实际上，在我们处理的情况中，$a_i(\theta)$ 都是相同的。

而对于多声源的，我们只需叠加之就好。
$$
x_i[k] = \sum_{p}a_i(\theta_p)\cdot s_p[k] + n_i[k]
$$
于是，$\ul{x}[k]$ 变复杂了，变为了
$$
\ul{x}[k] = A \cdot \ul{s}[k] + \ul{n}[k]
$$
其中，$A$ 为一个 $J \times P$ 的矩阵，而 $\ul{s}[k]$ 是不同信号源组成的列向量。

然后的然后，线性代数要开始了！



## MUSIC algorithm

>  信号的相关性

Wikipedia 上给出的定义，翻译到离散信号，就是
$$
R_x = \mathbb{E}\{\ul{x}[k]\ul{x}^h[k]\}
$$
其中 $\ul{x}^h[k]$ 是 $\ul{x}[k]$ 的共轭转置，$\mathbb{E}$ 是求期望，线性时不变。则，若将其展开（假设噪声的期望为 0）
$$
\mathbb{E}\{\ul{x}[k]\ul{x}^h[k]\} = \mathbb{E} \{ (A \cdot \ul{s}[k] + \ul{n}[k])(A \cdot \ul{s}[k] + \ul{n}[k])^h \} \Rightarrow A \mathbb{E}\{ \ul{s}[k]\ul{s}^h[k] \}A^h + \mathbb{E}\{ \ul{n}[k] \ul{n}^h[k]\}
$$
即，其中 $\mathbb{E}\{ \ul{s}[k]\ul{s}^h[k] \} I$ 为一个 Hermite 正定矩阵，记为 $R_s$，根据其性质，有
$$
rank(R_s) = rank(A) = rank(A R_s A^h) = P_{source}
$$
而矩阵的秩等于其非零特征值个数，则 $A R_s A^h$ 含有 $J - P$ 个零特征值（所以我最开始说 $J > P$）。

令 $\ul{u}_i$ 作为 0 对应的特征向量，则 $A R_s A^h \ul{u}_i = \ul{0} \Rightarrow \ul{u}_i^h A R_s A^h \ul{u}_i = \ul{0}$，于是 $(A^h\ul{u}_i)^h R_s (A^h \ul{u}_i) = \ul{0}$，即
$$
A^h\ul{u}_i = \ul{0}
$$
对该公式进行变形可得，$\ul{a}^h(\theta_p)\ul{u}_i = 0$，说明这 $J - P$ 个零特征向量与声音的相位移动向量垂直。

于是，我们可以通过遍历$\theta$，来得到 $\sum_{i}\ul{a}^h(\theta_p)\ul{u}_i = 0$ 的 $P$ 个角度，但是实际情况不可能如此顺利，于是我们定义：
$$
P_{music}(\theta) = \dfrac{1}{\sum_{i = 1}^{J - P}\big|\ul{a}^h(\theta_p)\ul{u}_i \big|^2}
$$
画出其关于$\theta$的函数，最大点则是波达方向。