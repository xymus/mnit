module sdl

import mnit # for
#import display
#import input_events

in "C header" `{
#include <unistd.h>
#include <SDL/SDL.h>
#include <SDL/SDL_syswm.h>
#include <SDL/SDL_image.h>
#include <SDL/SDL_ttf.h>
#define DEBUG 1
`}

extern SDLDisplay in "C" `{SDL_Surface *`}
	super Display

	redef type I : SDLImage

	new ( w, h : Int) is extern `{
		SDL_Init(SDL_INIT_VIDEO);
	
		if(TTF_Init()==-1) {
			printf("TTF_Init: %s\n", TTF_GetError());
			exit(2);
		}
	
		/* ignores mousemotion for performance reasons */
		SDL_EventState( SDL_MOUSEMOTION, SDL_IGNORE );
	
		return SDL_SetVideoMode( w, h, 24, SDL_HWSURFACE );
	`}

	fun destroy is extern `{
	if ( SDL_WasInit( SDL_INIT_VIDEO ) )
		SDL_Quit();
		
	if ( TTF_WasInit() )
		TTF_Quit();
	`}
	
	redef fun finish is extern `{
	SDL_Flip( recv );
	`}

	fun clear( r, g, b : Int ) is extern `{
	SDL_FillRect( recv, NULL, SDL_MapRGB(recv->format,r,g,b) ); 
	`}
	
	redef fun width : Int is extern `{
	return recv->w;
	`}
	redef fun height : Int is extern `{
	return recv->h;
	`}
	
	fun fill_rect( rect : SDLRectangle, r, g, b : Int ) is extern `{
	SDL_FillRect( recv, rect,  SDL_MapRGB(recv->format,r,g,b) );
	`}
	
	fun events : Sequence[ IE ]
	do
		var new_event : nullable Object = null
		var events = new List[ IE ]
		loop do
			new_event = poll_event
			if new_event != null then # new_event isa Event then #
				events.add( new_event )
			else
				break
			end
		end
		return events
	end
	
	private fun poll_event : nullable IE is extern import SDLKeyEvent, SDLMouseEvent, SDLQuitEvent, String::from_cstring, SDLMouseEvent as (nullable IE), SDLKeyEvent as (nullable IE), SDLQuitEvent as (nullable IE) `{
	SDL_Event event;
	
	SDL_PumpEvents();

	if ( SDL_PollEvent(&event) )
	{
		switch (event.type ) {
			case SDL_KEYDOWN:
			case SDL_KEYUP:
#ifdef DEBUG
				printf("The \"%s\" key was pressed!\n",
					   SDL_GetKeyName(event.key.keysym.sym));
#endif
					   
				return SDLKeyEvent_as_nullable_InputEvent(
						new_SDLKeyEvent( new_String_from_cstring( 
							SDL_GetKeyName(event.key.keysym.sym) ),
							event.type==SDL_KEYDOWN ) );
			
		/*	case SDL_MOUSEMOTION:
				printf("Mouse moved by %d,%d to (%d,%d)\n", 
					   event.motion.xrel, event.motion.yrel,
					   event.motion.x, event.motion.y);*/
			
			case SDL_MOUSEBUTTONDOWN:
			case SDL_MOUSEBUTTONUP:
#ifdef DEBUG
				printf("Mouse button \"%d\" pressed at (%d,%d)\n",
					   event.button.button, event.button.x, event.button.y);
#endif
				return SDLMouseEvent_as_nullable_InputEvent(
						new_SDLMouseEvent( event.button.x, event.button.y, 
							event.button.button, event.type == SDL_MOUSEBUTTONDOWN ) );
			
			case SDL_QUIT:
#ifdef DEBUG
				printf("Quit event\n");
#endif
				return SDLQuitEvent_as_nullable_InputEvent( new_SDLQuitEvent() );
		}
	}
	
	return null_InputEvent();
	`}
end

extern SDLDrawable in "C" `{SDL_Surface*`}
	super Drawable

	redef type I : SDLImage

	redef fun blit( img, x, y ) is extern `{
	SDL_Rect dst; /* [ x, y, 0, 0 ); */
	dst.x = x;
	dst.y = y;
	dst.w = 0;
	dst.h = 0;

	SDL_BlitSurface( img, NULL, recv, &dst );
	`}

	redef fun blit_centered( img, x, y )
	do
		x = x - img.width / 2
		y = y - img.height / 2
		blit( img, x, y )
	end
end

extern SDLImage in "C" `{SDL_Surface*`} # TODO remove
	super DrawableImage
	super SDLDrawable

	new from_file( path : String ) is extern import String::to_cstring `{
	SDL_Surface *image = IMG_Load( String_to_cstring( path ) );
	return image;
	`}

	new partial( original : Image, clip : SDLRectangle ) is extern `{
	return NULL;
	`}
	
	new copy_of( image : SDLImage ) is extern `{
	SDL_Surface *new_image = SDL_CreateRGBSurface( image->flags, image->w, image->h, 24,
						  0, 0, 0, 0 );
	/*SDL_Surface *new_image = (SDL_Surface*)malloc(sizeof(SDL_Surface));
	memcpy(new_image, image, sizeof(SDL_Surface));
	new_image->refcount++;*/
	
	SDL_Rect dst; /* [ x, y, 0, 0 ); */
	dst.x = 0;
	dst.y = 0;
	dst.w = image->w;
	dst.h = image->h;
	SDL_BlitSurface( image, NULL, new_image, &dst );
	
	return new_image;
	`}
	
	fun save_to_file( path : String ) is extern import String::to_cstring `{ `}
	fun clear( c : Float ) is extern `{ `}
	
	redef fun destroy is extern `{
	SDL_FreeSurface( recv );
	`}
	
	redef fun width : Int is extern `{
	return recv->w;
	`}
	redef fun height : Int is extern `{
	return recv->h;
	`}
	
	fun is_ok : Bool do return true # TODO
end

extern SDLRectangle in "C" `{SDL_Rect*`}
	new ( x : Int, y : Int, w : Int, h : Int ) is extern `{
	SDL_Rect *rect = malloc( sizeof( SDL_Rect ) );
	rect->x = (Sint16)x;
	rect->y = (Sint16)y;
	rect->w = (Uint16)w;
	rect->h = (Uint16)h;
	return rect;
	`}

	fun x=( v : Int ) is extern `{
	recv->x = (Sint16)v;
	`}
	fun x : Int is extern `{
	return recv->x;
	`}

	fun y=( v : Int ) is extern `{
	recv->y = (Sint16)v;
	`}
	fun y : Int is extern `{
	return recv->y;
	`}

	fun w=( v : Int ) is extern `{
	recv->w = (Uint16)v;
	`}
	fun w : Int is extern `{
	return recv->w;
	`}

	fun h=( v : Int ) is extern `{
	recv->h = (Uint16)v;
	`}
	fun h : Int is extern `{
	return recv->h;
	`}
	
	fun destroy is extern `{ `}
end

interface SDLInputEvent
	super InputEvent
end

class SDLMouseEvent
	super PointerEvent
	super SDLInputEvent

	redef var x : Float
	redef var y : Float
	var button : Int
	redef var down : Bool
	fun up : Bool do return not down
	
	init ( x, y : Float, button : Int, down : Bool )
	do
		self.x = x
		self.y = y
		self.button = button
		self.down = down
	end
	
	redef fun to_s
	do
		if down then
			return "MouseEvent button {button} down at {x}, {y}"
		else
			return "MouseEvent button {button} up at {x}, {y}"
		end
	end
end

class SDLKeyEvent
	super KeyEvent
	super SDLInputEvent

	var key_name : String
	var down : Bool
	
	init ( key_name : String, down : Bool )
	do
		self.key_name = key_name
		self.down = down
	end

	redef fun to_c : nullable Char
	do
		if key_name.length == 1 then return key_name.first
		return null
	end
	
	redef fun to_s
	do
		if down then
			return "KeyboardEvent key {key_name} down"
		else
			return "KeyboardEvent key {key_name} up"
		end
	end

	redef fun is_down do return down
end

class SDLQuitEvent
	super SDLInputEvent
	super QuitEvent
end

redef class Int
	fun delay is extern `{
	SDL_Delay( recv );
	`}
end

extern SDLFont in "C" `{TTF_Font *`}
special Pointer
	new ( name : String, points : Int ) is extern import String::to_cstring `{
	char * cname = String_to_cstring( name );
	
	TTF_Font *font = TTF_OpenFont( cname, (int)points);
	if(!font) {
		printf("TTF_OpenFont: %s\n", TTF_GetError());
		exit( 1 );
	}
	
	return font;
	`}
	
	fun destroy is extern `{
	TTF_CloseFont( recv );
	`}
	
	fun render( text : String, r, g, b : Int ) : SDLImage is extern import String::to_cstring `{
	SDL_Color color;
	SDL_Surface *text_surface;
	char *ctext;
	
	/*color = SDL_MapRGB(NULL,r,g,b);*/
	color.r = r;
	color.g = g;
	color.b = b;
	
	ctext = String_to_cstring( text );
	if( !(text_surface=TTF_RenderText_Blended( recv, ctext, color )) )
	{
		fprintf( stderr, "SDL TFF error: %s\n", TTF_GetError() );
		exit( 1 );
	}
	else
		return text_surface;
	`}
	
	# TODO reactivate fun below when updating libsdl_ttf to 2.0.10 or above
	#fun outline : Int is extern # TODO check to make inline/nitside only
	#fun outline=( v : Int ) is extern
	
	#fun kerning : Bool is extern
	#fun kerning=( v : Bool ) is extern
	
	# Maximum pixel height of all glyphs of this font.
	fun height : Int is extern `{
	return TTF_FontHeight( recv );
	`}
	
	fun ascent : Int is extern `{
	return TTF_FontAscent( recv );
	`}
	
	fun descent : Int is extern `{
	return TTF_FontDescent( recv );
	`}
	
	# Get the recommended pixel height of a rendered line of text of the loaded font. This is usually larger than the Font::height.
	fun line_skip : Int is extern `{
	return TTF_FontLineSkip( recv );
	`}
	
	fun is_fixed_width : Bool is extern `{
	return TTF_FontFaceIsFixedWidth( recv );
	`}
	fun family_name : nullable String is extern import String::to_cstring, String as nullable `{
	char *fn = TTF_FontFaceFamilyName( recv );
	
	if ( fn == NULL )
		return null_String();
	else
		return String_as_nullable( new_String_from_cstring( fn ) );
	`}
	fun style_name : nullable String is extern import String::to_cstring, String as nullable `{
	char *sn = TTF_FontFaceStyleName( recv );
	
	if ( sn == NULL )
		return null_String();
	else
		return String_as_nullable( new_String_from_cstring( sn ) );
	`}
	
	fun width_of( text : String ) : Int is extern import String::from_cstring `{
	char *ctext = String_to_cstring( text );
	int w;
	if ( TTF_SizeText( recv, ctext, &w, NULL ) )
	{
		fprintf( stderr, "SDL TFF error: %s\n", TTF_GetError() );
		exit( 1 );
	}
	else
		return w;
	`}
	
#	fun render_within( text : String, width, height : Int ) : Image
#	do
#		return 
#	end
end

