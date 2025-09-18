# Microsoft Forms Setup Guide

## Overview
This guide walks through creating the Microsoft Form that feeds data into the SharePoint lists for the mission scheduling system.

## Form Structure

Based on your Excel template analysis, the form should capture the following fields:

### Required Fields

1. **Personnel Name**
   - Type: Text
   - Required: Yes
   - Description: "Enter the full name of the assigned personnel"

2. **DOD ID**
   - Type: Text
   - Required: Yes
   - Description: "Enter the 10-digit Department of Defense ID number"
   - Validation: Must be exactly 10 digits

3. **Mission/Event Name**
   - Type: Text
   - Required: Yes
   - Description: "Enter a descriptive name for the mission or event"

4. **Mission Start Date & Time**
   - Type: Date
   - Required: Yes
   - Include Time: Yes
   - Description: "Select the mission start date and time"

5. **Mission End Date & Time**
   - Type: Date
   - Required: Yes
   - Include Time: Yes
   - Description: "Select the mission end date and time"

### Optional Fields

6. **Mission Description**
   - Type: Long Text
   - Required: No
   - Description: "Provide additional details about the mission"

7. **Mission Type**
   - Type: Choice (Dropdown)
   - Required: No
   - Options: Training, Operation, Exercise, Maintenance, Administrative, Leave/Pass, Medical, Education
   - Description: "Select the type of mission or event"

8. **Unit**
   - Type: Text
   - Required: No
   - Description: "Enter the responsible unit (e.g., Alpha Company, HHC)"

9. **Location**
   - Type: Text
   - Required: No
   - Description: "Enter the mission location"

10. **Priority**
    - Type: Choice (Dropdown)
    - Required: No
    - Options: High, Medium, Low
    - Default: Medium
    - Description: "Select the mission priority level"

11. **Additional Property 1**
    - Type: Text
    - Required: No
    - Description: "Additional custom field for unit-specific requirements"

12. **Additional Property 2**
    - Type: Text
    - Required: No
    - Description: "Additional custom field for unit-specific requirements"

## Step-by-Step Form Creation

### Step 1: Create New Form
1. Go to [forms.microsoft.com](https://forms.microsoft.com)
2. Click **"New Form"**
3. Title: **"Mission Scheduling Data Entry"**
4. Description: **"Use this form to submit new mission assignments and personnel scheduling information."**

### Step 2: Add Questions

For each field above, click **"+ Add new"** and select the appropriate question type:

#### Personnel Name
```
Question: Personnel Name
Type: Text
Settings: Required
Subtitle: Enter the full name of the assigned personnel
```

#### DOD ID
```
Question: DOD ID
Type: Text
Settings: Required
Subtitle: Enter the 10-digit Department of Defense ID number
Restrictions: Text → Contains → Numbers only
```

#### Mission/Event Name
```
Question: Mission/Event Name
Type: Text
Settings: Required
Subtitle: Enter a descriptive name for the mission or event
```

#### Mission Start Date & Time
```
Question: Mission Start Date & Time
Type: Date
Settings: Required, Include time
Subtitle: Select the mission start date and time
```

#### Mission End Date & Time
```
Question: Mission End Date & Time
Type: Date
Settings: Required, Include time
Subtitle: Select the mission end date and time
```

#### Mission Description
```
Question: Mission Description
Type: Text
Settings: Long answer
Subtitle: Provide additional details about the mission (optional)
```

#### Mission Type
```
Question: Mission Type
Type: Choice
Options: Training, Operation, Exercise, Maintenance, Administrative, Leave/Pass, Medical, Education
Settings: Dropdown
Subtitle: Select the type of mission or event (optional)
```

#### Unit
```
Question: Unit
Type: Text
Subtitle: Enter the responsible unit (e.g., Alpha Company, HHC) - optional
```

#### Location
```
Question: Location
Type: Text
Subtitle: Enter the mission location (optional)
```

#### Priority
```
Question: Priority
Type: Choice
Options: High, Medium, Low
Settings: Dropdown, Default value: Medium
Subtitle: Select the mission priority level (optional)
```

### Step 3: Configure Form Settings

1. Click **"Settings"** (gear icon)
2. **Response options:**
   - ✅ Record name
   - ✅ One response per person
   - ✅ Start date and end date

3. **Who can fill out this form:**
   - Select **"People in my organization"**

4. **Response receipts:**
   - ✅ Send email receipt to respondents

### Step 4: Customize Theme and Branding

1. Click **"Theme"**
2. Choose a professional theme (recommend: Blue or Green)
3. Add unit logo if available
4. Customize header image if desired

### Step 5: Test the Form

1. Click **"Preview"**
2. Fill out the form with sample data
3. Verify all fields work correctly
4. Check date/time functionality
5. Test validation rules

### Step 6: Share the Form

1. Click **"Share"**
2. Copy the form link
3. Share with unit personnel via:
   - Email
   - Teams channel
   - Unit website
   - QR code (for mobile access)

## Integration with SharePoint

### Automatic Response Collection
- Form responses are automatically saved to an Excel file
- This Excel file can be stored in SharePoint
- Power Automate will monitor for new responses

### Response File Location
1. Go to **"Responses"** tab in Forms
2. Click **"Open in Excel"**
3. Save the Excel file to your SharePoint site
4. Note the file path for Power Automate configuration

## Form Validation Rules

Add these validation rules to ensure data quality:

### DOD ID Validation
- **Rule:** Text contains numbers only
- **Length:** Exactly 10 characters
- **Error message:** "DOD ID must be exactly 10 digits"

### Date Validation
- **Rule:** End date must be after start date
- **Error message:** "Mission end date must be after start date"

### Name Validation
- **Rule:** Required field
- **Error message:** "Personnel name is required"

## Customization Options

### Unit-Specific Fields
Modify the form based on your unit's needs:
- Add MOS field if not using personnel lookup
- Add rank field if needed
- Include equipment requirements
- Add approval workflow fields

### Conditional Logic
Set up branching logic:
- Show additional fields based on mission type
- Require different information for different priorities
- Hide/show fields based on user role

## Mobile Optimization

The form is automatically mobile-friendly, but consider:
- Keep question text concise
- Use dropdown choices instead of long text where possible
- Test on mobile devices
- Provide QR code for easy mobile access

## Security Considerations

- Form is restricted to organization members only
- Responses are encrypted in transit and at rest
- Access logs are maintained
- Integration with Azure AD for authentication

## Troubleshooting

### Common Issues
1. **Date fields not working:** Ensure browser supports HTML5 date inputs
2. **Validation errors:** Check field requirements and restrictions
3. **Mobile display issues:** Test on different devices and browsers
4. **Permission errors:** Verify organization settings allow form creation

### Support Resources
- Microsoft Forms documentation
- Organization IT support
- Form analytics and response monitoring

## Next Steps

After form creation:
1. **Test thoroughly** with sample data
2. **Train personnel** on form usage
3. **Set up Power Automate** integration
4. **Monitor responses** and adjust as needed
5. **Gather feedback** and iterate

The form is now ready to collect mission scheduling data that will feed into your automated conflict detection and Power BI dashboard system.
