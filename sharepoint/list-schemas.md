# SharePoint Infrastructure Schema

## Overview
Based on the Excel file analysis and the adapted Planner template structure, here are the SharePoint Lists needed for the mission scheduling system.

## List 1: Personnel_Roster

**Purpose:** Master personnel database with MOS/Rank information
**List Type:** Custom List

| Column Name | Type | Required | Description |
|-------------|------|----------|-------------|
| Title | Single line of text | Yes | Auto-generated ID |
| DOD_ID | Single line of text | Yes | Department of Defense ID (Primary Key) |
| Last_Name | Single line of text | Yes | Personnel last name |
| First_Name | Single line of text | Yes | Personnel first name |
| Full_Name | Calculated | No | [First_Name] + " " + [Last_Name] |
| Rank | Choice | Yes | Military rank (E1-E9, O1-O10, W1-W5) |
| MOS | Single line of text | Yes | Military Occupational Specialty |
| Unit | Single line of text | Yes | Assigned unit |
| Contact_Email | Single line of text | No | Email address |
| Status | Choice | Yes | Active, Inactive, Deployed |
| Created | Date and Time | Auto | Auto-populated |
| Modified | Date and Time | Auto | Auto-populated |

## List 2: Mission_Calendar

**Purpose:** Central repository for all mission events and assignments
**List Type:** Custom List

| Column Name | Type | Required | Description |
|-------------|------|----------|-------------|
| Title | Single line of text | Yes | Auto-generated ID |
| Mission_Name | Single line of text | Yes | Name of the mission/event |
| Mission_Description | Multiple lines of text | No | Detailed description |
| Mission_Type | Choice | Yes | Training, Operation, Exercise, Meeting |
| Start_Date | Date and Time | Yes | Mission start date and time |
| End_Date | Date and Time | Yes | Mission end date and time |
| Duration_Hours | Calculated | No | ([End_Date] - [Start_Date]) * 24 |
| Assigned_Personnel | Lookup | No | Link to Personnel_Roster (DOD_ID) |
| Personnel_Name | Lookup | No | Display name from Personnel_Roster |
| Personnel_Rank | Lookup | No | Rank from Personnel_Roster |
| Personnel_MOS | Lookup | No | MOS from Personnel_Roster |
| Unit | Single line of text | No | Responsible unit |
| Status | Choice | Yes | Planned, Active, Completed, Cancelled |
| Priority | Choice | No | High, Medium, Low |
| Location | Single line of text | No | Mission location |
| Property_1 | Single line of text | No | Additional custom field |
| Property_2 | Single line of text | No | Additional custom field |
| Conflict_Flag | Yes/No | No | Auto-populated by Power Automate |
| Created_By | Person or Group | Auto | Form submitter |
| Created | Date and Time | Auto | Auto-populated |
| Modified | Date and Time | Auto | Auto-populated |

## List 3: Mission_Requirements

**Purpose:** Track specific MOS/Rank requirements for missions
**List Type:** Custom List

| Column Name | Type | Required | Description |
|-------------|------|----------|-------------|
| Title | Single line of text | Yes | Auto-generated ID |
| Mission_ID | Lookup | Yes | Link to Mission_Calendar |
| Required_MOS | Single line of text | No | Specific MOS requirement |
| Required_Rank | Choice | No | Minimum rank requirement |
| Slots_Needed | Number | Yes | Number of personnel needed |
| Slots_Filled | Number | No | Number of slots filled |
| Is_O2A | Yes/No | No | Open to All (MOS-nonspecific) |
| Status | Choice | Yes | Open, Filled, Overbooked |

## List 4: Conflict_Log

**Purpose:** Track and log scheduling conflicts
**List Type:** Custom List

| Column Name | Type | Required | Description |
|-------------|------|----------|-------------|
| Title | Single line of text | Yes | Auto-generated ID |
| Personnel_DOD_ID | Single line of text | Yes | Conflicted personnel |
| Mission_1_ID | Lookup | Yes | First conflicting mission |
| Mission_2_ID | Lookup | Yes | Second conflicting mission |
| Conflict_Type | Choice | Yes | Overlap, Double-booking, Resource |
| Conflict_Start | Date and Time | Yes | When conflict begins |
| Conflict_End | Date and Time | Yes | When conflict ends |
| Resolution_Status | Choice | Yes | Unresolved, Resolved, Escalated |
| Resolution_Notes | Multiple lines of text | No | How conflict was resolved |
| Detected_Date | Date and Time | Auto | When conflict was detected |
| Resolved_Date | Date and Time | No | When conflict was resolved |

## SharePoint Site Structure

```
Battalion SharePoint Site
├── Lists/
│   ├── Personnel_Roster
│   ├── Mission_Calendar  
│   ├── Mission_Requirements
│   └── Conflict_Log
├── Document Libraries/
│   ├── Forms (Microsoft Forms responses)
│   ├── Reports (Power BI exports)
│   └── Templates (Power Automate flows)
└── Pages/
    ├── Mission Dashboard (Power BI embed)
    ├── Personnel Management
    └── Conflict Resolution
```

## Relationships

1. **Personnel_Roster** ↔ **Mission_Calendar** (One-to-Many via DOD_ID)
2. **Mission_Calendar** ↔ **Mission_Requirements** (One-to-Many via Mission_ID)
3. **Mission_Calendar** ↔ **Conflict_Log** (One-to-Many via Mission_ID)

## Security and Permissions

- **Read Access:** All battalion personnel
- **Contribute Access:** Mission planners, S3 staff
- **Full Control:** S3 OIC, Battalion Commander
- **Form Submission:** All personnel (via Microsoft Form)

This schema provides the foundation for the automated mission scheduling system while maintaining data integrity and supporting the conflict detection requirements.
