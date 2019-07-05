FROM golang:alpine3.8 as tools

RUN apk update
RUN apk add git
RUN go get github.com/subfuzion/envtpl/...

FROM alpine:3.7

COPY --from=tools /go/bin/envtpl /usr/local/bin/
RUN apk update
RUN apk add mysql-client
ADD entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]