uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;

#ifdef FOV_OVERRIDE
	varying mat4 projection;
	varying mat4 projectionInverse;
	
	void SetupProjectionMatrices() {
		projection = gbufferProjection;
		projectionInverse = gbufferProjectionInverse;
		
		float gameTrueFOV = degrees(atan(1.0 / gbufferProjection[1].y) * 2.0);
		
		cfloat gameSetFOV = FOV_DEFAULT_TENS;
		cfloat targetSetFOV = FOV_TRUE_TENS + FOV_TRUE_FIVES;
		
		float targetTrueFOV = targetSetFOV + (gameTrueFOV - gameSetFOV) * targetSetFOV / gameSetFOV;
		
		projection      = gbufferProjection;
		projection[1].y = 1.0 / tan(radians(targetTrueFOV) * 0.5);
		projection[0].x = projection[1].y * gbufferProjection[0].x / gbufferProjection[1].y;
		
		
		vec4 i = 1.0 / vec4(diagonal2(projection), projection[3].z, projection[2].w);
		
		projectionInverse = mat4(
			i.x, 0.0, 0.0, 0.0,
			0.0, i.y, 0.0, 0.0,
			0.0, 0.0, 0.0, i.z,
			0.0, 0.0, i.w, -projection[2].z * i.z * i.w);
	}
	
	#define projMatrix projection
	#define projInverseMatrix projectionInverse
#else
	#define projMatrix gbufferProjection
	#define projInverseMatrix gbufferProjectionInverse
#endif
