#version 150 compatibility

out vec3	color;

void main() {
	color = gl_Color.rgb;
	
	gl_Position	= ftransform();
}