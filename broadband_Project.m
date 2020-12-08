clear all; close all;

%% Load data
[X_audio, Fs] = audioread("data\Array_output\Array_output_01.wav");
disp("Playing the audio: data\Array_output\Array_output_01.wav")
% soundsc(X_audio, Fs);
[Frame, ~] = size(X_audio);
afft = fftshift(fft(X_audio))/Frame;

%% Plot
t = (0:Frame-1)/Fs; % Convert to real time
f = (-Frame/2:Frame/2-1)*Fs/Frame; % Initialize the frequency domain
figure
subplot(2, 1, 1);
plot(t, X_audio);
axis([0 Frame/Fs -inf inf]);
title('Time Domain');
xlabel('t(s)');
subplot(2, 1, 2);
plot(f, abs(afft));
title('Frequency Domain');
xlabel('f (Hz)');

%% Before STFT
% load("Observation_wb.mat");
load("data\gen.mat");
[Frame, ~] = size(X);

%% Perform window function
% TODO...

%% STFT

len = 512;
inc = 5;
nfft = len;
[st_idx, ed_idx, fn] = separate(len, inc, Frame);

tmp_x = [];
tmp_y = [];
F = [];
for i=1:fn
    [source_1, source_2, trust, f_c] = MUSIC(X(st_idx(i):ed_idx(i), :), fs);
    F(end+1) = f_c;
    if trust == 1
        tmp_x(end+1) = source_1;
        tmp_y(end+1) = source_2;
    end
end

figure;
subplot(2, 1, 1);
plot((0:fn-1)*inc/fs, F);
subplot(2, 1, 2);
stft(real(X(:, 1)), fs, 'Window', hamming(256,'periodic'), 'OverlapLength', 236);

figure;
scatter(tmp_x, tmp_y);
axis([-90 90 -90 90]);

%% Test cases

% load("Observations_nb.mat");  
% [ source_1, source_2 ] = MUSIC(X, fs);

%% Functions

function [ st_index, ed_index, fn ] = separate(len, inc, Frame)
    fn = (Frame-len)/inc + 1;
    st_index = (0:(fn-1))*inc + 1;
    ed_index = (0:(fn-1))*inc + len;
end

%% MUSIC Algorithm

function [ source_1, source_2, trust, f_c ] = MUSIC(X, fs)

% source_1 and source_2: the angle of the two sources
% trust: if the answer is accurate enough
% Deal with staionary signal.(short time)
trust = 1;
[Frame, nSensors] = size(X); 

% estimate f_c

sum = 0;
for i=1:4
    Y = fft(real(X(:, i))); % ???
    Y = Y(1:end/2-1); % get the half of the graph
    [~, I] = max(abs(Y)); % get its largest point
    sum = sum + (I - 1)*fs/Frame;
end % already fixed.
% f_domain = (-Frame/2:Frame/2-1)*fs/Frame;
% plot(f_domain, abs(fftshift(fft(real(X(:, 1))))/Frame));

% Initialize data
J = nSensors; 
dx = 3.4*10^-2; 
dy = 0;
c = 340; % Velocity of sound
Index = linspace(0,J-1,J);
p = (-(J-1)/2 + Index.') * [dx dy]; % Position vector
f_c = sum/4; % Get the f_c
if f_c >= 1200 || f_c <= 160
    f_c = 0;
    trust = 0; % select human's voice
end

% Perform MUSIC
stride = 1; 
theta = -90:stride:90;  
v = [sin(theta*pi/180);-cos(theta*pi/180)];
R_x = X'*X/Frame;
a_theta = exp(-1j*2*pi*f_c*(p*v)./c); % steering vector

[V, D] = eig(R_x);
eig_val = diag(D);
[~, Idx] = sort(eig_val);
Un = V(:, Idx(1:J-2)); % noise subspace
P_sm = 1./diag(a_theta'*(Un*Un')*a_theta);

% Get the two `Maximum point`
P_middle = abs(P_sm(2:end-1));
P_front = abs(P_sm(1:end-2));
P_back = abs(P_sm(3:end));
logic_front = (P_middle - P_front)>0;
logic_back = (P_middle - P_back)>0;
logic = logic_front & logic_back;
P_middle(~logic) = min(P_middle);
P_local = [abs(P_sm(1)); P_middle; abs(P_sm(end))];
[~,doa_Idx] = maxk(P_local, 2);
doa = theta(doa_Idx);
[~,minIdx] = min(abs(doa));
source_1 = doa(minIdx);
[~,maxIdx] = max(abs(doa));
source_2 = doa(maxIdx);

tmp = [source_1 source_2];
tmp = sort(tmp);
source_1 = tmp(1);
source_2 = tmp(2);

end