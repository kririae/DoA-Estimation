# DOA Estimation

[TOC]

## MUSIC Algorithm

Multiple Signal Classification algorithm.

基础要求是，$P < J$，源数目必须小于麦克风数目

首先，对基础的麦克风进行建模

根据窄带的特性，

对于每个麦克风的位置，为 $\vec{p_i} = (-d_{st}+(i - 1)d, 0)^{T}$，对于我们的数据，$d = 2.5\times 10^{-2}m, d_{st} = -3.75 \times 10^{-2}m$

