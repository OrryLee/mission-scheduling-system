# Customization Guide

## Overview
This guide explains how to customize and extend the mission scheduling system for your specific unit requirements.

## 🔧 Configuration Files

### Primary Configuration: `scripts/config.json`

This is the main configuration file that controls system behavior:

```json
{
  "system_config": {
    "unit_name": "Your Unit Name Here",
    "unit_abbreviation": "UNIT",
    "timezone": "America/New_York",
    "fiscal_year_start": "October",
    "work_week_start": "Monday"
  }
}
```

**Customizable Settings:**
- **unit_name**: Full unit designation
- **unit_abbreviation**: Short unit identifier
- **timezone**: Local timezone for scheduling
- **fiscal_year_start**: When your fiscal year begins
- **work_week_start**: First day of work week

### Email Configuration

```json
{
  "email_config": {
    "notification_sender": "s3@yourunit.mil",
    "conflict_recipients": [
      "s3@yourunit.mil",
      "commander@yourunit.mil"
    ],
    "daily_summary_recipients": [
      "s3@yourunit.mil",
      "xo@yourunit.mil"
    ]
  }
}
```

**Customization Options:**
- Add/remove email recipients
- Change notification timing
- Customize email templates
- Add SMS notifications

### Military Configuration

```json
{
  "military_config": {
    "enlisted_ranks": ["PVT", "PV2", "PFC", "SPC", "CPL", "SGT", "SSG", "SFC", "MSG", "1SG", "SGM", "CSM"],
    "officer_ranks": ["2LT", "1LT", "CPT", "MAJ", "LTC", "COL", "BG", "MG", "LTG", "GEN"],
    "common_mos": ["11B", "11C", "12B", "13B", "13F", "19D", "25B", "25U", "35F", "35S", "42A", "68W", "88M", "91B", "92G"]
  }
}
```

**Customization Options:**
- Add unit-specific MOS codes
- Include warrant officer ranks
- Add civilian positions
- Include contractor roles

## 📋 SharePoint List Customization

### Adding Custom Columns

#### Personnel_Roster Enhancements
```json
// Add to sharepoint/list-schemas.md
{
  "Security_Clearance": {
    "type": "Choice",
    "choices": ["None", "Confidential", "Secret", "Top Secret"],
    "required": false
  },
  "Deployment_Status": {
    "type": "Choice", 
    "choices": ["Available", "Deployed", "Training", "Leave"],
    "required": true
  },
  "Certification_Expiry": {
    "type": "Date",
    "required": false
  }
}
```

#### Mission_Calendar Enhancements
```json
{
  "Equipment_Required": {
    "type": "Multiple lines of text",
    "required": false
  },
  "Weather_Dependent": {
    "type": "Yes/No",
    "default": false
  },
  "Classification_Level": {
    "type": "Choice",
    "choices": ["Unclassified", "FOUO", "Confidential", "Secret"],
    "default": "Unclassified"
  }
}
```

### Creating Additional Lists

#### Equipment_Inventory List
```json
{
  "list_name": "Equipment_Inventory",
  "description": "Track equipment assignments and availability",
  "columns": {
    "Equipment_ID": {"type": "Text", "required": true},
    "Equipment_Name": {"type": "Text", "required": true},
    "Equipment_Type": {"type": "Choice", "choices": ["Vehicle", "Weapon", "Radio", "Medical", "Other"]},
    "Status": {"type": "Choice", "choices": ["Available", "In Use", "Maintenance", "Damaged"]},
    "Assigned_To": {"type": "Lookup", "source": "Personnel_Roster"},
    "Last_Maintenance": {"type": "Date"}
  }
}
```

#### Training_Records List
```json
{
  "list_name": "Training_Records",
  "description": "Track individual training completion and certifications",
  "columns": {
    "Personnel_ID": {"type": "Lookup", "source": "Personnel_Roster"},
    "Training_Name": {"type": "Text", "required": true},
    "Completion_Date": {"type": "Date", "required": true},
    "Expiry_Date": {"type": "Date"},
    "Instructor": {"type": "Text"},
    "Score": {"type": "Number"},
    "Certification_Number": {"type": "Text"}
  }
}
```

## 📝 Microsoft Forms Customization

### Adding Custom Questions

#### Equipment Requirements
```json
{
  "question": "Equipment Required",
  "type": "Choice",
  "multiple": true,
  "options": [
    "Vehicles",
    "Weapons", 
    "Radios",
    "Medical Equipment",
    "Night Vision",
    "GPS Devices"
  ]
}
```

#### Weather Considerations
```json
{
  "question": "Weather Dependent Mission",
  "type": "Yes/No",
  "subtitle": "Will this mission be cancelled due to severe weather?"
}
```

#### Classification Level
```json
{
  "question": "Classification Level",
  "type": "Choice",
  "options": ["Unclassified", "FOUO", "Confidential", "Secret"],
  "default": "Unclassified"
}
```

### Conditional Logic Examples

#### Show Equipment Details
```
IF "Equipment Required" contains "Vehicles"
THEN show "Number of Vehicles Needed"
AND show "Vehicle Type Required"
```

#### Show Training Requirements
```
IF "Mission Type" equals "Training"
THEN show "Training Objectives"
AND show "Instructor Required"
AND show "Certification Awarded"
```

## ⚡ Power Automate Customization

### Enhanced Conflict Detection

#### Equipment Conflicts
```json
{
  "trigger": "When Mission_Calendar is modified",
  "condition": "Equipment_Required is not empty",
  "action": "Check Equipment_Inventory for conflicts",
  "notification": "Send equipment conflict alert"
}
```

#### Training Prerequisites
```json
{
  "trigger": "When training mission is created",
  "condition": "Personnel lacks required certification",
  "action": "Flag training prerequisite issue",
  "notification": "Alert training coordinator"
}
```

### Custom Email Templates

#### Equipment Conflict Template
```html
<h2>🚛 Equipment Conflict Detected</h2>
<p><strong>Equipment:</strong> @{variables('EquipmentName')}</p>
<p><strong>Conflicting Missions:</strong></p>
<ul>
  <li>@{variables('Mission1')} - @{variables('Time1')}</li>
  <li>@{variables('Mission2')} - @{variables('Time2')}</li>
</ul>
<p><strong>Action Required:</strong> Reassign equipment or reschedule missions</p>
```

#### Training Reminder Template
```html
<h2>📚 Training Certification Expiring</h2>
<p><strong>Personnel:</strong> @{variables('PersonnelName')}</p>
<p><strong>Certification:</strong> @{variables('CertificationName')}</p>
<p><strong>Expiry Date:</strong> @{variables('ExpiryDate')}</p>
<p><strong>Action Required:</strong> Schedule recertification training</p>
```

## 📊 Power BI Customization

### Additional Measures

#### Equipment Utilization
```dax
Equipment Utilization % = 
DIVIDE(
    CALCULATE(DISTINCTCOUNT(Equipment_Inventory[Equipment_ID]), Equipment_Inventory[Status] = "In Use"),
    DISTINCTCOUNT(Equipment_Inventory[Equipment_ID])
)
```

#### Training Compliance
```dax
Training Compliance % = 
DIVIDE(
    CALCULATE(COUNTROWS(Training_Records), Training_Records[Expiry_Date] > TODAY()),
    COUNTROWS(Personnel_Roster)
)
```

#### Mission Readiness Score
```dax
Mission Readiness Score = 
VAR PersonnelReady = [Personnel Utilization]
VAR EquipmentReady = [Equipment Utilization %]
VAR TrainingCurrent = [Training Compliance %]
RETURN
AVERAGE({PersonnelReady, EquipmentReady, TrainingCurrent}) * 100
```

### Custom Visuals

#### Equipment Status Dashboard
```json
{
  "visual_type": "Donut Chart",
  "data": {
    "legend": "Equipment_Status",
    "values": "Count of Equipment",
    "colors": {
      "Available": "#4CAF50",
      "In Use": "#FF9800", 
      "Maintenance": "#F44336",
      "Damaged": "#9E9E9E"
    }
  }
}
```

#### Training Expiry Timeline
```json
{
  "visual_type": "Gantt Chart",
  "data": {
    "tasks": "Training_Name",
    "start_date": "Completion_Date",
    "end_date": "Expiry_Date",
    "resource": "Personnel_Name",
    "status": "Training_Status"
  }
}
```

### Custom Themes

#### Military Theme Colors
```json
{
  "name": "Military Professional",
  "colors": {
    "primary": "#1f3a93",
    "secondary": "#4a5d23", 
    "accent": "#ffd700",
    "alert": "#d32f2f",
    "success": "#388e3c",
    "warning": "#f57c00",
    "info": "#1976d2"
  }
}
```

## 🔐 Security Customization

### Row-Level Security

#### Unit-Based Security
```dax
// Users can only see their unit's data
[Unit] = USERPRINCIPALNAME()
```

#### Rank-Based Security
```dax
// Officers can see all data, NCOs see their company, soldiers see their squad
VAR UserRank = LOOKUPVALUE(Personnel_Roster[Rank], Personnel_Roster[Email], USERPRINCIPALNAME())
RETURN
SWITCH(
    TRUE(),
    UserRank IN {"2LT", "1LT", "CPT", "MAJ", "LTC", "COL"}, TRUE(),
    UserRank IN {"SGT", "SSG", "SFC", "MSG", "1SG"}, [Unit] = LOOKUPVALUE(Personnel_Roster[Unit], Personnel_Roster[Email], USERPRINCIPALNAME()),
    [Assigned_Personnel] = LOOKUPVALUE(Personnel_Roster[DOD_ID], Personnel_Roster[Email], USERPRINCIPALNAME())
)
```

### Classification Handling

#### Classified Data Filtering
```dax
// Hide classified missions from unauthorized users
VAR UserClearance = LOOKUPVALUE(Personnel_Roster[Security_Clearance], Personnel_Roster[Email], USERPRINCIPALNAME())
RETURN
SWITCH(
    UserClearance,
    "Top Secret", TRUE(),
    "Secret", [Classification_Level] <> "Top Secret",
    "Confidential", [Classification_Level] IN {"Unclassified", "FOUO", "Confidential"},
    [Classification_Level] IN {"Unclassified", "FOUO"}
)
```

## 🔄 Integration Customization

### External System Integration

#### DTMS Integration
```json
{
  "system": "Digital Training Management System",
  "integration_type": "API",
  "data_sync": [
    "Training completion records",
    "Certification status",
    "Training schedules"
  ],
  "frequency": "Daily"
}
```

#### GCSS-Army Integration
```json
{
  "system": "Global Combat Support System",
  "integration_type": "File Export/Import",
  "data_sync": [
    "Personnel assignments",
    "Equipment status",
    "Maintenance schedules"
  ],
  "frequency": "Weekly"
}
```

### Mobile App Customization

#### Power Apps Integration
```json
{
  "app_name": "Mission Scheduler Mobile",
  "features": [
    "Quick mission entry",
    "Personnel availability check",
    "Conflict notifications",
    "Offline capability"
  ],
  "data_source": "SharePoint Lists"
}
```

## 📱 Mobile Optimization

### Responsive Design
- Optimize Power BI mobile layout
- Create mobile-friendly forms
- Enable offline data entry
- Push notifications for conflicts

### Field-Friendly Features
- QR codes for quick access
- Voice-to-text for mission descriptions
- GPS location capture
- Photo attachments for mission documentation

## 🔧 Development Workflow

### Version Control
```bash
# Create feature branch
git checkout -b feature/equipment-tracking

# Make changes
# Test thoroughly
# Update documentation

# Commit changes
git add .
git commit -m "Add equipment tracking functionality"

# Push and create pull request
git push origin feature/equipment-tracking
```

### Testing Strategy
1. **Unit Testing**: Test individual components
2. **Integration Testing**: Test data flow between systems
3. **User Acceptance Testing**: Test with actual users
4. **Performance Testing**: Test with realistic data volumes

### Deployment Process
1. **Development**: Make changes in dev branch
2. **Testing**: Deploy to test environment
3. **Staging**: Deploy to staging for final validation
4. **Production**: Deploy to production environment

## 📞 Support and Maintenance

### Regular Maintenance Tasks
- **Weekly**: Review system performance and user feedback
- **Monthly**: Update documentation and training materials
- **Quarterly**: Review and update security settings
- **Annually**: Major feature updates and system optimization

### Troubleshooting Resources
- Check system logs and error messages
- Review user feedback and support tickets
- Monitor system performance metrics
- Consult Microsoft documentation and community forums

### Getting Help
1. **Documentation**: Check the docs/ directory first
2. **Community**: Search GitHub issues and discussions
3. **Microsoft Support**: For platform-specific issues
4. **Professional Services**: For major customizations

Your mission scheduling system is now fully customizable and ready to adapt to your unit's evolving requirements!
