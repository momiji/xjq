BIN := xjq
VERSION := $$(make -s show-version)
VERSION_PATH := cli
CURRENT_REVISION = $(shell git rev-parse --short HEAD)
BUILD_LDFLAGS = "-s -w -X github.com/itchyny/gojq/cli.revision=github.com/momiji/xjq@$(CURRENT_REVISION)"
SHELL := /bin/bash

.PHONY: all
all: build

.PHONY: build
build:
	go build -ldflags=$(BUILD_LDFLAGS) -o $(BIN) .
