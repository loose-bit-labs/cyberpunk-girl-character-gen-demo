shader_type spatial;

uniform vec3 SEED = vec3(22., 33., 44.);
uniform vec2 OFFSET = vec2(.0);
uniform bool NEXT = false;

// can't seem to make this work...
#define RAW_WORLD_
#ifdef RAW_WORLD
render_mode skip_vertex_transform;
varying vec3 OG_VERTEX;
#endif

varying float IS_BUILDING;

const float GRID = 16. * .5;
const float FUDGE = .009;
const vec2 OFFSET_X = vec2(FUDGE,.0);
const vec2 OFFSET_Y = OFFSET_X.yx;

const float BUILDING_THRESHOLD = .31;
const float BUILDING_LO = 5.5   * 2.2;
const float BUILDING_HI = 31.13 * 2.2;
const float BUILDING_STEPS = 7.;

const float LZ_BARE = .22; 

const vec3 UP    = vec3(.0, .0, 1.); // blue
const vec3 NORTH = vec3(.0, 1., .0); // green
const vec3 EAST  = vec3(1., .0, .0); // red

#include "res://common.gdshaderinc"

vec2 hash(in vec2 uv) {
	return hash22seeded(uv, SEED);
}

float step_up(float f) {
	return smoothstep(BUILDING_THRESHOLD, BUILDING_THRESHOLD+FUDGE, f);
}

float getGrid() {
	return GRID; 
	// won't work...
	vec2 h = hash(OFFSET);
	float g = .5 * h.x  + .5;
	return GRID  * g;
}

float building(in vec2 xy, in vec2 og) {
	// flip direction possibly
	vec2 quirk = abs(hash(floor(og)));
	xy = mod(1. + xy * (step(.5, quirk) * 2. - 1.), 1.);

	// make sort of an l shape
	float mx = step(xy.x, xy.y);
	float my = 1. - mx;

	float l = .1 + .95 * quirk.x;
	xy *= 1. + vec2(mx, my) * l;

	// leave some space for the drop
	vec2 bc = og - getGrid() * .33;
	float bare = step(LZ_BARE, dot(bc, bc));

	return step_up(xy.x) * step_up(xy.y) * bare;
}

float tile(in vec2 xy, float scale) {
	return step(.1, building(fract(xy * scale), xy * scale));
}

float max5(float a, float b, float c, float d, float e) {
	//return a + b + c + d + e;
	return max(a,max(b,max(c,max(d,e))));
}

float min5(float a, float b, float c, float d, float e) {
	//return a * b * c * d * e;
	return min(a,min(b,min(c,min(d,e))));
}

float goMax(vec2 st ) {
	return max5(
		tile(st, getGrid()),
		tile(st+OFFSET_X, getGrid()),
		tile(st-OFFSET_X, getGrid()),
		tile(st+OFFSET_Y, getGrid()),
		tile(st-OFFSET_Y, getGrid())
	);
}

float goMin(vec2 st ) {
	return min5(
		tile(st, getGrid()),
		tile(st+OFFSET_X, getGrid()),
		tile(st-OFFSET_X, getGrid()),
		tile(st+OFFSET_Y, getGrid()),
		tile(st-OFFSET_Y, getGrid())
	);
}

vec3 map_normal(vec2 st) {
	float f = 1.5;
	float me = tile(st.xy, getGrid());
	float e = tile(st+OFFSET_X *f, getGrid());
	float w = tile(st-OFFSET_X *f, getGrid());
	float s = tile(st+OFFSET_Y *f, getGrid());
	float n = tile(st-OFFSET_Y *f, getGrid());

	float maxo = .33;

	if (abs(me - e) + abs(e - w) + abs(w - s) + abs(s - n) < maxo) return UP;

	f = step(.0, me) * 2. -1.;
	if (abs(me - e) + abs(me-w)<maxo) { // me == e && me == w)
		if (abs(n - me)<maxo) f = -1.;
		return -f *  NORTH; // swapped?
	}
	if (abs(me-e) < maxo) f = -1.;
	return f * EAST; // swapped?
}

// inspired by //https://www.shadertoy.com/view/WljcRG
float jarblish(in vec2 uv) {
	int qf = 8888;
	ivec2 qi = ivec2(uv * float(qf));
	int qr = qi.x ^ qi.y;
	qi.y += qf / 4;
	bool qa = abs(qr * qr * qr ) / qi.y % (qf*8) < qf;
	return float(qa);
}

vec3 ground_color(in vec2 uv) {
	vec4 hex = hexTile(uv * 2222.);
	vec3 color = vec3(.4,.7,.4) * smoothstep(.02120,.02020, hex.y);
	return color + jarblish(uv - TIME * .001);
}

vec3 wall_color(in vec2 uv, in vec3 p, in vec3 n) {
	// really not sure how to map into texture space nicely....
#if 0
	vec2 st = (UP3 == abs(n)) ? uv : (88. * uv + vec2(.0, p.y * .1));
#else
	vec2 st = 88. * uv + vec2(.0, p.y * .1);
#endif
	st += TIME * .003300;

	st = fract(st);
	return step_up(st.x) * step_up(st.y) * vec3(.9);
}

vec3 fragment_playing(in vec2 uv , in vec3 p, in vec3 n) {
	float l = goMax(uv); // works better than using IS_BUILDING

	// not happy with this: l = BUILDING;
	l = mix(l, IS_BUILDING, .33);	 

	vec3 color = mix(ground_color(uv), wall_color(uv, p, n), l);
	vec2 quirk = abs(hash(floor(99. * uv + TIME * 4.4)));
	color *= 1. + step(.88 * 2., quirk.x + quirk.y);
	return color;
}

vec3 fragment_next(in vec2 uv, in vec3 p, in vec3 n) {
	return vec3(1.) *  jarblish(uv * 2. + TIME * .01);
	// float d =
	vec4 hex = hexTile(uv * 222.);
	vec2 id = hex.zw * 134.34 + TIME * .005;

	vec2 quirk = abs(hash(id));
	float on = step(.6, quirk.x); // step(.3, fract(hex.z* 134.34 + TIME * .3));
	return vec3(.8,.3,.4)  * hex.y * 3. * on;
	return p;
}

vec2 nowUVme(vec2 uv) {
	return uv.xy + OFFSET - .2;
}

void fragment() {
	vec2 uv = nowUVme(UV);
	vec3 p = VERTEX;
#ifdef RAW_WORLD
	p = OG_VERTEX;
#endif
	ALBEDO.rgb = NEXT ? fragment_next(uv, p, NORMAL) : fragment_playing(uv, p, NORMAL);
	
	////uv = step(.9, fract(uv *33.));
	//ALBEDO.rgb = vec3(uv.x * uv.y);
}

void vertex() {
#ifdef RAW_WORLD
	// dox claim you can do this yourself, but it does not seem to work
	// as I expected
 	OG_VERTEX = VERTEX;
	VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
    NORMAL = normalize((MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
    BINORMAL = normalize((MODELVIEW_MATRIX * vec4(BINORMAL, 0.0)).xyz);
    TANGENT = normalize((MODELVIEW_MATRIX * vec4(TANGENT, 0.0)).xyz);
#endif

	vec2 uv = nowUVme(UV);
	float building = goMin(uv);
	IS_BUILDING = building;

	vec2 quirk = abs(hash(floor(uv * getGrid() * .77)));
	float m = floor(quirk.x * BUILDING_STEPS) / BUILDING_STEPS;
	
	VERTEX.y = building * mix(BUILDING_LO, BUILDING_HI, m) * 1.03;
	NORMAL = normalize(map_normal(uv));
}