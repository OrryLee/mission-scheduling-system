# Mission Scheduling System Deployment Script
# PowerShell script to automate the deployment process

param(
    [Parameter(Mandatory=$true)]
    [string]$SharePointSiteUrl,
    
    [Parameter(Mandatory=$true)]
    [string]$UnitName,
    
    [Parameter(Mandatory=$false)]
    [string]$ConfigFile = "config.json"
)

Write-Host "🚀 Mission Scheduling System Deployment" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green

# Load configuration
if (Test-Path $ConfigFile) {
    $config = Get-Content $ConfigFile | ConvertFrom-Json
    Write-Host "✅ Configuration loaded from $ConfigFile" -ForegroundColor Green
} else {
    Write-Host "❌ Configuration file not found: $ConfigFile" -ForegroundColor Red
    exit 1
}

# Update configuration with provided parameters
$config.system_config.unit_name = $UnitName
$config.sharepoint_config.site_url = $SharePointSiteUrl

Write-Host "📋 Deployment Configuration:" -ForegroundColor Cyan
Write-Host "   Unit Name: $UnitName" -ForegroundColor White
Write-Host "   SharePoint Site: $SharePointSiteUrl" -ForegroundColor White

# Function to create SharePoint lists
function New-SharePointList {
    param(
        [string]$SiteUrl,
        [string]$ListName,
        [string]$Description,
        [hashtable]$Columns
    )
    
    Write-Host "📝 Creating SharePoint list: $ListName" -ForegroundColor Yellow
    
    # This would use PnP PowerShell in a real deployment
    # Install-Module PnP.PowerShell -Force -AllowClobber
    # Connect-PnPOnline -Url $SiteUrl -Interactive
    
    Write-Host "   ⚠️  Manual step required: Create list '$ListName' in SharePoint" -ForegroundColor Yellow
    Write-Host "   📖 See docs/sharepoint-setup.md for detailed instructions" -ForegroundColor White
}

# Function to import sample data
function Import-SampleData {
    param(
        [string]$DataFile,
        [string]$ListName
    )
    
    if (Test-Path $DataFile) {
        Write-Host "📊 Sample data available: $DataFile → $ListName" -ForegroundColor Yellow
        Write-Host "   ⚠️  Manual step required: Import data to SharePoint list" -ForegroundColor Yellow
    } else {
        Write-Host "❌ Sample data file not found: $DataFile" -ForegroundColor Red
    }
}

# Step 1: Validate prerequisites
Write-Host "`n🔍 Step 1: Validating Prerequisites" -ForegroundColor Cyan

$prerequisites = @(
    "Microsoft 365 Business/Enterprise license",
    "SharePoint site owner permissions", 
    "Power BI Pro license",
    "Power Automate license"
)

foreach ($prereq in $prerequisites) {
    Write-Host "   ⚠️  Ensure you have: $prereq" -ForegroundColor Yellow
}

# Step 2: SharePoint Lists Setup
Write-Host "`n📋 Step 2: SharePoint Lists Setup" -ForegroundColor Cyan

$lists = @{
    "Personnel_Roster" = "Master personnel database with MOS and Rank information"
    "Mission_Calendar" = "Central repository for all mission events and assignments"
    "Mission_Requirements" = "Track specific MOS/Rank requirements for missions"
    "Conflict_Log" = "Track and log scheduling conflicts"
}

foreach ($list in $lists.GetEnumerator()) {
    New-SharePointList -SiteUrl $SharePointSiteUrl -ListName $list.Key -Description $list.Value -Columns @{}
}

# Step 3: Sample Data Import
Write-Host "`n📊 Step 3: Sample Data Preparation" -ForegroundColor Cyan

Import-SampleData -DataFile "sample-data/sample-personnel.csv" -ListName "Personnel_Roster"
Import-SampleData -DataFile "sample-data/sample-missions.csv" -ListName "Mission_Calendar"

# Step 4: Power BI Template Setup
Write-Host "`n📈 Step 4: Power BI Template Setup" -ForegroundColor Cyan

$powerBITemplates = @(
    "powerbi/Planner Report with flow.pbit",
    "powerbi/PlannerFromSharePoint V2.0.pbit"
)

foreach ($template in $powerBITemplates) {
    if (Test-Path $template) {
        Write-Host "   📊 Power BI template available: $template" -ForegroundColor Green
        Write-Host "   📖 See docs/powerbi-setup.md for configuration instructions" -ForegroundColor White
    } else {
        Write-Host "   ❌ Template not found: $template" -ForegroundColor Red
    }
}

# Step 5: Power Automate Flows
Write-Host "`n⚡ Step 5: Power Automate Flows" -ForegroundColor Cyan

$flowPackages = Get-ChildItem "power-automate/*.zip" -ErrorAction SilentlyContinue

if ($flowPackages) {
    foreach ($package in $flowPackages) {
        Write-Host "   📦 Flow package available: $($package.Name)" -ForegroundColor Green
    }
    Write-Host "   📖 See docs/power-automate-setup.md for import instructions" -ForegroundColor White
} else {
    Write-Host "   ❌ No flow packages found in power-automate directory" -ForegroundColor Red
}

# Step 6: Microsoft Forms
Write-Host "`n📝 Step 6: Microsoft Forms Setup" -ForegroundColor Cyan
Write-Host "   📖 See docs/forms-setup.md for form creation instructions" -ForegroundColor White
Write-Host "   🎯 Form will capture data matching your Excel template structure" -ForegroundColor Green

# Step 7: Configuration Update
Write-Host "`n⚙️  Step 7: Updating Configuration" -ForegroundColor Cyan

$config | ConvertTo-Json -Depth 10 | Set-Content $ConfigFile
Write-Host "   ✅ Configuration updated with deployment parameters" -ForegroundColor Green

# Step 8: Next Steps
Write-Host "`n🎯 Step 8: Next Steps" -ForegroundColor Cyan

$nextSteps = @(
    "1. Complete SharePoint list creation using docs/sharepoint-setup.md",
    "2. Import sample data to test the system",
    "3. Create Microsoft Form using docs/forms-setup.md", 
    "4. Import Power Automate flows using docs/power-automate-setup.md",
    "5. Configure Power BI dashboard using docs/powerbi-setup.md",
    "6. Test the complete workflow with sample data",
    "7. Train personnel on system usage",
    "8. Deploy to production environment"
)

foreach ($step in $nextSteps) {
    Write-Host "   $step" -ForegroundColor White
}

# Summary
Write-Host "`n✅ Deployment Preparation Complete!" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green
Write-Host "📁 All files are ready in the repository structure" -ForegroundColor White
Write-Host "📖 Follow the documentation in the docs/ directory" -ForegroundColor White
Write-Host "🔧 Customize using the configuration files in scripts/" -ForegroundColor White
Write-Host "📊 Test with sample data in sample-data/" -ForegroundColor White

Write-Host "`n🚀 Your mission scheduling system is ready for deployment!" -ForegroundColor Green
