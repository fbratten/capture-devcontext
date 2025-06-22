# 📦 Capture-DevContext

[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue?logo=powershell)](https://docs.microsoft.com/en-us/powershell/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub release](https://img.shields.io/github/release/fbratten/capture-devcontext.svg)](https://github.com/fbratten/capture-devcontext/releases)
[![GitHub stars](https://img.shields.io/github/stars/fbratten/capture-devcontext.svg)](https://github.com/fbratten/capture-devcontext/stargazers)

> **PowerShell cmdlet that captures project root into an AI-ready YAML Dev Context snapshot-hierarchy + selective file content in one shot.**

A robust, self-contained PowerShell script that scans software project directories, captures folder structures, and extracts file content into a structured YAML file. Perfect for creating comprehensive project snapshots for AI analysis, code reviews, or documentation.

---

## 📋 Table of Contents

- [✨ Features](#-features)
- [⚡ Quick Start](#-quick-start)
- [📋 Requirements](#-requirements)
- [🚀 Usage](#-usage)
- [📖 Examples](#-examples)
- [⚙️ Parameters](#️-parameters)
- [🤝 Contributing](#-contributing)
- [📄 License](#-license)

---

## ✨ Features

🔧 **No Dependencies:** Fully self-contained - no external modules like `PSYaml` required

📁 **Structured YAML Output:** Clean, nested YAML representing your project's file system

⚙️ **Highly Configurable:**
   - 📂 Specify which file extensions to include
   - 🚫 Define folders and files to exclude (with wildcard support)
   - 📏 Limit recursion depth for large projects

🔍 **`.gitignore` Integration:** Automatically respects your project's `.gitignore` rules

📝 **Verbose Logging:** Detailed execution logs with the `-Verbose` flag

🎯 **AI-Ready Format:** Optimized output structure for AI analysis and processing

---

## ⚡ Quick Start

```powershell
# Basic usage - scan a project and create YAML snapshot
.\Capture-DevContext.ps1 -Path "C:\my-project" -OutputPath "C:\temp\project-snapshot.yml"

# Advanced usage - with .gitignore integration and custom filters
.\Capture-DevContext.ps1 -Path "C:\my-repo" -OutputPath "snapshot.yml" -UseGitIgnore -Force -Verbose
```

---

## 📋 Requirements

- 🖥️ **PowerShell 5.1** or later
- 🪟 **Windows, macOS, or Linux** (PowerShell Core supported)

---

## 🚀 Usage

```powershell
.\Capture-DevContext.ps1 -Path <path_to_project> -OutputPath <output_file.yml> [options]
```

---

## 📖 Examples

### 🔰 1. Basic Scan

Simple execution with default settings:

```powershell
.\Capture-DevContext.ps1 -Path "C:\dev\my-app" -OutputPath "C:\temp\my-app.yml"
```

**What it does:**
- 📂 Scans the entire `my-app` directory
- 📋 Uses default file extensions (`.js`, `.py`, `README.md`, etc.)
- 🚫 Uses default exclusions (`node_modules`, `.git`, etc.)
- 💾 Saves output to `my-app.yml`

### 🎯 2. Custom File Types with Verbose Logging

Perfect for specialized projects:

```powershell
.\Capture-DevContext.ps1 -Path "C:\dev\data-science-project" -OutputPath "C:\temp\data-science.yml" -IncludeExtension ".py", ".ipynb", ".csv" -ExcludePath "venv", "data", "*.tmp" -Verbose
```

**What it does:**
- 🐍 **Includes only:** Python scripts, Jupyter notebooks, CSV files
- 🚫 **Excludes:** `venv`, `data` folders, and `*.tmp` files
- 📊 **Verbose logging:** Detailed execution information

### 🔄 3. Git Repository Scan (Recommended)

Ideal for Git repositories:

```powershell
.\Capture-DevContext.ps1 -Path "C:\dev\my-repo" -OutputPath "C:\temp\repo-snapshot.yml" -UseGitIgnore -Force
```

**What it does:**
- 📂 Scans Git repository
- 🔍 **Reads `.gitignore`** and adds patterns to exclusions
- 💪 **Force flag:** Overwrites existing output file

### 📏 4. Shallow Scan for Large Projects

High-level overview of complex projects:

```powershell
.\Capture-DevContext.ps1 -Path "C:\dev\mono-repo" -OutputPath "C:\temp\overview.yml" -Depth 3
```

**What it does:**
- 📊 **Depth limit:** Only scans 3 levels deep
- ⚡ **Fast execution:** Perfect for large, nested projects

### 🌐 5. Web Project with Custom Configuration

Comprehensive example for web development:

```powershell
.\Capture-DevContext.ps1 -Path "D:\projects\ecommerce-site" -OutputPath "D:\backups\ecommerce.yml" -IncludeExtension ".js", ".html", ".css", ".json", "Dockerfile" -ExcludePath "dist", "build", "coverage" -UseGitIgnore -Force -Verbose
```

**What it does:**
- 🌐 **Web-focused:** Includes web files (JS, HTML, CSS, JSON, Dockerfile)
- 🚫 **Smart exclusions:** Skips build directories + `.gitignore` patterns
- 📊 **Full logging:** Complete execution details
- 💪 **Force overwrite:** Replaces existing files

---

## ⚙️ Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `-Path` | String | ✅ | Root path of the project to scan |
| `-OutputPath` | String | ✅ | Full path for the output YAML file |
| `-IncludeExtension` | String[] | ❌ | File extensions to include (default: common code files) |
| `-ExcludePath` | String[] | ❌ | Folders/files to exclude (supports wildcards) |
| `-Depth` | Int | ❌ | Maximum recursion depth (default: unlimited) |
| `-Force` | Switch | ❌ | Overwrite existing output file |
| `-UseGitIgnore` | Switch | ❌ | Include `.gitignore` patterns in exclusions |
| `-Verbose` | Switch | ❌ | Enable detailed logging |

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. 🍴 **Fork** the repository
2. 🌿 **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. 📝 **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. 📤 **Push** to the branch (`git push origin feature/amazing-feature`)
5. 🔄 **Open** a Pull Request

### 🐛 Reporting Issues

Found a bug? Please open an [issue](https://github.com/fbratten/capture-devcontext/issues) with:
- 🖥️ **Environment:** PowerShell version, OS
- 📝 **Description:** What happened vs. what you expected
- 🔄 **Steps:** How to reproduce the issue

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

## 🔗 Links

- 📦 **Repository:** [https://github.com/fbratten/capture-devcontext](https://github.com/fbratten/capture-devcontext)
- 📋 **Issues:** [Report bugs or request features](https://github.com/fbratten/capture-devcontext/issues)
- 📖 **Wiki:** [Documentation and guides](https://github.com/fbratten/capture-devcontext/wiki)

---

<p align="center">
  <strong>⭐ If this project helped you, please consider giving it a star! ⭐</strong>
</p>
