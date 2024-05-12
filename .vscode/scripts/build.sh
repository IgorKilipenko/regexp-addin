#!/usr/bin/env bash

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

cd "$target_dir/out" || exit

# Используем find для поиска файлов .so и .dll в поддиректориях debug, игнорируя путь */debug/*deps
# Передаем их в цикл for, где копируем файлы во временную директорию с измененными именами
find "$target_dir" -type f \( -name "*${lib_name}.so" -o -name "*${lib_name}.dll" \) -not -path "*/debug/*deps*" -print0 | while IFS= read -r -d '' file; do
    file_name=$(basename "$file")
    parent_dir=$(basename "$(dirname $(dirname "$file"))")
    new_name="$parent_dir-$file_name"

    # Если имя файла уникально
    if [[ -z ${unique_names[$new_name]} ]]; then
        # Добавляем новое имя в ассоциативный массив
        unique_names[$new_name]=1

        # Копируем файл во временную директорию с новым именем
        cp "$file" "$temp_dir/$new_name"

        #echo "Копирование файла $file_name в $temp_dir/$new_name"
    fi
done

echo "<?xml version="1.0" encoding="UTF-8"?>
<bundle xmlns="http://v8.1c.ru/8.2/addin/bundle" name="ByteReader">
    <component os="Windows" path="i686-pc-windows-gnu-regexp_addin.dll" type="native" arch="i386" />
    <component os="Windows" path="x86_64-pc-windows-gnu-regexp_addin.dll" type="native" arch="x86_64" />
    <component os="Linux" path="x86_64-unknown-linux-gnu-libregexp_addin.so" type="native" arch="x86_64" />
</bundle>" > "$temp_dir/Manifest.xml"

# Упаковываем скопированные файлы в архив
zip -r -j "$zipfile" "$temp_dir"

# Удаляем временную директорию
rm -rf "$temp_dir"

echo "Файлы из $target_dir упакованы в $zipfile"
