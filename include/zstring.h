#ifndef __ZSTRING_H__
#define __ZSTRING_H__

#include <stddef.h>

typedef struct zstring_t zstring_t;

typedef struct zstring_iterator_t {
  const zstring_t* zstring;
  size_t index;
} zstring_iterator_t;

typedef enum zstring_error_t {
    ZSTRING_ERROR_NONE,
    ZSTRING_ERROR_OUT_OF_MEMORY,
    ZSTRING_ERROR_INVALID_RANGE,
} zstring_error_t;

extern zstring_t* zstring_init();

extern zstring_t* zstring_init_with_contents(const char* contents, zstring_error_t* out_err);

extern void zstring_deinit(zstring_t* self);

extern size_t zstring_size(const zstring_t* self);

extern size_t zstring_capacity(const zstring_t* self);

extern zstring_error_t zstring_allocate(zstring_t* self, size_t bytes);

extern zstring_error_t zstring_truncate(zstring_t* self);

extern zstring_error_t zstring_concat(zstring_t* self, const char* _char);

extern zstring_error_t zstring_insert(zstring_t* self, const char* literal, size_t index);

extern const char* zstring_pop(zstring_t* self, size_t* len);

extern int zstring_cmp(const zstring_t* self, const char* literal);

extern const char* zstring_str(const zstring_t* self, size_t* len);

extern char* zstring_to_owned(const zstring_t* self, zstring_error_t* out_err, size_t* len);

extern const char* zstring_char_at(const zstring_t* self, size_t index, size_t* len);

extern size_t zstring_len(const zstring_t* self);

extern size_t zstring_find(const zstring_t* self, const char* literal);

extern zstring_error_t zstring_remove(zstring_t* self, size_t index);

extern zstring_error_t zstring_remove_range(zstring_t* self, size_t start, size_t end);

extern void zstring_trim_start(zstring_t* self, const char* whitelist);

extern void zstring_trim_end(zstring_t* self, const char* whitelist);

extern void zstring_trim(zstring_t* self, const char* whitelist);

extern zstring_t* zstring_clone(const zstring_t* self, zstring_error_t* out_err);

extern void zstring_reverse(zstring_t* self);

extern zstring_error_t zstring_repeat(zstring_t* self, size_t n);

extern int zstring_is_empty(const zstring_t* self);

extern const char* zstring_split(const zstring_t* self, const char* delimiters, size_t index, size_t* len);

extern zstring_t* zstring_split_to_zstring(const zstring_t* self, const char* delimiters, size_t index, zstring_error_t* out_err);

extern void zstring_clear(zstring_t* self);

extern void zstring_to_lowercase(zstring_t* self);

extern void zstring_to_uppercase(zstring_t* self);

extern zstring_t* zstring_substr(const zstring_t* self, size_t start, size_t end, zstring_error_t* out_err);

extern const char* zstring_iterator_next(zstring_iterator_t* it, size_t* len);

extern zstring_iterator_t zstring_iterator(const zstring_t* self);

#endif // __ZSTRING_H__
