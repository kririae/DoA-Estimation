clear all; close all;
%% Load data
load("..\data\Observations_nb.mat");   
% load data
[Frame,nSensors] = size(X);
f_domain = (-Frame/2:Frame/2-1)*fs/Frame;
%% Plot waveform

figure
subplot(1, 2, 1);
plot(real(X(:, 1)), 'k', 'LineWidth', 0.5);
axis([-inf inf -4 4]);
title("The time-domain");
subplot(1, 2, 2);
plot(f_domain, abs(fftshift(fft(X(:, 1)))/Frame), 'k', 'LineWidth', 0.5); 
title("The frequency-domain");
axis([0 5000 0 inf]);

%% Array setup
% number of sensors
J = nSensors;
% inter-sensor distance in x direction (m)
dx = 3.4*10^-2;
% sensor distance in y direction (m)
dy = 0;
% sound velocity  (m/s)
c = 340;     
% number of sources
n_source = 2;
Index = linspace(0,J-1,J);
% sensor position
p = (-(J-1)/2 + Index.') * [dx dy];

%% Plot sensor positions
linspec = {'rx','MarkerSize',12,'LineWidth',2};
figure
plot(p(:,1),p(:,2),linspec{:});  
title('Sensor positions');
xlabel('x position in meters');
ylabel('y position in meters');
disp('The four microphones are ready !');


%% DoA estimation (MUSIC) 
% determine the angular resolution(deg)
stride = 0.5;
% grid
theta = -90:stride:90;
% center frequency  (Hz)
f_c = 2500;
% autocorrelation estimate
R_x = X'*X/Frame;
% direction vector 
v = [sin(theta*pi/180); -cos(theta*pi/180)];  
% steer vector
a_theta = exp(-1i*2*pi*f_c*(p*v)./c);

% implement eigen-decomposition 

[V, D] = eig(R_x);
eig_val = diag(D);
[eig_val, Idx] = sort(eig_val);
% noise subspace (columns are eigenvectors), size: J*(J-n_source)
Un = V(:, Idx(1:J-n_source));  
% pseudo music power
P_sm = 1./diag(a_theta'*(Un*Un')*a_theta);

%% Plot the MUSIC pseudo power spectrum
figure;
linspec = {'k-','LineWidth', 0.5};
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

disp(['The desired source DOA with MUSIC is: ',num2str(doa_source),' deg']);
disp(['The interfering DOA with MUSIC is: ',num2str(interfer),' deg']);