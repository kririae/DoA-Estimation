clear all; close all;

% Generate original data
theta = [-70 40]*pi/180; % The position of the source
J = 4; 
dx = 3.4*10^-2; 
dy = 0;
c = 340; 
Index = linspace(0,J-1,J);
p = (-(J-1)/2 + Index.') * [dx dy]; % Position vector
v = [sin(theta); -cos(theta)];

fs = 16000;
t = 0:1/fs:3-1/fs;
Frame = fs*3;
f = (-Frame/2:Frame/2-1)*fs/Frame;
% plot(f, abs(fftshift(fft(y))/Frame));

S = zeros(2, Frame); % The S matrix(sensors)
X = zeros(4, Frame);

% freq = (I - 1)*fs/length(idx);
freq = 1200;

% init the complex signal
S(1, :) = 1*exp(1i*2*pi*freq*(1:Frame)/fs);
S(2, :) = S(1, :);

figure;
stft(S(1, :), fs, 'Window', hamming(256,'periodic'), 'OverlapLength', 236);

a_theta = exp(-1i*2*pi*freq*(p*v)/c);
X = a_theta*S;

X = X.'; % Not $$\overline{X}^T$$
save("data\gen.mat", "X", "fs");
% plot(real(X(:, 1)));
figure;
plot((-Frame/2:Frame/2-1)*fs/Frame, abs(fftshift(fft(X(:, 1)))/Frame));