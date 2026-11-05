FROM alpine:3.20
RUN apk add --no-cache curl unzip ca-certificates
WORKDIR /app
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh
EXPOSE 10000
ENTRYPOINT ["/app/entrypoint.sh"]
