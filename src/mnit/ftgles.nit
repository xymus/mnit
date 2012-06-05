import opengles1
import font

in "C header" `{
	#include <FTGL/ftgles.h>
`}

extern FTGLFont `{ FTGLfont * `}
	super Font

	new from_file( path : String ) import String::to_cstring `{
		FTGLfont *f = ftglCreateTextureFont( String_to_cstring( path ) );
		printf( "init\n" );
		ftglSetFontFaceSize( f, 14, 72 );
		return f;
	`}

	fun destroy `{
		ftglDestroyFont( recv );
	`}

	private fun inner_write( text : NativeString, x : Int, y : Int ) `{
		glLoadIdentity();
		glTranslatef(x,y,0);
		glColor4f( 1.0f, 1.0f, 1.0f, 1.0f );
		glScalef( 1.0f, -1.0f, 1.0f ); /* Hack to prevent inverted writing */
		ftglRenderFont( recv, text, FTGL_RENDER_ALL);
	`}

	# Sets size according to resolution
	fun set_size( size, resolution : Int ) `{
		ftglSetFontFaceSize( recv, size, resolution );
	`}

	fun width_of( text : String ) : Float do return advance( text )

	fun ascender : Float `{ return ftglGetFontAscender( recv ); `}
	fun descender : Float `{ return ftglGetFontDescender( recv ); `}
	fun line_height : Float `{ return ftglGetFontLineHeight( recv ); `}
	fun advance( text : String ) : Float import String::to_cstring `{
		return ftglGetFontAdvance( recv, String_to_cstring( text ) );
	`}
end

redef class Opengles1Display
	redef fun write( text, font, x, y )
	do
		assert font isa FTGLFont

		font.inner_write( text.to_cstring, x, y )
	end
end
