# Build the Go application
FROM golang:1.18-alpine AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN go build -o /meshell_server server.go

# Create the final image
FROM alpine:latest

WORKDIR /app

COPY --from=builder /meshell_server .

COPY static ./static
COPY index.html ./

EXPOSE 8080

CMD ["./meshell_server"]
