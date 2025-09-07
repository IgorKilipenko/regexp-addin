# Установка MinGW для кросскомпиляции Windows

Для сборки внешней компоненты для Windows платформ из Linux необходимо установить MinGW-w64.

## Ubuntu/Debian

```bash
# Установка MinGW-w64 для 64-битных Windows
sudo apt-get update
sudo apt-get install gcc-mingw-w64-x86-64

# Установка MinGW-w64 для 32-битных Windows
sudo apt-get install gcc-mingw-w64-i686

# Установка дополнительных инструментов
sudo apt-get install binutils-mingw-w64-x86-64
sudo apt-get install binutils-mingw-w64-i686
```

## Fedora/RHEL/CentOS

```bash
# Установка MinGW-w64 для 64-битных Windows
sudo dnf install mingw64-gcc

# Установка MinGW-w64 для 32-битных Windows
sudo dnf install mingw32-gcc

# Установка дополнительных инструментов
sudo dnf install mingw64-binutils
sudo dnf install mingw32-binutils
```

## Arch Linux

```bash
# Установка MinGW-w64
sudo pacman -S mingw-w64-gcc

# Установка дополнительных инструментов
sudo pacman -S mingw-w64-binutils
```

## Проверка установки

После установки проверьте, что инструменты доступны:

```bash
# Проверка 64-битных инструментов
x86_64-w64-mingw32-gcc --version
x86_64-w64-mingw32-dlltool --version

# Проверка 32-битных инструментов
i686-w64-mingw32-gcc --version
i686-w64-mingw32-dlltool --version
```

## Настройка Rust для MinGW

После установки MinGW, Rust должен автоматически найти инструменты. Если возникают проблемы, можно настроить переменные окружения:

```bash
# Для 64-битных Windows
export CC_x86_64_pc_windows_gnu=x86_64-w64-mingw32-gcc
export CXX_x86_64_pc_windows_gnu=x86_64-w64-mingw32-g++
export AR_x86_64_pc_windows_gnu=x86_64-w64-mingw32-ar

# Для 32-битных Windows
export CC_i686_pc_windows_gnu=i686-w64-mingw32-gcc
export CXX_i686_pc_windows_gnu=i686-w64-mingw32-g++
export AR_i686_pc_windows_gnu=i686-w64-mingw32-ar
```

## Тестирование кросскомпиляции

После установки MinGW протестируйте кросскомпиляцию:

```bash
# Сборка для 64-битных Windows
cargo build --target x86_64-pc-windows-gnu --release

# Сборка для 32-битных Windows
cargo build --target i686-pc-windows-gnu --release
```

## Устранение неполадок

### Ошибка "No such file or directory"
Убедитесь, что все необходимые пакеты установлены:
```bash
# Ubuntu/Debian
sudo apt-get install gcc-mingw-w64-x86-64 gcc-mingw-w64-i686 binutils-mingw-w64-x86-64 binutils-mingw-w64-i686

# Fedora
sudo dnf install mingw64-gcc mingw32-gcc mingw64-binutils mingw32-binutils
```

### Ошибки линковки
Убедитесь, что установлены все необходимые библиотеки:
```bash
# Ubuntu/Debian
sudo apt-get install libc6-dev-i386

# Fedora
sudo dnf install glibc-devel.i686
```

### Проблемы с правами доступа
Убедитесь, что у пользователя есть права на выполнение MinGW инструментов:
```bash
ls -la /usr/bin/*mingw*
```

## Альтернативные методы

### Использование Docker
Если возникают проблемы с установкой MinGW, можно использовать Docker:

```dockerfile
FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    gcc-mingw-w64-x86-64 \
    gcc-mingw-w64-i686 \
    binutils-mingw-w64-x86-64 \
    binutils-mingw-w64-i686 \
    curl

# Установка Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Установка целевых платформ
RUN rustup target add x86_64-pc-windows-gnu
RUN rustup target add i686-pc-windows-gnu
```

### Использование GitHub Actions
Для автоматической сборки можно использовать GitHub Actions с предустановленными инструментами.
