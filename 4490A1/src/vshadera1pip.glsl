#version 150

in vec4 vPosition;

uniform mat4 ModelView, Projection;
uniform vec3 colour;
flat out vec4 f_colour;

void main()
{
  gl_Position = Projection * ModelView * vPosition;

	f_colour.rgb = colour;
  f_colour.a = 1; //change alpha based on postion
}
