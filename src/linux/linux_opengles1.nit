module linux_opengles1

import mnit
import sdl

import `{
#include "sdl.nit.h"
// #include "EGL/egl.h"
`}

`{
#include <mnit_log.h>

NativeWindowType mnit_window;
EGLNativeDisplayType mnit_native_display;

SDL_Surface* mnit_sdl_surface;
`}

redef class Opengles1Display # as `{struct mnit_opengles_Texture *`}

	# display managing the window, events, fonts? and image loading?
	var sdl_display : SDLDisplay

	redef fun extern_init do
		sdl_display = new SDLDisplay( 640, 480 )
		init_from_sdl( sdl_display )
		return super
	end

	fun init_from_sdl( sdl_display : SDLDisplay ) : Bool is extern `{

	mnit_sdl_surface = sdl_display;

	mnit_window = (NativeWindowType)XOpenDisplay(NULL);
	mnit_native_display = (EGLNativeDisplayType)mnit_window;
 
	if (!mnit_window)
	{
		fprintf(stderr, "ERROR: unable to get display!n");
		return 3;
	}

	SDL_SysWMinfo mnit_sys_info;
	 SDL_VERSION(&mnit_sys_info.version);
	 if(SDL_GetWMInfo(&mnit_sys_info) <= 0)
	 {
		  printf("Unable to get window handle");
		  return 0;
	 }

	mnit_window = (EGLNativeWindowType)mnit_sys_info.info.x11.window;

	return 0;
	`}
end

redef extern Opengles1Image
	new from_sdl_image( sdl_image : SDLImage ) is extern `{
	/*glPixelStorei(GL_UNPACK_ALIGNMENT,4);
	glGenTextures(1, &texture);
	glBindTexture(GL_TEXTURE_2D, texture);*/

	/* TODO *
	if (sdl_image->format->Amask) */

	return mnit_opengles_load_image( sdl_image->pixels, sdl_image->w, sdl_image->h, sdl_image->format->Amask );
	`}

	# using sdl
	new from_file( path : String ) is extern import String::to_cstring `{
	SDL_Surface *sdl_image;
	struct mnit_opengles_Texture *opengles_image;

	sdl_image = IMG_Load( String_to_cstring( path ) );
	if ( !sdl_image ) {
		LOGW( "SDL failed to load image <%s>: %s\n", String_to_cstring( path ), IMG_GetError() );
		return NULL;
	} else {
		printf( "bpp %i\n", sdl_image->format->BytesPerPixel );
		opengles_image = mnit_opengles_load_image( sdl_image->pixels, sdl_image->w, sdl_image->h, sdl_image->format->Amask );
		SDL_FreeSurface(sdl_image);
		return opengles_image;
	}
	`}
end

