#version 150 compatibility

uniform vec3	skyColor;

uniform vec3	sunPosition;

uniform float	sunAngle;

out vec2	texcoord;

out vec3	lightVector;

out vec3	colorSkylight;

void main() {
	texcoord	= gl_MultiTexCoord0.st;
	
	gl_Position	= ftransform();
	
	lightVector = normalize(sunAngle < 0.5 ? sunPosition : -sunPosition);
	
	colorSkylight = pow(skyColor, vec3(1.0 / 2.2));
}