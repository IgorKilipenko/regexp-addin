# DevContainer для RegExp AddIn

Этот DevContainer содержит все необходимые зависимости для разработки внешней компоненты RegExp AddIn для 1C:Предприятие.

## 🚀 Быстрый старт

### Требования
- [Docker](https://www.docker.com/get-started)
- [VS Code](https://code.visualstudio.com/)
- [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

### Запуск
1. Откройте проект в VS Code
2. Нажмите `Ctrl+Shift+P` (или `Cmd+Shift+P` на macOS)
3. Выберите `Dev Containers: Reopen in Container`
4. Дождитесь сборки контейнера

## 📦 Что включено

### Системные зависимости
- **Rust 1.89** - основной язык разработки
- **MinGW** - для кросскомпиляции Windows версий
- **ARM64 GCC** - для кросскомпиляции Linux ARM64
- **OneScript** - для разработки 1C
- **Git** - система контроля версий

### Rust targets
- `x86_64-pc-windows-gnu` - Windows 64-bit ✅
- `i686-pc-windows-gnu` - Windows 32-bit ✅
- `x86_64-unknown-linux-gnu` - Linux 64-bit ✅
- `i686-unknown-linux-gnu` - Linux 32-bit ✅
- `aarch64-unknown-linux-gnu` - Linux ARM64 ✅
- `x86_64-apple-darwin` - macOS 64-bit (заглушка)
- `aarch64-apple-darwin` - macOS ARM64 (заглушка)

### Инструменты разработки
- **rustfmt** - форматирование кода
- **clippy** - линтер
- **cargo-audit** - проверка безопасности
- **cargo-outdated** - проверка устаревших зависимостей
- **cargo-tree** - дерево зависимостей
- **cargo-expand** - расширение макросов

### VS Code расширения
- **Rust Analyzer** - основной Rust LSP
- **Code Spell Checker** - проверка орфографии
- **Makefile Tools** - поддержка Makefile
- **GitLens** - расширенная работа с Git
- **Docker** - поддержка Docker

## 🛠️ Использование

### Проверка установки
```bash
make check-deps    # Проверить все зависимости
make info          # Информация о проекте
```

### Сборка
```bash
make release       # Собрать release версию
make build         # Собрать debug версию
make full-build    # Полная сборка с тестами
```

### Индивидуальная сборка
```bash
make build-linux-x64     # Linux x86_64
make build-windows-x64   # Windows x86_64
make build-linux-arm64   # Linux ARM64
```

### Проверка результата
```bash
make verify-archive      # Проверить архив
make size               # Размеры библиотек
make manifest           # Показать MANIFEST.XML
```

## 🔧 Настройка

### Переменные окружения
- `RUST_BACKTRACE=1` - включить полный backtrace
- `RUST_LOG=debug` - уровень логирования

### Кэширование
- Cargo кэш сохраняется в Docker volume
- Rustup кэш сохраняется в Docker volume
- При пересборке контейнера кэш сохраняется

## 📁 Структура

```
.devcontainer/
├── Dockerfile          # Основной Dockerfile
├── devcontainer.json   # Конфигурация DevContainer
└── README.md          # Эта документация
```

## 🐛 Устранение проблем

### Контейнер не запускается
1. Убедитесь, что Docker запущен
2. Проверьте, что Dev Containers extension установлен
3. Попробуйте пересобрать контейнер: `Dev Containers: Rebuild Container`

### Ошибки сборки
1. Проверьте зависимости: `make check-deps`
2. Очистите кэш: `make clean-all`
3. Пересоберите: `make release`

### Медленная сборка
1. Убедитесь, что Docker имеет достаточно ресурсов
2. Проверьте, что кэш работает корректно
3. Используйте `make build` для debug версии (быстрее)

## 📚 Дополнительная информация

- [Dockerfile](Dockerfile) - подробности сборки контейнера
- [devcontainer.json](devcontainer.json) - конфигурация VS Code
- [../README.md](../README.md) - основная документация проекта
- [../BUILD_GUIDE.md](../BUILD_GUIDE.md) - руководство по сборке
