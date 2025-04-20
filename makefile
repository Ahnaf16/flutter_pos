.PHONY: all run_dev_web run_dev_mobile run_unit clean upgrade lint format build_dev_mobile help watch gen run_stg_mobile run_prd_mobile build_apk_dev build_apk_stg build_apk_prd purge 

all: lint format run_dev_mobile

# Adding a help file: https://gist.github.com/prwhite/8168133#gistcomment-1313022
help: ## This help dialog.
	@IFS=$$'\n' ; \
	help_lines=(`fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//'`); \
	for help_line in $${help_lines[@]}; do \
		IFS=$$'#' ; \
		help_split=($$help_line) ; \
		help_command=`echo $${help_split[0]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
		help_info=`echo $${help_split[2]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
		printf "%-30s %s\n" $$help_command $$help_info ; \
	done

clean: ## Cleans the environment
	@echo "╠ Cleaning the project..."
	@rm -rf pubspec.lock
	@flutter clean
	@flutter pub get

format: ## Formats the code
	@echo "╠ Formatting the code"
	@dart format lib .

lint: ## Lints the code
	@echo "╠ Verifying code..."
	@dart analyze . || (echo "Error in project"; exit 1)

builder_run:
	@echo "╠ Running build runner..."
	@fvm flutter pub run build_runner build --delete-conflicting-outputs

assets_gen: ## generates assets using flutter-gen and adds inline html preview for assets
	@echo "╠ Generating assets"
	@fluttergen
	@dart run bin/gen_assets_preview.dart || (echo "Error in project"; exit 1)

keystore_info: ## get keystore info
	@echo "╠ Getting keystore info..."
	@echo keytool -list -v -keystore /Users/ahnafsakil/DEVELOPMENT/Flutter_projects/qhub360/android/app/upload-keystore.jks -alias upload -storepass qhub_key -keypass qhub_key
 