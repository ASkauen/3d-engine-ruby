#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aNormal;
uniform mat4 projection_matrix;
uniform mat4 view_matrix;
uniform mat4 model_matrix;

out vec4 vertex_Pos;
out vec3 normal;
out vec3 frag_pos;
void main()
{
    vertex_Pos = projection_matrix * view_matrix * model_matrix * vec4(aPos.x, aPos.y, aPos.z, 1.0);
    gl_Position = vertex_Pos;
    normal = mat3(transpose(inverse(model_matrix))) * aNormal;
    frag_pos = vec3(model_matrix * vec4(aPos, 1.0));
}