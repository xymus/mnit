#include <android/log.h>

#define LOGW(...) ((void)__android_log_print(ANDROID_LOG_WARN, "mnit", __VA_ARGS__))
#ifdef DEBUG
	#define LOGI(...) ((void)__android_log_print(ANDROID_LOG_INFO, "mnit", __VA_ARGS__))
#else
	#define LOGI(...) (void)0
#endif

