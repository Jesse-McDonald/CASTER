CASTER is a programm called Computer Assisted Segmentation Tool Environment Revisit, and has been developed for the segmentation of neves with in stacks of Scanning Electron Microscope scans of mice retina.
CASTER is currently indev and is not ready to be used as a standalone system, but it does make a good platform for testing automatic and semi-automatic segmentation tools and algorithems.
The current plan is to attempt to make CASTER a fully functioning program and eventually port it from Processing to another language in the C/Java family.

FEATURES:
Import and display multiple sequential images representing SEM scans in png format 
Navigation of image stack
Easily Modifiable code for rapid testing of tools
Brush style Segmentation
Saving and loading overlays in JEMO format
RAE CAST ray segmentation semi-automatic segmentation brush
EdgeDetection brush for semi-automatic and automatic selection of membrain
3D visualization
Priority Queue stack loading for systems with insufficient memory

NOTE:
The CASTER_Key.pdf is key to understanding the EdgeFollowing Brush. 


This addendum was orignally a document is designed to assist anyone who wants to use or modify CASTER

#Purpose
CASTER is designed to load 32GB grayscale image stacks into 128GB of ram.  These image stacks are generated on a Scanning Electron Microscope.  Any tools found in CASTER have only been tested on our images of nerve cells in mouse retinas.  CATER is designed to assist users in navigating and segmenting the stack for the purpose of identifying where neurons go.

#Paradigm
In the construction of CASTER certain assumptions where made.
1.	Images in the stack are sequential 2D Slices of a 3D object
2.	The base images files should never be changed by CASTER nor should the in memory image be changed in a way that would require reloading from disk.
3.	The stack should be aligned prior to loading
4.	There is enough available RAM for the program to store and manipulate all images in memory.
5.	There is a separate 1 to 1 image layer (the Overlay) for indicating which pixels are in which segmentation
6.	This Overlay is easily modifiable by the user
7.	The overlay can be saved and loaded from disk at any time
8.	Each unique segment has its own color on the overlay
If any of the above assumptions are incompatible with your application, CASTER is not the right program for you.
#Controls
	The following controls for CASTER are partially determined by the paradigm.
•	To switch image layers use the scroll wheel or the up and down arrow keys
•	To paint on the overlay with the active brush, left click

The following controls are partially determined by the above controls.
•	To change brush size, hold control while scrolling, or use the + and – buttons.
•	To move on the same layer, press and hold the middle mouse button while dragging the mouse
•	To zoom in or out on a layer, press and hold the right mouse button while dragging the mouse.  Zooming always occurs about the center of the window as indicated by the intersection of the 2 blue lines
The reason why:
It would be logical to put layer changing, zooming and brush sizing on the scroll wheel, however only 1 can take the top spot.  Layer changing is one of the core paradigms and happens in integer increments (just like the scroll wheel), therefore it is given top billing on the scroll wheel. Similarly brush sizing happens in integer increments so got a secondary spot on the wheel.  Zoom on the other hand requires floating increments not available on the mouse wheel, and the wheel is mostly full any way.
Moving, and painting logicaly go on primary mouse button, however, they must both be available at the same time.  Painting is a paradigm so it gets the primary mouse button.  Thus moving must go on either the middle or right mouse button, as the scroll wheel is already used for changing layers, it felt natural that moving should also be on the middle mouse button.
This leaves the right mouse button empty, so zooming is assigned to it.
The up, down, + and – key bindings where added for WACOM tablet support on in situations where the scroll wheel is for some reason unavailable.  However, currently there is no middle mouse button alternative.  At some point a config file for changing the key bindings will be added.
#Settings
Certain settings can be customized in the settings file.  These settings are dependent on the machine being used.  You can find the settings file in “data/settings.json”

undoDepth is the max number of undos to remember.  An “undo” is recorded after each mouse release or every 100 frames of continuous painting.  After the depth is reached the oldest undo is dropped.  Increase if you need more undos, decrease if you are running out of memory while drawing

autoOpen tells CASTER if it should attempt to open the previous project file on launch, set to true if you frequently work on 1 project in a fixed location, or false if you work on many projects or the project is not in a fixed location

monitorPPI is the pixels per inch of your monitor and is used for scaling the UI.  The buttons should be approximately 1 inch across.  Default of -1 tells CASTER to attempt to figure this out on its own.  If the buttons are too small, increase, and if they don’t fit on the screen decrease

maxPixelCache is the number of pixels that can be loaded from ram in a single frame.  Affects quality of image 1 second after layer change.  Increase for higher quality images, decrease for better performance while scrolling.  

lastProject is the path of the last project open.  autoOpen looks here to determine what project to load.  If CASTER crashes at start, try removing the path

maxProgramRam is the max amount of ram CASTER can use.  It is used by a few internal tasks to attempt to prevent CASTER crashing by using all available ram.


If you are a user of CASTER not looking to modify the source code, you can stop reading here
#Core Architecture
CASTER is heavily object oriented and most of the stack runs from a single global instance of the class EMStack called img





