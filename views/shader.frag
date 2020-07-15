#version 330 core

in vec2 tex_coordinate;
out vec4 out_color;

uniform sampler2D image;

void main() {
    out_color = texture(image, tex_coordinate);
}