# build stage
FROM golang:alpine AS builder

ENV GO111MODULE=on

# install git.
RUN apk update && apk add --no-cache git

# Create appuser
RUN adduser -D -g '' appuser

RUN mkdir -p /go/src/github.com/prongbang/govsktor
WORKDIR /go/src/github.com/prongbang/govsktor
COPY . .

# Using go mod with go 1.11
RUN go mod vendor

# With go ≥ 1.10
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -installsuffix cgo -ldflags="-w -s" -o /go/bin/github.com/prongbang/govsktor

# final stage small image
FROM scratch

COPY --from=builder /etc/passwd /etc/passwd

# Copy our static executable
COPY --from=builder /go/bin/github.com/prongbang/govsktor /go/bin/

# Use an unprivileged user.
USER appuser

# run binary.
ENTRYPOINT ["/go/bin/govsktor"]