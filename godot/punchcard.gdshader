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
	vec2 uv = UV;

	vec3 white = vec3(.9,.9,.7);
	vec3 lines = vec3(.1);

	// let's make some boxes
	vec2 bv = uv * vec2(11., 33.)  + vec2(.2, .2);
	vec2 bh = hash22(floor(bv)*3.31234);
	bv = fract(bv);

	float outer = step(.4,bv.x) * step(.7, bv.y);
	float inner = 1. - step(.44,bv.x) * step(.74, bv.y) * step(bv.x,.97) * step(bv.y,.96);
	float fill = step(.6, bh.x); // fill about 40% of them
	float sides =  step(uv.y, .97) * step(.03, uv.y) * step(.2, uv.x) * step(uv.x, .9);
	float box = outer * (inner + fill) * sides;

	uv *= -VN.z; // flip the back:
	float notch = 1. - step(uv.x * .15, uv.y-.98); // FIXME: notch is only on the front for some reason!

	ALBEDO = mix(white, lines, box);
	ALPHA = (1. - box * fill ) * notch;
}