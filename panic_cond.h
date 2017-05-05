#if SOL >= 999
#pragma once

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>

// Panic with the given error message if condition is false.
static void
panic_cond(int cond, const char *fmt, ...)
{
	va_list args;

	if (!cond) {
		va_start(args, fmt);
		vfprintf(stderr, fmt, args);
		fputc('\n', stderr);
		va_end(args);
		abort();
	}
}
#endif
