
#define LOGW(...) ((void)fprintf(stderr, "# warn: %s", __VA_ARGS__))
#ifdef DEBUG
	#define LOGI(...) ((void)fprintf(stderr, "# info: %s", __VA_ARGS__))
#else
	#define LOGI(...) (void)0
#endif

