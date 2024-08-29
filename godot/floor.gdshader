shader_type spatial;

const float GRID = 16.  *.5;
const float UP = .61;
const float HI = 9.9;

float square( in vec2 xy ) {
	float s = UP;
	return step(UP, xy.x) * step(s, xy.y);
}

float rectangle(in vec2 xy, in vec2 og) {
	float f = 2.2;
	if (int(og.x) > int(og.y))
	xy.x *= f;
	else xy.y *= f;

	float s = UP;
	return step(s, xy.x) * step(s, xy.y);
}

float circle( in vec2 xy ) {
	xy -= vec2( 0.5 );
	return step( 0.5 * 0.5 * 0.77, dot( xy, xy ) );
}

float tile(in vec2 xy, float scale) {
	return rectangle(fract(xy * scale), xy * scale);
	return circle(fract(xy * scale));
}

float goMax(vec2 st ) {
	float fudge = .01;
	vec2 xf = vec2(fudge,.0);
	vec2 yf = vec2(.0,fudge);

	float n0 = tile(st, GRID);
	float xa = tile(st+xf, GRID);
	float xb = tile(st-xf, GRID);
	float ya = tile(st+yf, GRID);
	float yb = tile(st-yf, GRID);

	return max(n0,max(xa,max(xb,max(ya,yb))));
}

float goMin(vec2 st ) {
	float fudge = .001;
	vec2 xf = vec2(fudge,.0);
	vec2 yf = vec2(.0,fudge);

	float n0 = tile(st, GRID);
	float xa = tile(st+xf, GRID);
	float xb = tile(st-xf, GRID);
	float ya = tile(st+yf, GRID);
	float yb = tile(st-yf, GRID);

	return min(n0,min(xa,min(xb,min(ya,yb))));
}
void  fragment() {
	float l = goMax(UV.xy - .2);
	vec3 c1 = vec3(.2, .2, .2); // ground
	vec3 c2 = vec3(.7, .7, .9); // walls

	//c2 = vec3( .3 + square(VERTEX.xz * 77.7));
	vec3 c = mix(c1, c2, l);
	ALBEDO.rgb = c;
}
void vertex() {
	float building = goMin(UV.xy-.2);
	VERTEX.y = building * HI;
	if (building> .0) NORMAL = normalize(vec3(1.,.0,1.)); // lol, this is terrible!
}