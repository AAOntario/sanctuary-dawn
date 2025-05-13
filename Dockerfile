FROM ubuntu:22.04

# Install system utilities
RUN apt-get update && apt-get install -y \
    openssh-server sudo curl wget gnupg2 jq netcat lsof dos2unix python3 python3-pip

# SSH Configuration
RUN mkdir /var/run/sshd && \
    sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    echo 'root:changeme' | chpasswd

EXPOSE 2222 11434 3000 8080 7777 8888

# Install Python packages and uvx (for OpenWebUI runtime install)
RUN pip install --no-cache-dir jupyterlab uv uvx

# --- PATCH STARTS HERE ---
# Install Ollama with Debug Logging
RUN curl -fsSL https://ollama.com/install.sh -o /tmp/ollama_install.sh && \
    echo "---- BEGIN OLLAMA INSTALL SCRIPT ----" && \
    cat /tmp/ollama_install.sh && \
    echo "---- END OLLAMA INSTALL SCRIPT ----" && \
    bash /tmp/ollama_install.sh && \
    echo "Ollama installation script executed successfully."
# --- PATCH ENDS HERE ---

# Default model storage and workspace
ENV OLLAMA_MODELS=/workspace/models

# Copy and prepare entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
