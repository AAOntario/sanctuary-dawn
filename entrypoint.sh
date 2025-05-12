#!/bin/bash
set -e

echo "[entrypoint] Enforcing safe OpenWebUI model runtime defaults..."

SETTINGS_FILE="/mnt/data/webui_data/config/settings.json"

mkdir -p "$(dirname "$SETTINGS_FILE")"

cat > "$SETTINGS_FILE" <<EOF
{
  "models": {
    "llama4:17b-scout-16e-instruct-q8_0": {
      "num_ctx": 4096,
      "num_thread": 16,
      "num_gpu": 1,
      "num_batch": 2
    }
  }
}
EOF

echo "[entrypoint] Safe runtime config written to $SETTINGS_FILE"


# Setup dynamic SSH keys and password
echo "[security] Generating runtime SSH key and Jupyter password..."
SSH_KEY_PATH="/workspace/.ssh/id_rsa"
mkdir -p "$(dirname "$SSH_KEY_PATH")"
ssh-keygen -t rsa -b 4096 -f "$SSH_KEY_PATH" -N "" -q
cat "$SSH_KEY_PATH.pub"

JUPYTER_PASS=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 20)
echo "[security] Jupyter password: $JUPYTER_PASS"

# Configure Ollama Models
export PATH="/root/.local/bin:$PATH"
mkdir -p "$OLLAMA_MODELS"
ln -sf "$OLLAMA_MODELS" /root/.ollama

# Start Ollama
echo "[ollama] Starting Ollama on port 11434..."
ollama serve >> /workspace/logs/ollama.log 2>&1 &

# Start OpenWebUI runtime install
echo "[openwebui] Installing and starting OpenWebUI on port 3000..."
uvx --python 3.11 open-webui@v1.2.3 serve >> /workspace/logs/openwebui.log 2>&1 &

# Start JupyterLab with generated password
echo "[jupyter] Starting JupyterLab on port 8888..."
jupyter lab --ip=0.0.0.0 --port=8888 --NotebookApp.password="$JUPYTER_PASS" --allow-root --no-browser >> /workspace/logs/jupyter.log 2>&1 &

# Start SSH daemon on port 2222
echo "[ssh] Starting SSH daemon on port 2222..."
/usr/sbin/sshd -D -p 2222 &
 
# Hold the container
echo "[entrypoint] Container running. Use provided ports for services."
tail -f /dev/null
