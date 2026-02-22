shader_type canvas_item;

uniform float blink_state;
uniform vec4 blink_color;
void fragment() {

    vec2 center = vec2(0.5, 0.5);
    float dist = distance(UV, center);


    float radius = 0.5;
    float alpha = step(dist, radius) * blink_state * 0.1;

	COLOR = vec4(blink_color.rgb, alpha);
}
