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
P_middle = abs(P_sm(2:end-1));
P_front = abs(P_sm(1:end-2));
P_back = abs(P_sm(3:end));
logic_front = (P_middle - P_front)>0;
logic_back = (P_middle - P_back)>0;
logic = logic_front & logic_back;
P_middle(~logic) = min(P_middle);
P_local = [abs(P_sm(1));P_middle;abs(P_sm(end))];
[~,doa_Idx] = maxk(P_local, NSOURCE);
doa = theta(doa_Idx);
[~,minIdx] = min(abs(doa));
source_1 = doa(minIdx);
[~,maxIdx] = max(abs(doa));
source_2 = doa(maxIdx);

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