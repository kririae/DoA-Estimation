clear all; close all;

% Generate original data
theta = [-60 40]*pi/180; % The position of the source
J = 4; 
dx = 3.4*10^-2; 
dy = 0;
c = 340; 
Index = linspace(0,J-1,J);
p = (-(J-1)/2 + Index.') * [dx dy]; % Position vector
v = [sin(theta); cos(theta)];

fs = 16000;
t = 0:1/fs:3-1/fs;
Frame = fs*3;
y = chirp(t, 1200, 3, 1200); % Sweep frequency
f = (-Frame/2:Frame/2-1)*fs/Frame;
% plot(f, abs(fftshift(fft(y))/Frame));

figure;
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
freq = (I - 1)*fs/length(idx);
Freq(end+1) = freq;

% init the complex signal
S(1, idx) = abs(y(idx)).*exp(1i*2*pi*freq*idx/fs);
S(2, idx) = S(1, idx);

a_theta = exp(-1i*2*pi*freq*(p*v)./c); % 4, 181 complex
X = a_theta*S;
% without noise

end

X = X.'; % Not $$\overline{X}^T$$
save("data\gen.mat", "X", "fs");
% plot(real(X(:, 1)));
figure;
plot((-Frame/2:Frame/2-1)*fs/Frame, abs(fftshift(fft(real(X(:, 1))))/Frame));

function [ st_index, ed_index, fn ] = separate(len, inc, Frame)
    fn = (Frame-len)/inc + 1;
    st_index = (0:(fn-1))*inc + 1;
    ed_index = (0:(fn-1))*inc + len;
end