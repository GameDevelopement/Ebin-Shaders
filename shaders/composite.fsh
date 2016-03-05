#version 120

#define GAMMA 2.2

const int	shadowMapResolution 		= 2160;
const float	shadowDistance 				= 140.0;
const float	shadowIntervalSize 			= 4.0;
const float	sunPathRotation 			= 30.0;
const bool	shadowHardwareFiltering0	= true;

uniform sampler2D colortex0;
uniform sampler2D colortex2;
uniform sampler2D colortex3;
uniform sampler2D gdepthtex;
uniform sampler2D shadowcolor;
uniform sampler2DShadow shadow;

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

varying vec3	lightVector;

varying vec2	texcoord;

varying vec3	colorSkylight;


float GetMaterialIDs(in vec2 coord) {		//Function that retrieves the texture that has all material IDs stored in it
	return texture2D(colortex3, coord).b;
}

void ExpandMaterialIDs(inout float matID, inout float bit0, inout float bit1, inout float bit2, inout float bit3) {
	matID *= 255.0;
	
	if (matID >= 128.0 && matID < 254.5) {
		matID -= 128.0;
		bit0 = 1.0;
	}
	
	if (matID >= 64.0 && matID < 254.5) {
		matID -= 64.0;
		bit1 = 1.0;
	}
	
	if (matID >= 32.0 && matID < 254.5) {
		matID -= 32.0;
		bit2 = 1.0;
	}
	
	if (matID >= 16.0 && matID < 254.5) {
		matID -= 16.0;
		bit3 = 1.0;
	}
}

float GetMaterialMask(in float mask, in float materialID) {
	return float(abs(materialID - mask) < 0.1);
}

vec3 GetDiffuse(in vec2 coord) {
	return texture2D(colortex2, coord).rgb;
}

vec3 GetDiffuseLinear(in vec2 coord) {
	return pow(texture2D(colortex2, coord).rgb, vec3(GAMMA));
}

float GetSkyLightmap(in vec2 coord) {
	return texture2D(colortex3, coord).g;
}

vec3 GetNormal(in vec2 coord) {
	return (gbufferModelView * vec4(texture2D(colortex0, coord).xyz * 2.0 - 1.0, 0.0)).xyz;
}

float GetDepth(in vec2 coord) {
	return texture2D(gdepthtex, coord).x;
}

vec4 GetViewSpacePosition(in vec2 coord, in float depth) {
	vec4
	position = gbufferProjectionInverse * vec4(vec3(coord, depth) * 2.0 - 1.0, 1.0);
	position /= position.w;
	
	return position;
}

vec4 ViewSpaceToWorldSpace(in vec4 viewSpacePosition) {
	return gbufferModelViewInverse * viewSpacePosition;
}

vec4 WorldSpaceToShadowSpace(in vec4 worldSpacePosition) {
	return shadowProjection * shadowModelView * worldSpacePosition;
}

float GetSunlight(in vec4 position) {
	position = ViewSpaceToWorldSpace(position);
	position = WorldSpaceToShadowSpace(position);
	position = position * 0.5 + 0.5;
	
	if (position.x < 0.0 || position.x > 1.0
	||	position.y < 0.0 || position.y > 1.0
	||	position.z < 0.0 || position.z > 1.0
		) return 1.0;
	
	return shadow2D(shadow, position.xyz - vec3(0.0, 0.0, 0.0005)).x;
}

vec3 Tonemap(in vec3 color) {
	return pow(color / (color + vec3(0.65)), vec3(1.0 / 2.2));
}

struct Mask {
	float materialIDs;
	float matIDs;
	
	float bit0;
	float bit1;
	float bit2;
	float bit3;
	
	float sky;
} mask;

struct Shading {		//Contains all the light levels, or light intensities, without any color
	float sunlight;
	float skylight;
} shading;

struct Lightmap {		//Contains all the light with color/pigment applied
	vec3 sunlight;
	vec3 skylight;
} lightmap;

void CalculateMasks(inout Mask mask) {
	mask.materialIDs	= GetMaterialIDs(texcoord);
	mask.matIDs			= mask.materialIDs;
	
	ExpandMaterialIDs(mask.matIDs, mask.bit0, mask.bit1, mask.bit2, mask.bit3);
	
	mask.sky			= GetMaterialMask(255, mask.matIDs);
}

void main() {
	CalculateMasks(mask);
	
	vec3	diffuse		= GetDiffuseLinear(texcoord);
	
	if (mask.sky > 0.5) { diffuse = Tonemap(diffuse); gl_FragData[0] = vec4(diffuse, 1.0); return; }
	
	float	skyLightmap	= GetSkyLightmap(texcoord);
	
	vec3	normal				= GetNormal(texcoord);
	float	depth				= GetDepth(texcoord);
	vec4	ViewSpacePosition	= GetViewSpacePosition(texcoord, depth);
	float	NdotL				= max(0.0, dot(normal, lightVector));
	
	
	shading.sunlight = NdotL;
	shading.sunlight *= GetSunlight(ViewSpacePosition);
	
	shading.skylight = skyLightmap;
	
	
	lightmap.sunlight = shading.sunlight * vec3(1.0);
	lightmap.skylight = shading.skylight * colorSkylight;
	
	
	vec3
	composite =	lightmap.sunlight / 0.5
			+	lightmap.skylight * 0.5
			;
	
	composite *= diffuse;
	composite = Tonemap(composite);
	
	gl_FragData[0] = vec4(composite, 1.0);
}