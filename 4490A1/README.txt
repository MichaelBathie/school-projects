Michael Bathie, 7835010
COMP 4490 Assignment #1

Testing Specifications:
    Operating System: Windows 10 Pro 64-bit, version 2004
    Graphics Hardware: NVIDIA GeForce GTX 1080

Question 1:
    Everything in the assignment should work correctly 

Interesting Shader Features:
    All of the shader changes occur on the die (in vshadera1cube and fshadera1cube).

    The change to the vertex shader is altering the intensity of the colour based 
    on the position of the vertex. So at the default viewer position, the cube will
    start at full colour intensity, then slowly change to being completely black before
    it disappears. A small problem is it's based on the camera position. When you rotate to the
    opposite side, the die starts as black instead of full colour.

    The fragment shader for the die implements a CRT scanline type effect. There are many scanlines
    that move done the die as time passes.

Macros:
    q: close the program
    spacebar: throws another pair of dice (deletes the previous ones)
    left click: starts spinning the camera
    r: toggles dice rotation
    m: toggles dice movement
    s: toggles shading effect in the vertex shader
    l: toggles scanline effect in the fragment shader

I've included all the needed source files, everything should work once placed into the example project