# 🧠 Copilot+ AI Workflow Map  
**Model Routing • Prompt Roles • Assistant Integration**

---

## 📑 Table of Contents
- [🧠 Copilot+ AI Workflow Map](#-copilot-ai-workflow-map)
  - [📑 Table of Contents](#-table-of-contents)
  - [📄 Overview](#-overview)
  - [🔀 Model Routing Summary](#-model-routing-summary)
  - [🧩 Prompt Role Assignments](#-prompt-role-assignments)
  - [🤖 Assistant Stack](#-assistant-stack)
  - [⚠️ Removed Models (Audit Notes)](#️-removed-models-audit-notes)

---

## 📄 Overview
This guide maps prompt roles to installed models across Brent’s local Ollama stack.  
It supports reproducible workflows for coding, product automation, and meeting assistant tasks.  
See `/reference-guides/ai-coding-models.md` for model descriptions and VRAM fit.

---

## 🔀 Model Routing Summary

| Task Type        | Default Model             | Notes |
|------------------|----------------------------|-------|
| Autocomplete     | `starcoder2:3b`            | Rich completions |
| Rerank           | `qwen2.5-coder:1.5b`       | Fast fallback |
| Chat/Review      | `codellama:13b-instruct`   | Deep reasoning |
| Edit/Apply       | `deepseek-coder:6.7b-base` | Fast inline edits, optimization |
| Refactor/Explain | `gemma3:12b`               | Assistant-style clarity |
| Summarize        | `nous-hermes:7b`           | Wrap-up tone |
| Automate         | `qwen3:14b`                | Structured output, multilingual |
| Assistant (default) | `llama3`                | Fast, responsive |
| Assistant (deep) | `nous-hermes:13b`          | Optional synthesis layer |
| Strategic Synthesis | `llama3:70b`            | Final-pass summaries, deep analysis |

---

## 🧩 Prompt Role Assignments

| Prompt Name             | Assigned Model             |
|-------------------------|----------------------------|
| `build-feature`         | `codellama:13b-instruct`   |
| `build-and-validate`    | `codellama:13b-instruct`   |
| `refactor-for-clarity`  | `gemma3:12b`               |
| `add-tests`             | `deepseek-coder:6.7b-base` |
| `security-review`       | `codellama:13b-instruct`   |
| `optimize-performance`  | `deepseek-coder:6.7b-base` |
| `explain-code`          | `gemma3:12b`               |
| `translate-language`    | `codellama:13b-instruct`   |
| `generate-documentation`| `codellama:13b-instruct`   |
| `debug-code`            | `deepseek-coder:6.7b-base` |
| `code-review`           | `codellama:13b-instruct`   |
| `integrate-library`     | `codellama:13b-instruct`   |
| `full-feature-pipeline` | `codellama:13b-instruct`   |
| `draft-feature-spec`    | `llama3`                   |
| `refine-feature-spec`   | `llama3`                   |
| `feature-specification-guide` | `llama3`             |

---

## 🤖 Assistant Stack

| Role               | Model                  | Notes |
|--------------------|------------------------|-------|
| Default Assistant  | `llama3`               | Fast, general-purpose |
| Summarizer         | `nous-hermes:7b`       | Wrap-up tone |
| Automation         | `qwen3:14b`            | Structured, multilingual |
| Deep Assistant     | `nous-hermes:13b`      | Optional, richer synthesis |
| Strategic Synthesis| `llama3:70b`           | Final-pass analysis, long-form reasoning |

---

## ⚠️ Removed Models (Audit Notes)

~~~bash
The following models were removed during the September 2025 audit:

- codellama:7b-instruct — replaced by gemma3:12b for refactor/explain
- phi3 — replaced by llama3 and qwen3:14b
- gemma:2b, gemma:7b, gemma2:9b — superseded by gemma3:12b
- qwen2.5:14b — replaced by qwen3:14b
- deepseek-coder:6.7b-base — temporarily removed, now reinstated
~~~

See `/docs/ollama_model_cleanup.sh` for reproducible cleanup.
