#version 330 core
out vec4 FragColor;
in vec4 vertex_Pos;
in vec3 normal;
in vec3 frag_pos;
uniform vec3 color;
uniform vec3 lightColor;
uniform vec3 view_pos;
uniform vec3 light_pos;
float specular_strength = 0.5;
void main()
{
    vec3 norm = normalize(normal);
    vec3 light_dir = normalize(light_pos - frag_pos);
    float diff = max(dot(norm, light_dir), 0.0);
    vec3 diffuse = diff * lightColor;
    vec3 result = (vec3(0.1) + diffuse) * color;
    FragColor = vec4(result, 1.0) * vertex_Pos;
}