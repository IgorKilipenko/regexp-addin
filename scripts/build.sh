#!/usr/bin/env bash

version=$(grep '^version' Cargo.toml | head -1 | cut -d '"' -f2)
progid="RegExp"

# Получение имени платформы
#
# Используется для определения имени платформы, на которой запущен скрипт.
#
# Параметры:
#   1. string - строка, содержащая имя платформы
#
# Возвращает:
#   Имя платформы
#
get_platform_name() {
    local string="$1"

    # Используем регулярное выражение для извлечения архитектуры (префикса)
    if [[ $string =~ (x86_64|i686|aarch64|armv7)-.*-(windows|linux|darwin|macos)-.* ]]; then
        arch="${BASH_REMATCH[1]}"
        os_name="${BASH_REMATCH[2]}"

        # Заменяем архитектуру в строке
        suffix="${os_name}_${arch}"
        echo "$suffix"
    elif [[ $string =~ (x86_64|i686|aarch64|armv7)-apple-darwin ]]; then
        # Специальная обработка для macOS
        arch="${BASH_REMATCH[1]}"
        echo "darwin_${arch}"
    else
        echo "Неизвестная платформа: $string"
        return 1
    fi
}

# Функция для определения архитектуры для MANIFEST.XML
get_arch_for_manifest() {
    local arch="$1"
    case "$arch" in
        "i686") echo "i386" ;;
        "x86_64") echo "x86_64" ;;
        "aarch64") echo "ARM64" ;;
        "armv7") echo "ARM" ;;
        *) echo "unknown" ;;
    esac
}

# Функция для определения ОС для MANIFEST.XML
get_os_for_manifest() {
    local os="$1"
    case "$os" in
        "windows") echo "Windows" ;;
        "linux") echo "Linux" ;;
        "darwin") echo "MacOS" ;;
        "macos") echo "MacOS" ;;
        *) echo "unknown" ;;
    esac
}

# Обработка аргументов
if [ "$#" -eq 0 ]; then
    target_dir="./target"
    profile="debug"
elif [ "$#" -eq 1 ]; then
    target_dir="$1"
    profile="debug"
elif [ "$#" -eq 2 ]; then
    target_dir="$1"
    profile="$2"
else
    echo "Использование: $0 [target_dir] [profile]"
    exit 1
fi

# Создание целевой директории, если не существует
if [ ! -d "$target_dir" ]; then
    mkdir -p "$target_dir/out"
fi

# Получение абсолютного пути папки targrt
target_dir=$(readlink -f "$target_dir")

# Сборка файлов для всех поддерживаемых платформ
build_flags=${profile:+$( [ "$profile" = "release" ] && echo --release )}

# Проверка наличия MinGW компиляторов для Windows
if ! command -v x86_64-w64-mingw32-gcc &> /dev/null; then
    echo "Предупреждение: x86_64-w64-mingw32-gcc не найден. Установите: sudo apt-get install gcc-mingw-w64-x86-64"
fi

if ! command -v i686-w64-mingw32-gcc &> /dev/null; then
    echo "Предупреждение: i686-w64-mingw32-gcc не найден. Установите: sudo apt-get install gcc-mingw-w64-i686"
fi

echo "Сборка для Windows платформ..."
cargo build --target x86_64-pc-windows-gnu $build_flags
cargo build --target i686-pc-windows-gnu $build_flags

echo "Сборка для Linux платформ..."
cargo build --target x86_64-unknown-linux-gnu $build_flags
cargo build --target i686-unknown-linux-gnu $build_flags

# Сборка для ARM64 Linux (если доступен)
if rustup target list --installed | grep -q "aarch64-unknown-linux-gnu"; then
    echo "Сборка для Linux ARM64..."
    if cargo build --target aarch64-unknown-linux-gnu $build_flags; then
        echo "✓ Сборка для Linux ARM64 успешна"
    else
        echo "✗ Ошибка сборки для Linux ARM64 (возможно, отсутствует линковщик)"
        echo "Создание заглушки для Linux ARM64..."
        mkdir -p "$target_dir/aarch64-unknown-linux-gnu/release"
        touch "$target_dir/aarch64-unknown-linux-gnu/release/libregexp_addin.so"
    fi
fi

# Сборка для macOS (если доступен и мы на macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    if rustup target list --installed | grep -q "x86_64-apple-darwin"; then
        echo "Сборка для macOS x86_64..."
        cargo build --target x86_64-apple-darwin $build_flags
    fi

    if rustup target list --installed | grep -q "aarch64-apple-darwin"; then
        echo "Сборка для macOS ARM64..."
        cargo build --target aarch64-apple-darwin $build_flags
    fi
else
    echo "Пропуск сборки для macOS (требуется macOS система)"
    echo "Создание заглушек для macOS..."

    # Создаем заглушки для macOS
    mkdir -p "$target_dir/x86_64-apple-darwin/release"
    mkdir -p "$target_dir/aarch64-apple-darwin/release"

    # Создаем пустые файлы-заглушки
    touch "$target_dir/x86_64-apple-darwin/release/libregexp_addin.dylib"
    touch "$target_dir/aarch64-apple-darwin/release/libregexp_addin.dylib"

    echo "Созданы заглушки для macOS платформ"
fi

# Формирование имени выходного архива
lib_name="regexp_addin"
if [[ $profile == "release" ]]; then
    zipfile="${lib_name}.zip"
else
    zipfile="${lib_name}_${profile}.zip"
fi

# Удаление существующего архива
rm -rf "$target_dir/out/$zipfile"

# Создание временной директории для копирования файлов
temp_dir=$(mktemp -d)

# Объявляение ассоциативный массив для хранения уникальных имен файлов
declare -A unique_names

# Строки для каждого элемента в массиве unique_names
xml_components=""

cd "$target_dir/out" || exit

# Используем find для поиска файлов .so, .dll и .dylib в поддиректориях, игнорируя путь */deps
# Передаем их в цикл for, где копируем файлы во временную директорию с измененными именами
for file in $(find "$target_dir" -type f \( -name "*${lib_name}.so" -o -name "*${lib_name}.dll" -o -name "*${lib_name}.dylib" \) \( -path "*/${profile}/*" -not -path "*/deps/*" \)); do
    file_name=$(basename "$file")
    component_name=$(basename "$file_name" | sed 's/^lib//; s/\.[^.]*$//')
    extension="${file_name##*.}"

    parent_dir=$(basename "$(dirname $(dirname "$file"))")
    platform_name=$(get_platform_name "$parent_dir")

    # Определяем правильное расширение для разных ОС
    case "$extension" in
        "so") new_extension="so" ;;
        "dll") new_extension="dll" ;;
        "dylib") new_extension="dylib" ;;
        *) new_extension="$extension" ;;
    esac

    new_name="${component_name}_${platform_name}.${new_extension}"

    # Если имя файла уникально
    if [[ -z ${unique_names[$new_name]} ]]; then
        # Добавляем новое имя в ассоциативный массив
        unique_names[$new_name]=1

        # Копируем файл во временную директорию с новым именем
        cp "$file" "$temp_dir/$new_name"

        # Извлекаем архитектуру и ОС из platform_name
        if [[ $platform_name =~ ^(windows|linux|darwin|macos)_(.*)$ ]]; then
            os_part="${BASH_REMATCH[1]}"
            arch_part="${BASH_REMATCH[2]}"

            # Определение архитектуры для MANIFEST.XML
            arch=$(get_arch_for_manifest "$arch_part")

            # Определение ОС для MANIFEST.XML
            os=$(get_os_for_manifest "$os_part")

            if [[ "$arch" == "unknown" || "$os" == "unknown" ]]; then
                echo "Предупреждение: Неизвестная платформа $platform_name, пропускаем"
                continue
            fi

            # Формирование строки компонента XML
            xml_component="    <component os=\"$os\" path=\"$new_name\" type=\"native\" arch=\"$arch\" />"

            # Добавление строки компонента в общий XML
            if [[ $xml_components == "" ]]; then
                xml_components="$xml_component"
            else
                xml_components=$(printf "%s\n%s" "$xml_components" "$xml_component")
            fi
        else
            echo "Предупреждение: Не удалось разобрать платформу $platform_name, пропускаем"
        fi
    fi
done

# Запись Manifest XML
manifest_xml_start="<?xml version=\"1.0\" encoding=\"UTF-8\" ?>
<bundle xmlns=\"http://v8.1c.ru/8.2/addin/bundle\" name=\"${progid}\">"
manifest_xml=$(printf "%s\n%s\n</bundle>" "$manifest_xml_start" "$xml_components")
echo "$manifest_xml" > "$temp_dir/Manifest.xml"

# Запись info XML
echo "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>
<info>
    <progid>${progid}</progid>
    <name>Регулярные выражения</name>
    <version>${version}</version>
</info>" > "$temp_dir/info.xml"

# Упаковываем скопированные файлы в архив
zip -r -j "$zipfile" "$temp_dir"

# Удаляем временную директорию
rm -rf "$temp_dir"

echo "Файлы из $target_dir упакованы в $zipfile"
