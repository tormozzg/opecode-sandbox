FROM debian:trixie-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8

ARG USER_ID
ARG GROUP_ID

RUN groupadd -g ${GROUP_ID} opencode && \
			useradd -l -u ${USER_ID} -g opencode -m opencode

#Instapp packages
RUN apt-get update &&  apt-get install --no-install-recommends -y python3 python3-pip python3-venv git curl ca-certificates wget unzip zip shellcheck sudo

# Allow opencode to run sudo without a password (for installing packages at runtime)
RUN echo 'opencode ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/opencode && \
    chmod 0440 /etc/sudoers.d/opencode

# Create a dedicated virtual environment
RUN python3 -m venv /opt/opencode-venv

# Create activation script for agents
RUN echo '#!/bin/bash\nsource /opt/opencode-venv/bin/activate\nexec "$@"' > /usr/local/bin/activate-venv && \
    chmod +x /usr/local/bin/activate-venv

# Set environment variables to use venv Python
ENV PATH="/opt/opencode-venv/bin:${PATH}"
ENV VIRTUAL_ENV="/opt/opencode-venv"

RUN chown -R opencode:opencode /opt/opencode-venv

ENV SKIP_EGRESS_FIREWALL="true"

RUN rm -rf /var/lib/apt/lists/*

USER opencode

COPY --chmod=755 entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]

SHELL ["/bin/bash", "-c"]

ENV JAVA_HOME="/home/opencode/.sdkman/candidates/java/current"
ENV OPENCODE_PATH="/home/opencode/.opencode/bin"
ENV PATH="$OPENCODE_PATH:$JAVA_HOME/bin:$PATH"

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.8/install.sh | bash
ENV NVM_DIR=/home/opencode/.nvm
ENV NODE_VERSION="24.15.0"
RUN bash -c "source $NVM_DIR/nvm.sh && nvm install $NODE_VERSION"
ENV PATH="${NVM_DIR}/versions/node/v${NODE_VERSION}/bin:${PATH}"

RUN curl -s "https://get.sdkman.io" | bash

# Install LSP servers
RUN npm install -g yaml-language-server bash-language-server bun

RUN npm install -g opencode-ai@1.19.6


WORKDIR /workspace


