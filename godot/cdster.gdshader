shader_type spatial;
#include "res://common.gdshaderinc"

// I'm sure there is a lazier version of this
void fragment() {
	// fix the uvs a bit
	vec2 uv = UV * 2. - 1.;
	uv.x *= .3;

	float a = atan(uv.y, uv.x) + triangle(TIME*.1) * .5 - .5;
	float d = length(uv);
	float outer = step(.33, d);

	float bands = 33.;
	float q = floor(a * bands) / bands;
	vec2 ah = hash22(vec2(q, q + .33)); // angular hash
	vec3 lans = vec3(triangle(ah.x + .0), triangle(ah.y + .3) * .8 , .4*triangle(ah.x + .6));

	/*
	lans = mix(lans.xzz, // red
		mix(
			lans * 2.2, // yellow
			lans.zxz, // green
			step(.6, ah.y)
		)

	,

	step(.3, ah.y));
	*/

	lans *= mix(1., 22., step(.6, ah.y));

	float grooves = triangle(d * 256.);
	vec3 hi = mix(lans, lans + .44, grooves);
	vec3 lo = vec3(.1);

	ALBEDO.rgb = mix(lo, hi, outer);
	ALPHA = mix(.3, 1., outer);
}