clear all; close all;

% Generate original data
theta = [-30 60]; % The position of the source
J = 4; 
dx = 3.4*10^-2; 
c = 340; 
Index = linspace(0,J-1,J);
p = (-(J-1)/2 + Index.') * [dx]; % Position vector
v = [sin(theta*pi/180); cos(theta*pi/180)];

fs = 16000;
t = 0:1/fs:3-1/fs;
Frame = fs*3;
y = chirp(t, 1200, 3, 1200); % Sweep frequency
f = (-Frame/2:Frame/2-1)*fs/Frame;
% plot(f, abs(fftshift(fft(y))/Frame));
stft(y, fs, 'Window', hamming(256,'periodic'), 'OverlapLength', 236);

len = 256;
inc = 256;
nfft = len;
[st_idx, ed_idx, fn] = separate(len, inc, Frame);
S = zeros(2, Frame); % The S matrix(sensors)
Freq = []; % perform STFT
X = zeros(4, Frame);

for i=1:fn
    idx = st_idx(i):ed_idx(i);
    Y = fft(y(idx));
    Y = Y(1:end/2-1);
    [~, I] = max(abs(Y));
    freq = (I - 1)*fs/Frame;
    Freq(end+1) = freq;
    
    for j_=idx
        % s[t] = y[t]*e^{j \omega t}
        t = j_/fs;
        S(:, j_) = y(j_)*exp(j*2*pi*freq*t);
    end
   
    a_theta = exp(-1j*2*pi*freq*(p.'*v)./c); % 4, 181 complex
    X = a_theta*S;
    % without noise
end

X = X.';
save("gen.mat", "X", "fs");

function [ st_index, ed_index, fn ] = separate(len, inc, Frame)
    fn = (Frame-len)/inc + 1;
    st_index = (0:(fn-1))*inc + 1;
    ed_index = (0:(fn-1))*inc + len;
end