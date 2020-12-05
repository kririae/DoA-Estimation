clear all; close all;

%% Load data
[X_audio, Fs] = audioread("Array_output\Array_output_01.wav");
disp("Playing the audio: Array_output\Array_output_01.wav")
soundsc(X_audio, Fs);
[Frame, tmp] = size(X_audio);
afft = fftshift(fft(X_audio))/Frame;

%% Plot
t = (0:Frame-1)/Fs; % Convert to real time
f = (-Frame/2:Frame/2-1)*Fs/Frame; % Initialize the frequency domain
figure
subplot(2, 1, 1);
plot(t, X_audio);
axis([0 Frame/Fs -inf inf]);
subplot(2, 1, 2);
plot(f, abs(afft));
axis([0 3000 0 inf]);