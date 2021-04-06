FROM golang:latest

WORKDIR /opt/unityexporter
COPY . .

RUN GO111MODULE=off go get -u github.com/equelin/gounity
RUN GO111MODULE=off go get -u github.com/prometheus/client_golang/prometheus
RUN GO111MODULE=off go get -u github.com/prometheus/client_golang/prometheus/promhttp

EXPOSE 8080

ENTRYPOINT GO111MODULE=off go run main.go utils.go unitycollector.go