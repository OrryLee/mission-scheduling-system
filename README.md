# Mission Scheduling System

An automated mission scheduling and conflict-detection system using Microsoft 365 and Power BI, designed for military units to manage personnel assignments and detect scheduling conflicts.

## 🎯 System Overview

This system provides:
- **Automated conflict detection** when personnel are double-booked
- **Real-time mission calendar** accessible to all unit personnel
- **Power BI dashboard** for operational picture visualization
- **Email notifications** for scheduling conflicts and updates
- **Microsoft Forms integration** for easy mission data entry

## 📋 CDR Requirements Met

✅ Create calendar with dummy missions, including overlapping missions  
✅ Include MOS/Rank requirements tracking  
✅ Mix of hardcoded MOS slots and MOS-nonspecific (O2A) slots  
✅ Export events automatically to Outlook calendar  
✅ Send notifications for overlapping personnel assignments  

## 🏗️ Architecture

```
Microsoft Form → SharePoint Lists → Power Automate → Power BI Dashboard
                                        ↓
                              Email Notifications & Teams Alerts
```

## 📁 Repository Structure

```
mission-scheduling-system/
├── docs/                    # Complete documentation and guides
├── sharepoint/             # SharePoint list schemas and setup scripts
├── powerbi/               # Power BI templates and DAX formulas
├── power-automate/        # Flow packages and email templates
├── forms/                 # Microsoft Forms configurations
├── sample-data/           # Test data and examples
├── scripts/               # Automation and deployment scripts
└── README.md              # This file
```

## 🚀 Quick Start

### Prerequisites
- Microsoft 365 Business/Enterprise license
- SharePoint site with owner permissions
- Power BI Pro license (for sharing)
- Power Automate license

### Installation Steps

1. **Clone this repository**
   ```bash
   git clone https://github.com/OrryLee/mission-scheduling-system.git
   cd mission-scheduling-system
   ```

2. **Set up SharePoint infrastructure**
   ```bash
   # Follow the guide in docs/sharepoint-setup.md
   ```

3. **Create Microsoft Form**
   ```bash
   # Use templates in forms/ directory
   ```

4. **Deploy Power Automate flows**
   ```bash
   # Import packages from power-automate/ directory
   ```

5. **Configure Power BI dashboard**
   ```bash
   # Open templates from powerbi/ directory
   ```

## 📖 Documentation

| Document | Description |
|----------|-------------|
| [SharePoint Setup Guide](docs/sharepoint-setup.md) | Step-by-step SharePoint configuration |
| [Power BI Configuration](docs/powerbi-setup.md) | Dashboard setup and data connections |
| [Power Automate Flows](docs/power-automate-setup.md) | Conflict detection and notifications |
| [Microsoft Forms Guide](docs/forms-setup.md) | Data entry form configuration |
| [Customization Guide](docs/customization.md) | How to modify and extend the system |

## 🔧 Customization

This system is designed to be easily customizable:

- **Unit-specific settings** in `scripts/config.json`
- **Email templates** in `power-automate/email-templates/`
- **Power BI themes** in `powerbi/themes/`
- **Form fields** in `forms/field-definitions.json`

## 📊 Sample Data

The `sample-data/` directory contains:
- Sample personnel roster
- Example mission data
- Test scenarios for conflict detection
- PowerShell scripts for bulk data import

## 🔄 Sync and Integration

### GitHub Integration
- All components version-controlled
- Branching strategy for development/production
- Automated deployment scripts

### Email Integration
- Conflict notifications
- Daily/weekly mission summaries
- Status update alerts
- Custom recipient groups

### Power BI Sync
- Real-time SharePoint connection
- Scheduled refresh (8x daily)
- Automated email reports
- Teams dashboard embedding

## 🛠️ Development

### Making Changes
1. Create a feature branch: `git checkout -b feature/new-functionality`
2. Make your changes in the appropriate directory
3. Update documentation if needed
4. Test with sample data
5. Submit pull request

### Configuration Files
- `scripts/config.json` - Main system configuration
- `sharepoint/list-schemas.json` - SharePoint list definitions
- `power-automate/flow-config.json` - Flow parameters
- `powerbi/data-sources.json` - Power BI connection settings

## 📞 Support

For issues or questions:
1. Check the documentation in `docs/`
2. Review sample configurations in `sample-data/`
3. Create an issue in this repository
4. Contact the system administrator

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📈 Version History

- **v1.0.0** - Initial release with core functionality
- **v1.1.0** - Added email notifications
- **v1.2.0** - Enhanced Power BI dashboard
- **v2.0.0** - Full automation pipeline

---

**Built for military units by leveraging proven Microsoft 365 templates and automation.**
