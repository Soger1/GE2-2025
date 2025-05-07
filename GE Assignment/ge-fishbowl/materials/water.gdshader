shader_type spatial;

// Water properties
uniform vec4 deep_color : source_color = vec4(0.0, 0.1, 0.4, 0.8);
uniform vec4 shallow_color : source_color = vec4(0.0, 0.4, 0.8, 0.5);
uniform float metallic : hint_range(0.0, 1.0) = 0.1;
uniform float roughness : hint_range(0.0, 1.0) = 0.05;

// Wave properties
uniform float wave_speed = 0.0001;
uniform float wave_strength = 0.0001;
uniform vec2 wave_direction_1 = vec2(0.00, 0.0);
uniform vec2 wave_direction_2 = vec2(0.00, 0.0);
uniform sampler2D wave_noise: hint_default_white;

// Caustics properties
uniform sampler2D caustics_texture: hint_default_white;
uniform float caustics_strength = 0.3;
uniform float caustics_scale = 5.0;
uniform float caustics_speed = 0.1;

// Refraction and depth properties
uniform float refraction_scale = 0.2;
uniform float depth_scale = 1.0;

// Functions for creating wave movement
vec2 calculate_wave_uv_offset(vec2 uv, float time, vec2 direction) {
    return direction * time * wave_speed * 0.05;
}

float calculate_wave_height(vec2 uv, float time, vec2 direction) {
    vec2 wave_uv = uv * 10.0 + calculate_wave_uv_offset(uv, time, direction);
    float height = texture(wave_noise, wave_uv).r;
    return height * 2.0 - 1.0;
}

void vertex() {
    // Calculate time-based wave movement
    float time = TIME;
    
    // Calculate wave heights from different directions
    float wave1 = calculate_wave_height(UV, time, wave_direction_1);
    float wave2 = calculate_wave_height(UV, time, wave_direction_2);
    
    // Combine waves and apply to vertex positions
    float combined_waves = (wave1 + wave2) * wave_strength;
    VERTEX.y += combined_waves;
    
    // Calculate normal based on the wave gradient
    NORMAL = normalize(vec3(
        combined_waves - calculate_wave_height(UV + vec2(0.01, 0.0), time, wave_direction_1) - 
                         calculate_wave_height(UV + vec2(0.01, 0.0), time, wave_direction_2),
        1.0,
        combined_waves - calculate_wave_height(UV + vec2(0.0, 0.01), time, wave_direction_1) - 
                         calculate_wave_height(UV + vec2(0.0, 0.01), time, wave_direction_2)
    ));
}

void fragment() {
    // Calculate time-based effects
    float time = TIME;
    
    // Calculate wave heights for this fragment
    float wave1 = calculate_wave_height(UV, time, wave_direction_1);
    float wave2 = calculate_wave_height(UV, time, wave_direction_2);
    float combined_waves = (wave1 + wave2) * 0.5;
    
    // Caustics calculation
    vec2 caustic_uv = UV * caustics_scale;
    caustic_uv += vec2(time * caustics_speed * 0.2, time * caustics_speed * 0.1);
    vec3 caustics = texture(caustics_texture, caustic_uv).rgb;
    
    // Moving caustics with a second offset
    vec2 caustic_uv2 = UV * caustics_scale * 1.2;
    caustic_uv2 += vec2(time * caustics_speed * -0.15, time * caustics_speed * 0.3);
    vec3 caustics2 = texture(caustics_texture, caustic_uv2).rgb;
    
    // Combine caustics layers
    caustics = max(caustics, caustics2);
    
    // Basic water coloring
    vec3 water_color = mix(deep_color.rgb, shallow_color.rgb, 0.5);
    
    // Apply caustics
    ALBEDO = water_color + caustics * caustics_strength;
    
    // Reflections and refraction
    METALLIC = metallic;
    ROUGHNESS = roughness;
    SPECULAR = 0.8;
    
    // Transparency
    ALPHA = mix(deep_color.a, shallow_color.a, 0.5);
    
    // Apply wave-based normal mapping
    NORMAL = normalize(vec3(
        combined_waves * 2.0,
        1.0,
        combined_waves * 2.0
    ));
    
    // Add refraction
    vec3 ref_normal = normalize(vec3(
        combined_waves * refraction_scale,
        1.0,
        combined_waves * refraction_scale
    ));
    
    NORMAL_MAP = ref_normal;
}
