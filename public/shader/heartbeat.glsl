#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;

const int MAX_STEPS = 32;
const float MAX_DISTANCE = 20.;
const float PI = 3.141592;
vec3 toLight = normalize(vec3(0., 10., -10.));

struct Ray{
	vec3 origin;
	vec3 dir;
};

Ray createCameraRay(vec2 coord){
	float fov = radians(90.0);
	float fx = tan(fov / 2.0) / u_resolution.x;
	vec2 d = (2.0 * coord - u_resolution) * fx;
	return Ray(vec3(0., 2.0, -3.), normalize(vec3(d, 1.0)));
}

mat2 rotate(float angle){
    return mat2(
		cos(angle),
		-sin(angle),
		sin(angle),
		cos(angle)
	);
}

float smin( float a, float b, float k )
{
    float res = exp2( -k*a ) + exp2( -k*b );
    return -log2( res )/k;
}

// from https://iquilezles.org/articles/distfunctions
float sdOctahedron(vec3 p, float s){
    p = abs(p);
    float m = p.x + p.y + p.z - s;
 	vec3 q;
    if( 3.0*p.x < m ) q = p.xyz;
    else if( 3.0*p.y < m ) q = p.yzx;
    else if( 3.0*p.z < m ) q = p.zxy;
    else return m*0.57735027;
    float k = clamp(0.5*(q.z-q.y+s),0.0,s); 
    return length(vec3(q.x,q.y-s+k,q.z-k)); 
}
 
vec2 distFunc(vec3 p){
	float tick = clamp(sin(u_time*0.75)*PI/2.,sin( PI/4.*0.75)*PI/2.,sin( PI/2.*0.75)*PI/2.);
	// wave pattern for plane
	float wave = sin(tick *p.x+u_time*0.25)
				* sin(tick *p.y+u_time*0.25)
				* sin(tick *p.z+u_time*0.25);
	float plane = dot(vec3(p.x,p.y, p.z), normalize(vec3(0,1.,0)))+wave;

	// octahedron movement
	p.y-=2.5+sin(u_time)*0.25;
	p.xz *= rotate(u_time*0.5);
	
	// displacement inspired by https://www.shadertoy.com/view/3sjSRD 
	const float disp = 5.;
	float displacement = sin(tick * p.x * disp)
	* cos(tick * p.y * disp)
	* sin(tick * p.z * disp) * 0.3;
	// two identical octahedron resulting in one with smooth edges
	float oct = smin(sdOctahedron(vec3(p.x, p.y, p.z), 1.5)+displacement,sdOctahedron(vec3(p.x, p.y, p.z), 1.5),7.);

	float d = min(oct,plane);
	
    int mat_id;
	if (oct < plane ){
		mat_id = 0;
	} else {
		mat_id = 1;
	}
    return vec2(d, mat_id);
}

vec3 getNormal(vec3 point, float delta){
	vec2 d = vec2(delta, 0.0);
	vec3 gradient = vec3(distFunc(point + d.xyy).x - distFunc(point - d.xyy).x,
		distFunc(point + d.yxy).x - distFunc(point - d.yxy).x,
		distFunc(point + d.yyx).x - distFunc(point - d.yyx).x);
	return normalize(gradient);
}

void main(){
    Ray ray = createCameraRay(gl_FragCoord.xy);
	vec3 col = vec3(0);
    float len = 0.;
    float obj_id;
	vec3 p = ray.origin;
    for(int i = 0; i < MAX_STEPS; i++) {
        vec2 d = distFunc(p);
		p += ray.dir * d.x;
		obj_id = d.y;
        len += d.x;
        if(len > MAX_DISTANCE){
			break;
		}
    }
	
	vec3 n = getNormal(p, 1e-3);
	float diff = clamp(dot(n, normalize(toLight)), 0., 1.);
	// object materials
	if(obj_id == 0.){
		col = diff* vec3(1.0, 0.0, 0.0);
	} else if (obj_id == 1.){
		col = diff* vec3(0.2549, 0.0235, 0.0235);
	}
    
	float fogAmount = 1. - exp( - len * 0.1 );
    col = mix(col, vec3(0.64, 0.49, 0.49), fogAmount);
	gl_FragColor = vec4(col,1.0);
}