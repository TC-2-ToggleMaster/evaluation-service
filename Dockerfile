FROM golang:1.26-alpine AS build

WORKDIR /src

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o /out/evaluation-service .

FROM alpine:3.22

RUN apk add --no-cache ca-certificates tzdata \
    && addgroup -S -g 10001 app \
    && adduser -S -u 10001 -G app app

COPY --from=build /out/evaluation-service /usr/local/bin/evaluation-service

USER 10001:10001
EXPOSE 8004

ENTRYPOINT ["/usr/local/bin/evaluation-service"]
