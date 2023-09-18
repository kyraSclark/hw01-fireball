#version 300 es

// This is a fragment shader. If you've opened this file first, please
// open and read lambert.vert.glsl before reading on.
// Unlike the vertex shader, the fragment shader actually does compute
// the shading of geometry. For every pixel in your program's output
// screen, the fragment shader is run for every bit of geometry that
// particular pixel overlaps. By implicitly interpolating the position
// data passed into the fragment shader by the vertex shader, the fragment shader
// can compute what color to apply to its pixel based on things like vertex
// position, light position, and vertex color.
precision highp float;

uniform vec4 u_Color; // The color with which to render this instance of geometry.
uniform float u_Time;

// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec4 fs_Pos;


out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

float bias(float b, float t)
{
    return pow(t, log(b) / log(0.5));
}

float triangle_wave(float x, float freq, float amp)
{
    return abs(mod((x * freq), amp) - (0.5 * amp));
}

float square_wave(float x, float freq, float amp)
{
    return abs(mod(floor(x*freq), 2.0) * amp);
}

void main()
{
    // Material base color (before shading)
        vec3 yellow = vec3(1.0, 0.8, 0.0);
        vec3 red = vec3(1.0, 0.0, 0.0);
        float t = triangle_wave(u_Time * 0.01, 0.25, 1.0);
        t = bias(0.9, t);
        vec3 col = mix(yellow, red, t);

        if (fs_Pos.x < 0.0 && fs_Pos.y < 0.0 && fs_Pos.z < 0.0)
        {
            float t1 = triangle_wave(u_Time * 0.001, .9, 0.8) + 0.01;
            col = mix(col, vec3(0.0, 0.0, 1.0), t1);
        }

        // Calculate the diffuse term for Lambert shading
        float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));

        float ambientTerm = 0.2;

        float lightIntensity = diffuseTerm + ambientTerm;   //Add a small float value to the color multiplier
                                                            //to simulate ambient lighting. This ensures that faces that are not
                                                            //lit by our point light are not completely black.

        lightIntensity = bias(0.25, lightIntensity);

        // Compute final shaded color
        out_Col = vec4(col * lightIntensity, u_Color.a);
}


