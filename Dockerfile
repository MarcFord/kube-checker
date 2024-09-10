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

# Install Google Cloud SDK
RUN curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-367.0.0-linux-x86_64.tar.gz && \
    tar -xzf google-cloud-sdk-367.0.0-linux-x86_64.tar.gz && \
    ./google-cloud-sdk/install.sh --quiet && \
    rm google-cloud-sdk-367.0.0-linux-x86_64.tar.gz

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip aws

# Install Azure CLI
RUN apk add --no-cache python3 py3-pip && \
    pip3 install --upgrade pip && \
    pip3 install azure-cli

ENV PATH=$PATH:/google-cloud-sdk/bin

COPY --from=build /root/go/bin/kubeconform /usr/local/bin/kubeconform
COPY --from=build /root/go/bin/kube-score /usr/local/bin/kube-score
COPY --from=build /root/go/bin/polaris /usr/local/bin/polaris
CMD ["/bin/bash"]