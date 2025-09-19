# Mission Scheduling TMDL Deployment Script
# This script deploys the TMDL model to Power BI Service

param(
    [Parameter(Mandatory=$true)]
    [string]$WorkspaceId,
    
    [Parameter(Mandatory=$true)]
    [string]$DatasetName = "Mission Scheduling Dashboard",
    
    [Parameter(Mandatory=$false)]
    [string]$TmdlPath = ".\mission_scheduling_model.tmdl",
    
    [Parameter(Mandatory=$false)]
    [string]$SharePointSiteUrl = "https://armyeitaas.sharepoint-mil.us/teams/2-358ARGrizzlies"
)

Write-Host "🚀 Starting Mission Scheduling TMDL Deployment" -ForegroundColor Green

# Check if required modules are installed
$requiredModules = @("MicrosoftPowerBIMgmt", "SqlServer")

foreach ($module in $requiredModules) {
    if (!(Get-Module -ListAvailable -Name $module)) {
        Write-Host "Installing $module module..." -ForegroundColor Yellow
        Install-Module -Name $module -Force -AllowClobber
    }
    Import-Module $module
}

try {
    # Connect to Power BI Service
    Write-Host "🔐 Connecting to Power BI Service..." -ForegroundColor Cyan
    Connect-PowerBIServiceAccount

    # Verify workspace exists
    Write-Host "📁 Verifying workspace..." -ForegroundColor Cyan
    $workspace = Get-PowerBIWorkspace -Id $WorkspaceId
    if (!$workspace) {
        throw "Workspace with ID $WorkspaceId not found"
    }
    Write-Host "✅ Connected to workspace: $($workspace.Name)" -ForegroundColor Green

    # Check if TMDL file exists
    if (!(Test-Path $TmdlPath)) {
        throw "TMDL file not found at: $TmdlPath"
    }

    # Update SharePoint URLs in TMDL if different
    Write-Host "🔧 Updating SharePoint URLs in TMDL..." -ForegroundColor Cyan
    $tmdlContent = Get-Content $TmdlPath -Raw
    $updatedContent = $tmdlContent -replace 'https://armyeitaas\.sharepoint-mil\.us/teams/2-358ARGrizzlies', $SharePointSiteUrl
    $updatedContent | Set-Content $TmdlPath

    # Deploy TMDL model
    Write-Host "📊 Deploying TMDL model to Power BI..." -ForegroundColor Cyan
    
    # Create temporary folder for TMDL deployment
    $tempFolder = New-TemporaryFile | ForEach-Object { Remove-Item $_; New-Item -ItemType Directory -Path $_ }
    $modelFolder = Join-Path $tempFolder "model"
    New-Item -ItemType Directory -Path $modelFolder -Force
    
    # Copy TMDL file to model folder
    Copy-Item $TmdlPath (Join-Path $modelFolder "model.tmdl")
    
    # Use Tabular Editor or Power BI REST API to deploy
    # Note: This requires Tabular Editor CLI or custom deployment logic
    Write-Host "⚠️  Manual step required: Deploy the TMDL using Tabular Editor or Power BI Desktop" -ForegroundColor Yellow
    Write-Host "   1. Open Tabular Editor" -ForegroundColor White
    Write-Host "   2. File > Open > From Folder: $modelFolder" -ForegroundColor White
    Write-Host "   3. Model > Deploy... to workspace: $($workspace.Name)" -ForegroundColor White
    
    # Alternative: Create .pbix from TMDL (requires additional tooling)
    Write-Host "💡 Alternative: Use Power BI Desktop to import TMDL" -ForegroundColor Cyan
    Write-Host "   1. Open Power BI Desktop" -ForegroundColor White
    Write-Host "   2. External Tools > Tabular Editor" -ForegroundColor White
    Write-Host "   3. File > Open > From Folder: $modelFolder" -ForegroundColor White

    # Clean up
    Remove-Item $tempFolder -Recurse -Force

    Write-Host "✅ TMDL deployment preparation complete!" -ForegroundColor Green
    Write-Host "📍 Model location: $modelFolder" -ForegroundColor Cyan
    Write-Host "🎯 Target workspace: $($workspace.Name)" -ForegroundColor Cyan

} catch {
    Write-Error "❌ Deployment failed: $($_.Exception.Message)"
    exit 1
}

Write-Host "🎉 Mission Scheduling TMDL deployment process completed!" -ForegroundColor Green
