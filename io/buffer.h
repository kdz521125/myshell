#ifndef BUFFER_H
#define BUFFER_H    

#include <stdlib.h>
#include <stdint.h>
#include <string.h>

// 内存管理结构
typedef struct {
    uint8_t *buffer;
    size_t size;
    size_t capacity;
} MemoryBuffer;

// 创建内存缓冲区
static MemoryBuffer* create_buffer(size_t initial_capacity);

// 扩展缓冲区
static int expand_buffer(MemoryBuffer *buf, size_t min_capacity);

// 写入数据到缓冲区
static int write_to_buffer(MemoryBuffer *buf, const void *data, size_t size);

#endif