<#
.SYNOPSIS
    Captures project root into an AI-ready YAML Dev Context snapshot—hierarchy + selective file content in one shot.

.DESCRIPTION
    This PowerShell cmdlet recursively scans a software project folder, filters for specified file types,
    reads their content, and generates a structured YAML file representing the project's layout.
    This version is self-contained and does not require any external modules.
    Run with the -Verbose switch for detailed execution logs.

.PARAMETER Path
    The root path of the project folder to scan. This parameter is mandatory.

.PARAMETER OutputPath
    The full path (including filename) for the output YAML file (e.g., C:\temp\project-snapshot.yml).
    This parameter is mandatory.

.PARAMETER IncludeExtension
    An array of file extensions to include (e.g., '.py', '.js', '.md'). If not provided, a default
    list of common source code and configuration file extensions is used.

.PARAMETER ExcludePath
    An array of folder or file names to exclude from the scan. Supports wildcards (e.g., 'node_modules', '*.log').
    A default list of common temporary/build folders is used if not provided.

.PARAMETER Depth
    The maximum folder depth to scan, relative to the root Path. If not provided, the script scans
    recursively without a depth limit.

.PARAMETER Force
    If specified, the script will overwrite the output file at -OutputPath if it already exists.

.PARAMETER UseGitIgnore
    If specified, the script will read the .gitignore file from the root of the project folder
    and add its patterns to the -ExcludePath list.

.EXAMPLE
    PS C:\> .\Capture-DevContext.ps1 -Path "C:\dev\my-simple-app" -OutputPath "C:\temp\my-simple-app.yml"
    
    This is the simplest execution. It scans the 'my-simple-app' directory using default settings for included
    files and exclusions, saving the output to 'my-simple-app.yml'.

.EXAMPLE
    PS C:\> .\Capture-DevContext.ps1 -Path "C:\dev\data-science-project" -OutputPath "C:\temp\data-science.yml" -IncludeExtension ".py", ".ipynb", ".csv" -ExcludePath "venv", "data", "*.tmp" -Verbose

    This command performs a custom scan on a data science project. It includes only Python scripts, Jupyter
    notebooks, and CSV files. It excludes the 'venv' and 'data' folders, along with temporary files.
    The -Verbose flag prints detailed execution logs.

.EXAMPLE
    PS C:\> .\Capture-DevContext.ps1 -Path "C:\dev\my-git-repo" -OutputPath "C:\temp\repo-snapshot.yml" -UseGitIgnore -Force

    This is the ideal command for scanning a Git repository. The -UseGitIgnore flag tells the script to find
    and read the .gitignore file in the project's root and add its patterns to the exclusion list. The -Force
    flag ensures that the output file is overwritten if it already exists.

.EXAMPLE
    PS C:\> .\Capture-DevContext.ps1 -Path "C:\dev\mono-repo" -OutputPath "C:\temp\mono-repo-overview.yml" -Depth 3

    This command performs a shallow scan, limiting its recursion to 3 levels deep. This is useful for getting
    a high-level overview of a large project without processing every single file.

.EXAMPLE
    PS C:\> .\Capture-DevContext.ps1 -Path "D:\projects\ecommerce-site" -OutputPath "D:\backups\ecommerce.yml" -IncludeExtension ".js", ".html", ".css", ".json", "Dockerfile" -ExcludePath "dist", "build" -UseGitIgnore -Force -Verbose

    This is a complex example for a web project. It includes only specific web-related files, explicitly excludes
    the 'dist' and 'build' folders, incorporates the .gitignore rules, overwrites any existing output file, and
    provides a full execution log.

.NOTES
    Author: Jack Bratten
    This script is self-contained and does not have external module dependencies.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = "The root path of the project folder to scan.")]
    [string]$Path,

    [Parameter(Mandatory = $true, Position = 1, HelpMessage = "The full path for the output YAML file.")]
    [string]$OutputPath,

    [Parameter(Position = 2, HelpMessage = "An array of file extensions to include.")]
    [string[]]$IncludeExtension = @(
        # Code files
        '.ps1', '.cs', '.js', '.ts', '.py', '.go', '.java', '.rb', '.php', '.html', '.css', '.scss', '.sql',
        # Configuration files
        '.json', '.xml', '.toml', '.ini', '.env',
        # Descriptive files
        'README.md', '.gitignore', 'Dockerfile', 'docker-compose.yml', '.txt'
    ),

    [Parameter(Position = 3, HelpMessage = "An array of folder or file names to exclude. Wildcards are supported.")]
    [string[]]$ExcludePath = @(
        '.git', '.vscode', '.idea',
        'node_modules', 'bower_components',
        'bin', 'obj', 'dist', 'build', 'target',
        '*.log', '*.tmp', '*.bak'
    ),

    [Parameter(Position = 4, HelpMessage = "The maximum folder depth to scan.")]
    [int]$Depth = 2147483647, # Max Int32 value effectively means no limit

    [Parameter(HelpMessage = "Overwrite the output file if it already exists.")]
    [switch]$Force,

    [Parameter(HelpMessage = "Use the .gitignore file for additional exclusions.")]
    [switch]$UseGitIgnore
)

# --- Start of Execution ---
Write-Verbose "--- Script Start: Capture-DevContext ---"
Write-Verbose "Mode: Self-contained (no external modules)."
Write-Verbose "Parameters provided:"
Write-Verbose "  - Path: $Path"
Write-Verbose "  - OutputPath: $OutputPath"
Write-Verbose "  - Depth: $Depth"
Write-Verbose "  - Force: $Force"
Write-Verbose "  - UseGitIgnore: $UseGitIgnore"
Write-Verbose "  - Included Extensions: $($IncludeExtension -join ', ')"
Write-Verbose "  - Excluded Paths: $($ExcludePath -join ', ')"

# --- Pre-flight Checks and Setup ---
Write-Verbose "Validating input path..."
if (-not (Test-Path -Path $Path -PathType Container)) {
    Write-Error "The path '$Path' does not exist or is not a directory."
    return
}
$RootPath = Resolve-Path -Path $Path
Write-Verbose "Successfully resolved root path to '$($RootPath.Path)'."

Write-Verbose "Validating output path..."
$OutputParent = Split-Path -Path $OutputPath -Parent
if (-not (Test-Path -Path $OutputParent -PathType Container)) {
    Write-Error "The output directory '$OutputParent' does not exist."
    return
}
if ((Test-Path -Path $OutputPath) -and (-not $Force)) {
    Write-Error "The output file '$OutputPath' already exists. Use the -Force switch to overwrite it."
    return
}
Write-Verbose "Output path is valid."

# --- .gitignore Handling ---
if ($UseGitIgnore) {
    $gitIgnorePath = Join-Path -Path $RootPath -ChildPath ".gitignore"
    Write-Verbose "Searching for .gitignore file at: '$gitIgnorePath'."
    if (Test-Path -Path $gitIgnorePath) {
        try {
            Write-Verbose "Reading .gitignore file..."
            $gitIgnorePatterns = Get-Content -Path $gitIgnorePath -Encoding UTF8 | Where-Object { $_.Trim() -and -not $_.Trim().StartsWith('#') }
            # Simple conversion: remove trailing slashes and convert git wildcards to PowerShell wildcards
            $pwshWildcards = $gitIgnorePatterns | ForEach-Object { $_.Trim().TrimEnd('/').TrimEnd('\').Replace('/', '\') }
            $ExcludePath += $pwshWildcards
            Write-Verbose "Added $($pwshWildcards.Count) patterns from .gitignore to the exclusion list. New Exclude List: $($ExcludePath -join ', ')"
        }
        catch {
            Write-Warning "Could not read or parse the .gitignore file. Error: $_"
        }
    }
    else {
        Write-Warning "The -UseGitIgnore switch was specified, but no .gitignore file was found at the root."
    }
}

# --- Manual YAML Conversion Function ---
function ConvertTo-ManualYaml {
    param(
        $InputObject,
        [int]$IndentLevel = 0
    )

    $indent = ' ' * ($IndentLevel * 2)
    $stringBuilder = New-Object -TypeName System.Text.StringBuilder

    foreach ($item in $InputObject) {
        $stringBuilder.AppendLine("$indent- name: '$($item.name)'") | Out-Null
        $stringBuilder.AppendLine("$($indent)  type: '$($item.type)'") | Out-Null
        $stringBuilder.AppendLine("$($indent)  path: '$($item.path)'") | Out-Null
        
        if ($item.type -eq 'file') {
            $stringBuilder.AppendLine("$($indent)  content: |") | Out-Null
            $contentLines = $item.content -split '(\r\n|\n|\r)'
            foreach ($line in $contentLines) {
                $stringBuilder.AppendLine("$($indent)    $line") | Out-Null
            }
        }
        elseif ($item.type -eq 'folder') {
            $stringBuilder.AppendLine("$($indent)  children:") | Out-Null
            if ($item.children.Count -gt 0) {
                $stringBuilder.Append((ConvertTo-ManualYaml -InputObject $item.children -IndentLevel ($IndentLevel + 2))) | Out-Null
            }
            else {
                 $stringBuilder.AppendLine("$($indent)    []") | Out-Null
            }
        }
    }
    return $stringBuilder.ToString()
}

# --- Core Processing Logic ---
function Get-DirectoryStructure {
    param(
        [string]$CurrentPath,
        [int]$CurrentDepth
    )
    
    Write-Verbose "Scanning directory: '$CurrentPath' at depth $CurrentDepth."

    if ($CurrentDepth -gt $Depth) {
        Write-Verbose "Skipping directory '$CurrentPath' because it exceeds the max depth of $Depth."
        return
    }

    $items = @()
    try {
        $childItems = Get-ChildItem -Path $CurrentPath -Force -ErrorAction Stop
        
        foreach ($item in $childItems) {
            # Check if the item should be excluded
            $isExcluded = $false
            foreach ($excludePattern in $ExcludePath) {
                if ($item.Name -like $excludePattern) {
                    Write-Verbose "Excluding '$($item.FullName)' because its name matches exclude pattern '$excludePattern'."
                    $isExcluded = $true
                    break
                }
            }
            if ($isExcluded) { continue } # Skip to the next item

            # Process the item
            $relativePath = $item.FullName.Substring($RootPath.Path.Length).TrimStart('\').TrimStart('/')
            if ($relativePath -eq "") { $relativePath = "." } else { $relativePath = "./" + $relativePath.Replace('\', '/') }

            if ($item.PSIsContainer) {
                # It's a directory
                $items += [ordered]@{
                    name     = $item.Name
                    type     = "folder"
                    path     = $relativePath
                    children = (Get-DirectoryStructure -CurrentPath $item.FullName -CurrentDepth ($CurrentDepth + 1))
                }
            }
            else {
                # It's a file, check if its extension is included
                Write-Verbose "Checking file: $($item.Name)"
                $extension = $item.Extension
                $nameMatch = $IncludeExtension -contains $item.Name
                $extMatch = $IncludeExtension -contains $extension

                if ($nameMatch -or $extMatch) {
                    Write-Verbose "Including file '$($item.Name)' due to matching name or extension."
                    $fileContent = ""
                    try {
                        $fileContent = Get-Content -Path $item.FullName -Raw -Encoding UTF8 -ErrorAction Stop
                    }
                    catch {
                        Write-Warning "Could not read content of file '$($item.FullName)'. It may be locked or you lack permissions. Error: $_"
                        $fileContent = "Error: Could not read file content."
                    }

                    $items += [ordered]@{
                        name    = $item.Name
                        type    = "file"
                        path    = $relativePath
                        content = $fileContent
                    }
                }
                else {
                    Write-Verbose "Skipping file '$($item.Name)' because its name/extension is not in the include list."
                }
            }
        }
    }
    catch {
        Write-Warning "Could not access path '$CurrentPath'. Error: $_"
    }

    return $items
}

# --- Execution ---
Write-Host "Starting project scan... (Run with -Verbose for detailed logs)"
$projectStructure = @(
    [ordered]@{
        name     = (Get-Item -Path $RootPath).Name
        type     = "folder"
        path     = "."
        children = (Get-DirectoryStructure -CurrentPath $RootPath -CurrentDepth 1)
    }
)

Write-Verbose "Project structure scan complete. Generating YAML content..."
$yamlOutput = ConvertTo-ManualYaml -InputObject $projectStructure
Write-Verbose "YAML content generated."

if ($PSCmdlet.ShouldProcess($OutputPath, "Save YAML Output")) {
    try {
        Write-Verbose "Writing YAML content to file: $OutputPath"
        Out-File -FilePath $OutputPath -InputObject $yamlOutput -Encoding utf8 -Force:$Force -ErrorAction Stop
        Write-Host "Project snapshot successfully exported to '$OutputPath'"
    }
    catch {
        Write-Error "Failed to write to output file '$OutputPath'. Error: $_"
    }
}
Write-Verbose "--- Script End ---"