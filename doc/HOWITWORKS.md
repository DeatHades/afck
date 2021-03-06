# Как работает система сборки
Система сборки построена на базе утилиты GNU Make. Эта утилита, хоть и не является идеалом системы сборки, однако широко доступна и многим знакома.

Тем, кому не знакома работа Make хотя бы в общих чертах, отсылаю к обучающим статьям в гугле, ключевые слова "как работает make". Например, вот вроде бы неплохая вводная статья по Make:
https://habr.com/ru/post/211751/

В системе сборки активно используются расширения Make в варианте GNU Make, так что потребуются определённые знания о них. Так как я не нашёл хороших вводных статей на тему именно расширений GNU Make, в следующей главе я кратенько опишу надстройки GNU Make над обычным Make.

В дальнейших разделах будет предполагаться наличие у пользователя базовых
знаний пользователя о Make в его GNU варианте.

# Отличия GNU Make от простого Make
Одним из главных расширений GNU Make является введение функций. Сначала в GNU Make появились встроенные функции:
```Makefile
SRC = $(wildcard src/*.c)
OBJ = $(patsubst %.c,%.o,$(SRC))
```
Как видно из примера, синтаксис вызова функций достаточно простой:
`$(имя-функции параметр1,параметр2,параметр3...)`. Результат функции подставляется в строку вместо вызова функции. В примере выше, если в подкаталоге src имеются файлы main.c и func.c, то код, приведённый выше, эквивалентен:
```Makefile
SRC = src/main.c src/func.c
OBJ = src/main.o src/func.o 
```
Полный список встроенных функций можно найти в [документации на GNU Make](https://www.gnu.org/software/make/manual/make.html#Functions).

Затем в GNU Make были добавлены функции, определяемые пользователем. Для этого была добавлена специальная встроенная функция `call`:
```Makefile
FUNC=$(if $(wildcard $1),$1,$(error file $1 not found))
FILE=$(call FUNC,src/main.c)
```
В примере выше функция FUNC возвращает имя переданного в качестве аргумента файла, если он существует, и выдаёт сообщение об ошибке, если файл не существует.
1. Функция `wildcard` возвращает пустой результат, если файл не существует.
2. Функция `if` возвращает второй аргумент, если первый аргумент не пустой.
3. Иначе функций if возвращает второй аргумент - результат выполнения функции `error`.
4. Функция `error` выводит на экран сообщение об ошибке и прекращает выполнение make.

# Последовательность инициализации системы сборки
Главная переменная, которая определяет поведение системы сборки, является переменная `TARGET`. Она задаёт *целевую платформу* - название подкаталога, в котором содержатся все необходимые файлы для создания прошивки именно под необходимую нам платформу. Целевая платформа состоит из названия аппаратной платформы (например, x96max) и названия разновидности прошивки (например, beelink), разделённых косой чертой. Файлы сборки под конкретную целевую платформу должны располагаться в каталоге build/$(TARGET), например, в каталоге build/x96max/beelink/.
При запуске make в корневом каталоге проекта, происходит следующее:
* Загружается файл `local-config.mak`, если он существует. В нём Вы можете задать значения по умолчанию для таких переменных, как `TARGET` (целевая платформа), `ANSI` (использовать ли ANSI расцветку текста, если 1) и другие.
* Далее загружается файл `build/rules.mak`, который устанавливает значения основных переменных системы сборки и определяет некоторые простые базовые функции. Например, переменная `OUT` содержит каталог, в котором ведётся сборка; функция `SAY` выводит текст, переданный в качестве аргумента, на консоль; переменная `COMMA` содержит просто запятую (полезно, если необходимо передать запятую в составе аргумента функции - иначе Make сочтёт запятую за разделитель аргументов) и так далее. Актуальный список можно посмотреть в указанном файле.
* Далее загружается файл rules.mak из подкаталога целевой платформы. Он решает, какие именно операции будут производиться для сборки прошивки. Из этого файла загружаются файлы правил из подкаталога build/, например:
  * `build/version.mak` задаёт правила для более простой работы с номером версии прошивки. Есть цели для увеличения старшего и младшего номера версии, а также номера ревизии.
  * `build/img-amlogic-unpack.mak` задаёт правила для распаковки образа прошивки для утилиты Amlogic USB Burning Tool.
  * `build/mod.mak` создаёт правила для всех модификаций прошивки. При загрузке этого файла происходит поиск всех файлов с расширением mak в каталоге `build/$(TARGET)/*/*.mak`. Каждый файл загружается по очереди, чтобы задать необходимые действия для наложения той или иной модификации прошивки. Пример простой модификации можно посмотреть в каталоге `build/x96max/beelink/example/`.
  * `build/img-amlogic-pack.mak` определяет правила для упаковки распакованного образа Amlogic USB Burning Tool в конечный файл прошивки.
  * `build/recovery-pack.mak` задаёт правила для создания прошивки в формате Recovery UPDATE.
  * `build/deploy.mak` создаёт цель `deploy`, которая осуществляет полную сборку всех конечных файлов прошивки.
