#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;

struct Ray {
    vec3 origin;
    vec3 direction;
};

struct Light {
    vec3 color;
    vec3 direction;
};

struct Material {
    vec3 color;
    float diffuse;
    float specular;
    float refractive;
};

struct Object
{
	vec4 data;
	int type; //PLANE, SPHERE, ...
    Material material;
};

struct Intersect {
    float len;
    vec3 normal;
    Object object;
};



const int PLANE = 0;
const int SPHERE = 1;

const int NUM_OBJECTS = 10;
Object objects[NUM_OBJECTS];

const float epsilon = 1e-3;

const vec3 ambient = vec3(0.6, 0.8, 1.0) ;

Light light = Light(vec3(1.0) , normalize(
                vec3(-1.0 + 4.0 * cos(u_time), 4.75,
                      1.0 + 4.0 * sin(u_time))));

// from https://www.shadertoy.com/view/4djSRW
vec2 hash2(vec2 seed) {
	vec3 p3 = fract(vec3(seed.xyx) * vec3(0.1031, 0.1030, 0.0973));
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.xx + p3.yz) * p3.zy);
}

vec2 rand2(vec2 a) { return hash2(a += vec2(0.1)); }
float frand(vec2 co) {return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453); }

vec2 randomInUnitDisk( vec2 seed ) {
    vec2 h = hash2(seed) * vec2(1,6.28318530718);
    float phi = h.y;
    float r = sqrt(h.x);
	return r*vec2(sin(phi),cos(phi));
}

const Intersect miss = Intersect(0.0, vec3(0.0), Object(vec4(0.), 0, Material(vec3(0.0), 0.0, 0.0, 0.)));

Intersect intersect(Ray ray, Object obj) {
    Intersect ret = miss;
    if(obj.type == SPHERE){
		vec3 oc = ray.origin - obj.data.xyz;
		float dotDirOC = dot(oc,ray.direction);
		float root = pow(dotDirOC, 2.0)- dot(oc,oc) + pow(obj.data.w, 2.);
		if( root > 0.0 ) root = -dotDirOC-sqrt(root);
        if (root > epsilon) ret = Intersect(root, normalize(ray.origin + root*ray.direction - obj.data.xyz), obj);
    } else if (obj.type == PLANE){
        // Do Plane intersection
        float len = -obj.data.w -dot(obj.data.xyz, ray.origin) / dot(obj.data.xyz, ray.direction);
        if (len > epsilon){
            // Overwrite color with chessboard pattern
            vec3 point = ray.origin + len * ray.direction;
            vec2 p = floor(point.xz * 2.0);
		    float checker = mod(p.x + p.y, 2.0);
		    obj.material = Material(mix(vec3(0.5), vec3(1), checker), obj.material.diffuse, obj.material.specular, obj.material.refractive);
            ret = Intersect(len, obj.data.xyz, obj);
        }
    }
    return ret;
}

Intersect findNearestObjectHit(Ray ray) {
    Intersect intersection = miss;
    for (int i = 0; i < NUM_OBJECTS; i++) {
        Intersect obj_intersect = intersect(ray, objects[i]);
        if (obj_intersect.len > 0.0)
            intersection = obj_intersect;
    }
    return intersection;
}

bool shadowSphere( in vec3 ro, in vec3 rd, in vec3 cen, in float rad, in float tmax ){
	vec3 oc = ro - cen;
	float b = dot( oc, rd );
	float c = dot( oc, oc ) - rad*rad;
	float h = b*b - c;
	if( h<0.0 ) return false;
	float t = -b - sqrt( h );
    return t>0.0 && t<tmax;
}

float softShadow( vec3 ro, vec3 rd, float w ){
    vec3 uu = normalize(cross(rd,vec3(0,1,0)));
    vec3 vv = normalize(cross(rd,uu));
    
    float tot = 0.0;
    const int shadowRays = 64; 
	for( int j=0; j<shadowRays; j++ ){
        // uniform distribution on an disk
        float ra = sqrt(frand(vec2(j*17,j*19)));
        float an = 6.283185*frand(vec2(j*11,j*21));
        vec3 jrd = normalize(rd + w*ra*(uu*cos(an)+vv*sin(an)));
        
        // raycast
        float res = 1.0;
        for( int i=1; i<NUM_OBJECTS; i++ ){
            bool sha = false;
            sha = shadowSphere(ro, jrd, objects[i].data.xyz, objects[i].data.w, 3.);
            if(sha){ 
                res=0.0; 
                break; 
            }
        }
        tot += res;
    }
    return tot/float(shadowRays);
}

vec3 traceRay(Ray ray){
	const int iterations = 10;

    vec3 color = vec3(0.0);
    float fresnel = 0.0;
    vec3 mask = vec3(1.0);
    
    for (int i = 0; i <= iterations; ++i) {
        Intersect hit = findNearestObjectHit(ray);
        if (hit.len > 0.0) {

			vec3 pt = ray.origin + ray.direction * hit.len;
			float ndotv = clamp(dot(hit.normal, -ray.direction), 0.0, 1.0);
			fresnel = hit.object.material.specular + (1.0 - hit.object.material.specular) * pow(1.0 - ndotv, 5.0);
            mask *= fresnel;
            
			if(hit.object.material.refractive > 0.0){
                // Refract
				ray.origin = pt - hit.normal * epsilon;
				ray.direction = refract(ray.direction, hit.normal, hit.object.material.refractive);
                mask = hit.object.material.color * (1.0 - fresnel) * (mask / fresnel);
			} else if(hit.object.material.specular > 0.0){
                // Reflect
                Intersect shadowRay = findNearestObjectHit(Ray(ray.origin + hit.len * ray.direction + epsilon * light.direction, light.direction));
                ray.origin = pt + hit.normal * epsilon;
				ray.direction = reflect(ray.direction, hit.normal);
                if (shadowRay == miss) {
                    // Not in Shadow
                    float diff = clamp(dot(hit.normal,light.direction),0.0,1.0);
                    color += ((1.0-hit.object.material.diffuse) * hit.object.material.color * light.color + light.color * diff * hit.object.material.diffuse * hit.object.material.color) * (1.0 - fresnel) * mask / fresnel;
                } else {    
                    // In Shadow of another Object                                                                       
                    float diff = clamp(dot(hit.normal,light.direction),0.0,1.0)*softShadow(pt, light.direction, 0.5) ;
                    color += diff * hit.object.material.color * light.color* (1.0 - fresnel) * mask / fresnel;
                }
			} else {
                // Diffuse
                if (findNearestObjectHit(Ray(ray.origin + hit.len * ray.direction + epsilon * light.direction, light.direction)) == miss) {
                    float diff = clamp(dot(hit.normal,light.direction),0.0,1.0);
                    color += ((1.0-hit.object.material.diffuse) * 8.* hit.object.material.color * light.color + light.color * diff * hit.object.material.diffuse * hit.object.material.color) * (1.0 - fresnel) * mask / fresnel;
                } 
            }
        } else {
            vec3 spotlight = vec3(1e3) * pow(abs(dot(ray.direction, light.direction)), 250.0);
			color += mask * (ambient + spotlight);
            break;
        }
    }

	return color;
}


void main() {
    // Plane
    objects[0] = Object(vec4(0, 1, 0, 0), PLANE, Material(vec3(0.), 1., 1e-7, 0.));
    // Spheres
    objects[1] = Object(vec4(-15, 1.0 , -15, 1.), SPHERE, Material(vec3(0.17, 1.0, 0.0), 0.5, 0.5, 0.));
    objects[2] = Object(vec4(-10, 1.0 , -10, 1.), SPHERE, Material(vec3(0.0, 0.75, 1.0), 0.5, 0.5, 0.));
    objects[3] = Object(vec4(0, 1.0 , -30., 1.), SPHERE, Material(vec3(1.0, 0.77, 0.0), 0.5, 0.5, 0.));
    objects[4] = Object(vec4(3.0, 3, 0, 3.), SPHERE, Material(vec3(0.58, 0.15, 0.53), 0.5, 1e-7, 0.));
    objects[5] = Object(vec4(-2.5, 2.0 , 0, 2.), SPHERE, Material(vec3(1.0, 0.0, 0.2), 0.5, 0.5, 0.));
    objects[6] = Object(vec4( .0 + cos(u_time * 0.25) * 3., 3.0, 2, 2.), SPHERE, Material(vec3(1.0), 0.5, 0.1, 0.8));
    objects[7] = Object(vec4(1, .5 , 6., 0.5), SPHERE, Material(vec3(1.0, 0.77, 0.0), 0.5, 0.5, 0.));
    objects[8] = Object(vec4(-1, .5 , 5., 0.5), SPHERE, Material(vec3(0.76, 0.58, 0.58), 1., 0.01, 0.9));
    
    vec3 color = vec3(0.43, 0.13, 0.13);
    const float focalLenght = 5.5;
	const int SAMPLES = 15;

	for(int i = 0; i < SAMPLES; ++i){
		// Camera
		float angle = 70.;
		float fov = radians(angle);
		float fx = tan(fov / 2.0) / u_resolution.x;
        
		//vec2 d = (2. * gl_FragCoord.xy - u_resolution) * fx;
		vec2 d = (2. * gl_FragCoord.xy + rand2(gl_FragCoord.xy) - u_resolution) * fx;
		Ray ray = Ray(vec3(0.0, 2.5, 10.0), normalize(vec3(d.x, d.y, -1.0)));

        // Depth of field
        vec3 focalPoint = ray.origin + ray.direction * focalLenght;
        ray.origin = ray.origin + vec3(randomInUnitDisk(vec2(float(i)*gl_FragCoord.x,float(i)*gl_FragCoord.y)), 0.)*0.05;
        ray.direction = normalize(focalPoint - ray.origin);
        
		color += traceRay(ray);
	}
	color /= float(SAMPLES);
    gl_FragColor = vec4(color , 1.0);
}
