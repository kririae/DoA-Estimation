function [P] = MUSIC(X)
%MUSIC_ISM Summary of this function goes here
%   Detailed explanation goes here
NSOURCE = 2;
fs = 16000;
[Frame, ~] = size(X);

%% STFT
len = 512;
inc = 512;
nfft = len; % The smallest 2^n \ge len, to optimize FFT
[st_idx, ed_idx, fn] = separate(len, inc, Frame);


% STFT -> 4 sensors, value after FFT,
STFT = zeros([fn nfft 4]);
window = hann(len);
for i=1:fn
    for j=1:4
        X(st_idx(i):ed_idx(i), j) = X(st_idx(i):ed_idx(i), j).*window;
    end
    STFT(i, :, :) = fft(X(st_idx(i):ed_idx(i), :), nfft);
end

% Perform MUSIC algorithm

% Initialize data
J = 4;
dx = 2.5*10^-2;
dy = 0;
c = 340; % Velocity of sound
Index = linspace(0,J-1,J);
p = (-(J-1)/2 + Index.') * [dx dy]; % Position vector
stride = 1; % Should not be modified!!!
theta = -90:1:90;
v = [sin(theta*pi/180); -cos(theta*pi/180)];

P = zeros([180/stride+1 1]); % -90:stride:90

fr = [40 3000]*nfft/fs+1; % range of frequency (to add weight)

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
    Un = V(:, Idx(1:J-2)); % noise subspace
    P_sm = diag(a_theta'*(Un*Un')*a_theta);
    P = P + abs(P_sm);
    
end

P = 1./P;
end

