//
// Dump1090Output.c
//
// See Dump1090Output.h.
//
#include "Dump1090Output.h"
#include "Dump1090API.h"

#include <errno.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>

// This file is compiled with Dump1090Output.h as its prefix header too, so
// drop the redirects to reach the real stdio functions.
#undef printf
#undef fprintf
#undef perror
#undef putchar

static dump1090_output_fn output_fn;
static void *output_ctx;

void dump1090_set_output_handler(dump1090_output_fn fn, void *ctx) {
    output_fn = fn;
    output_ctx = ctx;
}

static int output_vprintf(FILE *fp, const char *fmt, va_list ap) {
    char stackbuf[1024];
    char *buf = stackbuf;
    va_list copy;
    int len;

    if (output_fn == NULL || (fp != stdout && fp != stderr)) {
        return vfprintf(fp, fmt, ap);
    }

    va_copy(copy, ap);
    len = vsnprintf(stackbuf, sizeof(stackbuf), fmt, copy);
    va_end(copy);
    if (len < 0) return len;

    if ((size_t)len >= sizeof(stackbuf)) {
        if ((buf = malloc((size_t)len + 1)) == NULL) return -1;
        vsnprintf(buf, (size_t)len + 1, fmt, ap);
    }
    output_fn(buf, (size_t)len, output_ctx);
    if (buf != stackbuf) free(buf);
    return len;
}

int dump1090_printf(const char *fmt, ...) {
    va_list ap;
    int len;

    va_start(ap, fmt);
    len = output_vprintf(stdout, fmt, ap);
    va_end(ap);
    return len;
}

int dump1090_fprintf(FILE *fp, const char *fmt, ...) {
    va_list ap;
    int len;

    va_start(ap, fmt);
    len = output_vprintf(fp, fmt, ap);
    va_end(ap);
    return len;
}

void dump1090_perror(const char *s) {
    const char *err = strerror(errno);

    if (s && *s) {
        dump1090_fprintf(stderr, "%s: %s\n", s, err);
    } else {
        dump1090_fprintf(stderr, "%s\n", err);
    }
}

int dump1090_putchar(int c) {
    char ch = (char)c;

    if (output_fn == NULL) return putchar(c);
    output_fn(&ch, 1, output_ctx);
    return (unsigned char)ch;
}
