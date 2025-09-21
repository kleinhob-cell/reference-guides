# 🧪 Testing and Debugging

This section covers how to use GitHub Copilot Pro and other tools to write tests, identify bugs, and debug code effectively in AI-based development workflows.

---

## ✅ Testing Philosophy

- Write tests early and often
- Use Copilot to generate unit tests and edge cases
- Validate Copilot-generated code with automated tests
- Document test strategies and results

---

## 🧪 Writing Tests with Copilot

Use Copilot Chat to:
- Generate unit tests for functions and modules
- Suggest edge cases and input variations
- Create test files and organize them in `/tests`

### Example Prompt:
```text
"Generate unit tests for a function that summarizes meeting transcripts."
```

### Example Structure:
```
tests/
├── test_main.py
├── test_calendar_integration.py
└── test_summarizer.py
```

---

## 🐞 Debugging with Copilot

Use Copilot Chat to:
- Explain error messages
- Suggest fixes and refactoring
- Identify logic flaws or missing conditions

### Example Prompts:
```text
"Why is this function returning None?"
"Fix this IndexError in the loop."
"Refactor this to handle empty input gracefully."
```

---

## 🧰 Recommended Tools

- `pytest` for Python testing
- `unittest` for built-in test framework
- `Copilot Labs` for experimental debugging features
- `logging` module for runtime diagnostics

---

## 📌 Best Practices

- Keep tests in a dedicated `/tests` folder
- Use descriptive test names and assertions
- Run tests automatically before commits
- Document test coverage and known issues

---

## 📁 Prompt Library

Save useful testing and debugging prompts in a `/prompts/testing-debugging.md` file for reuse.

