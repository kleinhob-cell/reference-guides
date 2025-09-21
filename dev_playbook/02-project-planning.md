# 🗂️ Project Planning

This section outlines how to plan AI-based development projects using GitHub Copilot Pro and low-code/no-code strategies. It includes best practices for scoping, prompting, and organizing your work.

---

## 🎯 Planning Philosophy

- Start with **plain English descriptions** of what you want to build
- Use **Copilot Chat** to break down tasks and generate scaffolds
- Apply **agile principles**: iterate quickly, validate often
- Document everything for reproducibility and learning

---

## 🧠 Using Copilot for Planning

Before writing any code, use Copilot Chat to:

- Describe your project goals
- Ask for architecture suggestions
- Request a folder and file scaffold
- Break down features into modular tasks

### Example Prompt:
```text
"I want to build a meeting assistant that integrates with Google Calendar and summarizes meetings using local LLMs. Can you suggest a project structure and key components?"
```

---

## 🧱 Project Scaffolding

Use Copilot to generate:
- Folder structure
- Initial files with boilerplate code
- README with project overview

Maintain a consistent structure across projects:
```
meeting-assistant/
├── README.md
├── src/
│   ├── main.py
│   ├── calendar_integration.py
│   └── summarizer.py
├── tests/
│   └── test_main.py
├── data/
└── docs/
```

---

## 📝 Task Breakdown

Use Copilot Chat to:
- Convert features into user stories
- Break stories into tasks
- Generate TODO lists and planning boards

### Example:
```text
"Break down the calendar integration into user stories and implementation tasks."
```

---

## 📌 Recommendations

- Use GitHub Projects or Issues to track tasks
- Keep planning prompts and responses in a `/planning` folder
- Review and refine Copilot-generated plans before implementation

