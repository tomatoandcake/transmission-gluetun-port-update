FROM alpine:latest
RUN apk add --no-cache curl jq
COPY port-update.sh /port-update.sh
RUN chmod +x /port-update.sh
CMD ["/bin/sh", "/port-update.sh"]
