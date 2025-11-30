#<><><><><><><> Files <><><><><><><><><><><><><><><><><><><>
ROOT		= $(abspath $(CURDIR))

SRC_DIR 	= $(ROOT)/src/
BUILD_DIR 	= $(ROOT)/build/
INC_DIR 	= $(ROOT)/include/

# .c files for source code SRC_FILES_NAMES = main.c
SRC_FILES_NAMES = main.c

# Full path to .c files
SRC_FILES = $(addprefix $(SRC_DIR), $(SRC_FILES_NAMES))

# .o files for compilation
OBJ_FILES = $(patsubst $(SRC_DIR)%.c, $(BUILD_DIR)%.o, $(SRC_FILES))

# .d files for header dependency
DEP_FILES = $(patsubst $(SRC_DIR)%.c, $(BUILD_DIR)%.d, $(SRC_FILES))


#<><><><><><><> Variables <><><><><><><><><><><><><><><><><>

NAME 	:= libminicode-test
CC 	:= cc
CFLAGS 	= -gdwarf-4 -Wall -Wextra -Werror -I $(INC_DIR) -MMD -MP
LCFLAGS ?=
LFLAGS 	= 
MKDIR 	:= mkdir -p
RM_RF 	:= rm -rf
ECHO   := printf '%b\n'

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
	@$(CC) -c $(CFLAGS) $(LCFLAGS) $< -o $@ 


# This is to add the .d files as dependencies for linking
-include $(DEP_FILES)

re : fclean all

$(NAME) : $(OBJ_FILES)
	@$(ECHO) "$(BROWN)[BLD] Building Test $(NAME) executable...$(NC)"
	@$(CC) $^ -o $(NAME) $(LFLAGS)
	@$(ECHO) "$(GREEN)[BLD] Test executable built successfully.$(NC)"

all : $(NAME) 

clean : 
	@$(ECHO) "$(BROWN)[CLN] Cleaning object and dependency files...$(NC)"
	@$(RM) $(DEP_FILES) $(OBJ_FILES)
	@$(ECHO) "$(GREEN)[CLN] Clean complete.$(NC)"

fclean : 
	@$(ECHO) "$(BROWN)[CLN] Cleaning object, dependency files, and executable...$(NC)"
	@$(RM_RF) $(BUILD_DIR) $(NAME)
	@$(ECHO) "$(GREEN)[CLN] Clean complete.$(NC)"
	@$(ECHO) # for newline

.DEFAULT_GOAL := all
.PHONY : all clean fclean re docs
