FROM debian:trixie-slim

USER root

#Instapp packages
RUN apt-get update
RUN apt-get install --no-install-recommends -y python3 python3-pip python3-venv
RUN apt-get install --no-install-recommends -y git curl ca-certificates wget unzip zip shellcheck

# Create a dedicated virtual environment
RUN python3 -m venv /opt/opencode-venv

# Create activation script for agents
RUN echo '#!/bin/bash\nsource /opt/opencode-venv/bin/activate\nexec "$@"' > /usr/local/bin/activate-venv && \
    chmod +x /usr/local/bin/activate-venv

# Set environment variables to use venv Python
ENV PATH="/opt/opencode-venv/bin:${PATH}"
ENV VIRTUAL_ENV="/opt/opencode-venv"

ENV SKIP_EGRESS_FIREWALL="true"

RUN rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]

SHELL ["/bin/bash", "-c"]

ENV JAVA_HOME="/root/.sdkman/candidates/java/current"
ENV OPENCODE_PATH="/root/.opencode/bin"
ENV PATH="$OPENCODE_PATH:$JAVA_HOME/bin:$PATH"

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
ENV NVM_DIR=/root/.nvm
RUN bash -c "source $NVM_DIR/nvm.sh && nvm install 22.22.2"
ENV PATH="${NVM_DIR}/versions/node/v22.22.2/bin:${PATH}"

RUN curl -s "https://get.sdkman.io" | bash

# Install LSP servers
RUN npm install -g yaml-language-server bash-language-server

RUN npm i -g opencode-ai@1.18.16

RUN npx oh-my-openagent install --no-tui --claude=no --gemini=no --copilot=no --openai=no
RUN npx oh-my-openagent doctor

WORKDIR /workspace

ARG JDK_PACKAGE

RUN source "$HOME/.sdkman/bin/sdkman-init.sh" \
	&& sdk install java ${JDK_PACKAGE} \
	&& sdk default java ${JDK_PACKAGE}


