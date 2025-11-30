 #
 # @file Makefile
 # @brief Makefile
 # @ingroup build
 #
 # @author Iyan Nazarian
 # @date 2025-11-28
 # @version 091a468
 #
 #

#<><><><><><><> Files <><><><><><><><><><><><><><><><><><><>
ROOT		= $(abspath $(CURDIR))

SRC_DIR 	= $(ROOT)/src/
BUILD_DIR 	= $(ROOT)/build/
INC_DIR 	= $(ROOT)/include/
TEST_DIR	= $(ROOT)/tests/
DOCS_DIR 	= $(ROOT)/docs

DOXYFILE_IN 	= $(DOCS_DIR)/Doxyfile.in
DOXYFILE 	= $(DOCS_DIR)/Doxyfile

# .c files for source code
SRC_FILES_NAMES = file.c

# Full path to .c files
SRC_FILES = $(addprefix $(SRC_DIR), $(SRC_FILES_NAMES))

# .o files for compilation
OBJ_FILES = $(patsubst $(SRC_DIR)%.c, $(BUILD_DIR)%.o, $(SRC_FILES))

# .d files for header dependency
DEP_FILES := $(OBJ_FILES:.o=.d)


#<><><><><><><> Variables <><><><><><><><><><><><><><><><><>
NAME 	:= libminicode.a
AR	:= ar rcs
CC 	:= cc
CFLAGS 	:= -gdwarf-4 -Wall -Wextra -Werror -I $(INC_DIR) -MMD -MP -DLOGFILE_NAME=\"$(LOGFILE)\"
MKDIR 	:= mkdir -p
RM_RF 	:= rm -rf
OPEN	:= $(shell command -v open 2> /dev/null) 
ECHO	:= printf '%b\n'

PROJECT_VERSION := $(shell git describe --tags --always)

BLUE	:= \033[34m
BROWN	:= \033[33m
GREEN	:= \033[32m
RED	:= \033[31m
NC	:= \033[0m

#<><><><><><><> Recipes <><><><><><><><><><><><><><><><><><>

# Modifying Implicit conversion rules to build in custom directory
$(BUILD_DIR)%.o : $(SRC_DIR)%.c
	@$(MKDIR) $(dir $@)
	@$(ECHO) "$(BLUE)[CMP] Compiling \b$(subst $(ROOT)/, ,$<)...$(NC)"
	@$(CC) -c $(CFLAGS) $< -o $@ 


# This is to add the .d files as dependencies for linking
-include $(DEP_FILES)

re : fclean all

$(NAME) : $(OBJ_FILES)
	@$(ECHO) "$(BROWN)[AR ] Building $(NAME) static library...$(NC)"
	@$(AR) $(NAME) $(OBJ_FILES)
	@$(ECHO) "$(GREEN)[AR ] library built successfully.$(NC)"


TEST_ALLOWED_GOALS := all re
TEST_SUBTARGET := $(firstword $(filter $(TEST_ALLOWED_GOALS),$(MAKECMDGOALS)))
ifeq ($(TEST_SUBTARGET),)
TEST_SUBTARGET := all
endif

$(TEST_DIR)/libminicode-test: $(NAME)
	@if [ -n "$(COMPILECOMMANDS)" ]; then \
		compiledb make -C $(TEST_DIR) \
			LCFLAGS=" -I$(INC_DIR)" \
			LFLAGS+=" $(ROOT)/$(NAME)" \
			$(TEST_SUBTARGET); \
		mv $(TEST_DIR)/libminicode-test $(ROOT)/; \
		mv compile_commands.json $(TEST_DIR); \
		compiledb make re; \
	else \
		$(MAKE) -C $(TEST_DIR) \
			LCFLAGS=" -I$(INC_DIR)" \
			LFLAGS+=" $(ROOT)/$(NAME)" \
			$(TEST_SUBTARGET); \
		mv $(TEST_DIR)/libminicode-test $(ROOT)/; \
	fi



tests: $(NAME) $(TEST_DIR)/libminicode-test

docs:
	@$(ECHO) "$(BROWN)[DOC] Generating documentation...$(NC)"
	@sed \
		-e "s|@DOCS_DIR@|$(DOCS_DIR)|" \
		-e "s|@PROJECT_VERSION@|$(PROJECT_VERSION)|" \
	$(DOXYFILE_IN) > $(DOXYFILE)

	@doxygen $(DOXYFILE) > /dev/null
	@rm -rf $(DOCS_DIR)/html/ $(DOCS_DIR)/latex/
	@mv html latex $(DOCS_DIR)/
	@$(ECHO) "$(GREEN)[DOC] Documentation generated successfully.$(NC)"
ifndef OPEN
	$(shell xdg-open $(DOCS_DIR)/html/index.html > /dev/null 2>&1 || true)
else
	echo $(DOCS_DIR)
	$(shell open $(DOCS_DIR)/html/index.html  || true)
endif


all : $(NAME) 

clean : 
	@$(ECHO) "$(BROWN)[CLN] Cleaning object and dependency files...$(NC)"
	@$(RM) $(DEP_FILES) $(OBJ_FILES)
	@$(ECHO) "$(GREEN)[CLN] Clean complete.$(NC)"

fclean : 
	@$(ECHO) "$(BROWN)[CLN] Cleaning Doxygen generated documentation...$(NC)"
	@$(RM_RF) $(DOCS_DIR)/html $(DOCS_DIR)/latex
	@$(RM_RF) $(DOXYFILE)
	@$(ECHO) "$(GREEN)[CLN] Documentation clean complete.$(NC)"
	@$(ECHO) "$(BROWN)[CLN] Cleaning object, dependency files, and library...$(NC)"
	@$(RM_RF) $(BUILD_DIR) $(NAME) libminicode-test
	@$(ECHO) "$(GREEN)[CLN] Clean complete.$(NC)"
	@$(ECHO) # for newline

.DEFAULT_GOAL := all
.PHONY : all clean fclean re docs
