.PHONY: build test lint run fmt

build:	go build ./...
test:	go test ./...
lint:	golangci-lint run
fmt:	gofmt -w .
run:	go run .
