shader_type spatial;
#include "res://common.gdshaderinc"

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float t = TIME * .1;	
	
	vec2 uv = UV * 333. + t;
	vec2 h = hash22(floor(uv +.5)*3.12341);
	vec2 j = hash22(floor(uv +.5)*1234.3392 + h + t);
	vec2 ut = vec2(triangle(uv.x), triangle(uv.y));
	float disco = ut.x * ut.y * 111.; ; // pretty decent actually...

	ALBEDO = disco * h.xyx * step(.11, j.x + j.y);
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
