#version 150

in vec4 vPosition;

uniform mat4 ModelView, Projection;
uniform vec3 colour;
uniform int ShadingSimulation;

flat out vec4 f_colour;
/*
  This vertex shader creates a different in colour intensity based on the z position of the vertex.
*/

void main()
{ 
	gl_Position = Projection * ModelView * vPosition;

  float diceZOffset = 5;
  float changeRange = 10;

  if(ShadingSimulation == 1) {
    float depth = gl_Position.z - diceZOffset;  
    depth = depth / changeRange; //change values from 0-1 over the specified range
    float intensity = 1.0 - depth; //get the intensity within this range

    f_colour.rgb = colour*intensity; //if shading is turned on then alter the intensity
  } else {
    f_colour.rgb = colour; //otherwise leave the colour alone
  }

  f_colour.a = 1; //always 1.0 alpha
}

