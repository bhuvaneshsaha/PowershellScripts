$projectsOutput = "Output"
$solutionName = "Dotnet.CleanArchitecture"
$projectPath = "src/$solutionName"
$testPath = "tests/$solutionName"

# Clearn Output folder if exists
if (Test-Path $projectsOutput) {
    Remove-Item -Path $projectsOutput -Recurse -Force
}

# Create .gitignore file
dotnet new gitignore -o $projectsOutput

# Create solution and projects
dotnet new sln -n $solutionName -o $projectsOutput
Set-Location $projectsOutput
dotnet new classlib -o "$projectPath.Core"
dotnet new classlib -o "$projectPath.Application"
dotnet new classlib -o "$projectPath.Infrastructure"
dotnet new webapi -o "$projectPath.API"

# Add projects to solution
dotnet sln add "$projectPath.Core"
dotnet sln add "$projectPath.Application"
dotnet sln add "$projectPath.Infrastructure"
dotnet sln add "$projectPath.API"

# Add reference to projects
dotnet add "$projectPath.Infrastructure" reference "$projectPath.Core"
dotnet add "$projectPath.API" reference "$projectPath.Application"
dotnet add "$projectPath.Application" reference "$projectPath.Infrastructure"

dotnet add "$projectPath.Application" reference "$projectPath.Core"
dotnet add "$projectPath.Infrastructure" reference "$projectPath.Application"
dotnet add "$projectPath.API" reference "$projectPath.Infrastructure"

# Create test projects
dotnet new xunit -o "$testPath.Core.Tests"
dotnet new xunit -o "$testPath.Infrastructure.Tests"
dotnet new xunit -o "$testPath.Application.Tests"
dotnet new xunit -o "$testPath.FunctionalTests"

# Add test projects to solution
dotnet sln add "$testPath.Core.Tests"
dotnet sln add "$testPath.Application.Tests"
dotnet sln add "$testPath.Infrastructure.Tests"
dotnet sln add "$testPath.FunctionalTests"

# Add reference to test projects
dotnet add "$testPath.Core.Tests" reference "$projectPath.Core"
dotnet add "$testPath.Application.Tests" reference "$projectPath.Application"
dotnet add "$testPath.Infrastructure.Tests" reference "$projectPath.Infrastructure"
dotnet add "$testPath.FunctionalTests" reference "$projectPath.API"

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
}
else {
    # Open project in VS Code
    code .
}

Set-Location ..