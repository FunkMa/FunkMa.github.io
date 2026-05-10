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
	vec3 pos;
    vec3 size;
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
const int BOX = 2;

const float epsilon = 1e-3;
const float MAX_HIT_LEN = 1e6;

const vec3 ambient = vec3(0.7608, 0.9294, 0.902) ;

const Intersect miss = Intersect(MAX_HIT_LEN, vec3(0.0), Object(vec3(0.), vec3(0.), 0, Material(vec3(0.), 0.0, 0.0, 0.)));

Light light = Light(vec3(0.67, 0.88, 0.88) , normalize(
                vec3(-5.0 + 4.0 * cos(u_time), 50.,
                      9.0 + 4.0 * sin(u_time))));

// from https://www.shadertoy.com/view/4djSRW
vec2 hash2(vec2 seed) {
	vec3 p3 = fract(vec3(seed.xyx) * vec3(0.1031, 0.1030, 0.0973));
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.xx + p3.yz) * p3.zy);
}

float randomFloat(float f){
    return fract(sin(dot(f, 12.9898)));
}

vec3 randomColor(float num){
    return vec3(fract(sin(dot(num, randomFloat(12.9898)))),
                fract(sin(dot(num, randomFloat(43758.5453123)))),
                fract(sin(dot(num, randomFloat(758.233)))));
}

vec2 randomInUnitDisk( vec2 seed ) {
    vec2 h = hash2(seed) * vec2(1,6.28318530718);
    float phi = h.y;
    float r = sqrt(h.x);
	return r*vec2(sin(phi),cos(phi));
}

mat4 translate( vec3 pos ){
    return mat4( 1.0, 0.0, 0.0, 0.0,
				 0.0, 1.0, 0.0, 0.0,
				 0.0, 0.0, 1.0, 0.0,
				 pos.x,   pos.y,   pos.z,   1.0 );
}

mat4 inverse( in mat4 m ){
	return mat4(
        m[0][0], m[1][0], m[2][0], 0.0,
        m[0][1], m[1][1], m[2][1], 0.0,
        m[0][2], m[1][2], m[2][2], 0.0,
        -dot(m[0].xyz,m[3].xyz),
        -dot(m[1].xyz,m[3].xyz),
        -dot(m[2].xyz,m[3].xyz),
        1.0 );
}

// https://www.shadertoy.com/view/ld23DV
Intersect iBox( vec3 ro, vec3 rd, Object obj ) 
{
    mat4 tra = translate( obj.pos.xyz );
	mat4 txx = inverse( tra );

    // convert from ray to box space
	vec3 rdd = (txx*vec4(rd,0.0)).xyz;
	vec3 roo = (txx*vec4(ro,1.0)).xyz;

	// ray-box intersection in box space
    vec3 m = 1.0/rdd;
    vec3 k = vec3(rdd.x>=0.0?obj.size.x:-obj.size.x, rdd.y>=0.0?obj.size.y:-obj.size.y, rdd.z>=0.0?obj.size.z:-obj.size.z)
        * obj.size.xyz;

    vec3 t1 = (-roo - k)*m;
    vec3 t2 = (-roo + k)*m;

    float tN = max(max(t1.x,t1.y),t1.z);
    float tF = min(min(t2.x,t2.y),t2.z);
    
    // no intersection
	if( tN>tF || tF<0.0 ) return miss;

    // use this instead if your rays origin can be inside the box
    vec4 res = (tN>0.0) ? vec4( tN, step(vec3(tN),t1)) :
                          vec4( tF, step(t2,vec3(tF)));
    
    // add sign to normal and convert to ray space
	res.yzw = (tra * vec4(-sign(rdd)*res.yzw,0.0)).xyz;

	return Intersect(res.x, res.yzw, obj);
}

Intersect intersect(Ray ray, Object obj) {
    Intersect ret = miss;
    if(obj.type == SPHERE){
		vec3 oc = ray.origin - obj.pos.xyz;
		float dotDirOC = dot(oc,ray.direction);
		float root = pow(dotDirOC, 2.0)- dot(oc,oc) + pow(obj.size.x, 2.);
		if( root > 0.0 ) root = -dotDirOC-sqrt(root);
        if (root > epsilon) ret = Intersect(root, normalize(ray.origin + root*ray.direction - obj.pos.xyz), obj);
    } else if (obj.type == PLANE){
        // Do Plane intersection
        float len = -obj.size.x -dot(obj.pos.xyz, ray.origin) / dot(obj.pos.xyz, ray.direction);
        if (len > epsilon){
            // Overwrite color with chessboard pattern
            vec3 point = ray.origin + len * ray.direction;
            vec2 p = floor(point.xz * 2.0);
		    float checker = mod(p.x + p.y, 2.0);
		    obj.material = Material(mix(vec3(0.5), vec3(1), checker), obj.material.diffuse, obj.material.specular, obj.material.refractive);
            ret = Intersect(len, obj.pos.xyz, obj);
        }
    } else if (obj.type == BOX){
        ret = iBox(ray.origin, ray.direction, obj);
    }
    return ret;
}

Intersect findNearestObjectHit(Ray ray) {
    Intersect intersection = miss;
    // refractive sphere
    Intersect obj_intersect = intersect(ray, Object(vec3( 30.0, -80, -30.), vec3( 60.), SPHERE, Material(vec3(0.5, 0.61, 0.93), 0.3, 0.3, 0.5)));
    if (obj_intersect.len > 0.0 && obj_intersect.len < intersection.len)
        intersection = obj_intersect;
    
    // box grid
    Object cube = Object(vec3(0.,0.0,0.0), vec3(1.225,1.,1.225), BOX, Material(vec3(0.), 0.5, 0.2, 0.));
    for (int x = 1; x <= 10; x++) {
        cube.pos.z = 0.;
        for (int z = 1; z <= 10; z++) {
            float seed = 2.*float(x)*3.21+(float(z)*1.23);
            cube.pos.y = randomFloat(seed);
            // view in graphtoy https://graphtoy.com/?f1(x,t)=fract((x)*0.4)*80.-40.&v1=false&f2(x,t)=floor(clamp(abs(fract((x)*0.25)*80.-40.),0.,1.))&v2=true&f3(x,t)=floor(0.05*x)&v3=false&f4(x,t)=fract((x-10.)*0.05)*100.-50.&v4=false&f5(x,t)=floor(clamp(abs(fract((x-10.)*0.05)*80.-40.),0.,1.))&v5=false&f6(x,t)=floor(0.25*x)&v6=true&grid=1&coords=-1.522490397026025,-0.48826847919843663,15.072732630063019
            float frequency = floor(0.05*u_time*4.+1.);
            float drop_movement = fract((u_time*4.-10.)*0.05)*100.-50.;
            float async_frequency = floor(0.25*u_time+1.);
            float async_drop_movement = fract((u_time+10.)*0.25)*100.-50.;
            if (randomFloat(seed * frequency * 1.5) > 0.95){
                cube.pos.y -= drop_movement * 1.5;
            }
            else if (randomFloat(seed * frequency * 3.) > 0.95){
                cube.pos.y -= drop_movement * 3.;
            }
            else if (randomFloat(seed *5.4321* async_frequency) > 0.95){
                cube.pos.y -= async_drop_movement;
            }
            cube.material.color = randomColor(seed);
            obj_intersect = intersect(ray, cube);
            if (obj_intersect.len > 0.0 && obj_intersect.len < intersection.len)
                        intersection = obj_intersect;
            cube.pos.z -= 3.;
        }
        cube.pos.x += 3.;
    }  
    return intersection;
}

// box soft shadow by iq https://www.shadertoy.com/view/WslGz4
float dot2( in vec3 v ) { return dot(v,v); }

float segShadow( in vec3 ro, in vec3 rd, in vec3 pa, float sh )
{
    float dm = dot(rd.yz,rd.yz);
    float k1 = (ro.x-pa.x)*dm;
    float k2 = (ro.x+pa.x)*dm;
    vec2  k5 = (ro.yz+pa.yz)*dm;
    float k3 = dot(ro.yz+pa.yz,rd.yz);
    vec2  k4 = (pa.yz+pa.yz)*rd.yz;
    vec2  k6 = (pa.yz+pa.yz)*dm;
    
    for( int i=0; i<4; i++ )
    {
        vec2  s = vec2(i);
        float t = dot(s,k4) - k3;
        
        if( t>0.0 )
        sh = min(sh,dot2(vec3(clamp(-rd.x*t,k1,k2),k5-k6*s)+rd*t)/(t*t));
    }
    return sh;
}

// https://iquilezles.org/articles/boxfunctions
float boxSoftShadow( in vec3 ro, in vec3 rd, Object obj, in float sk ) 
{
    mat4 tra = translate( obj.pos.xyz );
	//mat4 txi = tra *rot; 
    mat4 txi = tra;
	mat4 txx = inverse( txi );

	vec3 rdd = (txx*vec4(rd,0.0)).xyz;
	vec3 roo = (txx*vec4(ro,1.0)).xyz;

    vec3 m = 1.0/rdd;
    vec3 n = m*roo;
    vec3 k = abs(m)*obj.size;
	
    vec3 t1 = -n - k;
    vec3 t2 = -n + k;

    float tN = max( max( t1.x, t1.y ), t1.z );
	float tF = min( min( t2.x, t2.y ), t2.z );
	
    if( tN<tF && tF>0.0) return 0.0;
    
    float sh = 1.0;
    sh = segShadow( roo.xyz, obj.size.xyz, obj.size.xyz, sh );
    sh = segShadow( roo.yzx, rdd.yzx, obj.size.yzx, sh );
    sh = segShadow( roo.zxy, rdd.zxy, obj.size.zxy, sh );
    sh = clamp(sk*sqrt(sh),0.0,1.0);
    return sh*sh*(3.0-2.0*sh);
}


vec3 traceRay(Ray ray){
	const int iterations = 10;

    vec3 color = vec3(0.0);
    float fresnel = 0.0;
    vec3 mask = vec3(1.0);
    
    for (int i = 0; i <= iterations; ++i) {
        Intersect hit = findNearestObjectHit(ray);
        if (hit.len > 0.0 && hit.len < MAX_HIT_LEN) {

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
                    float diff = 1.;
                    if(hit.object.type == BOX){
                        diff = clamp(dot(hit.normal,light.direction),0.0,1.0)*boxSoftShadow(ray.origin,light.direction,hit.object, 4.);
                    }                                                       
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
			color += mask * (ambient+spotlight );
            break;
        }
    }

	return color;
}

void main() {
    vec3 color = vec3(0.0);

	bool enable_dof_and_mb = false;

     // Camera
    float angle = 60.;
    float fov = radians(angle);
    float fx = tan(fov / 2.0) / u_resolution.x;
    
    vec2 d = (2. * gl_FragCoord.xy - u_resolution) * fx;
    Ray ray = Ray(vec3(.0, 10., 20.0), normalize(vec3(d.x+0.5, d.y-0.5, -1.0)));

	if(enable_dof_and_mb){
		const float focalLenght = 25.;
		const int SAMPLES = 8;

		for(int i = 0; i < SAMPLES; ++i){
			// Depth of field
			vec3 focalPoint = ray.origin + ray.direction * focalLenght;
			ray.origin = ray.origin + vec3(randomInUnitDisk(vec2(float(i)*gl_FragCoord.x,float(i)*gl_FragCoord.y)), 0.)*0.05;
			ray.direction = normalize(focalPoint - ray.origin);
			
			color += traceRay(ray);
		}
		color /= float(SAMPLES);
	} else {
			color = traceRay(ray);
	}
    gl_FragColor = vec4(color , 1.0);

}
