# 🧠 AI Coding Models — VS Code + Continue + Ollama

## 📄 Overview
This guide documents the AI models installed via  
`/home/brent/ai-assistant-project/docs/ollama_model_setup.sh`  
and configured in Continue (v1.2.2) for coding, reviews, and meeting assistant workflows.

It covers:
- **Scope:** Model roles in the workflow
- **Hardware fit:** What runs well on RX 7900 XTX (24 GB)
- **Config mapping:** Continue model roles
- **Usage tips:** When to switch models

---

## 🖥️ Hardware summary
- **CPU:** AMD Ryzen 9700X — high thread count for preprocessing/context ingestion
- **GPU:** AMD Radeon RX 7900 XTX (24 GB VRAM) — runs 13B dense and Mixtral comfortably, 70B quantized on-demand
- **Storage:** Samsung 980 PRO NVMe SSDs — fast model load times
- **OS:** Ubuntu 24.04 LTS — ROCm-friendly for Ollama

## 📊 Model Roles

| Role | Ollama Model Tag | Purpose |
|------|------------------|---------|
| **Autocomplete (fast)** | `qwen2.5-coder:1.5b` | Very fast, low VRAM, warning‑free completions |
| **Autocomplete (richer)** | `starcoder2:3b` | Larger, still fast, trained for code completion |
| **Autocomplete/Chat hybrid** | `deepseek-coder:6.7b-base` | Higher quality completions, more VRAM |
| **Chat (default)** | `codellama:7b-instruct` | Quick code help, explanations |
| **Chat (deep coding)** | `codellama:13b-instruct` | Complex refactors, multi‑file reasoning |
| **Review** | `mixtral:8x7b` | Senior Architect + Security Audit reviews |
| **Summarization/Creative** | `llama3`, `mistral`, `phi3`, `qwen2.5:14b`, `gemma:2b`, `gemma:7b`, `gemma2:9b`, `nous-hermes2:7b` | Meeting assistant, doc drafting, creative tasks |
| **Deep Reasoning (on‑demand)** | `llama3:70b` | Very deep reasoning, large context — slower, high VRAM use |

## 📈 Hardware Fit Table

| Model | VRAM (Q4_K_M approx) | Fits in 24 GB VRAM? | Notes |
|-------|----------------------|--------------------|-------|
| `qwen2.5-coder:1.5b` | ~2 GB | ✅ | Instant load, ideal for autocomplete |
| `starcoder2:3b` | ~4–5 GB | ✅ | Richer completions, still light |
| `deepseek-coder:6.7b-base` | ~7–8 GB | ✅ | Higher‑quality completions, more VRAM |
| `codellama:7b-instruct` | ~5–6 GB | ✅ | Fast, responsive |
| `codellama:13b-instruct` | ~10–12 GB | ✅ | Leaves headroom for context |
| `mixtral:8x7b` | ~12–14 GB active | ✅ | Long context, multi‑file reviews |
| `llama3` / `mistral` / `phi3` | ~4–8 GB | ✅ | General reasoning, summarization |
| `qwen2.5:14b` | ~14–16 GB | ✅ | Multilingual precision |
| `gemma` family | ~2–8 GB | ✅ | Creative, doc‑friendly |
| `llama3:70b` | ~20–22 GB | ⚠️ | Fits, but minimal VRAM left — slower if spilling to RAM |

## 🛠 Continue Config Role Mapping

~~~bash
models:
  - name: qwen2.5coder1b
    provider: ollama
    model: qwen2.5-coder:1.5b
    roles: [autocomplete]

  - name: starcoder2_3b
    provider: ollama
    model: starcoder2:3b
    roles: [autocomplete]

  - name: deepseekcoder6.7b
    provider: ollama
    model: deepseek-coder:6.7b-base
    roles: [autocomplete, chat]

  - name: codellama7b
    provider: ollama
    model: codellama:7b-instruct
    roles: [chat]

  - name: codellama13b
    provider: ollama
    model: codellama:13b-instruct
    roles: [chat]

  - name: mixtral8x7b
    provider: ollama
    model: mixtral:8x7b
    roles: [chat]
~~~

## 💡 Usage Tips

- **Day‑to‑day coding:** Use `codellama:7b-instruct` for quick answers, small code snippets, and explanations.
- **Complex refactors:** Switch to `codellama:13b-instruct` when you need deeper reasoning or multi‑file context.
- **Full project review:** Use `mixtral:8x7b` with the “Architect Review” or “Security Audit” prompts for long‑context, structured feedback.
- **Autocomplete testing:** Compare `qwen2.5-coder:1.5b` (fastest), `starcoder2:3b` (richer completions), and `deepseek-coder:6.7b-base` (highest quality) to see which feels best in your workflow.
- **Meeting assistant / creative work:** Switch to summarization/creative models (`llama3`, `mistral`, `phi3`, `qwen2.5:14b`, `gemma` family, `nous-hermes2:7b`) for drafting, summarizing, or brainstorming.
- **Deep reasoning:** Only load `llama3:70b` when you truly need maximum reasoning depth — it will consume most of your VRAM and run slower.

---

