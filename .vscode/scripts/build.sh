#!/usr/bin/env bash

cargo build --target x86_64-pc-windows-gnu
#cargo build --target i686-pc-windows-gnu
cargo build --target x86_64-unknown-linux-gnu
#cargo build --target i686-unknown-linux-gnu

# Создание архива

if [ "$#" -eq 0 ]; then
    files_path="./target"
else
    files_path="$1"
fi

if [ ! -d "$files_path" ]; then
    echo "Ошибка: '$files_path' не является директорией или не существует"
    exit 1
fi

cd "$files_path" || exit

lib_name="regexp_addin"
zipfile="$lib_name.zip"

#zip -r "$zipfile" **/*"$lib_name".so ./**/*"$lib_name".dll
#zip -r regexp_addin.zip . -i **/debug/*${lib_name}.so **/debug/*${lib_name}.dll
#find . -type f \( -name "*${lib_name}.so" -o -name "*${lib_name}.dll" \) -path "*/debug/*" -not -path "*/debug/deps/*" -exec zip -j "$zipfile" {} +

# Используем find для поиска файлов .so и .dll в поддиректориях debug, игнорируя путь */debug/*deps
# Передаем их в цикл for, где переименовываем файлы в зависимости от имен их родительских папок,
# и упаковываем их с измененными именами в архив
#find . -type f \( -name "*${lib_name}.so" -o -name "*${lib_name}.dll" \) -not -path "*/debug/*deps*" -print0 | while IFS= read -r -d '' file; do
#    parent_dir="$(basename "$(dirname "$file")")"
#    new_name="$parent_dir-$(basename "$file")"
#    zip -r "$zipfile" "${file%/*}/$new_name"
#done

# Создаем временную директорию для копирования файлов
temp_dir=$(mktemp -d)

# Объявляем ассоциативный массив для хранения уникальных имен файлов
declare -A unique_names

# Используем find для поиска файлов .so и .dll в поддиректориях debug, игнорируя путь */debug/*deps
# Передаем их в цикл for, где копируем файлы во временную директорию с измененными именами
find . -type f \( -name "*${lib_name}.so" -o -name "*${lib_name}.dll" \) -not -path "*/debug/*deps*" -print0 | while IFS= read -r -d '' file; do
    file_name=$(basename "$file")

    # Если имя файла уникально
    if [[ -z ${unique_names[$file_name]} ]]; then
        # Добавляем новое имя в ассоциативный массив
        unique_names[$file_name]=1

        parent_dir=$(basename "$(dirname "$file")")
        new_name="$parent_dir-$file_name"

        # Копируем файл во временную директорию с новым именем
        cp "$file" "$temp_dir/$new_name"

        echo "Копирование файла $file_name в $temp_dir/$new_name"
    fi
done

# Упаковываем скопированные файлы в архив
zip -r -j "$zipfile" "$temp_dir"

# Удаляем временную директорию
rm -rf "$temp_dir"

echo "Файлы из $files_path упакованы в $zipfile"
