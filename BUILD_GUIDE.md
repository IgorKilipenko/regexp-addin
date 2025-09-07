# Руководство по сборке RegExp AddIn

## 🚀 Быстрый старт

```bash
# 1. Клонируйте репозиторий
git clone <repository-url>
cd regexp-addin

# 2. Полная настройка
make dev-setup

# 3. Сборка
make release

# 4. Проверка результата
make verify-archive
```

## 📋 Подробная инструкция

### Шаг 1: Проверка зависимостей
```bash
make check-deps
```

Убедитесь, что установлены:
- ✅ Rust (rustc, cargo, rustup)
- ✅ MinGW для Windows кросскомпиляции
- ⚠️ ARM64 линковщик (опционально)

### Шаг 2: Установка целевых платформ
```bash
make setup
```

Устанавливает Rust targets для всех поддерживаемых платформ.

### Шаг 3: Установка дополнительных инструментов

#### MinGW для Windows (если не установлен)
```bash
make install-mingw  # Покажет инструкции
```

#### ARM64 линковщик (опционально)
```bash
make install-arm64-toolchain
```

### Шаг 4: Сборка

#### Полная сборка
```bash
make release        # Release версия
make build          # Debug версия
make full-build     # С тестами
```

#### Индивидуальная сборка платформ
```bash
# Linux
make build-linux-x64
make build-linux-x32
make build-linux-arm64

# Windows
make build-windows-x64
make build-windows-x32

# macOS (только на macOS)
make build-macos-x64
make build-macos-arm64
```

### Шаг 5: Проверка результата

```bash
make verify-archive    # Проверить архив
make size             # Размеры библиотек
make manifest         # Показать MANIFEST.XML
make info             # Общая информация
```

## 🔧 Устранение проблем

### Ошибка сборки ARM64 Linux
```
error: linking with `cc` failed
```
**Решение:** Проблема решена автоматически через `.cargo/config.toml`, который настраивает правильный линковщик для ARM64.

### Ошибка сборки Windows
```
error: could not find native static library
```
**Решение:** Установите MinGW:
```bash
# Ubuntu/Debian
sudo apt-get install gcc-mingw-w64-x86-64 gcc-mingw-w64-i686

# Fedora
sudo dnf install mingw64-gcc mingw32-gcc

# Arch Linux
sudo pacman -S mingw-w64-gcc
```

### macOS сборка на Linux
Создаются заглушки автоматически. Для реальных библиотек нужна macOS система.

## 📦 Результат сборки

После успешной сборки в `target/out/` создается:
- `regexp_addin.zip` - архив для загрузки в 1C
- `Manifest.xml` - манифест компоненты
- `info.xml` - информация о компоненте

### Содержимое архива
- **Linux**: `regexp_addin_linux_x86_64.so`, `regexp_addin_linux_i686.so`
- **Windows**: `regexp_addin_windows_x86_64.dll`, `regexp_addin_windows_i686.dll`
- **Заглушки**: ARM64 Linux, macOS (если не удалось собрать)

## 🎯 Полезные команды

```bash
make help              # Справка по всем командам
make list-targets      # Установленные Rust targets
make clean             # Очистка артефактов
make clean-all         # Полная очистка
make clippy            # Проверка кода
make fmt               # Форматирование
make test              # Тесты
```

## 📚 Дополнительная информация

- [README.md](README.md) - Основная документация
- [scripts/INSTALL_MINGW.md](scripts/INSTALL_MINGW.md) - Подробная установка MinGW
- [scripts/build.sh](scripts/build.sh) - Скрипт сборки
- [scripts/setup-targets.sh](scripts/setup-targets.sh) - Установка Rust targets
