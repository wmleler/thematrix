# thematrix
Flutter app that shows off 3D transformation matrices, and the use of the accelerometers. 

This app is just a prototype and is not finished, but it still gives a good demo.
Try doing the following to show it off:

1. Make sure you have your phone set so it will not auto-rotate the display (you want to keep it in portrait mode).
1. Start the app. It looks like a normal app, but it is really a Flutter app that doesn't use any OEM widgets.
1. Show this off by touching the "SPIN" button. Display should rotate once.
1. Really show this off by touching the screen (in some empty place) and moving your finger around. The app should roll around in 3D.
1. You can also use a pinch gesture to scale the size of the app.
1. To reset the display to the starting configuration (no rotations), just touch and hold your finger on some empty space. Alternatively, press the "RESET" button, but you may not be able to do this.
1. The app also allows you to manipulate perspective. Use the two arrow buttons to vary the perspective from -2 to +2. Normal perspective is 1. If perspective is zero, there is no perspective, so things stay the same size regardless of their distance. When perspective is negative, then things that are further away actually get larger!
1. Reset the display again, and now touch the "LEVEL" button. The display tries to keep parallel to the ground (like a level).

The shadows are a bit wonky. This is probably a bug in Flutter, but just ignore it for now.