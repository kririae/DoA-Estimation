<h1 align="center">DoA Estimation</h1>

<div align="center">
	SI100b project: Array Signal Processing
</div>
[TOC]

## Usage

Click `run` to get result.

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

[TODO: @Aiedails]