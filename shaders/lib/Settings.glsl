#define SHADOW_MAP_BIAS 0.8    // [0.0 0.6 0.7 0.8 0.85 0.9]
#define EXTENDED_SHADOW_DISTANCE
#define SOFT_SHADOWS

#define GI_TRANSLUCENCE 0.2    // [0.0 0.2 0.4 0.6 0.8 1.0]
#define GI_BOOST

#define COMPOSITE0_SCALE 0.5   // [0.25 0.33 0.4 0.5 0.75 1.0]

#define FOGPOW 3.0
#define FOG_ENABLED

#define FORWARD_SHADING


const int   shadowMapResolution      = 2048;    //[1024 2048 3072 4096]
const float sunPathRotation          = -40.0;
const float shadowDistance           = 140.0;
const float shadowIntervalSize       = 4.0;
const bool  shadowHardwareFiltering0 = true;

const int RGB8            = 0;
const int RG16            = 0;
const int RGB16           = 0;
const int RGBA16          = 0;
const int colortex0Format = RGB16;
const int colortex2Format = RGB16;
const int colortex3Format = RGB8;
const int colortex4Format = RGBA16;
const int colortex5Format = RGB16;

const int noiseTextureResolution = 4;


/* Option unwravelling */
#ifdef GI_BOOST 
	#define GI_Boost true
#else
	#define GI_Boost false
#endif

#ifdef FORWARD_SHADING
	#define Forward_Shading  true
	#define Deferred_Shading false
#else
	#define DEFERRED_SHADING
	#define Forward_Shading  false
	#define Deferred_Shading true
#endif