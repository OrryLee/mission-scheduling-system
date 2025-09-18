# Power BI Setup Guide

## Overview
This guide covers setting up the Power BI dashboard for the mission scheduling system, including data connections, visualizations, and automated refresh.

## Architecture

```
SharePoint Lists → Power BI Desktop → Power BI Service → Teams Integration
                                           ↓
                                   Automated Refresh → Email Reports
```

## Prerequisites

- Power BI Desktop (free download)
- Power BI Pro license (for sharing and scheduled refresh)
- Access to SharePoint lists
- Power BI workspace permissions

## Template Files Available

The repository includes several Power BI templates:

| File | Purpose | Source |
|------|---------|--------|
| `Planner Report with flow.pbit` | Main dashboard template | Adapted from Planner automation |
| `PlannerFromSharePoint V2.0.pbit` | SharePoint connector template | Direct SharePoint integration |
| `Planner V8.0.pbit` | Alternative layout | File-based version |
| `calendar.pq` | Advanced calendar table | M language script |
| `periods.pq` | Period calculations | M language script |
| `time.pq` | Time intelligence | M language script |

## Step 1: Set Up Data Connections

### Option A: Direct SharePoint Connection (Recommended)

1. **Open Power BI Desktop**
2. **Get Data** → **SharePoint Online List**
3. **Enter SharePoint Site URL:** `https://[tenant].sharepoint.com/sites/[battalion-name]`
4. **Select Lists:**
   - Personnel_Roster
   - Mission_Calendar
   - Mission_Requirements
   - Conflict_Log

### Option B: Using Template Files

1. **Open Template File:** `PlannerFromSharePoint V2.0.pbit`
2. **Enter Parameters:**
   - SharePoint Site URL
   - List names (if different from defaults)
3. **Sign in** with organizational account
4. **Load data** and verify connections

## Step 2: Data Transformation

### Transform Personnel Data
```m
// Clean and standardize personnel data
let
    Source = SharePoint.Tables("https://[site-url]", [ApiVersion = 15]),
    Personnel_Roster = Source{[Name="Personnel_Roster"]}[Items],
    #"Expanded Columns" = Table.ExpandRecordColumn(Personnel_Roster, "fields", 
        {"DOD_ID", "Last_Name", "First_Name", "Rank", "MOS", "Unit", "Status"}),
    #"Changed Type" = Table.TransformColumnTypes(#"Expanded Columns",{
        {"DOD_ID", type text},
        {"Last_Name", type text},
        {"First_Name", type text},
        {"Rank", type text},
        {"MOS", type text},
        {"Unit", type text},
        {"Status", type text}
    }),
    #"Added Full Name" = Table.AddColumn(#"Changed Type", "Full_Name", 
        each [First_Name] & " " & [Last_Name], type text)
in
    #"Added Full Name"
```

### Transform Mission Data
```m
// Process mission calendar data
let
    Source = SharePoint.Tables("https://[site-url]", [ApiVersion = 15]),
    Mission_Calendar = Source{[Name="Mission_Calendar"]}[Items],
    #"Expanded Columns" = Table.ExpandRecordColumn(Mission_Calendar, "fields", 
        {"Mission_Name", "Start_Date", "End_Date", "Assigned_Personnel", "Status", "Mission_Type"}),
    #"Changed Type" = Table.TransformColumnTypes(#"Expanded Columns",{
        {"Start_Date", type datetimezone},
        {"End_Date", type datetimezone},
        {"Mission_Name", type text},
        {"Status", type text},
        {"Mission_Type", type text}
    }),
    #"Added Duration" = Table.AddColumn(#"Changed Type", "Duration_Hours", 
        each Duration.TotalHours([End_Date] - [Start_Date]), type number)
in
    #"Added Duration"
```

### Add Advanced Calendar Table
1. **Create New Query** → **Blank Query**
2. **Copy calendar.pq script** from repository
3. **Paste into Advanced Editor**
4. **Configure parameters:**
   ```m
   startDate = #date(2024, 1, 1),
   yearsAhead = 2,
   startOfWeek = Day.Monday,
   language = "en-US"
   ```

## Step 3: Data Model Setup

### Create Relationships
1. **Model View** in Power BI Desktop
2. **Create relationships:**
   - `Personnel_Roster[DOD_ID]` ↔ `Mission_Calendar[Assigned_Personnel]`
   - `Mission_Calendar[ID]` ↔ `Mission_Requirements[Mission_ID]`
   - `Calendar[Date]` ↔ `Mission_Calendar[Start_Date]`

### Configure Date Table
1. **Mark Calendar table as Date Table**
2. **Table Tools** → **Mark as Date Table**
3. **Select Date Column:** `Date`

## Step 4: Create Measures (DAX)

### Basic Measures
```dax
// Total Missions
Total Missions = COUNTROWS(Mission_Calendar)

// Active Missions
Active Missions = 
CALCULATE(
    COUNTROWS(Mission_Calendar),
    Mission_Calendar[Status] IN {"Planned", "Active"}
)

// Personnel Utilization
Personnel Utilization = 
DIVIDE(
    DISTINCTCOUNT(Mission_Calendar[Assigned_Personnel]),
    DISTINCTCOUNT(Personnel_Roster[DOD_ID])
)

// Conflicts Count
Conflicts Count = COUNTROWS(Conflict_Log)
```

### Advanced Measures
```dax
// Mission Duration Average
Avg Mission Duration = 
AVERAGE(Mission_Calendar[Duration_Hours])

// Overlapping Missions (for conflict detection)
Overlapping Missions = 
VAR CurrentMissionStart = SELECTEDVALUE(Mission_Calendar[Start_Date])
VAR CurrentMissionEnd = SELECTEDVALUE(Mission_Calendar[End_Date])
VAR CurrentPersonnel = SELECTEDVALUE(Mission_Calendar[Assigned_Personnel])
RETURN
CALCULATE(
    COUNTROWS(Mission_Calendar),
    FILTER(
        Mission_Calendar,
        Mission_Calendar[Assigned_Personnel] = CurrentPersonnel &&
        Mission_Calendar[Start_Date] < CurrentMissionEnd &&
        Mission_Calendar[End_Date] > CurrentMissionStart
    )
) - 1

// Mission Status Distribution
Mission Status % = 
DIVIDE(
    COUNTROWS(Mission_Calendar),
    CALCULATE(COUNTROWS(Mission_Calendar), ALL(Mission_Calendar[Status]))
)
```

## Step 5: Create Visualizations

### Page 1: Mission Overview Dashboard

#### 1. Key Metrics Cards
- **Total Missions** (Card visual)
- **Active Missions** (Card visual)  
- **Personnel Utilization %** (Card visual)
- **Active Conflicts** (Card visual)

#### 2. Mission Calendar (Calendar Visual)
- **Visual:** Calendar by MAQ Software (free from AppSource)
- **Date Field:** Start_Date
- **Values:** Mission_Name
- **Tooltips:** Personnel, Duration, Status

#### 3. Mission Timeline (Gantt Chart)
- **Visual:** Gantt Chart by MAQ Software
- **Tasks:** Mission_Name
- **Start Date:** Start_Date
- **End Date:** End_Date
- **Resource:** Assigned_Personnel

#### 4. Personnel Workload (Bar Chart)
- **Axis:** Personnel Full_Name
- **Values:** Count of missions
- **Color:** Mission_Type

### Page 2: Conflict Analysis

#### 1. Conflict Summary Table
- **Columns:** Personnel, Mission 1, Mission 2, Conflict Type, Status
- **Filters:** Resolution_Status = "Unresolved"

#### 2. Conflict Timeline
- **Visual:** Line chart
- **Axis:** Date
- **Values:** Count of conflicts
- **Legend:** Conflict_Type

#### 3. Personnel Conflict Heatmap
- **Visual:** Matrix
- **Rows:** Personnel
- **Columns:** Date
- **Values:** Conflict indicator

### Page 3: Unit Analysis

#### 1. Mission Distribution by Unit
- **Visual:** Pie chart
- **Legend:** Unit
- **Values:** Count of missions

#### 2. MOS Utilization
- **Visual:** Bar chart
- **Axis:** MOS
- **Values:** Count of personnel assigned

#### 3. Mission Type Breakdown
- **Visual:** Donut chart
- **Legend:** Mission_Type
- **Values:** Count of missions

## Step 6: Configure Filters and Slicers

### Global Filters
1. **Date Range Slicer**
   - Field: Calendar[Date]
   - Type: Between
   - Default: Current month

2. **Unit Slicer**
   - Field: Personnel_Roster[Unit]
   - Type: Dropdown

3. **Mission Status Slicer**
   - Field: Mission_Calendar[Status]
   - Type: Checkbox

### Page-Level Filters
- **Conflict Page:** Filter to unresolved conflicts
- **Overview Page:** Filter to active/planned missions

## Step 7: Formatting and Themes

### Apply Military Theme
1. **View** → **Themes** → **Browse for themes**
2. Use colors:
   - Primary: Navy Blue (#1f3a93)
   - Secondary: Army Green (#4a5d23)
   - Accent: Gold (#ffd700)
   - Alert: Red (#d32f2f)

### Format Visuals
- **Consistent fonts:** Segoe UI
- **Professional colors:** Military color scheme
- **Clear titles:** Descriptive and actionable
- **Tooltips:** Include relevant context

## Step 8: Publish to Power BI Service

### Initial Publish
1. **File** → **Publish** → **Publish to Power BI**
2. **Select Workspace:** Create or select appropriate workspace
3. **Publish** and wait for completion

### Configure Dataset
1. **Go to Power BI Service** (app.powerbi.com)
2. **Find your dataset** in the workspace
3. **Settings** → **Data source credentials**
4. **Edit credentials** and sign in

### Set Up Scheduled Refresh
1. **Dataset Settings** → **Scheduled refresh**
2. **Configure refresh times:**
   - 6:00 AM
   - 10:00 AM  
   - 2:00 PM
   - 6:00 PM
3. **Enable refresh failure notifications**

## Step 9: Share and Embed

### Share Dashboard
1. **Share** button in Power BI Service
2. **Add email addresses** of authorized personnel
3. **Set permissions:** View only for most users
4. **Send invitation emails**

### Embed in Teams
1. **Teams Channel** → **Add a tab**
2. **Power BI** → **Select your report**
3. **Configure tab name:** "Mission Dashboard"
4. **Save** and test access

### Mobile Optimization
1. **Power BI Desktop** → **View** → **Mobile Layout**
2. **Arrange visuals** for mobile viewing
3. **Test on Power BI mobile app**

## Step 10: Monitoring and Maintenance

### Set Up Alerts
1. **Data alerts** for critical metrics
2. **Refresh failure notifications**
3. **Usage monitoring** reports

### Regular Maintenance
- **Monthly:** Review and update measures
- **Quarterly:** Assess user feedback and requirements
- **Annually:** Major updates and new features

## Customization Options

### Additional Visuals
- **Equipment utilization** tracking
- **Training completion** status
- **Leave/availability** calendar
- **Performance metrics** dashboard

### Advanced Features
- **Row-level security** for sensitive data
- **Custom visuals** for specific military needs
- **R/Python integration** for advanced analytics
- **Real-time streaming** for live updates

## Troubleshooting

### Common Issues
1. **Data refresh failures:** Check SharePoint permissions
2. **Slow performance:** Optimize DAX measures
3. **Visual errors:** Verify data types and relationships
4. **Mobile display issues:** Adjust mobile layout

### Performance Optimization
- **Use DirectQuery** for large datasets
- **Implement aggregations** for summary tables
- **Optimize DAX** calculations
- **Reduce visual complexity** where possible

## Security Considerations

- **Row-level security** for classified information
- **Workspace permissions** aligned with organizational structure
- **Data encryption** in transit and at rest
- **Regular access reviews** and permission audits

Your Power BI dashboard is now configured to provide comprehensive mission scheduling visibility with automated conflict detection and real-time updates.
