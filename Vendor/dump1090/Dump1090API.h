//
// Dump1090API.h
//
// Public interface for running dump1090 inside the app process.
//
// Only one dump1090_main() may run at a time: dump1090 keeps its state in
// globals. It is safe to call it again once the previous call has returned.
//
#ifndef DUMP1090_API_H
#define DUMP1090_API_H

#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

// Receives everything dump1090 would have written to stdout or stderr.
// Called on dump1090's own threads, not the main thread.
typedef void (*dump1090_output_fn)(const char *buf, size_t len, void *ctx);

// Set before calling dump1090_main(). Pass NULL to write to stdout again.
void dump1090_set_output_handler(dump1090_output_fn fn, void *ctx);

// Runs dump1090 with command line style arguments (argv[0] is ignored).
// Blocks until dump1090_stop() is called, the device goes away, or an
// error occurs. Returns 0 on a clean stop, non-zero on error.
int dump1090_main(int argc, char **argv);

// Asks the current, or about to start, dump1090_main() call to return.
// Safe to call from any thread.
void dump1090_stop(void);

#ifdef __cplusplus
}
#endif

#endif // DUMP1090_API_H
