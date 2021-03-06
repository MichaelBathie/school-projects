#version 150

flat in vec4 f_colour;
out vec4 out_colour;
uniform float Time;
uniform float WindowSize;
uniform int ScanLine;
/*
  This fragment shader creates a scanline effect on the dice, similar to an old CRT TV.
*/

void main() 
{
  if (ScanLine == 1) {
    float yCoord = gl_FragCoord.y / WindowSize; //puts frag coord in 0-1 range
    float scan_speed = 50; //the speed at which the lines go down the cube
    float line_size = 1000; //changes line size (but bigger number is smaller line)

    /*
      using cos to have the values cycle between -1 and 1
      Time as a non static value to have the lines move
      Time is multiplied by scan_speed because time on its own is too small (the lines move really slow)
      yCoord of the fragment shader to make all identical y coords create a horizontal line
      yCoord is multipled by line_size to create a bigger gap between two different y frag coords.
      Without it we end up with a strobe like effect that makes the whole die black then colour then black ...
    */
    float scan_line = cos((yCoord * line_size) + (Time * scan_speed));

    //our output is somewhere between -1 and 1, if we're negative let's create a scan line
    if(scan_line < 0) {
      out_colour = vec4(0.0,0.0,0.0,1.0);
    //if we're positive lets put the normal colour there
    } else {
      out_colour = f_colour;
    }
  } else {
    out_colour = f_colour;
  }
}
