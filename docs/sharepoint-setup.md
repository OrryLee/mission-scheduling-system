# SharePoint Setup Guide - Mission Scheduling System

## Prerequisites
- Access to your Battalion's SharePoint site
- Site Owner or Site Collection Administrator permissions
- Microsoft 365 Business or Enterprise license

## Phase 1: Create the SharePoint Lists

### Step 1: Navigate to Your SharePoint Site
1. Go to your Battalion's SharePoint site (e.g., `https://[tenant].sharepoint.com/sites/BattalionName`)
2. Click on **"Site contents"** in the left navigation
3. Click **"+ New"** → **"List"**

### Step 2: Create Personnel_Roster List

1. **Create the List:**
   - Click **"Blank list"**
   - Name: `Personnel_Roster`
   - Description: `Master personnel database with MOS and Rank information`
   - Click **"Create"**

2. **Add Columns:**
   - Click **"+ Add column"** for each of the following:

   | Column Name | Type | Settings |
   |-------------|------|----------|
   | DOD_ID | Single line of text | Required: Yes, Unique: Yes |
   | Last_Name | Single line of text | Required: Yes |
   | First_Name | Single line of text | Required: Yes |
   | Rank | Choice | Required: Yes, Choices: E1,E2,E3,E4,E5,E6,E7,E8,E9,O1,O2,O3,O4,O5,O6,O7,O8,O9,O10,W1,W2,W3,W4,W5 |
   | MOS | Single line of text | Required: Yes |
   | Unit | Single line of text | Required: Yes |
   | Contact_Email | Single line of text | Required: No |
   | Status | Choice | Required: Yes, Choices: Active,Inactive,Deployed, Default: Active |

3. **Add Calculated Column (Full_Name):**
   - Column Name: `Full_Name`
   - Type: Calculated
   - Formula: `=[First_Name]&" "&[Last_Name]`
   - Data type: Single line of text

### Step 3: Create Mission_Calendar List

1. **Create the List:**
   - Name: `Mission_Calendar`
   - Description: `Central repository for all mission events and assignments`

2. **Add Columns:**

   | Column Name | Type | Settings |
   |-------------|------|----------|
   | Mission_Name | Single line of text | Required: Yes |
   | Mission_Description | Multiple lines of text | Required: No |
   | Mission_Type | Choice | Required: Yes, Choices: Training,Operation,Exercise,Meeting |
   | Start_Date | Date and Time | Required: Yes, Include time: Yes |
   | End_Date | Date and Time | Required: Yes, Include time: Yes |
   | Assigned_Personnel | Lookup | Required: No, Get info from: Personnel_Roster, Column: DOD_ID |
   | Unit | Single line of text | Required: No |
   | Status | Choice | Required: Yes, Choices: Planned,Active,Completed,Cancelled, Default: Planned |
   | Priority | Choice | Required: No, Choices: High,Medium,Low, Default: Medium |
   | Location | Single line of text | Required: No |
   | Property_1 | Single line of text | Required: No |
   | Property_2 | Single line of text | Required: No |
   | Conflict_Flag | Yes/No | Required: No, Default: No |

3. **Add Calculated Column (Duration_Hours):**
   - Column Name: `Duration_Hours`
   - Type: Calculated
   - Formula: `=([End_Date]-[Start_Date])*24`
   - Data type: Number

### Step 4: Create Mission_Requirements List

1. **Create the List:**
   - Name: `Mission_Requirements`
   - Description: `Track specific MOS/Rank requirements for missions`

2. **Add Columns:**

   | Column Name | Type | Settings |
   |-------------|------|----------|
   | Mission_ID | Lookup | Required: Yes, Get info from: Mission_Calendar, Column: Title |
   | Required_MOS | Single line of text | Required: No |
   | Required_Rank | Choice | Required: No, Choices: E1,E2,E3,E4,E5,E6,E7,E8,E9,O1,O2,O3,O4,O5,O6,O7,O8,O9,O10,W1,W2,W3,W4,W5 |
   | Slots_Needed | Number | Required: Yes, Min: 1 |
   | Slots_Filled | Number | Required: No, Default: 0 |
   | Is_O2A | Yes/No | Required: No, Default: No |
   | Status | Choice | Required: Yes, Choices: Open,Filled,Overbooked, Default: Open |

### Step 5: Create Conflict_Log List

1. **Create the List:**
   - Name: `Conflict_Log`
   - Description: `Track and log scheduling conflicts`

2. **Add Columns:**

   | Column Name | Type | Settings |
   |-------------|------|----------|
   | Personnel_DOD_ID | Single line of text | Required: Yes |
   | Mission_1_ID | Lookup | Required: Yes, Get info from: Mission_Calendar, Column: Title |
   | Mission_2_ID | Lookup | Required: Yes, Get info from: Mission_Calendar, Column: Title |
   | Conflict_Type | Choice | Required: Yes, Choices: Overlap,Double-booking,Resource |
   | Conflict_Start | Date and Time | Required: Yes, Include time: Yes |
   | Conflict_End | Date and Time | Required: Yes, Include time: Yes |
   | Resolution_Status | Choice | Required: Yes, Choices: Unresolved,Resolved,Escalated, Default: Unresolved |
   | Resolution_Notes | Multiple lines of text | Required: No |
   | Resolved_Date | Date and Time | Required: No, Include time: Yes |

## Phase 2: Configure List Settings

### Step 6: Set Up List Permissions
For each list:
1. Go to **List Settings** → **Permissions for this list**
2. Click **"Stop Inheriting Permissions"**
3. Set up custom permissions:
   - **Battalion Personnel:** Read access
   - **Mission Planners/S3:** Contribute access
   - **S3 OIC/Commander:** Full Control

### Step 7: Create List Views
For **Mission_Calendar**:
1. Create view: **"Current Missions"**
   - Filter: Status = Active OR Status = Planned
   - Sort: Start_Date (ascending)

2. Create view: **"Conflicts"**
   - Filter: Conflict_Flag = Yes
   - Sort: Start_Date (ascending)

3. Create view: **"Calendar View"**
   - View format: Calendar
   - Calendar date field: Start_Date

## Phase 3: Populate Sample Data

### Step 8: Add Sample Personnel
Add 3-5 sample personnel records to test the system:

| DOD_ID | Last_Name | First_Name | Rank | MOS | Unit | Status |
|--------|-----------|------------|------|-----|------|--------|
| 1234567890 | Smith | John | SGT | 11B | Alpha Co | Active |
| 2345678901 | Johnson | Sarah | SPC | 68W | Bravo Co | Active |
| 3456789012 | Williams | Mike | SSG | 25B | HHC | Active |

### Step 9: Add Sample Missions
Add 2-3 sample missions with overlapping times to test conflict detection:

| Mission_Name | Start_Date | End_Date | Mission_Type | Assigned_Personnel |
|--------------|------------|----------|--------------|-------------------|
| Training Exercise Alpha | [Today + 1 week] 0800 | [Today + 1 week] 1700 | Training | 1234567890 |
| Medical Training | [Today + 1 week] 1400 | [Today + 1 week] 1800 | Training | 1234567890 |

## Verification Checklist

✅ All four lists created with correct columns
✅ Lookup relationships established
✅ Calculated columns working properly
✅ Sample data added successfully
✅ List permissions configured
✅ Calendar views created

## Next Steps

After completing this setup:
1. **Create Microsoft Form** (Phase 4)
2. **Configure Power Automate** for conflict detection (Phase 5)
3. **Set up Power BI connection** (Phase 6)
4. **Deploy to Teams** (Phase 7)

The SharePoint infrastructure is now ready to support the automated mission scheduling system.
