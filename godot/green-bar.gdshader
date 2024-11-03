shader_type spatial;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float xo = .02, xw = .00033;
	float perforations =   (
		step(fract(UV.y * 333.), .138)
		* step(abs(UV.x-xo), xw ) + step(xw, abs(UV.x -(1. - xo)))
	);
	vec3 white = vec3(.9) * (.8 + .2 * perforations);

	// green is darker on top and bottom
	float green_bars = fract(UV.y * 11. - .2); // how many green lines and offset
	vec3 green = vec3(.5,1.,.5) * (.6 + .4 * step(.01610, green_bars) * step(green_bars, .484));
	ALBEDO.rgb = mix(white, green, step(green_bars, .5) * step(.02,UV.x) * step(UV.x, .98));

	float hole_count = 32., hole_radius = .015;
	vec2 holistic = vec2(UV.x * hole_count +.2, fract(UV.y * hole_count *.77)); // this .77 is a lazy way to skip vertical space but...
	vec2 left = holistic -.5;
	vec2 right = holistic - vec2(hole_count -.125,.5);
	float left_d = dot(left, left);
	float right_d = dot(right, right);
	float hole = step(hole_radius, left_d) * step(hole_radius, right_d);
	ALPHA = hole;
}