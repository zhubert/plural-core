.PHONY: test clean

test:
	go test -count=1 ./...

clean:
	go clean -cache
