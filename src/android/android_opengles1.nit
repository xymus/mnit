import mnit

`{
#include <mnit_log.h>
#include <android_native_app_glue.h>

NativeWindowType mnit_window;
struct android_app *mnit_java_app;
EGLNativeDisplayType mnit_native_display = EGL_DEFAULT_DISPLAY;
`}

redef class Opengles1Display
	redef fun midway_init( format ) is extern `{
    mnit_window = mnit_java_app->window;
	if ( ANativeWindow_setBuffersGeometry(mnit_window, 0, 0, (EGLint)format) != 0 ) {
		LOGW("Unable to ANativeWindow_setBuffersGeometry");
	}
	`}
end

