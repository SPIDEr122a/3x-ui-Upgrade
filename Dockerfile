FROM golang:1.21-alpine AS builder

WORKDIR /app

ARG TARGETARCH

RUN apk add --no-cache build-base gcc wget git

COPY . .

RUN go mod download

RUN CGO_ENABLED=1 GOOS=linux GOARCH=${TARGETARCH} go build -o build/x-ui main.go

FROM alpine:latest

ENV TZ=Asia/Tehran

WORKDIR /app

RUN apk add --no-cache ca-certificates tzdata bash

COPY --from=builder /app/build/x-ui /app/x-ui
COPY --from=builder /app/x-ui.sh /usr/bin/x-ui
COPY --from=builder /app/DockerInit.sh /app/DockerInit.sh
COPY start.sh /app/start.sh

RUN sed -i 's/\r$//' /app/start.sh /app/DockerInit.sh /usr/bin/x-ui

RUN chmod +x \
    /app/x-ui \
    /app/start.sh \
    /app/DockerInit.sh \
    /usr/bin/x-ui

VOLUME [ "/etc/x-ui" ]

CMD [ "/app/start.sh" ]
