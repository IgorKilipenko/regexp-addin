# Скрипты сборки внешней компоненты 1C

Этот каталог содержит скрипты для сборки внешней компоненты RegExp для всех поддерживаемых платформ 1C:Предприятие.

## Поддерживаемые платформы

- **Windows**: x86_64, i686
- **Linux**: x86_64, i686, ARM64
- **macOS**: x86_64, ARM64

## Быстрый старт

1. Установите целевые платформы Rust: `./scripts/setup-targets.sh`
2. Для Windows кросскомпиляции установите MinGW (см. [INSTALL_MINGW.md](INSTALL_MINGW.md))
3. Запустите сборку: `./scripts/build.sh ./target release`

## Подготовка к сборке

### 1. Установка целевых платформ Rust

Перед сборкой необходимо установить все необходимые целевые платформы:

```bash
./scripts/setup-targets.sh
```

### 2. Установка дополнительных инструментов

#### Для Windows платформ (кросскомпиляция):
```bash
# Ubuntu/Debian
sudo apt-get install gcc-mingw-w64-x86-64 gcc-mingw-w64-i686

# Fedora
sudo dnf install mingw64-gcc mingw32-gcc

# Arch Linux
sudo pacman -S mingw-w64-gcc
```

#### Для macOS платформ (кросскомпиляция):
```bash
# Установка Xcode Command Line Tools
xcode-select --install
```

## Сборка

### Базовая сборка (debug)
```bash
./scripts/build.sh
```

### Сборка в release режиме
```bash
./scripts/build.sh ./target release
```

### Сборка в указанную директорию
```bash
./scripts/build.sh /path/to/target release
```

## Результат сборки

После успешной сборки в директории `target/out/` будет создан архив `regexp_addin.zip` (или `regexp_addin_debug.zip` для debug сборки), содержащий:

- Скомпилированные библиотеки для всех поддерживаемых платформ
- Файл `MANIFEST.XML` с описанием компонент
- Файл `info.xml` с информацией о компоненте

## Структура MANIFEST.XML

Скрипт автоматически генерирует MANIFEST.XML в соответствии со стандартом 1C:

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<bundle xmlns="http://v8.1c.ru/8.2/addin/bundle" name="RegExp">
    <component os="Windows" path="regexp_addin_windows_x86_64.dll" type="native" arch="x86_64" />
    <component os="Windows" path="regexp_addin_windows_i686.dll" type="native" arch="i386" />
    <component os="Linux" path="regexp_addin_linux_x86_64.so" type="native" arch="x86_64" />
    <component os="Linux" path="regexp_addin_linux_i686.so" type="native" arch="i386" />
    <component os="Linux" path="regexp_addin_linux_aarch64.so" type="native" arch="ARM64" />
    <component os="MacOS" path="regexp_addin_darwin_x86_64.dylib" type="native" arch="x86_64" />
    <component os="MacOS" path="regexp_addin_darwin_aarch64.dylib" type="native" arch="ARM64" />
</bundle>
```

## Устранение неполадок

### Ошибка "target not found"
Убедитесь, что все необходимые целевые платформы установлены:
```bash
rustup target list --installed
```

### Ошибки кросскомпиляции
Убедитесь, что установлены необходимые инструменты для кросскомпиляции (см. раздел "Установка дополнительных инструментов").

### Отсутствие некоторых платформ в результате
Скрипт автоматически проверяет доступность целевых платформ и собирает только те, которые доступны. Это нормальное поведение.
