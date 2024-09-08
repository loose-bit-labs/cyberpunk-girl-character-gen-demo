shader_type spatial;

render_mode skip_vertex_transform;
varying vec3 VN;
#include "res://common.gdshaderinc"

const vec3 BLUE   = vec3(.0,.0,1.);
const vec3 SILVER = vec3(.4,.4,.4);

int faceOff() {
	vec3 n = normalize(VN);
	if (n.x >  0.5) { return 5; }
	if (n.x < -0.5) { return 4; }
	if (n.y >  0.5) { return 3; }
	if (n.y < -0.5) { return 2; }
	if (n.z >  0.5) { return 1; }
	return 0;
}

float isSlider(vec2 uv) {
	int face = faceOff();
	switch(face) {
		case 0: uv.y = 1. - uv.y;
		case 1: 
			
			
			return 
			( 1.- step(uv.x, .6) * step(.45, uv.x) *  step(uv.y, .37) * step(.02,uv.y)    )
			*
			
			
			step(uv.y, .4) * step(uv.x, .88) * step(.4, uv.x);
		case 3: return step(uv.y,.88) * step(.4, uv.y);
	}
	return .0;
}

void vertex() {
	VN = NORMAL;
	VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
    NORMAL = normalize((MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
    BINORMAL = normalize((MODELVIEW_MATRIX * vec4(BINORMAL, 0.0)).xyz);
    TANGENT = normalize((MODELVIEW_MATRIX * vec4(TANGENT, 0.0)).xyz);
}

void fragment() {
	float slid = isSlider(UV);
	ALBEDO.rgb = mix(BLUE, SILVER, slid);
	
	//low fi ruffness
	float r = 128.;
	vec3 n = hash22(floor(UV * r) / r).xyx * .44;
	NORMAL = normalize(NORMAL +   mix(n, vec3(.0), slid));
}
