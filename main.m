clear all;
close all;

NSOURCE = 2;
fs = 16000;
[y1, ~] = audioread("01-音轨.wav");
[y2, ~] = audioread("02-音轨.wav");
[y3, ~] = audioread("03-音轨.wav");
[y4, ~] = audioread("04-音轨.wav");
[Frame, ~] = size(y1);
X = zeros(Frame, 4);
X(:, 1) = hilbert(y1);
X(:, 2) = hilbert(y2);
X(:, 3) = hilbert(y3);
X(:, 4) = hilbert(y4);

len = 2048;
inc = 2048;
nfft = len; % The smallest 2^n \ge len, to optimize FFT
[st_idx, ed_idx, fn] = separate(len, inc, Frame);

STFT = zeros([fn nfft 4]);
for i=1:fn
  STFT(i, :, :) = fft(X(st_idx(i):ed_idx(i), :), nfft);
end

% Perform MUSIC algorithm

% Initialize data
J = 4;
dx = 2.5*10^-2;
dy = 0;
c = 340; % Velocity of sound
Index = linspace(0,J-NSOURCE,J);
p = (-(J-1)/2 + Index.') * [dx dy]; % Position vector
stride = 0.5;
theta = -90:stride:90;
v = [sin(theta*pi/180); -cos(theta*pi/180)];

P = zeros([180/stride+1 1]); % -90:stride:90

fr = [20 6000]*nfft/fs+1; % range of frequency (to add weight)

% for i=1:ceil(nfft/2)
for i=floor(fr(1)):ceil(fr(2))
    
% P: index -> f
% $$\frac{(k - 1)f_s}{n}$$
f_c = (i - 1)*fs/nfft;
X_ = squeeze(STFT(:, i, :));

[Frame_, ~] = size(X_);

R_x = X_'*X_/Frame_;
a_theta = exp(-1i*2*pi*f_c*(p*v)./c); % steering vector

[V, D] = eig(R_x);
eig_val = diag(D);
[~, Idx] = sort(eig_val);
Un = V(:, Idx(1:J-1)); % noise subspace
P_sm = diag(a_theta'*(Un*Un')*a_theta);
P = P + P_sm;

end

P = 1./P;

figure;
linspec = {'b-','LineWidth',2};
plot(theta, 10*log10(abs(P)), linspec{:});
title('MUSIC pseudo power spectrum')
xlabel('Angle in [degrees]');
ylabel('Power spectrum in [dB]');
xlim([-90,90])

% Find the local maximum;
P_middle = abs(P(2:end-1));
P_front = abs(P(1:end-2));
P_back = abs(P(3:end));
logic_front = (P_middle - P_front)>0;
logic_back = (P_middle - P_back)>0;
logic = logic_front & logic_back;
P_middle(~logic) = min(P_middle);
P_local = [abs(P(1));P_middle;abs(P(end))];
[~,doa_Idx] = maxk(P_local, 2);
doa = theta(doa_Idx);
[~,minIdx] = min(abs(doa));
source_1 = doa(minIdx);
[~,maxIdx] = max(abs(doa));
source_2 = doa(maxIdx);

disp(['The first source with MUSIC is: ',num2str(source_1),' deg']);
disp(['The second source with MUSIC is: ',num2str(source_2),' deg']);

function [ st_index, ed_index, fn ] = separate(len, inc, Frame)
  fn = floor((Frame-len)/inc + 1);
  st_index = (0:(fn-1))*inc + 1;
  ed_index = (0:(fn-1))*inc + len;
end