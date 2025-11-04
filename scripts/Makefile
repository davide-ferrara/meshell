BINARY_NAME=meshell_list_dirs

.PHONY: all build install clean

all: meshell_list_dirs

meshell_list_dirs:
	@echo "Building $(BINARY_NAME)..."
	go build -o $(BINARY_NAME) $(SRC)

install: meshell_list_dirs
	@echo "Installing $(BINARY_NAME) to /usr/local/bin..."
	sudo mv $(BINARY_NAME) /usr/local/bin/$(BINARY_NAME)

clean:
	@echo "Cleaning..."
	go clean
	rm -f $(BINARY_NAME)
