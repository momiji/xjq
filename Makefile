BIN := xjq
VERSION := $$(make -s show-version)
VERSION_PATH := cli
CURRENT_REVISION = $(shell git rev-parse --short HEAD)
X_REV = $(shell cat go.mod | grep -o "github.com/momiji/gojq .*" | awk '{print $$2}')
BUILD_LDFLAGS = "-s -w -X github.com/momiji/gojq/cli.revision=$(X_REV):github.com/momiji/xjq@$(CURRENT_REVISION)"
SHELL := /bin/bash

.PHONY: all
all: build

.PHONY: build
build:
	CGO_ENABLED=0 go build -ldflags=$(BUILD_LDFLAGS) -o $(BIN) .
