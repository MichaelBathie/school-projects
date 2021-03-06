#version 150

out vec4 out_colour;

uniform vec3 colour;

void main() 
{
  out_colour.rgb = colour;
  out_colour.a = 1;
}
