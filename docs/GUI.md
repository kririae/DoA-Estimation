### GUI

The GUI part, which focuses on building a user-friendly program doing the real-time DOA estimation, can show the probability of every direction of the sound through a polar diagram, and display the most possible two directions on the interface. The start and stop can be entirely controlled by a button. It is a task finished with lots of difficulties and obstacles mostly caused by the unfamiliarity with MATLAB.

We started with designing an application using MATLAB Guide. But not long we found that it's really hard to use so we turn to MATLAB App designer,  a more easy-to-use tool. But what we didn't know then was that it was just the beginning of the tough development process.

Aiming at a GUI which can start and stop the real-time DOA estimation algorithm at any time, the first thought of us was to conform to the multi-threaded procedural framework by using the object `timer` in MATLAB. In fact, it was not only a natural choice but also an efficient way to control all the program work and stop according to every "tic" of the `timer`. But soon we found that it caused a large number of problems, list as follows:

- No graph. Though there're three running modes for `timer`, the period is fixed. That means the program itself will pitilessly start the next period regardless of the graph has not been plot yet, which caused that there will be hard to control the `timer.period` to let the graph be plotted.

- Chaos. The timer will never stop unless the `stop` command is executed. And if you execute the `start` command while the previous `timer` is still running, the command will create another `timer` doing the same thing as the previous one, and you don't have effective means to tell them apart, which causes that all the command become confusing and lead to the total chaos of the program.

- Unreasonable bugs. Though the logic of the program is right, the test of it discovers many unreasonable bugs, such as unfixed update rate of the graph, unexpected crash of MATLAB, not being able to restart after stop, etc.

So it becomes impossible for us to accomplish the GUI through timer. We replace it with another construction, which has a prepare part, a main working part and a stop part. The prepare part does necessary settings like setup the `audioDeviceReader`, change the text of the button; the working part do the MUSIC algorithm to estimate the direction of the sound and update the graph; the stop part help the program stop properly by release the `audioDeviceReader` and change the text of the button back. This model works regularly by the signal produced by the button. Below are the details of how it work.

1. Get started. When the program is first launched, all of the elements are set.

2. Get prepared. The double-state button is the only controller of the whole program. When it turns to "press", which equals its value turn to "1", the prepare part is firstly launched by the callback of the button.

3. Work. Working part runs right after the prepare part. It will continue working until the value of the button element comes to "0". 

4. Stop. When the value of the button element comes to "0", the working circulation will be broken and the stop part will do something to recover some properties for next time.

Seems really easy, but the problem is, if a callback is working without special operations, then any other callbacks won't be launched at all. That means, if the button turns to the other state, its corresponding callback will just keep pending, and any of the properties of any elements of the program won't be changed by that. Furthermore, the plot course will also be interrupted by next working part. It really costs some time to find out the solution: `drawnow`.

It surely a great breakthrough in finding this suitable function. The description is "updates figures and processes any pending callbacks". That means it can plot the graph and change the value of the button to "0" to let the working part know it should stop next time. However, this function seems not working every time. It would randomly ignore the callback caused by the button and continue working without any hesitation. Till now, we still don't know why `drawnow` sometimes loses its efficacy, we can only guess that it is caused by the running mode of MATLAB and its unclear multi-threaded procedural framework. This surely leaves some regret for the project, but we have really tried our best.

