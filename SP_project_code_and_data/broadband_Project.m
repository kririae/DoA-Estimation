clear all; close all;

%% Load data
[X_audio, Fs] = audioread("Array_output\Array_output_01.wav");
disp("Playing the audio: Array_output\Array_output_01.wav")
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
load("Observation_wb.mat");
[Frame, ~] = size(X);

%% Perform window function
% TODO...

%% STFT
figure
% plot(1:48000, real(X(:, 1)), 1:48000, imag(X(:, 1)));
% [s, f, t] = stft(real(X(:, 1)), fs, 'Window', hamming(128,'periodic'), 'OverlapLength', 50);
% disp("Showing the stft result:");
% waterfall(f, t, abs(s(:,:,1))')

len = 256;
inc = 220;
nfft = len;
[st_idx, ed_idx, fn] = separate(len, inc, Frame);

tmp_x = [];
tmp_y = [];
for i=1:fn
   [source_1, source_2] = MUSIC(X(st_idx(i):ed_idx(i), :), fs);
   % disp(num2str(source_1) + ' ' + num2str(source_2));
   tmp_x(end+1) = source_1;
   tmp_y(end+1) = source_2;
end

scatter(tmp_x, tmp_y);

stft(X(:, 1), fs, 'Window', kaiser(256,5), 'OverlapLength', 220, 'FFTLength', 512);
view(-45,65)
colormap jet
% load("Observations_nb.mat");  
% [ source_1, source_2 ] = MUSIC(X, fs);
%% Functions

function [ st_index, ed_index, fn ] = separate(len, inc, Frame)
    fn = (Frame-len)/inc + 1;
    st_index = (0:(fn-1))*inc + 1;
    ed_index = (0:(fn-1))*inc + len;
end

function [ source_1, source_2 ] = MUSIC(X, fs)
    % Deal with staionary signal.(short time)
    [Frame, nSensors] = size(X); 
    % estimate f_c
    sum = 0;
    for i=1:4
        sum = sum+abs(max(abs(fftshift(fft(real(X(:, i)))))))*fs/Frame;
        % disp(abs(max(abs(fftshift(fft(real(X(:, i)))))))*fs/Frame);
    end
    % figure;
    % plot(f_domain, abs(fftshift(fft(real(X(:, 1))))));
    
    J = nSensors; 
    dx = 2.5*10^-2; 
    dy = 0;
    c = 340; % Velocity of sound
    Index = linspace(0,J-1,J); % Tmp...
    p = (-(J-1)/2 + Index.') * [dx dy]; % Position vector
    f_c = sum/4; % Get the f_c
    disp(f_c);
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
    
%     figure;
%     linspec = {'b-','LineWidth',2};
%     plot(theta, 10*log10(abs(P_sm)), linspec{:});
%     title('MUSIC pseudo power spectrum')
%     xlabel('Angle in [degrees]');
%     ylabel('Power spectrum in [dB]');
%     xlim([-90,90]);

    [~, doa_Idx] = maxk(P_sm, 2);
    tmp = sort([theta(doa_Idx(1)), theta(doa_Idx(2))]);
    source_1 = tmp(1);
    source_2 = tmp(2);
end