# 🧠 AI Coding Models Reference  
**Local Ollama Stack • Roles • VRAM Fit • Routing Guide**

---

## 📑 Table of Contents
- [🧠 AI Coding Models Reference](#-ai-coding-models-reference)
  - [📑 Table of Contents](#-table-of-contents)
  - [📄 Overview](#-overview)
  - [💻 Hardware Context](#-hardware-context)
  - [📊 VRAM Fit Table](#-vram-fit-table)
  - [⚡ Quick Reference Table](#-quick-reference-table)
  - [🧩 Per‑Model Details](#-permodel-details)
    - [`qwen2.5-coder:1.5b`](#qwen25-coder15b)
    - [`starcoder2:3b`](#starcoder23b)
    - [`deepseek-coder:6.7b-base`](#deepseek-coder67b-base)
    - [`codellama:13b-instruct`](#codellama13b-instruct)
    - [`gemma3:12b`](#gemma312b)
    - [`qwen3:14b`](#qwen314b)
    - [`nous-hermes:7b`](#nous-hermes7b)
    - [`nous-hermes:13b`](#nous-hermes13b)
    - [`llama3`](#llama3)
    - [`llama3:70b`](#llama370b)
    - [`mixtral:8x7b`](#mixtral8x7b)
- [🧠 Ollama Model Setup \& Recovery Guide](#-ollama-model-setup--recovery-guide)
  - [📊 Model Comparison Table — Current Script Loadout](#-model-comparison-table--current-script-loadout)
  - [🔀 Pipeline Role Mapping](#-pipeline-role-mapping)
  - [🛠 Rebuild \& Recovery Instructions](#-rebuild--recovery-instructions)
    - [1. Re‑run the Setup Script](#1-rerun-the-setup-script)
    - [2. Verify Model Availability](#2-verify-model-availability)
    - [3. Troubleshoot “file does not exist” Errors](#3-troubleshoot-file-does-not-exist-errors)
    - [4. Re‑run the Benchmark Script](#4-rerun-the-benchmark-script)
    - [5. Full Clean Rebuild](#5-full-clean-rebuild)
  - [📌 Notes](#-notes)
  - [Continue config.yaml (Reference)](#continue-configyaml-reference)
  - [ollama\_model\_setup.sh (Reference)](#ollama_model_setupsh-reference)
  - [🧹 Removed Models (Audit Notes)](#-removed-models-audit-notes)

---

## 📄 Overview
This reference documents the curated Ollama model stack used for coding workflows, assistant‑style reasoning, and reproducible automation.  
It is designed for maintainability, VRAM fit on the RX 7900 XTX (24 GB), and seamless integration with VS Code + Continue extension.  
All models are validated for reproducible installs via `/docs/ollama_model_setup.sh` and are benchmarked for fit within Brent’s meeting assistant and product automation pipelines.

---

## 💻 Hardware Context
- **GPU**: AMD RX 7900 XTX (24 GB VRAM) — ROCm stack, validated firmware
- **CPU/RAM**: High‑core workstation, 64 GB RAM
- **OS**: Ubuntu 24.04 LTS
- **Environment**: Local Ollama server with reproducible scripts and pinned model versions
- **Primary IDE**: VS Code with Continue extension
- **Integration Targets**: Meeting assistant pipelines, product automation workflows
- **Reliability Notes**: All environments are reproducible and pinned for stability; hardware and firmware alignment is maintained for maximum reliability

---

## 📊 VRAM Fit Table

| Model                     | Size   | VRAM Use | Context | Role(s) |
|---------------------------|--------|----------|---------|---------|
| `qwen2.5-coder:1.5b`      | 1.5B   | ~2 GB    | ~4K     | autocomplete, rerank |
| `starcoder2:3b`           | 3B     | ~4–5 GB  | ~8K     | autocomplete, edit |
| `deepseek-coder:6.7b-base`| 6.7B   | ~7–8 GB  | ~4K     | apply, debug, test |
| `codellama:13b-instruct`  | 13B    | ~10–12 GB| ~8K     | build, validate, translate |
| `gemma3:12b`              | 12B    | ~11–13 GB| ~128K   | refactor, explain |
| `qwen3:14b`               | 14B    | ~14–16 GB| ~32K    | automation, spec, structured output |
| `nous-hermes:7b`          | 7B     | ~6–7 GB  | ~8K     | summarize, wrap-up |
| `nous-hermes:13b`         | 13B    | ~11–13 GB| ~8K     | assistant, synthesis |
| `llama3`                  | 8B     | ~4–8 GB  | ~8K     | default assistant, spec drafting |
| `llama3:70b`              | 70B    | ~20–22 GB| ~8K     | strategic synthesis |
| `mixtral:8x7b`            | MoE    | ~12–14 GB| ~32K    | architect review |

---

## ⚡ Quick Reference Table

| Task Type            | Default Model             |
|----------------------|----------------------------|
| Autocomplete         | `starcoder2:3b`            |
| Rerank               | `qwen2.5-coder:1.5b`       |
| Apply / Debug / Test | `deepseek-coder:6.7b-base` |
| Build / Validate     | `codellama:13b-instruct`   |
| Refactor / Explain   | `gemma3:12b`               |
| Automation / Spec    | `qwen3:14b`                |
| Summarize            | `nous-hermes:7b`           |
| Assistant (default)  | `llama3`                   |
| Assistant (deep)     | `nous-hermes:13b`          |
| Strategic Synthesis  | `llama3:70b`               |
| Architect Review     | `mixtral:8x7b`             |

---

## 🧩 Per‑Model Details

### `qwen2.5-coder:1.5b`
- **Role(s)**: Autocomplete, rerank  
- **VRAM / Load**: < 2 GB, near‑instant load  
- **Strengths**:  
  - Extremely fast token generation, ideal for real‑time completions in VS Code  
  - Minimal VRAM footprint allows it to run alongside heavier models  
  - Excellent at reranking multiple candidate completions for relevance  
- **Weaknesses**:  
  - Limited reasoning depth, not suited for complex problem‑solving  
  - Short context window limits multi‑file or large‑scope awareness  
- **Best Use Cases**: Inline autocompletion, lightweight reranking of outputs from larger models  
- **Best Paired With**: `codellama:13b-instruct` or `starcoder2:3b` for deeper reasoning after initial suggestions

### `starcoder2:3b`
- **Role(s)**: Autocomplete, edit  
- **VRAM / Load**: ~4–5 GB, fast load  
- **Strengths**:  
  - Context‑aware completions with good balance of speed and accuracy  
  - Strong for inline edits, small refactors, and targeted code improvements  
  - VRAM‑friendly for continuous background use  
- **Weaknesses**:  
  - Not tuned for deep architectural reasoning or large‑scale changes  
- **Best Use Cases**: Quick clean‑ups, targeted edits, medium‑sized file autocomplete  
- **Best Paired With**: `gemma3:12b` for follow‑up explanations or refactors

### `deepseek-coder:6.7b-base`
- **Role(s)**: Apply, debug, test  
- **VRAM / Load**: ~8 GB, fast load  
- **Strengths**:  
  - Clean, concise completions with low overhead  
  - Ideal for quick apply/debug loops and generating unit tests  
  - Good at spotting syntax or logic errors in isolated code  
- **Weaknesses**:  
  - Short context (~4K tokens) limits multi‑file awareness  
- **Best Use Cases**: Rapid iteration on small code segments, automated test generation  
- **Best Paired With**: `codellama:13b-instruct` for initial build, then `deepseek-coder` for test coverage

### `codellama:13b-instruct`
- **Role(s)**: Build, validate, translate  
- **VRAM / Load**: ~12–14 GB, slower load than smaller models  
- **Strengths**:  
  - Deep code generation and multi‑file reasoning capabilities  
  - Strong for feature builds, validation passes, and language translation  
  - Handles complex logic and architectural patterns well  
- **Weaknesses**:  
  - Higher VRAM use and slower cold start  
- **Best Use Cases**: End‑to‑end feature implementation, multi‑language codebase migrations  
- **Best Paired With**: `qwen2.5-coder:1.5b` for reranking, `gemma3:12b` for post‑build refactoring

### `gemma3:12b`
- **Role(s)**: Refactor, explain  
- **VRAM / Load**: ~12 GB, long context (~128K tokens)  
- **Strengths**:  
  - Fluent, assistant‑like tone for explanations  
  - Can handle large files or multi‑file refactors in a single pass  
  - Excels at restructuring code for clarity and maintainability  
- **Weaknesses**:  
  - Slightly slower than mid‑tier models  
- **Best Use Cases**: Codebase‑wide refactors, detailed onboarding documentation  
- **Best Paired With**: `codellama:13b-instruct` for build → `gemma3:12b` for cleanup

### `qwen3:14b`
- **Role(s)**: Automation, spec, structured output  
- **VRAM / Load**: ~14 GB, slower load  
- **Strengths**:  
  - Multilingual with strong structured JSON/table output  
  - Great for generating technical specifications and automation scripts  
  - Handles schema‑driven tasks with precision  
- **Weaknesses**:  
  - Higher VRAM use, slower than mid‑tier models  
- **Best Use Cases**: Drafting feature specs, generating config files or scripts  
- **Best Paired With**: `llama3` for conversational refinement of specs

### `nous-hermes:7b`
- **Role(s)**: Summarize, wrap‑up  
- **VRAM / Load**: ~7 GB, fast load  
- **Strengths**:  
  - Human‑like tone, quick summarization  
  - Low VRAM and quick startup for on‑demand summarization tasks  
- **Weaknesses**:  
  - Less depth than larger models  
- **Best Use Cases**: Summarizing meeting transcripts, creating concise project status updates  
- **Best Paired With**: `nous-hermes:13b` for deeper synthesis

### `nous-hermes:13b`
- **Role(s)**: Assistant, synthesis  
- **VRAM / Load**: ~13 GB, moderate load  
- **Strengths**:  
  - Richer reasoning than 7B variant  
  - Good for deep synthesis and assistant‑style responses  
- **Weaknesses**:  
  - Slower than smaller assistants  
- **Best Use Cases**: Complex Q&A, synthesis of multi‑source information  
- **Best Paired With**: `llama3:70b` for final strategic review

### `llama3`
- **Role(s)**: Default assistant, spec drafting  
- **VRAM / Load**: ~8–10 GB, balanced load  
- **Strengths**:  
  - Balanced reasoning and speed  
  - Good for drafting and refining specifications  
- **Weaknesses**:  
  - Not as deep as `llama3:70b` for strategic synthesis  
- **Best Use Cases**: Day‑to‑day assistant tasks, drafting technical documentation  
- **Best Paired With**: `qwen3:14b` for structured spec generation

### `llama3:70b`
- **Role(s)**: Strategic synthesis  
- **VRAM / Load**: ~70 GB, heavy load  
- **Strengths**:  
  - Deep analysis and nuanced synthesis  
  - Ideal for final‑pass reviews and complex reasoning  
- **Weaknesses**:  
  - Very high VRAM requirement, slow load  
- **Best Use Cases**: Strategic decision support, high‑stakes code or architecture reviews  
- **Best Paired With**: `mixtral:8x7b` for long‑context architectural input

### `mixtral:8x7b`
- **Role(s)**: Architect review  
- **VRAM / Load**: ~16 GB, slower load  
- **Strengths**:  
  - Long‑context reasoning (~32K tokens)  
  - High‑quality token generation for multi‑file analysis  
- **Weaknesses**:  
  - Larger disk size, higher load time  
- **Best Use Cases**: Reviewing large codebases, architectural decision records  
- **Best Paired With**: `llama3:70b` for strategic synthesis after architectural review


---

# 🧠 Ollama Model Setup & Recovery Guide

This section documents the models installed by  
`ollama_model_setup.sh` for the **RX 7900 XTX + ROCm** meeting assistant + VS Code dev environment,  
and provides instructions for rebuilding the environment if something breaks.

---

## 📊 Model Comparison Table — Current Script Loadout

| Model & Tag | Size / Arch | Context Window | Strengths | Weaknesses | Best Fit in Pipeline |
|-------------|-------------|----------------|-----------|------------|----------------------|
| **Llama 3** (`llama3`) | 8B, dense | ~8K | Balanced general reasoning, fast and helpful | Not as deep as 70B | Default “generalist” for summaries, Q&A, spec drafting |
| **Llama 3:70B** (`llama3:70b`) | 70B, dense | ~8K | Deep reasoning, nuanced synthesis | Heavy VRAM, slower | Final‑pass reviews, strategic synthesis |
| **Starcoder 2:3B** (`starcoder2:3b`) | 3B, code‑tuned | ~8K | Lightweight, context‑aware completions | Limited depth | Default autocomplete in VS Code |
| **Qwen 2.5 Coder 1.5B** (`qwen2.5-coder:1.5b`) | 1.5B, code‑tuned | ~4K | Instant load, great reranker | Minimal reasoning | Rerank and fast fallback |
| **DeepSeek Coder 6.7B** (`deepseek-coder:6.7b-base`) | 6.7B, code‑tuned | ~4K | Fast apply/debug/test, clean code | Short context | Apply/debug/test stages |
| **CodeLlama 13B Instruct** (`codellama:13b-instruct`) | 13B, code‑tuned | ~8K | Deep codegen + validation | Slower than small models | Build/validate loops |
| **Gemma 3:12B** (`gemma3:12b`) | 12B, assistant‑tuned | Long (~128K) | Clear explanations, refactors | Slightly slower | Refactor/explain prompts |
| **Qwen 3:14B** (`qwen3:14b`) | 14B, dense | ~32K | Structured outputs, multilingual | Higher VRAM | Automation/spec generation |
| **Nous‑Hermes 7B** (`nous-hermes:7b`) | 7B, assistant‑tuned | ~8K | Fast, human‑like tone | Less depth | Summaries, wrap‑ups |
| **Nous‑Hermes 13B** (`nous-hermes:13b`) | 13B, assistant‑tuned | ~8K | Deeper synthesis | Slower | Deep assistant layer |
| **Mixtral 8x7B** (`mixtral:8x7b`) | MoE (~12–14GB active) | ~32K | Long‑context, multi‑file review | Larger load | Architect/security reviews |

---

## 🔀 Pipeline Role Mapping

| Pipeline Step        | Model                      |
|----------------------|----------------------------|
| Autocomplete         | `starcoder2:3b`            |
| Rerank               | `qwen2.5-coder:1.5b`       |
| Apply / Debug / Test | `deepseek-coder:6.7b-base` |
| Build / Validate     | `codellama:13b-instruct`   |
| Refactor / Explain   | `gemma3:12b`               |
| Automation / Spec    | `qwen3:14b`                |
| Summarize            | `nous-hermes:7b`           |
| Assistant (default)  | `llama3`                   |
| Assistant (deep)     | `nous-hermes:13b`          |
| Strategic Synthesis  | `llama3:70b`               |
| Architect Review     | `mixtral:8x7b`             |

---

## 🛠 Rebuild & Recovery Instructions

### 1. Re‑run the Setup Script
```bash
chmod +x /home/brent/ai-assistant-project/docs/ollama_model_setup.sh
/home/brent/ai-assistant-project/docs/ollama_model_setup.sh
```

### 2. Verify Model Availability
```bash
ollama pull <model:tag>
```

### 3. Troubleshoot “file does not exist” Errors
- Open https://ollama.com/library
- Confirm the correct tag and update the setup script
- Re‑run the setup script

### 4. Re‑run the Benchmark Script
```bash
chmod +x /home/brent/dev/ollama_benchmark.py
/home/brent/dev/ollama_benchmark.py
```

### 5. Full Clean Rebuild
```bash
ollama list | awk 'NR>1 {print $1}' | xargs -n1 ollama rm
/home/brent/ai-assistant-project/docs/ollama_model_setup.sh
```

---

## 📌 Notes
- `llama3:70b` consumes most of 24 GB VRAM; avoid dual‑loading heavy models alongside it.  
- Prefer small models for real‑time tasks; switch to heavier ones for final‑pass analysis.  
- Keep routing consistent with VS Code defaults and pipeline roles above.

---

## Continue config.yaml (Reference)

```bash
# Continue VS Code Extension Config (v1.2.0 compatible)
name: brent-local-ollama
version: 1.0.0
schema: v1

models:
  - name: codellama13b
    provider: ollama
    model: codellama:13b-instruct
    api_base: http://localhost:11434
    roles:
      - chat
      - edit
      - apply

  - name: mixtral8x7b
    provider: ollama
    model: mixtral:8x7b
    api_base: http://localhost:11434
    roles:
      - chat

  - name: qwen2.5coder1b
    provider: ollama
    model: qwen2.5-coder:1.5b
    api_base: http://localhost:11434
    roles:
      - autocomplete
      - edit
      - apply
      - rerank

  - name: starcoder2_3b
    provider: ollama
    model: starcoder2:3b
    api_base: http://localhost:11434
    roles:
      - autocomplete
      - edit
      - apply
      - rerank

  - name: deepseekcoder6.7b
    provider: ollama
    model: deepseek-coder:6.7b-base
    api_base: http://localhost:11434
    roles:
      - chat
      - autocomplete
      - edit
      - apply

  - name: gemma3_12b
    provider: ollama
    model: gemma3:12b
    api_base: http://localhost:11434
    roles:
      - edit
      - chat

  - name: qwen3_14b
    provider: ollama
    model: qwen3:14b
    api_base: http://localhost:11434
    roles:
      - chat
      - apply

  - name: noushermes7b
    provider: ollama
    model: nous-hermes:7b
    api_base: http://localhost:11434
    roles:
      - chat

  - name: noushermes13b
    provider: ollama
    model: nous-hermes:13b
    api_base: http://localhost:11434
    roles:
      - chat

  - name: llama3
    provider: ollama
    model: llama3
    api_base: http://localhost:11434
    roles:
      - chat

  - name: llama3_70b
    provider: ollama
    model: llama3:70b
    api_base: http://localhost:11434
    roles:
      - chat

# Defaults must reference `name:` keys
default_model: starcoder2_3b
default_chat_model: codellama13b
default_edit_model: gemma3_12b
default_apply_model: deepseekcoder6.7b
default_rerank_model: qwen2.5coder1b

ui:
  show_model_picker: true
  sidebar_width: 350

prompts:
  - name: build-feature
    description: Generate production‑ready code from a natural language spec
    model: codellama13b
    prompt: |
      You are an expert software engineer. Based on the following specification, generate complete, production‑ready code.
      - Include docstrings and inline comments.
      - Follow Python best practices (PEP 8) unless otherwise specified.
      - If the spec is ambiguous, ask clarifying questions before coding.
      - Output only the code block unless explicitly asked for explanation.

  - name: build-and-validate
    description: Generate code and then self‑review it for correctness
    model: codellama13b
    prompt: |
      Step 1: Generate the requested code based on the specification.
      Step 2: Review your own output for:
        - Logical correctness
        - Syntax errors
        - Missing edge cases
        - Security vulnerabilities
      Step 3: Provide the corrected final version.
      Output the reviewed code only, unless explicitly asked for the review notes.

  - name: refactor-for-clarity
    description: Improve readability, maintainability, and structure
    model: gemma3_12b
    prompt: |
      Refactor the provided code to:
        - Improve naming and structure
        - Reduce complexity
        - Add docstrings and inline comments
        - Preserve all functionality
      Output only the refactored code.

  - name: add-tests
    description: Generate unit tests for existing code
    model: deepseekcoder6.7b
    prompt: |
      Write comprehensive unit tests for the provided code.
      - Cover normal, edge, and error cases.
      - Use pytest style unless otherwise specified.
      - Include fixtures if needed.
      Output only the test code.

  - name: security-review
    description: Audit code for vulnerabilities and suggest fixes
    model: codellama13b
    prompt: |
      Review the provided code for:
        - Security vulnerabilities
        - Insecure coding patterns
        - Missing validation or sanitization
      Suggest specific fixes and explain why they are needed.

  - name: optimize-performance
    description: Improve efficiency and speed of the code
    model: deepseekcoder6.7b
    prompt: |
      Analyze the provided code for performance bottlenecks.
      Suggest and implement optimizations to improve speed and reduce resource usage.
      Ensure the optimized code maintains the same functionality.
      Output only the optimized code.

  - name: explain-code
    description: Provide a detailed explanation of the code's functionality
    model: gemma3_12b
    prompt: |
      Explain the functionality of the provided code in detail.
      - Describe the purpose of the code.
      - Explain how it works step-by-step.
      - Highlight any important design decisions or patterns used.
      Output the explanation in clear, concise language.


  - name: translate-language
    description: Convert code from one programming language to another
    model: codellama13b
    prompt: |
      Translate the provided code from its current programming language to the specified target language.
      - Preserve the original functionality.
      - Follow best practices and idioms of the target language.
      - Include comments and docstrings as appropriate.
      Output only the translated code.

  - name: generate-documentation
    description: Create comprehensive documentation for the codebase
    model: codellama13b
    prompt: |
      Generate detailed documentation for the provided code.
      - Include an overview of the code's purpose and functionality.
      - Document key classes, functions, and modules.
      - Provide usage examples where applicable.
      Output the documentation in markdown format.

  - name: debug-code
    description: Identify and fix bugs in the provided code
    model: deepseekcoder6.7b
    prompt: |
      Analyze the provided code to identify any bugs or issues.
      Suggest specific fixes and implement them.
      Ensure the fixed code maintains the same functionality.
      Output only the corrected code.

  - name: code-review
    description: Review code for quality, style, and best practices
    model: codellama13b
    prompt: |
      Review the provided code for:
        - Code quality
        - Adherence to style guidelines
        - Use of best practices
      Suggest specific improvements and explain why they are needed.

  - name: integrate-library
    description: Add and configure a new library or framework in the codebase
    model: codellama13b
    prompt: |
      Integrate the specified library or framework into the provided codebase.
      - Add necessary import statements.
      - Configure the library as needed.
      - Update existing code to utilize the new library.
      Output only the updated code.

  - name: full-feature-pipeline
    description: Build, validate, test, and optimize a feature in one run
    model: codellama13b
    prompt: |
      You are an expert software engineer. Follow these steps:
      1. Generate production-ready code from the given specification.
      2. Review your own output for correctness, syntax errors, missing edge cases, and security vulnerabilities. Correct any issues.
      3. Generate comprehensive pytest-style unit tests for the corrected code.
      4. Optimize the corrected code for performance without changing functionality.
      Output in this order:
      - Final optimized code
      - Unit tests
      - Brief summary of changes and optimizations

  - name: draft-feature-spec
    description: Interactive Q&A to build a complete feature specification
    model: llama3
    prompt: |
      You are an expert product engineer helping to create a complete, high-quality feature specification.
      Ask me structured questions in sequence to gather:
      1. Feature overview (purpose, user story, scope)
      2. Functional requirements (inputs, outputs, core logic, edge cases)
      3. Technical context (language, framework, dependencies, environment, performance targets)
      4. Data & storage details (schema, persistence, validation)
      5. Security & compliance requirements
      6. Testing expectations
      7. Documentation needs
      After gathering all answers, output a clean, copy-ready Markdown specification following the Feature Specification Guide format.

  - name: refine-feature-spec
    description: Review and improve an existing feature specification
    model: llama3
    prompt: |
      You are an expert product engineer and technical writer.
      Review the provided feature specification for:
      - Missing or unclear details
      - Ambiguities that could cause incorrect implementation
      - Opportunities to improve clarity, completeness, and testability
      Suggest specific additions or changes, then output the improved specification in clean Markdown.

  - name: feature-specification-guide
    description: Guidelines for writing high-quality feature specifications
    model: llama3
    prompt: |
      Use the following guidelines to write high-quality feature specifications:
      1. **Feature Overview**: Start with a clear purpose, user story, and scope.
      2. **Functional Requirements**: Detail inputs, outputs, core logic, and edge cases.
      3. **Technical Context**: Specify language, framework, dependencies, environment, and performance targets.
      4. **Data & Storage**: Define data schema, persistence, and validation needs.
      5. **Security & Compliance**: Outline any security measures or compliance requirements.
      6. **Testing Expectations**: Describe required tests and coverage goals.
      7. **Documentation Needs**: Note any documentation or usage examples required.
      Follow this structure and be as specific as possible to ensure a clear, implementable specification.

# =========================
# CUSTOM PROMPTS
# =========================
# Add your own custom prompts below. See https://continue.so/docs/prompts for details.
```

---

## ollama_model_setup.sh (Reference)
```bash
#!/usr/bin/env bash
#
# ollama_model_setup.sh
# Install selected Ollama models for coding and meeting assistance.
# Confirm each MODELS array below to ensure only wanted models are installed.
#
# Usage:
#   chmod +x /home/brent/ai-assistant-project/docs/ollama_model_setup.sh
#   ./home/brent/ai-assistant-project/docs/ollama_model_setup.sh
# Note: This script assumes Ollama is installed and configured.
# It will skip models that are already installed.
# For a fresh setup, consider running the cleanup script first:
#   /home/brent/ai-assistant-project/docs/ollama_model_cleanup.sh
#-----------------------------------------------------------------------------
set -euo pipefail

TS=$(date +"%Y%m%d_%H%M%S")
BENCHMARK_SCRIPT="/home/brent/dev/ollama_benchmark.py"
RESULTS_DIR="/home/brent/ai-assistant-project/docs/benchmark_results"
mkdir -p "$RESULTS_DIR"

echo "=== Ollama Model Setup Script ==="
echo "Target: RX 7900 XTX + ROCm, VS Code + Meeting Assistant"
echo "Reference: /home/brent/reference-guides/ai-coding-models.md"
echo "Review Prompts: /home/brent/reference-guides/mixtral-architect-review.md"
echo "Note: Already-installed models will be skipped. For fresh installs, run:"
echo "      /home/brent/ai-assistant-project/docs/ollama_model_cleanup.sh"

# -----------------------------------------------------------------------------
# Core models (VS Code + AI Coding Workflow)
# -----------------------------------------------------------------------------
CORE_MODELS=(
  "qwen2.5-coder:1.5b"       # Autocomplete (fast, warning-free)
  "starcoder2:3b"            # Autocomplete (larger, richer completions)
  "deepseek-coder:6.7b-base" # Edit & Apply (refactored, safer)
  "codellama:13b-instruct"   # Deep coding (multi-file reasoning)
  "mixtral:8x7b"             # Architect/Security reviews
)

echo "=== Pulling core models (VS Code + AI Coding Workflow) ==="
for MODEL in "${CORE_MODELS[@]}"; do
    if ollama list | grep -q "$MODEL"; then
        echo "✅ Model '$MODEL' already installed — skipping."
    else
        read -rp "Pull model '$MODEL'? [y/N]: " CONFIRM
        if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
            ollama pull "$MODEL"
        else
            echo "⏭ Skipped $MODEL"
        fi
    fi
done

# -----------------------------------------------------------------------------
# Summarization + Assistant Models
# -----------------------------------------------------------------------------
EXTRA_MODELS=(
  "llama3"           # Default assistant
  "gemma3:12b"       # Upgrade: replaces gemma2:9b
  "nous-hermes:7b"   # Summarization and wrap-up
  "nous-hermes:13b"  # Optional deeper assistant
  "qwen3:14b"        # Upgrade: replaces qwen2.5:14b
)

echo "=== Pulling Summarization + Assistant Models ==="
for MODEL in "${EXTRA_MODELS[@]}"; do
    if ollama list | grep -q "$MODEL"; then
        echo "✅ Model '$MODEL' already installed — skipping."
    else
        read -rp "Pull model '$MODEL'? [y/N]: " CONFIRM
        if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
            ollama pull "$MODEL"
        else
            echo "⏭ Skipped $MODEL"
        fi
    fi
done

# -----------------------------------------------------------------------------
# Deep Reasoning Model (on-demand)
# -----------------------------------------------------------------------------
DEEP_MODEL="llama3:70b"
echo "=== Pulling Deep Reasoning Model (on-demand) ==="
if ollama list | grep -q "$DEEP_MODEL"; then
    echo "✅ Model '$DEEP_MODEL' already installed — skipping."
else
    read -rp "Pull model '$DEEP_MODEL'? [y/N]: " CONFIRM
    if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
        ollama pull "$DEEP_MODEL"
    else
        echo "⏭ Skipped $DEEP_MODEL"
    fi
fi

# -----------------------------------------------------------------------------
# Deprecated / Removed Models (do not reinstall)
# -----------------------------------------------------------------------------
echo "=== Skipping deprecated models ==="
echo "❌ mistral"
echo "❌ phi3"
echo "❌ gemma:2b"
echo "❌ gemma:7b"
echo "❌ gemma2:9b (replaced by gemma3:12b)"
echo "❌ qwen2.5:14b (replaced by qwen3:14b)"
echo "❌ codellama:7b-instruct"

# -----------------------------------------------------------------------------
# Benchmark (optional)
# -----------------------------------------------------------------------------
if [[ -x "$BENCHMARK_SCRIPT" ]]; then
    echo "Running benchmark..."
    "$BENCHMARK_SCRIPT" | tee "$RESULTS_DIR/ollama_benchmark_${TS}.csv"
else
    echo "No benchmark script found at $BENCHMARK_SCRIPT — skipping."
fi

echo "=== Model installation complete ==="
ollama list
echo "Benchmark results (if run) saved to $RESULTS_DIR"
echo "=================================="
# End of script
```

---

## 🧹 Removed Models (Audit Notes)

The following models were removed during the September 2025 audit:

- `codellama:7b-instruct` — replaced by `gemma3:12b` for refactor/explain
- `phi3` — replaced by `llama3` and `qwen3:14b`
- `gemma:2b`, `gemma:7b`, `gemma2:9b` — superseded by `gemma3:12b`
- `qwen2.5:14b` — replaced by `qwen3:14b`
- `mistral` — replaced by `llama3` for assistant tasks

See `/docs/ollama_model_cleanup.sh` for reproducible cleanup.
