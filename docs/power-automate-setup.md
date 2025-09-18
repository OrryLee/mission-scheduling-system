# Power Automate Setup Guide

## Overview
This guide covers setting up the Power Automate flows for conflict detection, email notifications, and data synchronization in the mission scheduling system.

## Flow Architecture

```
Microsoft Form Submission → Conflict Detection → SharePoint Update → Email Notifications
                                    ↓
                            Teams Channel Alert → Power BI Refresh
```

## Required Flows

### 1. Mission Conflict Detection Flow
**Trigger:** When a new form response is submitted
**Purpose:** Detect scheduling conflicts and send notifications

### 2. Daily Mission Summary Flow  
**Trigger:** Scheduled (daily at 0600)
**Purpose:** Send daily mission summary emails

### 3. Weekly Mission Report Flow
**Trigger:** Scheduled (Monday at 0800)  
**Purpose:** Send weekly mission planning reports

### 4. Power BI Refresh Flow
**Trigger:** When SharePoint list is updated
**Purpose:** Refresh Power BI dataset automatically

## Flow 1: Mission Conflict Detection

### Trigger
- **Type:** When a new response is submitted (Microsoft Forms)
- **Form:** Mission Scheduling Data Entry

### Steps

#### Step 1: Get Form Response Details
```
Action: Get response details (Microsoft Forms)
Form: Mission Scheduling Data Entry
Response ID: triggerOutputs()?['body/resourceData/responseId']
```

#### Step 2: Parse Form Data
```
Action: Compose
Inputs: 
{
  "PersonnelName": outputs('Get_response_details')?['body/r1c1d1e1f1g1h1i1j1k1l1'],
  "DODID": outputs('Get_response_details')?['body/r2c1d1e1f1g1h1i1j1k1l1'],
  "MissionName": outputs('Get_response_details')?['body/r3c1d1e1f1g1h1i1j1k1l1'],
  "StartDate": outputs('Get_response_details')?['body/r4c1d1e1f1g1h1i1j1k1l1'],
  "EndDate": outputs('Get_response_details')?['body/r5c1d1e1f1g1h1i1j1k1l1']
}
```

#### Step 3: Get Existing Missions for Personnel
```
Action: Get items (SharePoint)
Site Address: [Your SharePoint Site]
List Name: Mission_Calendar
Filter Query: Assigned_Personnel eq 'outputs('Compose')?['DODID']' and Status ne 'Completed' and Status ne 'Cancelled'
```

#### Step 4: Check for Conflicts
```
Action: Apply to each
Select an output: outputs('Get_items')?['body/value']

Inside loop:
  Condition: Check if dates overlap
  Expression: 
    and(
      less(outputs('Compose')?['StartDate'], items('Apply_to_each')?['End_Date']),
      greater(outputs('Compose')?['EndDate'], items('Apply_to_each')?['Start_Date'])
    )
```

#### Step 5: If Conflict Detected
```
Action: Send an email (V2)
To: [S3 Email], [Commander Email]
Subject: CONFLICT DETECTED - Mission Scheduling
Body: [See Email Template 1 below]

Action: Create item (SharePoint)
Site Address: [Your SharePoint Site]
List Name: Conflict_Log
Fields:
  - Personnel_DOD_ID: outputs('Compose')?['DODID']
  - Mission_1_ID: [New Mission ID]
  - Mission_2_ID: items('Apply_to_each')?['ID']
  - Conflict_Type: "Overlap"
  - Resolution_Status: "Unresolved"
```

#### Step 6: If No Conflict
```
Action: Create item (SharePoint)
Site Address: [Your SharePoint Site]
List Name: Mission_Calendar
Fields:
  - Mission_Name: outputs('Compose')?['MissionName']
  - Start_Date: outputs('Compose')?['StartDate']
  - End_Date: outputs('Compose')?['EndDate']
  - Assigned_Personnel: outputs('Compose')?['DODID']
  - Status: "Planned"
```

## Flow 2: Daily Mission Summary

### Trigger
```
Type: Recurrence
Frequency: Daily
Time: 06:00
Time zone: [Your timezone]
```

### Steps

#### Step 1: Get Today's Missions
```
Action: Get items (SharePoint)
Site Address: [Your SharePoint Site]
List Name: Mission_Calendar
Filter Query: 
  and(
    ge(Start_Date, formatDateTime(utcNow(), 'yyyy-MM-dd')),
    le(Start_Date, formatDateTime(addDays(utcNow(), 1), 'yyyy-MM-dd'))
  )
```

#### Step 2: Get Active Conflicts
```
Action: Get items (SharePoint)
Site Address: [Your SharePoint Site]
List Name: Conflict_Log
Filter Query: Resolution_Status eq 'Unresolved'
```

#### Step 3: Send Daily Summary Email
```
Action: Send an email (V2)
To: [Daily Summary Recipients]
Subject: Daily Mission Summary - formatDateTime(utcNow(), 'yyyy-MM-dd')
Body: [See Email Template 2 below]
```

## Flow 3: Weekly Mission Report

### Trigger
```
Type: Recurrence
Frequency: Weekly
Days: Monday
Time: 08:00
Time zone: [Your timezone]
```

### Steps

#### Step 1: Get This Week's Missions
```
Action: Get items (SharePoint)
Site Address: [Your SharePoint Site]
List Name: Mission_Calendar
Filter Query: 
  and(
    ge(Start_Date, formatDateTime(startOfWeek(utcNow()), 'yyyy-MM-dd')),
    le(Start_Date, formatDateTime(addDays(startOfWeek(utcNow()), 7), 'yyyy-MM-dd'))
  )
```

#### Step 2: Generate Weekly Report
```
Action: Send an email (V2)
To: [Weekly Report Recipients]
Subject: Weekly Mission Planning Report - Week of formatDateTime(startOfWeek(utcNow()), 'yyyy-MM-dd')
Body: [See Email Template 3 below]
```

## Email Templates

### Template 1: Conflict Detection Alert

```html
<h2 style="color: #d32f2f;">⚠️ MISSION SCHEDULING CONFLICT DETECTED</h2>

<p><strong>Personnel:</strong> @{outputs('Compose')?['PersonnelName']} (DOD ID: @{outputs('Compose')?['DODID']})</p>

<h3>Conflicting Missions:</h3>
<table border="1" style="border-collapse: collapse; width: 100%;">
  <tr style="background-color: #f5f5f5;">
    <th>Mission Name</th>
    <th>Start Date/Time</th>
    <th>End Date/Time</th>
    <th>Status</th>
  </tr>
  <tr>
    <td>@{outputs('Compose')?['MissionName']} (NEW)</td>
    <td>@{formatDateTime(outputs('Compose')?['StartDate'], 'yyyy-MM-dd HH:mm')}</td>
    <td>@{formatDateTime(outputs('Compose')?['EndDate'], 'yyyy-MM-dd HH:mm')}</td>
    <td style="color: #d32f2f;">CONFLICT</td>
  </tr>
  <tr>
    <td>@{items('Apply_to_each')?['Mission_Name']} (EXISTING)</td>
    <td>@{formatDateTime(items('Apply_to_each')?['Start_Date'], 'yyyy-MM-dd HH:mm')}</td>
    <td>@{formatDateTime(items('Apply_to_each')?['End_Date'], 'yyyy-MM-dd HH:mm')}</td>
    <td style="color: #d32f2f;">CONFLICT</td>
  </tr>
</table>

<h3>Required Action:</h3>
<p>Please resolve this scheduling conflict by:</p>
<ul>
  <li>Reassigning personnel to different missions</li>
  <li>Adjusting mission times</li>
  <li>Canceling one of the conflicting missions</li>
</ul>

<p><strong>Conflict logged at:</strong> @{utcNow()}</p>
<p><strong>System:</strong> Mission Scheduling System</p>

<hr>
<p><em>This is an automated message from the Mission Scheduling System. Please do not reply to this email.</em></p>
```

### Template 2: Daily Mission Summary

```html
<h2 style="color: #1976d2;">📅 Daily Mission Summary - @{formatDateTime(utcNow(), 'dddd, MMMM dd, yyyy')}</h2>

<h3>Today's Missions (@{length(outputs('Get_items')?['body/value'])} total)</h3>

@{if(greater(length(outputs('Get_items')?['body/value']), 0), 
  '<table border="1" style="border-collapse: collapse; width: 100%;">
    <tr style="background-color: #e3f2fd;">
      <th>Mission Name</th>
      <th>Time</th>
      <th>Personnel</th>
      <th>Status</th>
    </tr>', 
  '<p>No missions scheduled for today.</p>')}

<!-- Mission details will be populated by the flow -->

<h3>Active Conflicts (@{length(outputs('Get_items_2')?['body/value'])} total)</h3>

@{if(greater(length(outputs('Get_items_2')?['body/value']), 0), 
  '<p style="color: #d32f2f;"><strong>⚠️ There are unresolved scheduling conflicts that require attention.</strong></p>', 
  '<p style="color: #388e3c;">✅ No active scheduling conflicts.</p>')}

<h3>Quick Stats</h3>
<ul>
  <li><strong>Missions Today:</strong> @{length(outputs('Get_items')?['body/value'])}</li>
  <li><strong>Personnel Assigned:</strong> [Calculated in flow]</li>
  <li><strong>Active Conflicts:</strong> @{length(outputs('Get_items_2')?['body/value'])}</li>
</ul>

<hr>
<p><strong>Generated:</strong> @{formatDateTime(utcNow(), 'yyyy-MM-dd HH:mm')} UTC</p>
<p><em>This is an automated daily summary from the Mission Scheduling System.</em></p>
```

### Template 3: Weekly Mission Report

```html
<h2 style="color: #388e3c;">📊 Weekly Mission Planning Report</h2>
<h3>Week of @{formatDateTime(startOfWeek(utcNow()), 'MMMM dd')} - @{formatDateTime(addDays(startOfWeek(utcNow()), 6), 'MMMM dd, yyyy')}</h3>

<h3>Mission Overview</h3>
<table border="1" style="border-collapse: collapse; width: 100%;">
  <tr style="background-color: #e8f5e8;">
    <th>Day</th>
    <th>Missions</th>
    <th>Personnel</th>
    <th>Status</th>
  </tr>
  <!-- Weekly breakdown will be populated by the flow -->
</table>

<h3>Key Metrics</h3>
<ul>
  <li><strong>Total Missions This Week:</strong> [Calculated]</li>
  <li><strong>Personnel Utilization:</strong> [Calculated]</li>
  <li><strong>Mission Types:</strong> [Breakdown by type]</li>
  <li><strong>Conflicts Resolved:</strong> [Count]</li>
</ul>

<h3>Upcoming Week Preview</h3>
<p>Next week's mission planning should consider:</p>
<ul>
  <li>Personnel availability</li>
  <li>Equipment requirements</li>
  <li>Training schedules</li>
</ul>

<hr>
<p><strong>Report Generated:</strong> @{formatDateTime(utcNow(), 'yyyy-MM-dd HH:mm')} UTC</p>
<p><em>Weekly report from the Mission Scheduling System.</em></p>
```

## Deployment Steps

### Step 1: Import Flow Packages
1. Go to [flow.microsoft.com](https://flow.microsoft.com)
2. Click **"My flows"** → **"Import"**
3. Upload the flow package files from the `power-automate/` directory
4. Configure connections for:
   - Microsoft Forms
   - SharePoint
   - Office 365 Outlook
   - Microsoft Teams (optional)

### Step 2: Update Connection References
For each imported flow:
1. Edit the flow
2. Update SharePoint site URLs
3. Update form IDs
4. Update email addresses
5. Test each step

### Step 3: Configure Email Recipients
Edit the `config.json` file to set:
- Conflict notification recipients
- Daily summary recipients  
- Weekly report recipients
- Sender email addresses

### Step 4: Test Flows
1. Submit test form responses
2. Verify conflict detection works
3. Check email formatting
4. Test scheduled flows
5. Monitor flow run history

### Step 5: Enable Flows
1. Turn on all flows
2. Set up monitoring and alerts
3. Train personnel on the system
4. Document any customizations

## Customization Options

### Additional Triggers
- **Equipment conflicts:** Check for equipment double-booking
- **Location conflicts:** Detect facility scheduling conflicts  
- **Training requirements:** Alert for certification expirations

### Enhanced Notifications
- **SMS alerts:** For critical conflicts
- **Teams channel posts:** For team-specific notifications
- **Mobile push notifications:** Via Power Apps

### Advanced Logic
- **Approval workflows:** Require approval for high-priority missions
- **Automatic resolution:** Suggest alternative times/personnel
- **Escalation rules:** Auto-escalate unresolved conflicts

## Troubleshooting

### Common Issues
1. **Flow failures:** Check connection permissions
2. **Email not sending:** Verify SMTP settings
3. **SharePoint errors:** Check list permissions
4. **Date formatting:** Ensure consistent timezone handling

### Monitoring
- Set up flow failure alerts
- Monitor run history regularly
- Check email delivery reports
- Review conflict resolution metrics

## Security Considerations

- Flows run with creator's permissions
- Sensitive data is encrypted
- Access logs are maintained
- Regular permission audits recommended

The Power Automate flows are now configured to provide automated conflict detection and comprehensive email notifications for your mission scheduling system.
