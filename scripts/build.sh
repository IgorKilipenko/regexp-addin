#!/usr/bin/env bash

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
    if [[ $string =~ (x86_64|i686)-.*-(windows|linux)-.* ]]; then
        arch="${BASH_REMATCH[1]}"
        os_name="${BASH_REMATCH[2]}"

        # Заменяем архитектуру в строке
        suffix="${os_name}_${arch}"
        echo "$suffix"
    else
        echo "Неизвестная платформа: $string"
        return 1
    fi
}

# Обработка аргументов
if [ "$#" -eq 0 ]; then
    target_dir="./target"
else
    target_dir="$1"
fi

if [ ! -d "$target_dir" ]; then
    mkdir -p "$target_dir/out"
fi

target_dir=$(readlink -f "$target_dir")

# Сборка файлов
cargo build --target x86_64-pc-windows-gnu
cargo build --target i686-pc-windows-gnu
cargo build --target x86_64-unknown-linux-gnu
cargo build --target i686-unknown-linux-gnu

# Создание архива
lib_name="regexp_addin"
zipfile="$lib_name.zip"

# Удаление существующего архива
rm -rf "$target_dir"/out/*

# Создание временной директории для копирования файлов
temp_dir=$(mktemp -d)

# Объявляение ассоциативный массив для хранения уникальных имен файлов
declare -A unique_names

# Строки для каждого элемента в массиве unique_names
xml_components=""

cd "$target_dir/out" || exit

# Используем find для поиска файлов .so и .dll в поддиректориях debug, игнорируя путь */debug/*deps
# Передаем их в цикл for, где копируем файлы во временную директорию с измененными именами
for file in $(find "$target_dir" -type f \( -name "*${lib_name}.so" -o -name "*${lib_name}.dll" \) -not -path "*/debug/*deps*"); do
    file_name=$(basename "$file")
    #filename_without_extension="${file_name%.*}"
    component_name=$(basename "$name" | sed 's/^lib//; s/\.[^.]*$//')
    extension="${file_name##*.}"

    parent_dir=$(basename "$(dirname $(dirname "$file"))")
    platform_name=$(get_platform_name "$parent_dir")
    new_name="${component_name}_${platform_name}.${extension}"

    # Если имя файла уникально
    if [[ -z ${unique_names[$new_name]} ]]; then
        # Добавляем новое имя в ассоциативный массив
        unique_names[$new_name]=1

        # Копируем файл во временную директорию с новым именем
        cp "$file" "$temp_dir/$new_name"

        # Определение архитектуры
        if [[ $platform_name == *"i686" ]]; then
            arch="i386"
        elif [[ $platform_name == *"x86_64" ]]; then
            arch="x86_64"
        else
            echo "Неизвестная архитектура платформы: $platform_name"
            return 1
        fi

        # Определение ОС
        if [[ $platform_name == "windows"* ]]; then
            os="Windows"
        elif [[ $platform_name == "linux"* ]]; then
            os="Linux"
        else
            echo "Неизвестная операционная система платформы: $platform_name"
            return 1
        fi

        # Формирование строки компонента XML
        xml_component="    <component os=\"$os\" path=\"$new_name\" type=\"native\" arch=\"$arch\" />"

        # Добавление строки компонента в общий XML
        xml_components=$(printf "%s\n%s" "$xml_components" "$xml_component")
    fi
done

echo "Компоненты: $xml_components"

# Запись Manifest XML
manifest_xml_start="<?xml version="1.0" encoding="UTF-8"?>
<bundle xmlns="http://v8.1c.ru/8.2/addin/bundle" name="SRegExp">"
manifest_xml=$(printf "%s\n%s\n</bundle>" "$manifest_xml_start" "$xml_components")
echo -e "$manifest_xml" > "$temp_dir/Manifest.xml"

# Запись info XML
echo "<?xml version="1.0" encoding="UTF-8"?>
<info>
    <progid>SRegExp</progid>
    <name>Регулярные выражения</name>
    <version>0.1.0</version>
</info>" > "$temp_dir/info.xml"

# Упаковываем скопированные файлы в архив
zip -r -j "$zipfile" "$temp_dir"

# Удаляем временную директорию
rm -rf "$temp_dir"

echo "Файлы из $target_dir упакованы в $zipfile"
