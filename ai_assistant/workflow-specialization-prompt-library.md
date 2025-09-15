Phase 3 — Model Role Specialization & Prompt Library for AI Assistant Development
Summary

This document defines the specific roles of each model in our multi‑model workflow and provides a curated library of prompts tailored for building, testing, and refining an AI Assistant. It is intended as a quick‑reference guide so you can select the right model for the right task — whether that’s Copilot for inline completions, Qwen 2.5‑Coder 7B for fast local iteration, or Qwen 2.5‑Coder 14B for deep reasoning and architecture work. The prompts are designed to accelerate development, improve code quality, and enhance the assistant’s conversational and functional capabilities.
Model Roles
Copilot

    Purpose: Quick code completions & inline help.

    Strengths: Instant suggestions, integrates with VS Code IntelliSense.

    Best For:

        Filling in code as you type.

        Quick syntax fixes.

        Short, context‑aware suggestions.

Local Chat (Qwen2.5‑Coder 7B)

    Purpose: Lightweight Q&A, code explanation, small refactors.

    Strengths: Fast, private, runs locally.

    Best For:

        Explaining code snippets.

        Suggesting small improvements.

        Quick brainstorming without heavy compute.

Local Chat (Qwen2.5‑Coder 14B)

    Purpose: Deep reasoning, multi‑file analysis, architecture discussions.

    Strengths: Handles larger context and more complex reasoning.

    Best For:

        Reviewing multiple files or large codebases.

        Designing architecture or workflows.

        Detailed problem‑solving.

Prompt Library — AI Assistant Project
General Development

Explain Code Explain the following code in simple terms, including its purpose, inputs, outputs, and any potential pitfalls: {{selection}}

Refactor for Readability Refactor the following code for clarity, maintainability, and performance without changing functionality: {{selection}}

Suggest Improvements Suggest small, incremental improvements for this code, focusing on efficiency, readability, and scalability: {{selection}}
Architecture & Design

Design AI Assistant Module Design a modular architecture for an AI assistant that can handle the following features: {{input}} Include data flow, API boundaries, and component responsibilities.

Integration Plan Given the following existing system, outline how to integrate an AI assistant component with minimal disruption: {{files}}

Feature Breakdown Break down the following feature request into actionable development tasks for an AI assistant project: {{input}}
Testing & Validation

Generate Unit Tests Write comprehensive unit tests for the following function, covering edge cases and error handling: {{selection}}

Test Plan Create a test plan for validating the AI assistant's responses against functional and UX requirements: {{input}}

Debugging Aid Analyze the following code and describe potential causes for the reported bug, along with possible fixes: {{selection}}
Prompt Engineering

Refine Prompt Given the following initial prompt for the AI assistant, refine it for clarity, specificity, and optimal model performance: {{input}}

Prompt Variations Generate 3 alternative phrasings of the following prompt that might yield better results from the model: {{input}}

Response Evaluation Evaluate the following AI assistant response for accuracy, helpfulness, and tone. Suggest improvements: {{input}}
User Experience

Conversation Flow Design a conversation flow for the AI assistant to guide a user through: {{input}} Include fallback responses and clarification prompts.

Tone & Style Guide Create a tone and style guide for the AI assistant to ensure consistent, engaging, and brand‑aligned responses: {{input}}

Error Handling UX Suggest user‑friendly error messages and recovery strategies for the AI assistant when it cannot fulfill a request: {{input}}
Usage Tips

    7B: Use for quick iterations on prompts, small code snippets, and lightweight design brainstorming.

    14B: Use for deep architectural planning, multi‑file reviews, and complex debugging.

    Copilot: Let it handle inline completions and micro‑suggestions while coding.

    Keep these prompts in a Continue Page or local reference file for quick copy‑paste into the chat input.