BINARY_NAME=meshell_list_dirs

.PHONY: all build install clean

all: meshell_list_dirs

meshell_list_dirs:
	@echo "Building $(BINARY_NAME)..."
	go build -o $(BINARY_NAME) $(SRC)
	mv $(BINARY_NAME) ../bin

clean:
	@echo "Cleaning..."
	go clean
	rm -f $(BINARY_NAME)
