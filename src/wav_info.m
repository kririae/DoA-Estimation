clear all; close all;

%% Load data
[X_audio, Fs] = audioread("..\data\Array_output\Array_output_01.wav");
disp("Playing the audio: ..\data\Array_output\Array_output_01.wav")
soundsc(X_audio, Fs);
[Frame, ~] = size(X_audio);
afft = fftshift(fft(X_audio))/Frame;

%% Plot
t = (0:Frame-1)/Fs; % Convert to real time
f = (-Frame/2:Frame/2-1)*Fs/Frame; % Initialize the frequency domain
figure
subplot(1, 2, 1);
plot(t, X_audio, 'k', 'LineWidth', 0.5);
axis([0 Frame/Fs -inf inf]);
title('Time Domain');
xlabel('t(s)');
subplot(1, 2, 2);
plot(f, abs(afft), 'k', 'LineWidth', 0.5);
title('Frequency Domain');
xlabel('f (Hz)');