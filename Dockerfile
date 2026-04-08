# Set the version to match that which is in go.mod
ARG GO_VERSION="build-arg-must-be-provided"

FROM --platform=${BUILDPLATFORM} golang:${GO_VERSION}-alpine AS builder

WORKDIR /proj

COPY go.mod ./
COPY go.sum ./
RUN go mod download

COPY *.go ./

ARG TARGETOS TARGETARCH
RUN GOOS=$TARGETOS GOARCH=$TARGETARCH go build -o lk-jwt-service
# set up nsswitch.conf for Go's "netgo" implementation
# - https://github.com/golang/go/blob/go1.24.0/src/net/conf.go#L343
RUN echo 'hosts: files dns' > /etc/nsswitch.conf

FROM alpine

RUN apk add --no-cache curl bind-tools

COPY --from=builder /proj/lk-jwt-service /lk-jwt-service

EXPOSE 8080

CMD [ "/lk-jwt-service" ]
