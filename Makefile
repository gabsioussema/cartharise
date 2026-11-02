# Cartharise — build, test and docs.
#
#   make            list targets
#   make check      flutter analyze + flutter test (must be clean/green)
#   make android    Android debug APK
#   make ios        iOS (needs Xcode; not installed on the build Mac)
#
# Works with the GNU Make 3.81 that ships with macOS.

FLUTTER      ?= flutter
DART         ?= dart
APK_DIR      := build/app/outputs/flutter-apk
SYMBOLS      := build/symbols
RELEASE_FLAGS := --obfuscate --split-debug-info=$(SYMBOLS)

.DEFAULT_GOAL := help
.PHONY: help deps l10n l10n-report brand icons splash analyze test check screenshots \
        android android-release run ios clean _require-xcode

## —— General ————————————————————————————————————————————————

help: ## Show this help
	@echo ""
	@echo "  Cartharise — make <target>"
	@echo ""
	@grep -E '^(## ——|[a-zA-Z0-9_-]+:.*## )' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*## "} /^## ——/ {sub(/^## /, ""); printf "\n  \033[1m%s\033[0m\n", $$0; next} {printf "    \033[36m%-18s\033[0m %s\n", $$1, $$2}'
	@echo ""

deps: ## flutter pub get
	$(FLUTTER) pub get

l10n: ## Merge l10n_src/<area>_<lang>.arb → lib/l10n/app_<lang>.arb (en, fr, ar), then generate AppLocalizations
	$(DART) run tool/merge_arb.dart
	$(FLUTTER) gen-l10n

l10n-report: ## Translation coverage per language and area (docs/translations.md)
	$(DART) run tool/merge_arb.dart --report

brand: ## Re-export the brand SVGs + icon PNGs from EmblemGeometry, then icons + splash
	$(FLUTTER) test --tags brand --run-skipped
	$(MAKE) icons splash

icons: ## Regenerate launcher icons from assets/brand/app_icon_1024.png
	$(DART) run flutter_launcher_icons

splash: ## Regenerate the native splash screens (forest + emblem)
	$(DART) run flutter_native_splash:create

## —— Quality ————————————————————————————————————————————————

analyze: ## Static analysis (must be clean)
	$(FLUTTER) analyze

test: ## Unit + widget tests (no device needed)
	$(FLUTTER) test

check: analyze test ## analyze + test

screenshots: ## Render design screenshots → test/screenshots/out
	$(FLUTTER) test --tags screenshots --run-skipped
	@echo "Screenshots in test/screenshots/out/"

## —— Apps ———————————————————————————————————————————————————

android: deps ## Android debug APK
	$(FLUTTER) build apk --debug
	@ls -lh $(APK_DIR)/*.apk | awk '{printf "  %-6s %s\n", $$5, $$9}'

android-release: deps ## Android release APKs, one per CPU type
	$(FLUTTER) build apk --release --split-per-abi $(RELEASE_FLAGS)
	@ls -lh $(APK_DIR)/*.apk | awk '{printf "  %-6s %s\n", $$5, $$9}'

run: ## Run on a connected device or emulator
	$(FLUTTER) run

ios: _require-xcode deps ## iOS release build without signing (compile check)
	$(FLUTTER) build ios --release --no-codesign

## —— Housekeeping ———————————————————————————————————————————

clean: ## Remove build output
	$(FLUTTER) clean

# —— internal ——

_require-xcode:
	@xcodebuild -version >/dev/null 2>&1 || { \
		echo ""; \
		echo "  ✖ Xcode is required to build iOS and is not installed here."; \
		echo "    iOS is configured (Info.plist, notifications, icons, splash);"; \
		echo "    run 'make ios' on a Mac with Xcode installed and selected:"; \
		echo "      sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"; \
		echo ""; \
		exit 1; }
