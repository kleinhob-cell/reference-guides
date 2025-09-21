# ⚙️ Environment Setup

This section outlines the setup of my AI development environment, including hardware, software, and configuration steps for both local and remote workflows.

---

## 🖥️ Primary Workstation: Ubuntu 24.04.3 LTS

### Hardware Specs
- AMD Ryzen 7 9700X
- AMD RX 7900 XTX (ROCm-enabled)
- Dual NVMe storage

### Software Stack
- VS Code
- GitHub Copilot Pro
- Python 3.11+
- Node.js (for web agents)
- Git
- Docker (recommended)
- Ollama (local model hosting)
- LangChain / LlamaIndex

### Configuration Steps
1. Install VS Code and extensions:
   - GitHub Copilot
   - Copilot Labs
   - Python
   - ESLint / Prettier
   - Remote SSH

2. Install Python and Node.js:
   ```bash
   sudo apt update && sudo apt install python3 python3-pip nodejs npm
   ```

3. Install Git and Docker:
   ```bash
   sudo apt install git docker.io
   ```

4. Set up Ollama:
   - Follow instructions at [ollama.com](https://ollama.com)
   - Install models like `llama2`, `codellama`, or `mistral`

5. Clone your GitHub repo and initialize workspace:
   ```bash
   git clone <your-repo-url>
   cd ai-dev-workflow-manual
   code .
   ```

---

## 💻 Remote Access: MacBook Pro

### Setup
- Use VS Code with Remote SSH extension
- Connect to Ubuntu workstation via SSH
- Future goal: full remote desktop access

### SSH Configuration
```bash
# On MacBook Pro
ssh user@your-ubuntu-ip
```

---

## 🧠 AI Dev Agent Integration (Planned)

- Embed custom AI Dev Agent into VS Code
- Use Ollama-hosted models for local inference
- Compare performance and usability against GitHub Copilot Pro

---

## ✅ Recommendations

- Use `Poetry` or `Pipenv` for Python dependency management
- Create `Makefile` or task runner for automation
- Use `Mermaid` for architecture diagrams
- Document setup scripts and configs in `/setup` folder

