.PHONY: clean builder_run assets_gen

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

clean: builder_clean## Cleans the environment
	@echo "╠ Cleaning the project..."
	@rm -rf pubspec.lock
	@fvm flutter clean
	@fvm flutter pub get
 
builder_run:  
	@echo "╠ Running build runner..."
	@fvm dart run build_runner build --delete-conflicting-outputs

builder_clean:
	@echo "╠ Running build clean..."
	@fvm dart run build_runner clean
	@fvm dart run build_runner build -d

assets_gen: ## generates assets using flutter-gen and adds inline html preview for assets
	@echo "╠ Generating assets"
	@fluttergen
	@fvm dart run bin/gen_assets_preview.dart || (echo "Error in project"; exit 1)

 
build_web: ## build for web
	@echo "╠ building web release"
	@fvm flutter build web --no-tree-shake-icons

 