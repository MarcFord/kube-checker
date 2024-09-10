FROM alpine:latest AS build

ARG GOLANG_VERSION=1.23.1

RUN apk update && apk add go git gcc bash musl-dev openssl-dev ca-certificates && update-ca-certificates

RUN wget https://dl.google.com/go/go$GOLANG_VERSION.src.tar.gz && tar -C /usr/local -xzf go$GOLANG_VERSION.src.tar.gz

RUN cd /usr/local/go/src && ./make.bash

ENV PATH=$PATH:/usr/local/go/bin:/root/go/bin

RUN rm go$GOLANG_VERSION.src.tar.gz

#we delete the apk installed version to avoid conflict
RUN apk del go

# Install kubeconform
RUN go install github.com/yannh/kubeconform/cmd/kubeconform@latest

# Install kube-score
RUN go install github.com/zegl/kube-score/cmd/kube-score@latest

# Install Polaris
RUN go install github.com/fairwindsops/polaris@latest

FROM alpine:latest
RUN apk update && apk upgrade && apk add ca-certificates kubectl bash && update-ca-certificates
COPY --from=build /root/go/bin/kubeconform /usr/local/bin/kubeconform
COPY --from=build /root/go/bin/kube-score /usr/local/bin/kube-score
COPY --from=build /root/go/bin/polaris /usr/local/bin/polaris
CMD ["/bin/bash"]