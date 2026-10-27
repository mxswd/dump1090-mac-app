//
// Dump1090Output.h
//
// Prefix header for the dump1090 target. Routes dump1090's console output
// to the handler set with dump1090_set_output_handler(), so the upstream
// printf/fprintf call sites can stay unchanged.
//
#ifndef DUMP1090_OUTPUT_H
#define DUMP1090_OUTPUT_H

#include <stdio.h>

int dump1090_printf(const char *fmt, ...) __attribute__((format(printf, 1, 2)));
int dump1090_fprintf(FILE *fp, const char *fmt, ...) __attribute__((format(printf, 2, 3)));
void dump1090_perror(const char *s);
int dump1090_putchar(int c);

#define printf(...) dump1090_printf(__VA_ARGS__)
#define fprintf(...) dump1090_fprintf(__VA_ARGS__)
#define perror(s) dump1090_perror(s)
#undef putchar
#define putchar(c) dump1090_putchar(c)

#endif // DUMP1090_OUTPUT_H
