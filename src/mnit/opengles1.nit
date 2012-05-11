# OpenGL ES1 general support (most of it)
module opengles1

import display

in "C header" `{
#include <EGL/egl.h>
#include <GLES/gl.h>
#include <GLES/glext.h>
#include <errno.h>

//#include "app.nit.h"

EGLDisplay mnit_display;
EGLSurface mnit_surface;
EGLContext mnit_context;
EGLConfig mnit_config;
int32_t mnit_width;
int32_t mnit_height;
float mnit_zoom;

struct mnit_opengles_Texture {
	GLuint texture;
	
	/* offsets on source texture */
	float src_xo, src_yo, src_xi, src_yi;
	
	/* destination width and height */
	int width, height;
	float scale;
	int blended;
};

struct mnit_opengles_DrawableTexture {
	struct mnit_opengles_Texture super;
	GLuint fbo;
	GLuint depth;
	GLuint color;
    /*
    EGLSurface surface;
    int width, height;
    */
};

GLenum mnit_opengles_error_code;

/* #include <android._nitni.h> */

struct mnit_opengles_Texture *mnit_opengles_load_image( const uint_least32_t *pixels, int width, int height, int has_alpha );
`}

in "C" `{
#include <mnit_log.h>

extern NativeWindowType mnit_window;
extern EGLNativeDisplayType mnit_native_display;

GLfloat mnit_opengles_vertices[6][3] =
{
	{0.0f, 0.0f, 0.0f},
	{0.0f, 1.0f, 0.0f},
	{1.0f, 1.0f, 0.0f},
	{0.0f, 0.0f, 0.0f},
	{1.0f, 1.0f, 0.0f},
	{1.0f, 0.0f, 0.0f},
};
GLfloat mnit_opengles_texture[6][2] =
{
	{0.0f, 0.0f},
	{0.0f, 1.0f},
	{1.0f, 1.0f},
	{0.0f, 0.0f},
	{1.0f, 1.0f},
	{1.0f, 0.0f}
};

struct mnit_opengles_Texture *mnit_opengles_load_image( const uint_least32_t *pixels, int width, int height, int has_alpha )
{
	struct mnit_opengles_Texture *image = malloc(sizeof(struct mnit_opengles_Texture));
	int format = has_alpha? GL_RGBA : GL_RGB;

	LOGI( "load_image" );
	
	image->width = width;
	image->height = height;
	image->scale = 1.0f;
	image->blended = has_alpha;

	image->src_xo = 0;
	image->src_yo = 0;
	image->src_xi = 1.0;
	image->src_yi = 1.0;

	
	if ((mnit_opengles_error_code = glGetError()) != GL_NO_ERROR) {
		LOGW ("a error loading image: %i\n", mnit_opengles_error_code);
		printf( "%i\n", mnit_opengles_error_code );
	}
	glGenTextures(1, &image->texture);
	
	if ((mnit_opengles_error_code = glGetError()) != GL_NO_ERROR) {
		LOGW ("b error loading image: %i\n", mnit_opengles_error_code);
		printf( "%i\n", mnit_opengles_error_code );
	}
	glBindTexture(GL_TEXTURE_2D, image->texture);
	
	if ((mnit_opengles_error_code = glGetError()) != GL_NO_ERROR) {
		LOGW ("c error loading image: %i\n", mnit_opengles_error_code);
		printf( "%i\n", mnit_opengles_error_code );
	}
	glTexImage2D(	GL_TEXTURE_2D, 0, format, width, height,
					0, format, GL_UNSIGNED_BYTE, (GLvoid*)pixels);
	
	if ((mnit_opengles_error_code = glGetError()) != GL_NO_ERROR) {
		LOGW ("d error loading image: %i\n", mnit_opengles_error_code);
		printf( "%i\n", mnit_opengles_error_code );
	}
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	
	if ((mnit_opengles_error_code = glGetError()) != GL_NO_ERROR) {
		LOGW ("e error loading image: %i\n", mnit_opengles_error_code);
		printf( "%i\n", mnit_opengles_error_code );
	}
	
	return image;
}
`}

# OpenGL ES1 display
# Uses 3d hardware optimization
class Opengles1Display
	super Display
	
	redef type I : Opengles1Image

	init do extern_init
	fun midway_init( format : Int ) do end
	fun extern_init : Bool is extern import midway_init `{
	/* initialize OpenGL ES and EGL */
	const EGLint attribs[] = {
			EGL_SURFACE_TYPE, EGL_WINDOW_BIT,
			EGL_BLUE_SIZE, 8,
			EGL_GREEN_SIZE, 8,
			EGL_RED_SIZE, 8,
			EGL_NONE
	};
	EGLint w, h, dummy, format;
	EGLint numConfigs;
	EGLConfig config;
	EGLSurface surface;
	EGLContext context;

//	EGLDisplay display = eglGetDisplay(EGL_DEFAULT_DISPLAY);	for android
	EGLDisplay display = eglGetDisplay(mnit_native_display);
	if ( display == EGL_NO_DISPLAY) {
		LOGW("Unable to eglGetDisplay");
		return -1;
	}

	if ( eglInitialize(display, 0, 0) == EGL_FALSE) {
		LOGW("Unable to eglInitialize");
		return -1;
	}

	/* Here, the application chooses the configuration it desires. In this
	 * sample, we have a very simplified selection process, where we pick
	 * the first EGLConfig that matches our criteria */
	if ( eglChooseConfig(display, attribs, &config, 1, &numConfigs) == EGL_FALSE) {
		LOGW("Unable to eglChooseConfig");
		return -1;
	}

	if ( numConfigs == 0 ) {
		LOGW("No configs available for egl");
		return -1;
	}

	/* EGL_NATIVE_VISUAL_ID is an attribute of the EGLConfig that is
	 * guaranteed to be accepted by ANativeWindow_setBuffersGeometry().
	 * As soon as we picked a EGLConfig, we can safely reconfigure the
	 * ANativeWindow buffers to match, using EGL_NATIVE_VISUAL_ID. */
	if ( eglGetConfigAttrib(display, config, EGL_NATIVE_VISUAL_ID, &format) == EGL_FALSE) {
		LOGW("Unable to eglGetConfigAttrib");
		return -1;
	}

	/* Used by Android to set buffer geometry */
	Opengles1Display_midway_init(recv, format);

	surface = eglCreateWindowSurface(display, config, mnit_window, NULL);
	context = eglCreateContext(display, config, NULL, NULL);

	if (eglMakeCurrent(display, surface, surface, context) == EGL_FALSE) {
		LOGW("Unable to eglMakeCurrent");
		return -1;
	}

	eglQuerySurface(display, surface, EGL_WIDTH, &w);
	eglQuerySurface(display, surface, EGL_HEIGHT, &h);

	mnit_display = display;
	mnit_context = context;
	mnit_surface = surface;
	mnit_config = config;
	mnit_width = w;
	mnit_height = h;
	mnit_zoom = 1.0f;

	LOGI( "surface: %i, display: %i, w %i, h %i", (int)surface, (int)display, w, h );
	
	glViewport(0, 0, mnit_width, mnit_height);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrthof(0.0f, w, h, 0.0f, 0.0f, 1.0f);
	glMatrixMode(GL_MODELVIEW);
	
	glFrontFace( GL_CW );

	return 0;
	`}

	fun close is extern `{
	if ( mnit_display != EGL_NO_DISPLAY) {
		eglMakeCurrent( mnit_display, EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT);
		if ( mnit_context != EGL_NO_CONTEXT) {
			eglDestroyContext( mnit_display,  mnit_context );
		}
		if ( mnit_surface != EGL_NO_SURFACE) {
			eglDestroySurface( mnit_display,  mnit_surface );
		}
		eglTerminate( mnit_display);
	}
	 /*mnit_mnit_animating = 0;*/
	 mnit_display = EGL_NO_DISPLAY;
	 mnit_context = EGL_NO_CONTEXT;
	 mnit_surface = EGL_NO_SURFACE;

	LOGW( "termed!" );
	`}
	
	redef fun begin is extern `{
	glClear(GL_COLOR_BUFFER_BIT);
	glLoadIdentity();
	`}
	
	redef fun width : Int is extern `{
	return mnit_width;
	`}
	redef fun height : Int is extern `{
	return mnit_height;
	`}
	
	redef fun finish is extern `{
	eglSwapBuffers( mnit_display, 
					mnit_surface );
	`}
	
	fun set_as_target is extern `{
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, 0);
	`}

	redef fun set_viewport( x, y, w, h ) is extern `{
	glLoadIdentity();
	glViewport(0,0, mnit_width, mnit_height );
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrthof(x, x+w, y+h, y, 0.0f, 1.0f);
	/*glOrthof(0.0f, w, h, 0.0f, 0.0f, 1.0f);*/
	mnit_zoom = ((float)w)/mnit_width;
	glMatrixMode(GL_MODELVIEW);
	glFrontFace( GL_CW );
	`}
	
	redef fun blit( image, x, y ) is extern  `{
	y += 32;
	GLfloat texture_coord[6][2] =
	{
		{image->src_xo, image->src_yo},
		{image->src_xo, image->src_yi},
		{image->src_xi, image->src_yi},
		{image->src_xo, image->src_yo},
		{image->src_xi, image->src_yi},
		{image->src_xi, image->src_yo}
	};
    
	glLoadIdentity();

	glBindTexture(GL_TEXTURE_2D, image->texture);

	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glTranslatef( x, y, 0.0f );
	glScalef( image->width*image->scale, image->height*image->scale, 1.0f );

	if ( image->blended ) {
		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	}

	glEnable(GL_TEXTURE_2D);
	glDisable(GL_DEPTH_TEST);

	glVertexPointer(3, GL_FLOAT, 0, mnit_opengles_vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, texture_coord ); /* mnit_opengles_texture); */

	glDrawArrays(GL_TRIANGLE_STRIP, 0, 6);

	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	if ( image->blended ) glDisable(GL_BLEND);
	glDisable(GL_TEXTURE_2D);

	if ((mnit_opengles_error_code = glGetError()) != GL_NO_ERROR) {
	   LOGW ("error drawing: %i", mnit_opengles_error_code);
	}
	`}
	
    redef fun blit_centered( img, x, y )
    do
    	x = x - img.width / 2
    	y = y - img.height / 2
    	blit( img, x, y )
    end
    
	redef fun blit_rotated( image, x, y, angle ) is extern  `{
	y += 32;
	GLfloat texture_coord[6][2] =
	{
		{image->src_xo, image->src_yo},
		{image->src_xo, image->src_yi},
		{image->src_xi, image->src_yi},
		{image->src_xo, image->src_yo},
		{image->src_xi, image->src_yi},
		{image->src_xi, image->src_yo}
	};
    
	glLoadIdentity();

	glBindTexture(GL_TEXTURE_2D, image->texture);

	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glTranslatef( x, y, 0.0f );
	glRotatef( angle*180.0f/3.14156f, 0, 0, 1.0f );
	glTranslatef( image->width*image->scale/-2, image->height*image->scale/-2, 0.0f );
	glScalef( image->width*image->scale, image->height*image->scale, 1.0f );
	if ( image->blended ) {
		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	}
	glEnable(GL_TEXTURE_2D);
	glDisable(GL_DEPTH_TEST);

	glVertexPointer(3, GL_FLOAT, 0, mnit_opengles_vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, texture_coord ); /* mnit_opengles_texture); */

	glDrawArrays(GL_TRIANGLE_STRIP, 0, 6);

	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	if ( image->blended ) glDisable(GL_BLEND);
	glDisable(GL_TEXTURE_2D);

	if ((mnit_opengles_error_code = glGetError()) != GL_NO_ERROR) {
	   LOGW ("error drawing: %i", mnit_opengles_error_code);
	}

	`}
#    fun clear( r, g, b : Int ) is extern `{
#	glClear(GL_COLOR_BUFFER_BIT);
#    `}

	# a = top left, b = bottom left, c = bottom right, d = top right
	redef fun blit_stretched( image, ax, ay, bx, by, cx, cy, dx, dy ) is extern  `{
	ay += 32;
	by += 32;
	cy += 32;
	dy += 32;
	GLfloat texture_coord[6][2] =
	{
		{image->src_xo, image->src_yo},
		{image->src_xo, image->src_yi},
		{image->src_xi, image->src_yi},
		{image->src_xo, image->src_yo},
		{image->src_xi, image->src_yi},
		{image->src_xi, image->src_yo}
	};

GLfloat mnit_opengles_vertices_stretched[6][3] =
{
	{ax, ay, 0.0f},
	{bx, by, 0.0f},
	{cx, cy, 0.0f},
	{ax, ay, 0.0f},
	{cx, cy, 0.0f},
	{dx, dy, 0.0f},
};
    
	glLoadIdentity();

	glBindTexture(GL_TEXTURE_2D, image->texture);

	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);

	if ( image->blended ) {
		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	}

	glEnable(GL_TEXTURE_2D);
	glDisable(GL_DEPTH_TEST);

	glVertexPointer(3, GL_FLOAT, 0, mnit_opengles_vertices_stretched);
	glTexCoordPointer(2, GL_FLOAT, 0, texture_coord ); 

	glDrawArrays(GL_TRIANGLE_STRIP, 0, 6);

	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	if ( image->blended ) glDisable(GL_BLEND);
	glDisable(GL_TEXTURE_2D);

	if ((mnit_opengles_error_code = glGetError()) != GL_NO_ERROR) {
	   LOGW ("error drawing: %i", mnit_opengles_error_code);
	}
	`}

	fun clear( r, g, b, a : Float ) is extern `{
	glClearColor( r, g, b, a );
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	`}
end

extern Opengles1Image in "C" `{struct mnit_opengles_Texture *`}
	super Image
    
    redef fun destroy is extern `{
    free( recv );
    `}
    
    redef fun width : Int is extern `{
    return recv->width;
    `}

    redef fun height : Int is extern `{
    return recv->height;
    `}

    redef fun scale=( v : Float ) is extern `{
    recv->scale = v;
    `}
    redef fun scale : Float is extern `{
    return recv->scale;
    `}

    redef fun blended=( v : Bool ) is extern `{
    recv->blended = v;
    `}
    redef fun blended : Bool is extern `{
    return recv->blended;
    `}

    # inherits scale and blend from source
    redef fun subimage( x, y, w, h : Int ) : Image is extern import Opengles1Image as ( Image ) `{
	struct mnit_opengles_Texture* image = 
		malloc( sizeof( struct mnit_opengles_Texture ) );

	image->texture = recv->texture;
	image->width = w;
	image->height = h;
	image->scale = recv->scale;
	image->blended = recv->blended;

	image->src_xo = ((float)x)/recv->width; 
	image->src_yo = ((float)y)/recv->height; 
	image->src_xi = ((float)w+w)/recv->width; 
	image->src_yi = ((float)x+h)/recv->height; 

	return Opengles1Image_as_Image( image );
    `}
end


extern Opengles1DrawableImage in "C" `{struct mnit_opengles_DrawableTexture*`}
	super DrawableImage
    new ( w, h : Int ) is extern `{
	struct mnit_opengles_DrawableTexture *image = 
		malloc( sizeof(struct mnit_opengles_DrawableTexture) );

    #ifdef a
    const EGLint attribs[] = {
        EGL_WIDTH, w,
        EGL_HEIGHT, h,
        EGL_TEXTURE_FORMAT, EGL_TEXTURE_RGBA,
        EGL_TEXTURE_TARGET, EGL_TEXTURE_2D,
        EGL_NONE
    };

    image->surface = eglCreatePbufferSurface( andronit.display,
                             andronit.config,
                             attribs );
    if ( eglGetError() )
        LOGW( "eglCreatePbuffer error" );
    
    image->width = w;
    image->height = h;
    eglMakeCurrent( andronit.display,
                    surface,
                    surface,
                    andronit.context );

#else
	/* texture */
	glGenTextures(1, &image->super.texture);
	glBindTexture(GL_TEXTURE_2D, image->super.texture);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, w, h, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	/* glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, GL_TRUE); // automatic mipmap generation included in OpenGL v1.4c */
	glBindTexture(GL_TEXTURE_2D, 0);

	/* fbo */
	glGenFramebuffersOES( 1, &image->fbo );
	glBindFramebufferOES( GL_FRAMEBUFFER_OES, image->fbo );
	glFramebufferTexture2DOES(GL_FRAMEBUFFER_OES, 
			GL_COLOR_ATTACHMENT0_OES,
			GL_TEXTURE_2D,
			image->super.texture,
			0 );

	/* depth */
	glGenRenderbuffersOES(1, &image->depth);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, image->depth);
	glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES,
				 w, h);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, 0);
	glFramebufferRenderbufferOES( GL_FRAMEBUFFER_OES, 
		GL_DEPTH_ATTACHMENT_OES, 
		GL_RENDERBUFFER_OES, 
		image->depth );

    /* tex framebuffer */
	glGenRenderbuffersOES(1, &image->color);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, image->color);
	glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_RGBA8_OES, w, h);
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, image->color );

	if ( glCheckFramebufferStatusOES( GL_FRAMEBUFFER_OES ) != GL_FRAMEBUFFER_COMPLETE_OES )
	{
		LOGW( "framebuffer not set" );
		if ( glCheckFramebufferStatusOES( GL_FRAMEBUFFER_OES ) == GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT_OES )
			LOGW( "framebuffer not set a" );
		else if ( glCheckFramebufferStatusOES( GL_FRAMEBUFFER_OES ) == GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS_OES )
			LOGW( "framebuffer not set b" );
		else if ( glCheckFramebufferStatusOES( GL_FRAMEBUFFER_OES ) == GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT_OES )
			LOGW( "framebuffer not set c" );
		else if ( glCheckFramebufferStatusOES( GL_FRAMEBUFFER_OES ) == GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT_OES )
			LOGW( "framebuffer not set d" );
	}

	image->super.width = w;
	image->super.height = h;
	image->super.scale = 1.0f;
	image->super.blended = 0;

    #endif

	if (glGetError() != GL_NO_ERROR) LOGW( "gl error");

	return image;
	`}

#    fun image : I is extern `{
#        struct mnit_opengles_Texture *image;
#        const uint_least32_t *pixels;
#        pixels = malloc( sizeof(uint_least32_t)*recv->width*recv->height );
#        glReadPixels( 0, 0, recv->width, recv->height,
#                      GL_RGBA, GL_UNSIGNED_BYTE, pixels );
#        image = mnit_opengles_load_image( pixels, recv->width, recv->height );
#        return image;

    fun set_as_target is extern `{
	LOGI( "sat %i", recv->fbo );
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, recv->fbo);
	/*glBindRenderbufferOES(GL_FRAMEBUFFER_OES, recv->color);*/
	if (glGetError() != GL_NO_ERROR) LOGW( "gl error 0");
	/*glGetIntegerv(GL_FRAMEBUFFER_BINDING_OES,&recv->fbo);
	//if (glGetError() != GL_NO_ERROR) LOGW( "gl error a");*/
	glViewport(0, 0, recv->super.width, recv->super.height);

	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrthof(0.0f, recv->super.width, recv->super.height, 0.0f, 0.0f, 1.0f);
	glMatrixMode(GL_MODELVIEW);
    glFrontFace( GL_CW );

	glClearColor( 0.0f, 1.0f, 1.0f, 1.0f );
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	`}

    fun unset_as_target is extern `{
    glFlush();
	/*glBindTexture(GL_TEXTURE_2D, recv->super.texture);
	glGenerateMipmapOES(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, 0);*/
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, 0);
	if (glGetError() != GL_NO_ERROR) LOGW( "gl error"); 
	`}
end

