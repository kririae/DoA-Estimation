clear all;
close all;

NSOURCE = 2;
fs = 16000;

samplingTime = 0.5; % seconds
calcRate = 1/samplingTime;
disp(['Calculation rate is: ', num2str(calcRate)]);

devReader = audioDeviceReader( ...
    'Driver', 'DirectSound', ...
    'SamplesPerFrame', fs*samplingTime, ...
    'SampleRate', fs, ...
    'NumChannels', 4, ...
    'BitDepth', '16-bit integer', ...
    'Device', '麦克风 (USB YDB01 Audio Effect)', ...
    'ChannelMappingSource', 'Property', ...
    'ChannelMapping', [2 1 4 3] ...
);
setup(devReader);

disp("Start collecting...")

tic
while toc < 20
X = hilbert(devReader());

[Frame, ~] = size(X);
len = 2048;
inc = 128;
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
stride = 1;
theta = -90:stride:90;
v = [sin(theta*pi/180); -cos(theta*pi/180)];

P = zeros([180/stride+1 1]); % -90:stride:90

fr = [0 6000]*nfft/fs+1; % range of frequency (to add weight)

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
Un = V(:, Idx(1:J-NSOURCE)); % noise subspace
P_sm = diag(a_theta'*(Un*Un')*a_theta);
P = P + abs(P_sm);

end

P = 1./P;

% Find the local maximum;
[pks, locs] = findpeaks(abs(P));
[pks, Idx] = sort(pks);
pks = fliplr(pks);
Idx = fliplr(Idx);
[isize, ~] = size(Idx);
if isize >= 2
    res = locs(Idx(1:2));
    source_1 = theta(res(1));
    source_2 = theta(res(2));
elseif isize == 1
    res = locs(Idx(1));
    source_1 = theta(res(1));
    source_2 = -1;
else
    source_1 = -1;
    source_2 = -1;
end

tmp = [source_1 source_2];
tmp = sort(tmp);
source_1 = tmp(1);
source_2 = tmp(2);

disp(['The first source with MUSIC is: ',num2str(source_1),' deg']);
disp(['The second source with MUSIC is: ',num2str(source_2),' deg']);

end

release(devReader);

function [ st_index, ed_index, fn ] = separate(len, inc, Frame)
  fn = floor((Frame-len)/inc + 1);
  st_index = (0:(fn-1))*inc + 1;
  ed_index = (0:(fn-1))*inc + len;
end