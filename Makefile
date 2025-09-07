# Makefile для сборки внешней компоненты RegExp для 1C:Предприятие
#
# Использование:
#   make help          - показать справку
#   make setup         - установить целевые платформы Rust
#   make build         - собрать debug версию для всех платформ
#   make release       - собрать release версию для всех платформ
#   make clean         - очистить артефакты сборки
#   make test          - запустить тесты
#   make check         - проверить код
#   make clippy        - запустить clippy
#   make fmt           - отформатировать код
#   make artifacts     - показать артефакты сборки
#   make manifest      - показать содержимое MANIFEST.XML

.PHONY: help setup build release clean test check clippy fmt artifacts manifest install-mingw \
	build-linux-x64 build-linux-x32 build-linux-arm64 build-windows-x64 build-windows-x32 \
	build-macos-x64 build-macos-arm64 list-targets list-available-targets size verify-archive \
	install-arm64-toolchain check-deps dev-setup full-build clean-all info

# Переменные
TARGET_DIR = ./target
PROFILE = debug
RELEASE_PROFILE = release
SCRIPT_DIR = ./scripts

# Цвета для вывода
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[1;33m
BLUE = \033[0;34m
NC = \033[0m # No Color

help: ## Показать справку
	@echo "$(BLUE)Доступные команды:$(NC)"
	@echo ""
	@echo "$(GREEN)Основные команды:$(NC)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(YELLOW)%-15s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "$(GREEN)Примеры использования:$(NC)"
	@echo "  make setup          # Установить целевые платформы"
	@echo "  make release        # Собрать release версию"
	@echo "  make test           # Запустить тесты"
	@echo "  make clean && make release  # Полная пересборка"

setup: ## Установить целевые платформы Rust
	@echo "$(BLUE)Установка целевых платформ Rust...$(NC)"
	@chmod +x $(SCRIPT_DIR)/setup-targets.sh
	@$(SCRIPT_DIR)/setup-targets.sh

install-mingw: ## Показать инструкции по установке MinGW
	@echo "$(BLUE)Инструкции по установке MinGW для Windows кросскомпиляции:$(NC)"
	@echo ""
	@echo "$(YELLOW)Ubuntu/Debian:$(NC)"
	@echo "  sudo apt-get install gcc-mingw-w64-x86-64 gcc-mingw-w64-i686"
	@echo ""
	@echo "$(YELLOW)Fedora:$(NC)"
	@echo "  sudo dnf install mingw64-gcc mingw32-gcc"
	@echo ""
	@echo "$(YELLOW)Arch Linux:$(NC)"
	@echo "  sudo pacman -S mingw-w64-gcc"
	@echo ""
	@echo "Подробные инструкции см. в $(SCRIPT_DIR)/INSTALL_MINGW.md"

build: ## Собрать debug версию для всех платформ
	@echo "$(BLUE)Сборка debug версии для всех платформ...$(NC)"
	@chmod +x $(SCRIPT_DIR)/build.sh
	@$(SCRIPT_DIR)/build.sh $(TARGET_DIR) $(PROFILE)

release: ## Собрать release версию для всех платформ
	@echo "$(BLUE)Сборка release версии для всех платформ...$(NC)"
	@chmod +x $(SCRIPT_DIR)/build.sh
	@$(SCRIPT_DIR)/build.sh $(TARGET_DIR) $(RELEASE_PROFILE)

clean: ## Очистить артефакты сборки
	@echo "$(BLUE)Очистка артефактов сборки...$(NC)"
	@cargo clean
	@rm -rf $(TARGET_DIR)/out

clean-all: clean ## Полная очистка (включая target)
	@echo "$(BLUE)Полная очистка...$(NC)"
	@rm -rf $(TARGET_DIR)

test: ## Запустить тесты
	@echo "$(BLUE)Запуск тестов...$(NC)"
	@cargo test

check: ## Проверить код
	@echo "$(BLUE)Проверка кода...$(NC)"
	@cargo check

clippy: ## Запустить clippy
	@echo "$(BLUE)Запуск clippy...$(NC)"
	@cargo clippy -- -D warnings

fmt: ## Отформатировать код
	@echo "$(BLUE)Форматирование кода...$(NC)"
	@cargo fmt

# Индивидуальные сборки для конкретных платформ
build-linux-x64: ## Собрать для Linux x86_64
	@echo "$(BLUE)Сборка для Linux x86_64...$(NC)"
	@cargo build --target x86_64-unknown-linux-gnu --release

build-linux-x32: ## Собрать для Linux i686
	@echo "$(BLUE)Сборка для Linux i686...$(NC)"
	@cargo build --target i686-unknown-linux-gnu --release

build-linux-arm64: ## Собрать для Linux ARM64
	@echo "$(BLUE)Сборка для Linux ARM64...$(NC)"
	@cargo build --target aarch64-unknown-linux-gnu --release

build-windows-x64: ## Собрать для Windows x86_64
	@echo "$(BLUE)Сборка для Windows x86_64...$(NC)"
	@cargo build --target x86_64-pc-windows-gnu --release

build-windows-x32: ## Собрать для Windows i686
	@echo "$(BLUE)Сборка для Windows i686...$(NC)"
	@cargo build --target i686-pc-windows-gnu --release

build-macos-x64: ## Собрать для macOS x86_64 (только на macOS)
	@echo "$(BLUE)Сборка для macOS x86_64...$(NC)"
	@if [[ "$(shell uname)" == "Darwin" ]]; then \
		cargo build --target x86_64-apple-darwin --release; \
	else \
		echo "$(RED)Сборка для macOS доступна только на macOS системе$(NC)"; \
	fi

build-macos-arm64: ## Собрать для macOS ARM64 (только на macOS)
	@echo "$(BLUE)Сборка для macOS ARM64...$(NC)"
	@if [[ "$(shell uname)" == "Darwin" ]]; then \
		cargo build --target aarch64-apple-darwin --release; \
	else \
		echo "$(RED)Сборка для macOS доступна только на macOS системе$(NC)"; \
	fi

# Утилиты
artifacts: ## Показать артефакты сборки
	@echo "$(BLUE)Артефакты сборки:$(NC)"
	@if [ -d "$(TARGET_DIR)/out" ]; then \
		ls -la $(TARGET_DIR)/out/; \
	else \
		echo "$(RED)Артефакты не найдены. Запустите 'make build' или 'make release'$(NC)"; \
	fi

manifest: ## Показать содержимое MANIFEST.XML
	@echo "$(BLUE)Содержимое MANIFEST.XML:$(NC)"
	@if [ -f "$(TARGET_DIR)/out/regexp_addin.zip" ]; then \
		cd $(TARGET_DIR)/out && unzip -p regexp_addin.zip Manifest.xml; \
	else \
		echo "$(RED)Архив не найден. Запустите 'make build' или 'make release'$(NC)"; \
	fi

info: ## Показать информацию о проекте
	@echo "$(BLUE)Информация о проекте:$(NC)"
	@echo "  Название: $(shell grep '^name' Cargo.toml | cut -d'"' -f2)"
	@echo "  Версия: $(shell grep '^version' Cargo.toml | cut -d'"' -f2)"
	@echo "  Целевые платформы:"
	@rustup target list --installed | sed 's/^/    /'
	@echo ""
	@echo "$(BLUE)Статус сборки:$(NC)"
	@if [ -f "$(TARGET_DIR)/out/regexp_addin.zip" ]; then \
		echo "  $(GREEN)✓ Архив создан$(NC)"; \
		ls -lh $(TARGET_DIR)/out/regexp_addin.zip | awk '{print "  Размер:", $$5}'; \
	else \
		echo "  $(RED)✗ Архив не создан$(NC)"; \
	fi

# Комбинированные команды
dev-setup: setup install-mingw ## Полная настройка для разработки
	@echo "$(GREEN)Настройка завершена!$(NC)"
	@echo "Теперь вы можете запустить 'make release' для сборки"

full-build: clean release test ## Полная сборка с тестами
	@echo "$(GREEN)Полная сборка завершена!$(NC)"

# Проверка зависимостей
check-deps: ## Проверить установленные зависимости
	@echo "$(BLUE)Проверка зависимостей:$(NC)"
	@echo -n "  Rust: "
	@if command -v rustc >/dev/null 2>&1; then \
		echo "$(GREEN)✓$(NC) $(shell rustc --version)"; \
	else \
		echo "$(RED)✗ Не установлен$(NC)"; \
	fi
	@echo -n "  Cargo: "
	@if command -v cargo >/dev/null 2>&1; then \
		echo "$(GREEN)✓$(NC) $(shell cargo --version)"; \
	else \
		echo "$(RED)✗ Не установлен$(NC)"; \
	fi
	@echo -n "  Rustup: "
	@if command -v rustup >/dev/null 2>&1; then \
		echo "$(GREEN)✓$(NC) $(shell rustup --version)"; \
	else \
		echo "$(RED)✗ Не установлен$(NC)"; \
	fi
	@echo -n "  MinGW (x86_64): "
	@if command -v x86_64-w64-mingw32-gcc >/dev/null 2>&1; then \
		echo "$(GREEN)✓$(NC)"; \
	else \
		echo "$(RED)✗ Не установлен$(NC)"; \
	fi
	@echo -n "  MinGW (i686): "
	@if command -v i686-w64-mingw32-gcc >/dev/null 2>&1; then \
		echo "$(GREEN)✓$(NC)"; \
	else \
		echo "$(RED)✗ Не установлен$(NC)"; \
	fi
	@echo -n "  ARM64 линковщик: "
	@if command -v aarch64-linux-gnu-gcc >/dev/null 2>&1 || command -v aarch64-linux-gnu-gcc-10 >/dev/null 2>&1 || command -v aarch64-linux-gnu-gcc-11 >/dev/null 2>&1; then \
		echo "$(GREEN)✓$(NC)"; \
	else \
		echo "$(YELLOW)⚠ Не установлен (создаются заглушки)$(NC)"; \
	fi

# Дополнительные утилиты
list-targets: ## Показать установленные Rust targets
	@echo "$(BLUE)Установленные Rust targets:$(NC)"
	@rustup target list --installed | sed 's/^/  /'

list-available-targets: ## Показать все доступные Rust targets
	@echo "$(BLUE)Доступные Rust targets:$(NC)"
	@rustup target list | grep -E "(linux|windows|darwin)" | sed 's/^/  /'

size: ## Показать размеры скомпилированных библиотек
	@echo "$(BLUE)Размеры скомпилированных библиотек:$(NC)"
	@if [ -d "$(TARGET_DIR)" ]; then \
		find $(TARGET_DIR) -name "*.so" -o -name "*.dll" -o -name "*.dylib" | \
		while read file; do \
			if [ -f "$$file" ] && [ -s "$$file" ]; then \
				size=$$(ls -lh "$$file" | awk '{print $$5}'); \
				platform=$$(echo "$$file" | sed 's/.*target\///' | cut -d'/' -f1); \
				arch=$$(echo "$$file" | sed 's/.*target\///' | cut -d'/' -f1 | sed 's/-.*//'); \
				echo "  $$platform ($$arch): $$size"; \
			fi; \
		done; \
	else \
		echo "$(RED)Библиотеки не найдены. Запустите 'make build' или 'make release'$(NC)"; \
	fi

verify-archive: ## Проверить содержимое архива
	@echo "$(BLUE)Проверка архива:$(NC)"
	@if [ -f "$(TARGET_DIR)/out/regexp_addin.zip" ]; then \
		echo "  Архив: $(GREEN)✓$(NC)"; \
		echo "  Размер: $$(ls -lh $(TARGET_DIR)/out/regexp_addin.zip | awk '{print $$5}')"; \
		echo "  Содержимое:"; \
		cd $(TARGET_DIR)/out && unzip -l regexp_addin.zip | tail -n +4 | head -n -2 | sed 's/^/    /'; \
	else \
		echo "$(RED)Архив не найден. Запустите 'make build' или 'make release'$(NC)"; \
	fi

install-arm64-toolchain: ## Установить ARM64 линковщик для Linux
	@echo "$(BLUE)Установка ARM64 линковщика...$(NC)"
	@if command -v apt-get >/dev/null 2>&1; then \
		echo "Установка через apt-get..."; \
		sudo apt-get install -y gcc-aarch64-linux-gnu; \
	elif command -v dnf >/dev/null 2>&1; then \
		echo "Установка через dnf..."; \
		sudo dnf install -y gcc-aarch64-linux-gnu; \
	elif command -v pacman >/dev/null 2>&1; then \
		echo "Установка через pacman..."; \
		sudo pacman -S aarch64-linux-gnu-gcc; \
	else \
		echo "$(RED)Неизвестный пакетный менеджер$(NC)"; \
	fi

# По умолчанию показываем справку
.DEFAULT_GOAL := help
