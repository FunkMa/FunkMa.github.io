#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;

const int MAX_STEPS = 64;
const float MAX_DISTANCE = 100.;
const float PI = 3.141592;

struct Ray{
	vec3 origin;
	vec3 dir;
};

Ray createCameraRay(vec2 coord){
	float fov = radians(90.0);
	float fx = tan(fov / 2.0) / u_resolution.x;
	vec2 d = (2.0 * coord - u_resolution) * fx;
	return Ray(vec3(0., -6.0, -5.5), normalize(vec3(d, 1.0)));
}

mat2 rotate(float angle){
    return mat2(
		cos(angle),
		-sin(angle),
		sin(angle),
		cos(angle)
	);
}

float sdSphere( vec3 p, float s )
{
    return length(p)-s;
}

float sdHexPrism( vec3 p, vec2 h )
{
    const vec3 k = vec3(-0.8660254, 0.5, 0.57735);
    p = abs(p);
    p.xy -= 2.0*min(dot(k.xy, p.xy), 0.0)*k.xy;
    vec2 d = vec2(
       length(p.xy - vec2(clamp(p.x, -k.z*h.x, k.z*h.x), h.x))*sign(p.y - h.x),
       p.z-h.y );
    return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

vec2 distFunc(vec3 p){
    
    vec2 singleHexPrism = vec2(
        int(mod(u_time, 1.)),
        int(mod(u_time, 2.)) );
    singleHexPrism = vec2(0);
    float time_int = mod(float(int(u_time)), 4.);
   
    float row = step(-1. + (4.*time_int), p.y) 
        - step( 3. + (4.*time_int), p.y);
	float col = step(-1. + (4.*time_int), p.x) 
        - step( 3. + (4.*time_int), p.x);
    float element = row * col;



    p.xy =  mod(p.xy+1., 4.) - 2.;
 
    float jump = 1.5 * abs(sin(u_time*element*PI));
 
    float plane = sdHexPrism(vec3(p.x, p.y-0.5, p.z + jump),
         vec2(1.5,2.0));
    
    float sphere2 = sdSphere(vec3(p.x, p.y-0.5, p.z + 2. + jump),1.2);
    float sphere = sdSphere(vec3(p.x, p.y-0.5, p.z + 2. + jump * 2.),1.);
 
    float d;
    d = max(plane, -sphere2);
    d = min(d, sphere); 

    int mat_id;
	mat_id = 0;

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
 
    ray.dir.zy *= rotate(PI/2.);
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
    vec3  lig = normalize( vec3(15., 0., -10.) );
	float diff = clamp(dot(n, normalize(lig)), 0., 1.);

	// object materials
	if(obj_id == 0.){
        vec2 pattern = floor(p.xy * 4.);
        float checker = mod(pattern.x , 2.0);
		col = diff * mix(vec3(0.41568, 0.721568, 0.), vec3(0.21568, 0.5372, 0.0), checker);;
        
    }
    col = mix( col, vec3(0.7,0.7,0.9), 1.0-exp( -0.0001*len*len*len ) );
	gl_FragColor = vec4(col,1.0);
}