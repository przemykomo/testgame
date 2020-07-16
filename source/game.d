module game;

import std.stdio;
import std.string : fromStringz;

import bindbc.sdl;
import bindbc.opengl;

import scene;

/// Exception for SDL related issues
class SDLException : Exception
{
	/// Creates an exception from SDL_GetError()
	this(string file = __FILE__, size_t line = __LINE__) nothrow @nogc
	{
		super(cast(string) SDL_GetError().fromStringz, file, line);
	}
}

private bool running = true;

enum MyEnum
{
    A,
    B
}

void main()
{
    MyEnum f = MyEnum.A;
    final switch(f) {
        case MyEnum.A:
            writeln("A!");
        break;
        case MyEnum.B:
            writeln("B!");
        break;
    }

	if (loadSDL() != sdlSupport) {
		writeln("Wrong SDL support!");
	}

	if (SDL_Init(SDL_INIT_VIDEO) < 0)
		throw new SDLException();

	SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
	SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 2);

	auto window = SDL_CreateWindow("OpenGL 3.2 App", SDL_WINDOWPOS_UNDEFINED,
			SDL_WINDOWPOS_UNDEFINED, 640, 480, SDL_WINDOW_OPENGL | SDL_WINDOW_SHOWN);
	if (!window)
		throw new SDLException();

	const context = SDL_GL_CreateContext(window);
	if (!context)
		throw new SDLException();

	if (SDL_GL_SetSwapInterval(1) < 0)
		writeln("Failed to set VSync");

	loadOpenGL();

	Scene scene = new Scene();

	SDL_Event event;

	glClearColor(0.0f, 0.32f, 0.8f, 1.0f);
	
	while (running)
	{
		while (SDL_PollEvent(&event))
		{
			switch (event.type)
			{
			case SDL_QUIT:
				stopGame();
				break;
			case SDL_KEYDOWN:
				if (event.key.keysym.sym == SDLK_ESCAPE)
				{
					stopGame();
				}
				break;
			default:
				break;
			}
		}

		scene.render;
		SDL_GL_SwapWindow(window);
	}
}

export void stopGame() {
	running = false;
}