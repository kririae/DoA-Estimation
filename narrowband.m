clear all; close all;
%% Load data
% load("data\Observations_nb.mat");   
load("data\gen.mat"); 
[Frame,nSensors] = size(X);                       % load data
f_domain = (-Frame/2:Frame/2-1)*fs/Frame;
% X =  ;                                          % 4-channel received signals 
% fs = ;                                          % sample rate (Hz)
%% Plot waveform
% figure                                          % need to be transformed.

figure
for i=1:4
    subplot(4, 2, i);
    plot(real(X(:, i)));
    title("The time-domain [" + i + "]");
end

for i=1:4
    subplot(4, 2, i+4);
    plot(f_domain, abs(fftshift(fft(X(:, i)))/Frame)); % perform FFT on its real part.
    title("The frequency-domain [" + i + "]");
    axis([0 5000 0 inf]);
end

%% Array setup                           
J = nSensors;                                      % number of sensors
dx = 3.4*10^-2;                                    % inter-sensor distance in x direction (m)
dy = 0;                                            % sensor distance in y direction (m)
c = 340;                                           % sound velocity  (m/s)
n_source = 2;                                      % number of sources
Index = linspace(0,J-1,J);
p = (-(J-1)/2 + Index.') * [dx dy];                % sensor position

%% Plot sensor positions
linspec = {'rx','MarkerSize',12,'LineWidth',2};
figure
plot(p(:,1),p(:,2),linspec{:});  
title('Sensor positions');
xlabel('x position in meters');
ylabel('y position in meters');
disp('The four microphones are ready !');


%% DoA estimation (MUSIC) 
stride = 0.5;                                                 % determine the angular resolution(deg)
theta = -90:stride:90;                                      % grid
f_c = 2500;                                                 % center frequency  (Hz)
R_x = X'*X/Frame;                                           % autocorrelation estimate
v = [sin(theta*pi/180); -cos(theta*pi/180)];                % direction vector  
a_theta = exp(-1i*2*pi*f_c*(p*v)./c);                       % steer vector

% implement eigen-decomposition 

[V, D] = eig(R_x);
eig_val = diag(D);
[eig_val, Idx] = sort(eig_val);
Un = V(:, Idx(1:J-n_source));                       % noise subspace (columns are eigenvectors), size: J*(J-n_source)
P_sm = 1./diag(a_theta'*(Un*Un')*a_theta);          % pseudo music power

%% Plot the MUSIC pseudo power spectrum
figure;
linspec = {'b-','LineWidth',2};
plot(theta, 10*log10(abs(P_sm)), linspec{:});
title('MUSIC pseudo power spectrum')
xlabel('Angle in [degrees]');
ylabel('Power spectrum in [dB]');
xlim([-90,90]);

%% Find the local maximum and visualization
P_middle = abs(P_sm(2:end-1));
P_front = abs(P_sm(1:end-2));
P_back = abs(P_sm(3:end));
logic_front = (P_middle - P_front)>0;
logic_back = (P_middle - P_back)>0;
logic = logic_front & logic_back;
P_middle(~logic) = min(P_middle);
P_local = [abs(P_sm(1));P_middle;abs(P_sm(end))];
[~,doa_Idx] = maxk(P_local,n_source);
doa = theta(doa_Idx);
[~,minIdx] = min(abs(doa));
doa_source = doa(minIdx);
[~,maxIdx] = max(abs(doa));
interfer = doa(maxIdx);

% Find the local maximum;
% [~, locs] = findpeaks(abs(P_sm)); % default two peaks.
% locs = theta(sort(locs));
% doa_source = locs(1);
% interfer = locs(2);

disp(['The desired source DOA with MUSIC is: ',num2str(doa_source),' deg']);
disp(['The interfering DOA with MUSIC is: ',num2str(interfer),' deg']);