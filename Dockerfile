# Official runner dockerfile. Included as a result of ECR rate limits trying to pull their images in GitHub Actions
FROM alpine:3.16

ARG TARGETARCH=amd64

RUN apk -U upgrade && apk add --no-cache \
    aws-cli \
    bash \
    ca-certificates \
    curl \
    git \
    jq \
    openssh \
    openssh-keygen \
    tzdata

# Download infracost
ADD "https://github.com/infracost/infracost/releases/latest/download/infracost-linux-${TARGETARCH}.tar.gz" /tmp/infracost.tar.gz
RUN tar -xzf /tmp/infracost.tar.gz -C /bin && \
    mv "/bin/infracost-linux-${TARGETARCH}" /bin/infracost && \
    chmod 755 /bin/infracost && \
    rm /tmp/infracost.tar.gz

# Download Terragrunt.
ADD "https://github.com/gruntwork-io/terragrunt/releases/latest/download/terragrunt_linux_${TARGETARCH}" /bin/terragrunt
RUN chmod 755 /bin/terragrunt

RUN echo "hosts: files dns" > /etc/nsswitch.conf \
    && adduser --disabled-password --uid=1983 spacelift

# Tailscale-related commands
RUN apk add tailscale && mkdir /spacelift-tailscale

COPY init-tailscale.sh /spacelift-tailscale/

RUN chmod +x /spacelift-tailscale/init-tailscale.sh

# User command moved to the end, so we still have the ability to install things up until the end of the build
USER spacelift
