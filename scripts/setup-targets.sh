#!/usr/bin/env bash

# Скрипт для установки необходимых целевых платформ Rust
# для сборки внешней компоненты 1C для всех поддерживаемых платформ

echo "Установка целевых платформ Rust для сборки внешней компоненты 1C..."

# Проверяем, установлен ли rustup
if ! command -v rustup &> /dev/null; then
    echo "Ошибка: rustup не найден. Пожалуйста, установите Rust с rustup."
    exit 1
fi

# Список целевых платформ для внешних компонент 1C
targets=(
    # Windows
    "x86_64-pc-windows-gnu"
    "i686-pc-windows-gnu"

    # Linux
    "x86_64-unknown-linux-gnu"
    "i686-unknown-linux-gnu"
    "aarch64-unknown-linux-gnu"

    # macOS
    "x86_64-apple-darwin"
    "aarch64-apple-darwin"
)

# Устанавливаем каждую целевую платформу
for target in "${targets[@]}"; do
    echo "Установка целевой платформы: $target"
    if rustup target add "$target"; then
        echo "✓ $target установлена успешно"
    else
        echo "✗ Ошибка при установке $target"
    fi
done

echo ""
echo "Проверка установленных целевых платформ:"
rustup target list --installed

echo ""
echo "Для Windows платформ также может потребоваться установка MinGW-w64:"
echo "Ubuntu/Debian: sudo apt-get install gcc-mingw-w64-x86-64 gcc-mingw-w64-i686"
echo "Fedora: sudo dnf install mingw64-gcc mingw32-gcc"
echo "Arch Linux: sudo pacman -S mingw-w64-gcc"

echo ""
echo "Для macOS платформ может потребоваться установка Xcode Command Line Tools:"
echo "xcode-select --install"
