shader_type spatial;
render_mode depth_draw_opaque,cull_back;

uniform float fov : hint_range(20, 120) = 40;
const float M_PI = 3.14159265359;
uniform sampler2D albedo_texture: source_color;

void vertex() {
    // recreate the camera projection matrix with our custom fov value 
    float scale = 1.0 / tan(fov * 0.5 * M_PI / 180.0); 
    PROJECTION_MATRIX[0][0] = -scale / (VIEWPORT_SIZE.x / -VIEWPORT_SIZE.y);
    PROJECTION_MATRIX[1][1] = -scale;
}

void fragment() {
	vec2 coords = UV;
	ALBEDO = texture(albedo_texture, UV).rgb;
	DEPTH = FRAGCOORD.z;
	DEPTH = FRAGCOORD.z * 3.0;
}