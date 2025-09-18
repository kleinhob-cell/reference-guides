# 🧠 Copilot+ AI Workflow Map  
**Model Routing • Prompt Roles • Assistant Integration**

---

## 📑 Table of Contents
- [🧠 Copilot+ AI Workflow Map](#-copilot-ai-workflow-map)
  - [📑 Table of Contents](#-table-of-contents)
  - [📄 Overview](#-overview)
  - [🔀 Model Routing Summary](#-model-routing-summary)
  - [🧩 Prompt → Model Mapping](#-prompt--model-mapping)
  - [📊 Installed Model Comparison](#-installed-model-comparison)
  - [🤖 Assistant Stack](#-assistant-stack)
  - [🛠 Spec Prep — Preparing a High‑Quality Feature Specification](#-spec-prep--preparing-a-highquality-feature-specification)
    - [Available Prompts](#available-prompts)
    - [Workflow](#workflow)
    - [Why This Matters](#why-this-matters)
  - [📋 Feature Specification Guide](#-feature-specification-guide)
    - [⚙️ Full Feature Pipeline Usage](#️-full-feature-pipeline-usage)
    - [Purpose](#purpose)
    - [When to Use](#when-to-use)
    - [How to Run in Continue](#how-to-run-in-continue)
    - [Example Input](#example-input)
    - [Example Output Structure](#example-output-structure)
    - [How to Run in Continue](#how-to-run-in-continue-1)
    - [Example Input](#example-input-1)
  - [⚠️ Removed Models (Audit Notes)](#️-removed-models-audit-notes)

---

## 📄 Overview
This workflow map documents how prompts, models, and assistant roles are routed in the current Ollama‑based Copilot+ stack.

It is designed to:
- **Ensure reproducibility** — every model and prompt pairing is intentional, documented, and can be re‑run by future maintainers.
- **Support meeting‑assistant integration** — enabling a smooth flow from discussion → specification → implementation → validation.
- **Provide clear routing** — so anyone can see which model is best suited for a given task without guesswork.
- **Align with hardware constraints** — optimized for the RX 7900 XTX (24 GB VRAM) and reproducible Linux environments.

The map covers:
- **Model Routing Summary** — which model is default for each role.
- **Prompt → Model Mapping** — explicit assignments for all prompts, including the spec‑to‑code pipeline.
- **Installed Model Comparison** — VRAM, context length, strengths, weaknesses, and best‑fit scenarios.
- **Assistant Stack** — conversational and automation roles for day‑to‑day and deep‑dive tasks.
- **Spec Prep** — how to prepare a high‑quality feature specification before coding, with prompt‑driven workflows.
- **Feature Specification Guide** — the agreed structure for specs to ensure clarity and completeness.
- **Full Feature Pipeline Usage** — how to go from spec to production‑ready code, tests, and optimizations in one run.

---

## 🔀 Model Routing Summary

| Task Type            | Default Model               | Notes |
|----------------------|------------------------------|-------|
| **Autocomplete**     | `starcoder2_3b`              | Code‑tuned completions with good context awareness; VRAM‑friendly for always‑on use. |
| **Rerank**           | `qwen2.5coder1b`             | Ultra‑fast candidate ranking; minimal VRAM footprint; ideal for inline suggestion filtering. |
| **Chat / Build / Review** | `codellama13b`           | Balanced reasoning and generation; strong for multi‑file builds and code reviews. |
| **Edit / Apply**     | `deepseekcoder6.7b`          | Fast inline edits, targeted fixes, and performance optimizations. |
| **Refactor / Explain** | `gemma3_12b`               | Long‑context restructuring and clear, detailed explanations; excellent for onboarding docs. |
| **Summarize / Wrap‑up** | `noushermes7b`            | Human‑like meeting summaries; quick turnaround for wrap‑up notes. |
| **Automate / Spec**  | `qwen3_14b`                  | Structured, multilingual output; excels at generating specs, configs, and automation scripts. |
| **Assistant (default)** | `llama3`                  | Fast, responsive general assistant for day‑to‑day queries. |
| **Assistant (deep)** | `noushermes13b`              | Richer synthesis and reasoning for complex assistant tasks. |
| **Strategic Synthesis** | `llama3_70b`              | Final‑pass analysis and nuanced reasoning for high‑stakes decisions. |
| **Architect Review** | `mixtral8x7b`                | Long‑context, multi‑file architectural analysis and design review. |

---

## 🧩 Prompt → Model Mapping

| Prompt Name                  | Assigned Model         | Best For |
|------------------------------|------------------------|----------|
| `build-feature`              | `codellama13b`         | Multi‑step feature builds from finalized specifications. |
| `build-and-validate`         | `codellama13b`         | Generate code, self‑review for correctness, and fix issues before output. |
| `refactor-for-clarity`       | `gemma3_12b`           | Large‑context structural clean‑ups and code readability improvements. |
| `add-tests`                  | `deepseekcoder6.7b`    | Generating comprehensive, relevant pytest‑style test suites. |
| `security-review`            | `codellama13b`         | Identifying subtle security issues and suggesting mitigations. |
| `optimize-performance`       | `deepseekcoder6.7b`    | Performance tuning without altering functionality. |
| `explain-code`               | `gemma3_12b`           | Detailed, clear explanations of code for onboarding or documentation. |
| `translate-language`         | `codellama13b`         | Syntax‑ and idiom‑aware code translations between languages. |
| `generate-documentation`     | `codellama13b`         | Structured, readable technical documentation. |
| `debug-code`                 | `deepseekcoder6.7b`    | Pinpointing and fixing bugs in targeted code segments. |
| `code-review`                | `codellama13b`         | Style, quality, and maintainability reviews. |
| `integrate-library`          | `codellama13b`         | Multi‑file library/framework integration with minimal disruption. |
| **`full-feature-pipeline`**  | `codellama13b`         | **Spec → Code → Validate → Test → Optimize** in one run. |
| **`draft-feature-spec`**     | `llama3`               | Interactive Q&A to build a complete, high‑quality feature specification from scratch. |
| **`refine-feature-spec`**    | `llama3`               | Review and improve an existing feature specification for clarity, completeness, and testability. |
| **`feature-specification-guide`** | `llama3`          | Output the agreed‑upon checklist for writing high‑quality feature specifications. |

---

## 📊 Installed Model Comparison

| Model Name / Tag           | Size  | VRAM Use* | Context | VRAM Fit** | Strengths | Weaknesses | Best Use Cases |
|----------------------------|-------|-----------|---------|------------|-----------|------------|----------------|
| `qwen2.5coder1b`           | 1.5B  | ~2 GB     | ~4K     | ✅ Dual    | Ultra‑fast rerank; minimal footprint; ideal for inline suggestion filtering | Limited reasoning depth; short context | Autocomplete rerank; background candidate scoring |
| `starcoder2_3b`            | 3B    | ~4 GB     | ~8K     | ✅ Dual    | Code‑tuned completions; good context awareness; VRAM‑friendly | Less deep reasoning; not for large‑scale builds | Default autocomplete in editors |
| `deepseekcoder6.7b`        | 6.7B  | ~7 GB     | ~4K     | ✅ Dual    | Fast inline edits; targeted fixes; performance optimization; test generation | Shorter context; less natural language fluency | Add‑tests; optimize‑performance; debug small modules |
| `codellama13b`             | 13B   | ~14 GB    | ~4K     | ⚠ Single  | Balanced reasoning and generation; strong for multi‑file builds and reviews | Slower than smaller models; higher VRAM | Build‑feature; build‑and‑validate; code‑review |
| `gemma3_12b`               | 12B   | ~12 GB    | ~128K   | ⚠ Single  | Long‑context restructuring; clear explanations; great for onboarding docs | Slightly slower than mid‑tier models | Refactor‑for‑clarity; explain‑code |
| `qwen3_14b`                | 14B   | ~14 GB    | ~32K    | ⚠ Single  | Structured, multilingual output; excels at specs/configs/scripts | Higher VRAM; slower load | Automate/spec creation; structured data output |
| `noushermes7b`             | 7B    | ~7 GB     | ~8K     | ✅ Dual    | Human‑like summaries; quick wrap‑ups | Less depth than larger assistants | Summarize meetings; wrap‑up notes |
| `noushermes13b`            | 13B   | ~13 GB    | ~8K     | ⚠ Single  | Richer synthesis; deeper reasoning than 7B | Slower; higher VRAM | Deep assistant tasks; synthesis of multi‑source info |
| `llama3`                   | 8–10B | ~10 GB    | ~8K     | ✅ Dual    | Balanced reasoning and speed; versatile | Not as deep as `llama3_70b` | Default assistant; draft‑feature‑spec; refine‑feature‑spec |
| `llama3_70b`               | 70B   | ~70 GB    | ~8K     | ❌ Single  | Deep analysis; nuanced synthesis; ideal for final‑pass reviews | Heavy VRAM; slow load | Strategic synthesis; high‑stakes reviews |
| `mixtral8x7b`               | MoE   | ~16 GB    | ~32K    | ⚠ Single  | Long‑context multi‑file analysis; high‑quality generation | Larger disk size; higher load time | Architect review; large PR/codebase analysis |

\* VRAM usage is approximate.  
\** VRAM Fit assumes RX 7900 XTX (24 GB VRAM).

---

## 🤖 Assistant Stack

| Role                | Model             | Notes |
|---------------------|-------------------|-------|
| **Default Assistant**   | `llama3`          | Fast, balanced reasoning; ideal for day‑to‑day queries, drafting, and lightweight problem‑solving. |
| **Summarizer**          | `noushermes7b`    | Human‑like tone for meeting wrap‑ups, quick summaries, and concise status updates. |
| **Automation / Spec**   | `qwen3_14b`       | Structured, multilingual output; excels at generating feature specs, configs, and automation scripts. |
| **Deep Assistant**      | `noushermes13b`   | Richer synthesis and reasoning for complex assistant tasks, multi‑source integration, and nuanced responses. |
| **Strategic Synthesis** | `llama3_70b`      | Final‑pass analysis, deep reasoning, and high‑stakes decision support. |
| **Architect Review**    | `mixtral8x7b`     | Long‑context, multi‑file architectural analysis; ideal for large PR/codebase reviews and design validation. |

---

## 🛠 Spec Prep — Preparing a High‑Quality Feature Specification

Before running `full-feature-pipeline`, ensure your feature specification is **complete, unambiguous, and implementation‑ready**.  
This stage is critical for reproducibility, maintainability, and smooth hand‑offs to future maintainers.

---

### Available Prompts

- **`draft-feature-spec`** → Interactive Q&A to build a new spec from scratch.  
  *Model:* `llama3`  
  *Best for:* Capturing requirements during or immediately after a meeting, using structured questioning to avoid gaps.

- **`refine-feature-spec`** → Review and improve an existing spec for clarity, completeness, and testability.  
  *Model:* `llama3`  
  *Best for:* Tightening specs from stakeholders or legacy docs before implementation.

- **`feature-specification-guide`** → Outputs the agreed‑upon checklist for writing high‑quality specs.  
  *Model:* `llama3`  
  *Best for:* Onboarding new contributors or validating that a spec meets project standards.

---

### Workflow

1. **If starting from scratch**  
   - Run `draft-feature-spec` and answer each question in detail.  
   - Use meeting assistant transcripts or notes as input to speed up Q&A.

2. **If you have a draft**  
   - Run `refine-feature-spec` to fill gaps, remove ambiguity, and improve testability.  
   - Address all suggested changes before marking the spec as final.

3. **Need a reminder of the structure?**  
   - Run `feature-specification-guide` to get the full checklist.  
   - Compare your spec against it to ensure nothing is missing.

4. **Lock the spec**  
   - Save the final version in `/docs/specs/` with a date/version tag.  
   - Commit alongside any related meeting notes for traceability.

---

### Why This Matters

- **Reproducibility** — A complete, structured spec ensures the same feature can be implemented consistently by different maintainers.
- **Meeting Efficiency** — Structured Q&A keeps requirement‑gathering focused and avoids scope creep.
- **Implementation Quality** — Clear specs reduce rework, speed up coding, and improve test coverage.
- **Onboarding** — New contributors can quickly understand the feature’s purpose, scope, and constraints without digging through meeting logs.

---

## 📋 Feature Specification Guide

Use this structure to ensure every feature specification is clear, complete, and implementation‑ready.  
This is the same checklist used by `feature-specification-guide` and referenced by `draft-feature-spec` and `refine-feature-spec`.

1. **Feature Overview**  
   - Purpose: Why this feature exists and the problem it solves.  
   - User Story: Who benefits and how.  
   - Scope: Boundaries of what’s included and excluded.

2. **Functional Requirements**  
   - Inputs: Data, parameters, or triggers.  
   - Outputs: Expected results or artifacts.  
   - Core Logic: Main processing steps.  
   - Edge Cases: Unusual or failure scenarios to handle.

3. **Technical Context**  
   - Language & Framework: Primary tech stack.  
   - Dependencies: Libraries, APIs, or services.  
   - Environment: OS, hardware, or runtime constraints.  
   - Performance Targets: Throughput, latency, or resource usage goals.

4. **Data & Storage**  
   - Schema: Data structures and relationships.  
   - Persistence: Where and how data is stored.  
   - Validation: Rules for data integrity.

5. **Security & Compliance**  
   - Security Measures: Authentication, encryption, access control.  
   - Compliance: Regulatory or policy requirements.

6. **Testing Expectations**  
   - Test Types: Unit, integration, end‑to‑end.  
   - Coverage Goals: Minimum acceptable coverage.  
   - Special Cases: Mocking, fuzzing, or load testing.

7. **Documentation Needs**  
   - Inline Comments: For maintainers.  
   - External Docs: User guides, API references.  
   - Changelog: Notable updates for release notes.

---

**Tip:**  
Before implementation, run your spec through `refine-feature-spec` to catch missing details and ambiguities.  
If you’re starting from scratch, use `draft-feature-spec` to build it interactively, then validate against this guide.

---

### ⚙️ Full Feature Pipeline Usage

### Purpose
The `full-feature-pipeline` prompt is designed to take a **finalized, implementation‑ready feature specification** and produce:
1. Production‑ready code.
2. Self‑reviewed corrections for correctness, syntax, edge cases, and security.
3. Comprehensive pytest‑style unit tests.
4. Performance optimizations without changing functionality.

This ensures that a single run moves a feature from **spec → validated code → tests → optimized implementation**.

---

### When to Use
- The feature specification has been **approved** and locked (see [Spec Prep](#-spec-prep--preparing-a-high-quality-feature-specification)).
- All functional, technical, and compliance requirements are documented.
- You want a **single, reproducible run** that outputs code, tests, and optimizations in a consistent format.
- Ideal for **handoffs** — future maintainers can re‑run the same prompt with the same spec to reproduce the output.

---

### How to Run in Continue
1. Select the `full-feature-pipeline` prompt.
2. Paste the **finalized feature specification** into the input field.
3. Optionally include:
   - Relevant codebase context (e.g., existing modules, APIs).
   - Any architectural constraints discussed in meetings.
4. Run the prompt — the model will:
   - Generate the initial implementation.
   - Self‑review and correct issues.
   - Produce pytest‑style tests.
   - Apply performance optimizations.
5. Review the output before committing:
   - Validate correctness in your local environment.
   - Run the generated tests in CI.
   - Document any deviations from the spec.

---

### Example Input
```markdown
## Feature Overview
Purpose: Allow meeting assistant to export summaries directly to Confluence.
User Story: As a project manager, I want meeting summaries automatically published to our Confluence space so the team can access them without manual copy-paste.
Scope: Export only finalized summaries; no draft publishing.

## Functional Requirements
Inputs: Finalized meeting summary text, Confluence API credentials.
Outputs: New Confluence page in the specified space with the summary content.
Core Logic: Authenticate with Confluence API, create page with correct title and body, confirm success.
Edge Cases: API rate limits, invalid credentials, network failures.

## Technical Context
Language: Python 3.11
Framework: None (standard library + requests)
Dependencies: requests, python-dotenv
Environment: Linux server with outbound HTTPS access
Performance Targets: Publish within 5 seconds of request.

## Data & Storage
Schema: N/A (data is transient)
Persistence: None
Validation: Ensure summary text is non-empty before publishing.

## Security & Compliance
Security Measures: Store API credentials in environment variables; never log secrets.
Compliance: Must meet internal data handling policy.

## Testing Expectations
Test Types: Unit tests for API call wrapper, integration test with mock Confluence API.
Coverage Goals: ≥90% for new code.
Special Cases: Simulate API failure responses.

## Documentation Needs
Inline Comments: For all functions.
External Docs: README update with usage instructions.
Changelog: Add entry for new export feature.
```

---

### Example Output Structure
```python
# Final Optimized Code
# src/confluence_exporter.py
import os
import requests
from dotenv import load_dotenv

load_dotenv()

# ... implementation code with error handling, logging, and performance optimizations ...

# Unit Tests
# tests/test_confluence_exporter.py
import pytest
from unittest.mock import patch

# ... pytest-style tests covering success, failure, and edge cases ...

# Summary of Changes and Optimizations
- Added retry logic for transient network errors.
- Reduced API call latency by reusing HTTP session.
- Improved error messages for easier debugging.
- Ensured credentials are only loaded once at startup.
```

---

**Tip:**  
For maximum reproducibility, commit:
- The **exact prompt text** used.
- The **spec** provided as input.
- The **generated output** (code + tests + summary).

This allows future maintainers to re‑run the pipeline and verify results.


---

### How to Run in Continue
1. Select the `full-feature-pipeline` prompt.
2. Paste the **finalized feature specification** into the input field.
3. Optionally include:
   - Relevant codebase context (e.g., existing modules, APIs).
   - Any architectural constraints discussed in meetings.
4. Run the prompt — the model will:
   - Generate the initial implementation.
   - Self‑review and correct issues.
   - Produce pytest‑style tests.
   - Apply performance optimizations.
5. Review the output before committing:
   - Validate correctness in your local environment.
   - Run the generated tests in CI.
   - Document any deviations from the spec.

---

### Example Input

---

## ⚠️ Removed Models (Audit Notes)

The following models were removed during the latest stack audit to reduce redundancy, free VRAM/disk space, and improve routing clarity.  
Each removal was benchmark‑driven and documented so future maintainers can reinstate a model if a workflow gap emerges.

| Model Name / Tag       | Reason for Removal | Replacement / Reroute |
|------------------------|--------------------|-----------------------|
| `codellama7b`          | Redundant with `codellama13b` for build tasks; lower reasoning depth | `codellama13b` |
| `wizardcoder13b`       | Redundant with `codellama13b` in build/validate role | `codellama13b` |
| `phi3`                 | Lower accuracy in structured output tasks compared to `qwen3_14b` | `qwen3_14b` |

**Audit Notes:**
- All removals were validated against benchmark tasks for speed, accuracy, and fit to role.
- Disk space savings: ~38 GB.
- VRAM routing is now cleaner — no overlapping models competing for the same role.
- If reinstating a model, update both:
  1. **Prompt → Model Mapping** table.
  2. **Installed Model Comparison** section.
