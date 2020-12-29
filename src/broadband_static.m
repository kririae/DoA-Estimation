clear all;
close all;

[y1, ~] = audioread("D:\check\data2\data2_01.wav");
[y2, ~] = audioread("D:\check\data2\data2_02.wav");
[y3, ~] = audioread("D:\check\data2\data2_03.wav");
[y4, ~] = audioread("D:\check\data2\data2_04.wav");
[Frame, ~] = size(y1);
X = zeros(Frame, 4);
% X(:, 1) = hilbert(y1);
% X(:, 2) = hilbert(y2);
% X(:, 3) = hilbert(y3);
% X(:, 4) = hilbert(y4);
X(:, 1) = y1;
X(:, 2) = y2;
X(:, 3) = y3;
X(:, 4) = y4;

P = MUSIC(X);

% Find the local maximum;
[source_1, source_2] = find_max(P);
theta = -90:1:90;

disp(['The first source with MUSIC is: ',num2str(source_1),' deg']);
disp(['The second source with MUSIC is: ',num2str(source_2),' deg']);

figure;
linspec = {'k-','LineWidth',0.5};
plot(theta, 10*log10(abs(P)), linspec{:});
title('MUSIC pseudo power spectrum')
xlabel('Angle in [degrees]');
ylabel('Power spectrum in [dB]');
xlim([-90,90])