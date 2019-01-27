# Раскраска текстового вывода

# ANSI цвета для раскрашивания вывода на терминал
ifeq ($(ANSI),1)
C.RST      = [0m
C.WHITE    = [1;37m
C.LCYAN    = [1;36m
C.LMAGENTA = [1;3m
C.LBLUE    = [1;34m
C.YELLOW   = [1;33m
C.LGREEN   = [1;32m
C.LRED     = [1;31m
C.DGRAY    = [1;30m
C.GRAY     = [0;37m
C.CYAN     = [0;36m
C.MAGENTA  = [0;3m
C.BLUE     = [0;34m
C.BROWN    = [0;33m
C.GREEN    = [0;32m
C.RED      = [0;31m
C.BLACK    = [0;30m
endif

# Цветовая палитра - используйте их вместо прямой ссылки на цвета

# Разделители
C.SEP = $(C.DGRAY)
# Заголовки
C.HEAD = $(C.LGREEN)
# "Подчёркнутый" текст
C.EMPH = $(C.LBLUE)
# "Выделенный" текст
C.BOLD = $(C.WHITE)
# Текст сообщения об ошибке
C.ERR = $(C.LRED)
