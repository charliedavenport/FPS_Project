shader_type spatial;
render_mode diffuse_toon;

const int H_FRAMES = 3;
const int V_FRAMES = 6;

uniform bool flipped;
uniform sampler2D tex : hint_albedo; 
uniform vec4 flash_color : hint_color = vec4(1.0);
uniform float flash_modifier : hint_range(0.0,1.0);
uniform int h_frame;
uniform int v_frame;

void vertex()
{
	// Recreate y-billboard effect. Copied from engine source code
	// https://github.com/godotengine/godot/blob/master/scene/resources/material.cpp#L793
	MODELVIEW_MATRIX = INV_CAMERA_MATRIX * mat4(CAMERA_MATRIX[0],WORLD_MATRIX[1],vec4(normalize(cross(CAMERA_MATRIX[0].xyz,WORLD_MATRIX[1].xyz)), 0.0),WORLD_MATRIX[3]);
	MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(vec4(length(WORLD_MATRIX[0].xyz), 0.0, 0.0, 0.0),vec4(0.0, 1.0, 0.0, 0.0),vec4(0.0, 0.0, length(WORLD_MATRIX[2].xyz), 0.0), vec4(0.0, 0.0, 0.0, 1.0));
}

void fragment() {
	vec2 new_uv = vec2(((UV.x + float(h_frame)) * 1.0/float(H_FRAMES)), 
					   ((UV.y + float(v_frame)) * 1.0/float(V_FRAMES)));
	if (flipped) {
		new_uv.x = -new_uv.x + ((2.0 * float(h_frame) + 1.0)/3.0);
	}
	vec4 col = texture(tex, new_uv);
	col.rgb = mix(col.rgb, flash_color.rgb, flash_modifier);
	ALBEDO = col.rgb;
	ALPHA = col.a;
}