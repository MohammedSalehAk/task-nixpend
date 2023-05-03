FROM alpine:latest
RUN apk add --no-cache bash
CMD for i in {1..10}; do echo $i >> /opt/numbers.txt; done && tail -f /dev/null
