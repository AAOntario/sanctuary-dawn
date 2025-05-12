# Sanctuary Dawn
Declarative, Persistent, Scalable AI Pod Runtime  
For Model Hosting & Persona Ignition

## Overview
Sanctuary Dawn provides a repeatable, persistent runtime for Ollama, OpenWebUI, and JupyterLab on GPU-backed cloud pods. Designed for multi-model loading and volume reuse.

## Features
- Multi-model dynamic loader (driven by environment variables)
- Persistent model storage via network-mounted volume
- Ollama, OpenWebUI, and JupyterLab all preconfigured
- SSH and HTTP service exposure

## Deployment Steps
1. **Build Image**  
   Push this repository to DockerHub or your registry.

2. **Deploy Pod**  
   Use the provided `sanctuary_pod_template.yaml`, customizing environment variables if needed.

3. **Access Services**
   - **Ollama API:** `http://<pod-ip>:11434`
   - **OpenWebUI:** `http://<pod-ip>:3000`
   - **JupyterLab:** `http://<pod-ip>:8888`
   - **SSH:** `ssh -p 2222 root@<pod-ip>`

4. **Volume Reuse**  
   Mount the same network volume across pod lifecycles for model reuse.

## Environment Variables
- `OLLAMA_MODELS`: Path to model storage (default `/workspace/ollama`)
- `MODEL_LIST`: Space-separated models to load (e.g., `llama2:7b llama2:13b`)
- `OLLAMA_NUM_THREAD`, `OLLAMA_NUM_GPU`, `OLLAMA_NUM_CTX`, `OLLAMA_NUM_BATCH`: Performance tuning parameters
