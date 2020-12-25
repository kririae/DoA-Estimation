<h1 align="center">DoA Estimation</h1>

<div align="center">
	SI100b project: Array Signal Processing
</div>
[TOC]

This repo contains our code and documents for DoA Estimation in SI100b Project. Aiming to implement certain functions that can estimation the direction of sound signal using a microphone array with 4 sensors.

## Usage

Click `run` to get result.

See `report/report.tex` or `report/report.pdf` for further information.

- Module 1: `src/narrowband.m`
- Module 2
  - Module 2.1: `src/wav_info.m` 
  - Module 2.2: `src/broadband.m`
- Module 3
  - Data: `data/sample01.zip`; `data/sample02.zip`
  - Code: `src/broadband_static.m`
- Bonus
  - Real-time:  `main.m`
  - GUI: open `GUI.mlapp` with MATLAB `appdesigner`(with some bugs)

## Folder Structure

- `data`: Contains simulation data and data collected by ourselves.
- `docs`: Some notes or restrictions in the process of learning.
- `report`: `.tex` file
- `src`: Contains the code of three main modules
- `main.m`: Implement of real time DoA estimation
- `GUI.mlapp`: GUI implemented

## Trouble shootings

In our practice, there should not appeared errors in the three main modules. However, due to different environment, there can be errors when running `main.m` and `GUI.mlapp`.

### Error using `matlab.system.StringSet/findMatch`
>  "麦克风 (USB YDB01 Audio Effect)" is not a valid value for the Device property.

This can due to different device name for the microphone.

Type in the following commands in interactive command window:

```matlab>> devReader = audioDeviceReader();
>> devReader = audioDeviceReader();
>> getAudioDevices(devReader())
```

Choose the string in the respond corresponding to your device, and replace the parameter of  Line 17 with your device name.

```
'Device', '麦克风 (USB YDB01 Audio Effect)', ...
```

```matlab
'Device', '[your device name]', ...
```

### Please connect microphone

And the button's message appeared to be `Retry`. However, due to the feature of MATLAB, you should restart the whole MATLAB program to load the audio device. When the message of the button switched to `Start`, the problem solved.

### Cannot stop the GUI program

> When you have another callback while the current callback is still working, there just exists several functions which can interrupt the current callback, like `drawnow`. It says it **should** "updates figures and processes any pending callbacks", which was exactly what I need. **But** what I find out was it didn't work every time.

The only way to deal with it currently is to press `Ctrl+C` in the interactive command line(where there's output of angle information), if the application is running independently, kill the process with task manager. That's because `drawnow` function ignore the information produced by the button and continue running. 

### Confused polar graph

Use software which can drive 4-channel microphone to ensure the channel map is right. The channel map may vary from time to time, causing totally useless result.

## Contributors

[@kririae](https://github.com/kririae); [@Aiedails](https://github.com/Aiedails); [@GuiltyInnocence](https://github.com/GuiltyInnocence);