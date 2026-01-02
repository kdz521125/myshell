#include "buffer.h"

// 创建内存缓冲区
 MemoryBuffer* create_buffer(size_t initial_capacity) {
    MemoryBuffer *buf = malloc(sizeof(MemoryBuffer));
    if (!buf) return NULL;
    
    buf->buffer = malloc(initial_capacity);
    if (!buf->buffer) {
        free(buf);
        return NULL;
    }
    
    buf->size = 0;
    buf->capacity = initial_capacity;
    return buf;
}

// 扩展缓冲区
 int expand_buffer(MemoryBuffer *buf, size_t min_capacity) {
    if (buf->capacity >= min_capacity) {
        return 1;
    }
    
    size_t new_capacity = buf->capacity * 2;
    if (new_capacity < min_capacity) {
        new_capacity = min_capacity;
    }
    
    uint8_t *new_buffer = realloc(buf->buffer, new_capacity);
    if (!new_buffer) {
        return 0;
    }
    
    buf->buffer = new_buffer;
    buf->capacity = new_capacity;
    return 1;
}

// 写入数据到缓冲区
 int write_to_buffer(MemoryBuffer *buf, const void *data, size_t size) {
    if (buf->size + size > buf->capacity) {
        if (!expand_buffer(buf, buf->size + size)) {
            return 0;
        }
    }
    memcpy(buf->buffer + buf->size, data, size);
    buf->size += size;
    return 1;
}