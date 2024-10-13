BIN := xjq
BUILD_LDFLAGS = "-s -w"

.PHONY: all
all: build

.PHONY: build
build:
	go get -u
	go mod tidy
	go mod vendor
	CGO_ENABLED=0 go build -ldflags=$(BUILD_LDFLAGS) -o $(BIN) .
