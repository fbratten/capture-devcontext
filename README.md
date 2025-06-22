# Capture-DevContext

**PowerShell cmdlet that captures project root into an AI-ready YAML Dev Context snapshot—hierarchy + selective file content in one shot.**

A robust, self-contained PowerShell script to scan a software project directory, capture its folder structure, and extract the content of specific source files into a single, structured YAML file.

This tool is ideal for creating comprehensive snapshots of a project's source code for AI analysis, archiving, or automated reviews.

## Features

- **No Dependencies:** The script is fully self-contained and requires no external modules like `PSYaml`.
    
- **Structured YAML Output:** Generates a clean, nested YAML file representing the project's file system.
    
- **Highly Configurable:**
    
    - Specify which file extensions to include.
        
    - Define folders and files to exclude (with wildcard support).
        
    - Limit the recursion depth of the scan.
        
- **`.gitignore` Integration:** Automatically uses the project's `.gitignore` file to determine exclusions.
    
- **Verbose Logging:** Use the `-Verbose` flag to see a detailed log of the script's execution.
    

## Requirements

- PowerShell 5.1 or later.
    

## How to Execute

To run the script, use the following syntax from your PowerShell terminal:

```
.\Capture-DevContext.ps1 -Path <path_to_project> -OutputPath <path_to_output.yml> [options]
```

### **Execution Examples**

Here are several examples for unique combinations of flags:

#### 1. Basic Scan

This is the simplest execution, using default settings for included files and exclusions.

- **Command:**
    
    ```
    .\Capture-DevContext.ps1 -Path "C:\dev\my-simple-app" -OutputPath "C:\temp\my-simple-app.yml"
    ```
    
- **What it does:**
    
    - Scans the entire `C:\dev\my-simple-app` directory.
        
    - Uses the default list of file extensions (e.g., `.js`, `.py`, `README.md`).
        
    - Uses the default exclusion list (e.g., `node_modules`, `.git`).
        
    - Saves the output to `my-simple-app.yml`. It will fail if the file already exists.
        

#### 2. Custom File Types and Exclusions with Verbose Logging

Useful for projects with non-standard file types or for when you want to see detailed output during the scan.

- **Command:**
    
    ```
    .\Capture-DevContext.ps1 -Path "C:\dev\data-science-project" -OutputPath "C:\temp\data-science.yml" -IncludeExtension ".py", ".ipynb", ".csv" -ExcludePath "venv", "data", "*.tmp" -Verbose
    ```
    
- **What it does:**
    
    - Scans `C:\dev\data-science-project`.
        
    - **Includes only** Python scripts (`.py`), Jupyter notebooks (`.ipynb`), and CSV files (`.csv`).
        
    - **Excludes** any folder named `venv` or `data`, and any file ending in `.tmp`.
        
    - The `-Verbose` flag prints detailed logs to the terminal.
        

#### 3. Using `.gitignore` and Overwriting the Output

The ideal command for scanning a Git repository, as it respects the project's own ignore rules.

- **Command:**
    
    ```
    .\Capture-DevContext.ps1 -Path "C:\dev\my-git-repo" -OutputPath "C:\temp\repo-snapshot.yml" -UseGitIgnore -Force
    ```
    
- **What it does:**
    
    - Scans `C:\dev\my-git-repo`.
        
    - The `-UseGitIgnore` flag tells the script to find and read the `.gitignore` file in the root of the project. The patterns found within are added to the exclusion list.
        
    - The `-Force` flag ensures that if `repo-snapshot.yml` already exists, it will be overwritten without asking.
        

#### 4. Limited Depth Scan

Use this when you only care about the top-level structure of a large and deeply nested project.

- **Command:**
    
    ```
    .\Capture-DevContext.ps1 -Path "C:\dev\mono-repo" -OutputPath "C:\temp\mono-repo-overview.yml" -Depth 3
    ```
    
- **What it does:**
    
    - Scans the `C:\dev\mono-repo` directory.
        
    - The `-Depth` 3 flag stops the scan three levels down from the root.
        

#### 5. Complex Combination for a Web Project

This example combines multiple flags for a finely-tuned scan of a typical web development project.

- **Command:**
    
    ```
    .\Capture-DevContext.ps1 -Path "D:\projects\ecommerce-site" -OutputPath "D:\backups\ecommerce.yml" -IncludeExtension ".js", ".html", ".css", ".json", "Dockerfile" -ExcludePath "dist", "build", "coverage" -UseGitIgnore -Force -Verbose
    ```
    
- **What it does:**
    
    - Scans `D:\projects\ecommerce-site`.
        
    - **Includes only** `.js`, `.html`, `.css`, `.json` files, and the `Dockerfile`.
        
    - **Explicitly excludes** the `dist`, `build`, and `coverage` folders while also using `.gitignore`.
        
    - Overwrites the output file (`-Force`) and prints detailed logs (`-Verbose`).

## Repository

GitHub repository: [https://github.com/fbratten/capture-devcontext](https://github.com/fbratten/capture-devcontext)
