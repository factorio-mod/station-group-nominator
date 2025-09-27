# Set the default goal to 'help'
.DEFAULT_GOAL := help

# Ensure jq is installed before proceeding
ifeq ($(shell command -v jq 2> /dev/null),)
    $(error "jq is not installed. Please install it to continue.")
endif

# Extract project name and version from info.json
PROJECT_NAME := $(shell jq -r .name info.json)
VERSION := $(shell jq -r .version info.json)

# Define the target zip file path
TARGET_ZIP := build/$(PROJECT_NAME)_$(VERSION).zip

# Define paths to be excluded from the zip archive.
# Each path is added incrementally.
EXCLUDE_PATHS :=
EXCLUDE_PATHS += .git/*
EXCLUDE_PATHS += .gitignore
EXCLUDE_PATHS += .aider*
EXCLUDE_PATHS += .*~
EXCLUDE_PATHS += build/*
EXCLUDE_PATHS += Makefile

# Format the exclusion paths for rsync
RSYNC_EXCLUDES := $(foreach p,$(EXCLUDE_PATHS),--exclude='$(p)')

# Declare phony targets to prevent conflicts with files of the same name
.PHONY: zip clean help

# Default rule to show help
help: ## Show this help message
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  make %-20s %s\n", $$1, $$2}'

# Rule to create the zip archive
zip: ## Create the zip archive in the build/ directory
	@# Check if the target file already exists and fail if it does
	@if [ -f $(TARGET_ZIP) ]; then \
		echo "Error: $(TARGET_ZIP) already exists. Run 'make clean' first."; \
		exit 1; \
	fi
	@# Stage files in a temporary directory to control the archive's root folder
	@echo "Staging files for archive..."
	@TMP_DIR=$$(mktemp -d); \
	mkdir -p "$${TMP_DIR}/$(PROJECT_NAME)"; \
	rsync -aq . "$${TMP_DIR}/$(PROJECT_NAME)/" $(RSYNC_EXCLUDES); \
	echo "Creating archive: $(TARGET_ZIP)"; \
	(cd "$${TMP_DIR}" && zip -qr "$(CURDIR)/$(TARGET_ZIP)" "$(PROJECT_NAME)"); \
	echo "Cleaning up staged files..."; \
	rm -r "$${TMP_DIR}"

# Rule to clean up the generated zip file
clean: ## Remove the generated zip archive from the build/ directory
	@echo "Cleaning build directory..."
	@rm -f $(TARGET_ZIP)
