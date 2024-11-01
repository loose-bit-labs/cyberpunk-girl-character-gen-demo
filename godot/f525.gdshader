shader_type spatial;
render_mode skip_vertex_transform;
varying vec3 VN;
#include "res://common.gdshaderinc"

void vertex() {
	VN = NORMAL;
	VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
    NORMAL = normalize((MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
    BINORMAL = normalize((MODELVIEW_MATRIX * vec4(BINORMAL, 0.0)).xyz);
    TANGENT = normalize((MODELVIEW_MATRIX * vec4(TANGENT, 0.0)).xyz);
}

void fragment() {
	vec2 uv = UV * 2. - 1.;
	uv.y *= -VN.z; // flip the back
	
	float d = length(uv);
	float inner = step(.2, d);
	float inward = step(.3, d);
	
	// inset at the botttom
	inward *= step(.1,
		step(.1, distance(uv * vec2(1,.4), vec2(.0, -.27))) // round bit
  		+  (   step(.08,abs(uv.x)) ) // square bit
	); 
	
	vec2 px = vec2(abs(uv.x), uv.y);
	float bottom_notches = smoothstep(.0, .04, distance(px, vec2(.2,-.985)));
	
	//low fi ruffness
	float r = 256.;
	vec3 n = hash22(floor(UV * r) / r).xyx * .11;
	NORMAL = normalize(NORMAL + mix(n, vec3(.0), 1.-inward * bottom_notches));

	ALBEDO = vec3(.01 * (inward));
	ALPHA = inner * bottom_notches;
}