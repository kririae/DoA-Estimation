# STFT(Short-time Fourier Transform)

> 用于处理宽带信号

实际思路倒是很简单，将波形通过[**窗函数**](https://zh.wikipedia.org/wiki/窗函数)进行切片，切片后对每一段分别进行傅里叶变换，然后重复 task1 的分析。

至于如何选择窗函数是个难题，因为切片后的结果会导致FFT结果出现误差，所以有各种窗函数供选择。

如何选择窗函数这个，我还真的不太能做（躺，所以我选择最朴素的切片方式。

STFT 的过程中，存在 overlap 这一个问题。我们可以通过 overlap，即重合，来消除部分影响。

查阅资料，可以得到，首先规定这么几个变量。

- 每帧的长度：$len$
- 每帧的移动：$inc$
- 重叠部分：$overlap$

计算可以得到，对于第$i$帧，其起始位置为 $(i - 1) \cdot inc + 1$

而其结束位置为 $(i - 1) \cdot inc+ len$

求总帧数可以用一个方程，$(fn - 1) \cdot inc + len = Frame$

计算得到 $fn = \dfrac{Frame - len}{inc} + 1$，一定为整数

$overlap$，先忽略掉。

还需要一个 $nfft$，即 FFT 运行的长度，而 $nfft$ 不一定和窗长相同。

FFT 的分辨率为 $\dfrac{fs}{Frame}$，则若 $nfft$ 过小，会导致 $fft$ 的分辨率不足。



查阅 Wikipedia 发现，根据海森堡不确定性原理，窗函数的长度暂且定在 $256$，$inc$ 定在 128，尝试实现一次通用的代码。