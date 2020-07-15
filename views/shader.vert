#version 330 core

layout(location = 0) in vec3 in_position;
layout(location = 1) in vec2 in_tex_coordinate;

out vec2 tex_coordinate;

void main() {
	gl_Position = vec4(in_position, 1.0f);
	tex_coordinate = in_tex_coordinate;
}