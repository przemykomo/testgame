module scene;

import std.stdio : writeln;

import bindbc.sdl;
import bindbc.opengl;

import dlib.image.io.png;
import dlib.image.image;

import imageformats;

/// A rendered scene.
class Scene
{
    private immutable float[] vertexBufferPositions = [
	    -0.5f, -0.5f, 0,
	    +0.5f, -0.5f, 0,
	    +0.5f, +0.5f, 0,

	    +0.5f, +0.5f, 0,
	    -0.5f, +0.5f, 0,
	    -0.5f, -0.5f, 0
    ];

    private immutable float[] vertexBufferTextureCoordinates = [
        0.0f, 0.0f,
        1.0f, 0.0f,
        1.0f, 1.0f,

        1.0f, 1.0f,
        0.0f, 1.0f,
        0.0f, 0.0f
    ];

    private GLuint vertexBuffer;
    private GLuint textureCoordinateBuffer;
    private GLuint programID;
    private GLuint vertexArrayID;

    /// Loads scene.
    this()
    {
        // create OpenGL buffers for vertex position and texture data
        glGenVertexArrays(1, &vertexArrayID);
        glBindVertexArray(vertexArrayID);

        // load position data
        glGenBuffers(1, &vertexBuffer);
        glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
        glBufferData(GL_ARRAY_BUFFER, float.sizeof * vertexBufferPositions.length,
                vertexBufferPositions.ptr, GL_STATIC_DRAW);

        // load color data
        glGenBuffers(1, &textureCoordinateBuffer);
        glBindBuffer(GL_ARRAY_BUFFER, textureCoordinateBuffer);
        glBufferData(GL_ARRAY_BUFFER, float.sizeof * vertexBufferTextureCoordinates.length,
                vertexBufferTextureCoordinates.ptr, GL_STATIC_DRAW);

        GLint result;
        int infoLogLength;

        // compile shaders
        GLuint vertexShaderID = glCreateShader(GL_VERTEX_SHADER);
        const(char*) vertSource = import("shader.vert");
        glShaderSource(vertexShaderID, 1, &vertSource, null);
        glCompileShader(vertexShaderID);
        glGetShaderiv(vertexShaderID, GL_COMPILE_STATUS, &result);
        glGetShaderiv(vertexShaderID, GL_INFO_LOG_LENGTH, &infoLogLength);
        if (infoLogLength > 0)
        {
            char[] errorMessage = new char[infoLogLength];
            glGetShaderInfoLog(vertexShaderID, infoLogLength, null, errorMessage.ptr);
            writeln(errorMessage[0 .. infoLogLength]);
        }

        GLuint fragmentShaderID = glCreateShader(GL_FRAGMENT_SHADER);
        const(char*) fragSource = import("shader.frag");
        glShaderSource(fragmentShaderID, 1, &fragSource, null);
        glCompileShader(fragmentShaderID);
        glGetShaderiv(fragmentShaderID, GL_COMPILE_STATUS, &result);
        glGetShaderiv(fragmentShaderID, GL_INFO_LOG_LENGTH, &infoLogLength);
        if (infoLogLength > 0)
        {
            char[] errorMessage = new char[infoLogLength];
            glGetShaderInfoLog(fragmentShaderID, infoLogLength, null, errorMessage.ptr);
            writeln(errorMessage[0 .. infoLogLength]);
        }

        // link shaders
        programID = glCreateProgram();
        glAttachShader(programID, vertexShaderID);
        glAttachShader(programID, fragmentShaderID);
        glLinkProgram(programID);
        glGetProgramiv(programID, GL_LINK_STATUS, &result);
        glGetProgramiv(programID, GL_INFO_LOG_LENGTH, &infoLogLength);
        if (infoLogLength > 0)
        {
            char[] errorMessage = new char[infoLogLength];
            glGetProgramInfoLog(programID, infoLogLength, null, errorMessage.ptr);
            writeln(errorMessage[0 .. infoLogLength]);
        }

        // Delete unused compiled shaders because program is linked already
        glDetachShader(programID, vertexShaderID);
        glDetachShader(programID, fragmentShaderID);

        glDeleteShader(vertexShaderID);
        glDeleteShader(fragmentShaderID);

        glEnableVertexAttribArray(0);
        glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
        glVertexAttribPointer(0, // attribute 0. No particular reason for 0, but must match the layout in the shader.
                3, // size
                GL_FLOAT, // type
                false, // normalized?
                0, // stride
                null  // array buffer offset
                );
        glEnableVertexAttribArray(1);
        glBindBuffer(GL_ARRAY_BUFFER, textureCoordinateBuffer);
        glVertexAttribPointer(1, // attribute 1
                2, // size
                GL_FLOAT, // type
                false, // normalized?
                0, // stride
                null  // array buffer offset
                );

        GLuint texture;
        glGenTextures(1, &texture);
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, texture);

        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

        // SuperImage image = loadPNG("image.png");
        // glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, image.width, image.height, 0, GL_RGB, GL_UNSIGNED_BYTE, image.data.ptr);
        // image.free();

        // IFImage image = read_image("image.png");
        // glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, image.w, image.h, 0, GL_RGB, GL_UNSIGNED_SHORT, image.pixels.ptr);

        glUseProgram(programID);
        glUniform1i(glGetUniformLocation(programID, "image"), 0);

        // mat4 trans = rotationMatrix!float(1, 1.0f);
        // glUniformMatrix4fv(glGetUniformLocation(programID, "transform"), 1, GL_FALSE, trans.arrayof.ptr);
    }

    ~this()
    {
        glDeleteBuffers(1, &vertexBuffer);
        glDeleteBuffers(1, &textureCoordinateBuffer);
        glDeleteVertexArrays(1, &vertexArrayID);
        glDeleteProgram(programID);
    }

    /// Renders scene.
    void render()
    {
        glClear(GL_COLOR_BUFFER_BIT);
        glDrawArrays(GL_TRIANGLES, 0, 6); // Starting from vertex 0; 3 vertices total -> 1 triangle
    }
}