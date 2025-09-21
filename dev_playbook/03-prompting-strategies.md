# 💬 Prompting Strategies

This section explores how to write effective prompts for GitHub Copilot Pro and other AI tools to maximize productivity and code quality.

---

## 🎯 Prompting Philosophy

- Be **specific**: Clearly describe what you want
- Be **contextual**: Include relevant variables, file names, or goals
- Be **iterative**: Refine prompts based on output
- Be **modular**: Break down complex tasks into smaller prompts

---

## ✍️ Prompt Types

### 1. Task Prompts
Use these to generate code for specific tasks.
```text
"Create a Python function that fetches weather data from OpenWeather API."
```

### 2. Planning Prompts
Use these to scaffold projects or suggest architecture.
```text
"Suggest a folder structure for a meeting assistant that uses local LLMs."
```

### 3. Debugging Prompts
Use these to troubleshoot issues.
```text
"Why is this function returning None instead of a string?"
```

### 4. Explanation Prompts
Use these to learn from generated code.
```text
"Explain what this regex pattern does."
```

---

## 🧠 Context-Aware Prompting

Copilot performs better when it understands the context:
- Include relevant file names or function names
- Reference existing variables or modules
- Use comments to guide inline suggestions

### Example:
```python
# Fetch weather data from OpenWeather API
# Include error handling and logging
```

---

## 🧪 Prompt Testing

- Try multiple phrasings to compare results
- Save successful prompts in a `/prompts` folder
- Document prompt-response pairs for future reuse

---

## ✅ Recommendations

- Maintain a prompt library with categorized examples
- Use Copilot Chat for exploratory prompting
- Review and refine generated code before use

