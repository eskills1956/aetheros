# Aether OS Main Makefile

SHELL := /bin/bash
.DEFAULT_GOAL := all

# Configuration
AETHEROS_VERSION := 1.0.0
BUILD_TYPE ?= eng
TARGET_ARCH ?= arm64
JOBS ?= $(shell nproc)

# Directories
TOP := $(shell pwd)
OUT_DIR := $(TOP)/out
BUILD_DIR := $(TOP)/build
SRC_DIR := $(TOP)/src

# Colors
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m

# Main targets
.PHONY: all clean kernel system apps image sdk

all: kernel system apps image
	@echo -e "$(GREEN)Aether OS build complete!$(NC)"

kernel:
	@echo -e "$(BLUE)Building kernel...$(NC)"
	@$(MAKE) -C $(SRC_DIR)/kernel

system:
	@echo -e "$(BLUE)Building system components...$(NC)"
	@$(BUILD_DIR)/build-system.sh

apps:
	@echo -e "$(BLUE)Building applications...$(NC)"
	@$(BUILD_DIR)/build-apps.sh

image:
	@echo -e "$(BLUE)Creating system image...$(NC)"
	@$(BUILD_DIR)/create-image.sh

sdk:
	@echo -e "$(BLUE)Building SDK...$(NC)"
	@$(BUILD_DIR)/build-sdk.sh

clean:
	@echo -e "$(YELLOW)Cleaning build...$(NC)"
	@rm -rf $(OUT_DIR)/*

help:
	@echo "Aether OS Build System"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  all       - Build complete system"
	@echo "  kernel    - Build kernel only"
	@echo "  system    - Build system services"
	@echo "  apps      - Build applications"
	@echo "  image     - Create flashable image"
	@echo "  sdk       - Build SDK"
	@echo "  clean     - Clean build files"
	@echo "  help      - Show this help"
