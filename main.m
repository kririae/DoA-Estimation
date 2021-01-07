clear all;
close all;

addpath('./src');
addpath('.');

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

P = MUSIC(X);

% Find the local maximum;
[source_1, source_2] = find_max(P);

disp(['The first source with MUSIC is: ',num2str(source_1),' deg']);
disp(['The second source with MUSIC is: ',num2str(source_2),' deg']);

end

release(devReader);