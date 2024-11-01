
vec2 hash22seeded( in vec2 uv, in vec3 seed ) {
    vec3 q = fract( uv.xyx * vec3(19.191, 53.733, 73.761));
    q += dot(q, q + vec3(41.557, 23.929, 37.983) + seed);
    return fract(vec2( q.x * q.y, q.y * q.z ));
}

vec2 hash22( in vec2 uv) {
	return hash22seeded(uv, vec3(.0));
}

float triangle(float f) {
	return abs(fract(f) - .5);
}


const vec2 HEX_MOD = vec2( 1., sqrt( 3.));
const float HALB = .5;
const vec2 HEX_HALB = HALB * HEX_MOD;

float sdHex( vec2 uv ) {
    uv = abs( uv );
    float angled = dot( uv, normalize( HEX_MOD ) );
    float sides = uv.x;

    return max( angled, sides );
}

vec4 hexTile( vec2 uv ) {
    vec2 a = mod(uv,            HEX_MOD) - HEX_HALB;
    vec2 b = mod(uv + HEX_HALB, HEX_MOD) - HEX_HALB;

    vec2 nu = mix(b, a, step(dot(a, a), dot(b,b)));
    vec2 id = (uv - nu);

    float angle = .0;// not using this...atan( nu.x, nu.y );
    float d = .5 - sdHex( nu );

    return vec4(angle, d, id.x, id.y);
}