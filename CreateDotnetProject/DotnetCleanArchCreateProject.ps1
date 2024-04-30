$projectsOutput = "Output"
$solutionName = "Dotnet.CleanArchitecture"
$projectPath = "src/$solutionName"
$testPath = "tests/$solutionName"

# Clearn Output folder if exists
if (Test-Path $projectsOutput) {
    Remove-Item -Path $projectsOutput -Recurse -Force
}

# Create solution and projects
dotnet new sln -n $solutionName -o $projectsOutput
Set-Location $projectsOutput
dotnet new classlib -o "$projectPath.Core"
dotnet new classlib -o "$projectPath.Infrastructure"
dotnet new classlib -o "$projectPath.Applications"
dotnet new webapi -o "$projectPath.Api"

# Add projects to solution
dotnet sln add "$projectPath.Core"
dotnet sln add "$projectPath.Infrastructure"
dotnet sln add "$projectPath.Applications"
dotnet sln add "$projectPath.Api"

# Add reference to projects
dotnet add "$projectPath.Infrastructure" reference "$projectPath.Core"
dotnet add "$projectPath.Applications" reference "$projectPath.Infrastructure"
dotnet add "$projectPath.Api" reference "$projectPath.Applications"

# Create test projects
dotnet new xunit -o "$testPath.Core.Tests"
dotnet new xunit -o "$testPath.Infrastructure.Tests"
dotnet new xunit -o "$testPath.Applications.Tests"
dotnet new xunit -o "$testPath.FunctionalTests"

# Add test projects to solution
dotnet sln add "$testPath.Core.Tests"
dotnet sln add "$testPath.Infrastructure.Tests"
dotnet sln add "$testPath.Applications.Tests"
dotnet sln add "$testPath.FunctionalTests"

# Add reference to test projects
dotnet add "$testPath.Core.Tests" reference "$projectPath.Core"
dotnet add "$testPath.Infrastructure.Tests" reference "$projectPath.Infrastructure"
dotnet add "$testPath.Applications.Tests" reference "$projectPath.Applications"
dotnet add "$testPath.FunctionalTests" reference "$projectPath.Api"

# Modify Project name in the README.md and Copy README.md to project root
Set-Location ..
Copy-Item "README.md" "$projectsOutput/README.md"
Set-Location $projectsOutput
$readmePath = "README.md"
$readmeContent = Get-Content $readmePath
$readmeContent = $readmeContent -replace "<project-path>", $projectPath
Set-Content $readmePath $readmeContent

# Check VS Code is installed
$vsCode = Get-Command code -ErrorAction SilentlyContinue
if ($null -eq $vsCode) {
    Write-Host "Visual Studio Code is not installed. Please install it to open the project."
} else {
    # Open project in VS Code
    code .
}

Set-Location ..