# 多文件夹项目Makefile
# ============================================

# 编译器和选项
CC = gcc
CFLAGS = -Wall -Wextra -O2 -std=c99 -fPIC
LDFLAGS = -lz -lcrypto -lm
EXE_LDFLAGS = $(LDFLAGS) -L$(BIN_DIR) -larchive

# 目录设置
SRC_DIR = src
LIB_DIR = lib
INC_DIR = include
BUILD_DIR = build
OBJ_DIR = $(BUILD_DIR)/obj
BIN_DIR = $(BUILD_DIR)/bin

# 确保目录存在
$(shell mkdir -p $(OBJ_DIR) $(BIN_DIR))

# 源文件（从多个目录收集）
SRC_FILES = $(wildcard $(SRC_DIR)/*.c)
LIB_FILES = $(wildcard $(LIB_DIR)/*.c)
ALL_SRC_FILES = $(SRC_FILES) $(LIB_FILES)

# 目标文件（在build/obj目录中）
SRC_OBJS = $(patsubst $(SRC_DIR)/%.c, $(OBJ_DIR)/%.o, $(SRC_FILES))
LIB_OBJS = $(patsubst $(LIB_DIR)/%.c, $(OBJ_DIR)/%.o, $(LIB_FILES))
OBJ_FILES = $(SRC_OBJS) $(LIB_OBJS)

# 头文件路径（注意：这里只需要一个INC_FLAGS定义）
INC_FLAGS = -I$(INC_DIR) -I$(SRC_DIR) -I$(LIB_DIR)

# 最终目标
TARGET = $(BIN_DIR)/archive
LIB_TARGET = $(BIN_DIR)/libarchive.so

# 默认目标
all: $(LIB_TARGET) $(TARGET)

# 链接可执行文件（依赖于动态库）
$(TARGET): $(OBJ_FILES) $(LIB_TARGET)
	$(CC) $(CFLAGS) -o $@ $(OBJ_FILES) $(EXE_LDFLAGS)
	@echo "可执行文件构建完成: $@"

# 创建动态库
$(LIB_TARGET): $(OBJ_FILES)
	$(CC) -shared -o $@ $(OBJ_FILES) $(LDFLAGS)
	@echo "动态库构建完成: $@"

# 编译规则：处理src目录下的.c文件
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) $(INC_FLAGS) -c $< -o $@
	@echo "编译: $< -> $@"

# 编译规则：处理lib目录下的.c文件
$(OBJ_DIR)/%.o: $(LIB_DIR)/%.c
	$(CC) $(CFLAGS) $(INC_FLAGS) -c $< -o $@
	@echo "编译: $< -> $@"

# 自动生成依赖关系（可选，更复杂的项目需要）
DEP_FILES = $(patsubst %.o, %.d, $(OBJ_FILES))

# 包含依赖文件
-include $(DEP_FILES)

# 生成依赖文件
$(OBJ_DIR)/%.d: $(SRC_DIR)/%.c
	@$(CC) $(CFLAGS) $(INC_FLAGS) -MM -MT "$(OBJ_DIR)/$*.o" $< > $@.tmp
	@sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.tmp > $@
	@rm -f $@.tmp

$(OBJ_DIR)/%.d: $(LIB_DIR)/%.c
	@$(CC) $(CFLAGS) $(INC_FLAGS) -MM -MT "$(OBJ_DIR)/$*.o" $< > $@.tmp
	@sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.tmp > $@
	@rm -f $@.tmp

# 清理
clean:
	rm -rf $(BUILD_DIR)
	@echo "清理完成"

# 安装到系统
install: all
	@echo "安装到系统..."
	@echo "需要root权限..."
	sudo cp $(TARGET) /usr/local/bin/
	sudo cp $(LIB_TARGET) /usr/local/lib/
	sudo ldconfig
	@echo "安装完成"

# 测试
test: $(TARGET)
	@echo "运行测试..."
	$(TARGET) --help || echo "程序运行完成"

# 调试构建
debug: CFLAGS += -g -DDEBUG -O0
debug: clean all

# 发布构建
release: CFLAGS += -DNDEBUG -O3
release: clean all

# 查看项目结构
tree:
	@echo "项目结构:"
	@tree -I 'build|*.o|*.so|*.a' --dirsfirst

# 帮助信息
help:
	@echo "可用命令:"
	@echo "  make all     - 构建所有目标（默认）"
	@echo "  make clean   - 清理构建文件"
	@echo "  make test    - 运行测试"
	@echo "  make install - 安装到系统"
	@echo "  make tree    - 查看项目结构"
	@echo "  make debug   - 构建调试版本"
	@echo "  make release - 构建发布版本"
	@echo "  make help    - 显示此帮助"

.PHONY: all clean install test tree help debug release