# Calendar Background Setup Script for Power BI
# Creates custom calendar visual with military-themed background and proper parameters

param(
    [Parameter(Mandatory=$false)]
    [string]$BackgroundColor = "#2C3E50",  # Dark blue-gray military theme
    
    [Parameter(Mandatory=$false)]
    [string]$HeaderColor = "#34495E",      # Darker header
    
    [Parameter(Mandatory=$false)]
    [string]$TextColor = "#FFFFFF",        # White text
    
    [Parameter(Mandatory=$false)]
    [string]$AccentColor = "#E74C3C",      # Red accent for alerts/conflicts
    
    [Parameter(Mandatory=$false)]
    [string]$GridColor = "#7F8C8D",        # Gray grid lines
    
    [Parameter(Mandatory=$false)]
    [string]$UnitName = "2-358 AR Grizzlies",
    
    [Parameter(Mandatory=$false)]
    [string]$CalendarTitle = "Mission Scheduling Calendar",
    
    [Parameter(Mandatory=$false)]
    [hashtable]$StatusColors = @{
        "Planned" = "#F39C12"    # Orange
        "Active" = "#27AE60"     # Green  
        "Completed" = "#3498DB"  # Blue
        "Cancelled" = "#E74C3C"  # Red
        "Conflict" = "#8E44AD"   # Purple
    },
    
    [Parameter(Mandatory=$false)]
    [hashtable]$EventTypeColors = @{
        "Training" = "#16A085"      # Teal
        "Operation" = "#E67E22"     # Orange
        "Exercise" = "#9B59B6"      # Purple
        "Maintenance" = "#F1C40F"   # Yellow
        "Administrative" = "#95A5A6" # Gray
    }
)

Write-Host "🎨 Setting up Calendar Background Configuration" -ForegroundColor Green

# Create calendar theme configuration
$calendarTheme = @{
    "name" = "Military Calendar Theme"
    "version" = "1.0.0"
    "description" = "Military-themed calendar for mission scheduling"
    "theme" = @{
        "background" = @{
            "color" = $BackgroundColor
            "gradient" = @{
                "enabled" = $true
                "direction" = "vertical"
                "colors" = @($BackgroundColor, "#34495E")
            }
        }
        "header" = @{
            "backgroundColor" = $HeaderColor
            "textColor" = $TextColor
            "fontSize" = "16px"
            "fontWeight" = "bold"
            "title" = $CalendarTitle
            "subtitle" = $UnitName
        }
        "grid" = @{
            "borderColor" = $GridColor
            "borderWidth" = "1px"
            "cellPadding" = "4px"
        }
        "text" = @{
            "primaryColor" = $TextColor
            "secondaryColor" = "#BDC3C7"
            "fontSize" = "12px"
            "fontFamily" = "Segoe UI, Arial, sans-serif"
        }
        "events" = @{
            "statusColors" = $StatusColors
            "typeColors" = $EventTypeColors
            "borderRadius" = "4px"
            "opacity" = 0.9
        }
        "navigation" = @{
            "buttonColor" = $AccentColor
            "buttonHoverColor" = "#C0392B"
            "arrowColor" = $TextColor
        }
        "today" = @{
            "highlightColor" = $AccentColor
            "borderWidth" = "2px"
            "backgroundColor" = "rgba(231, 76, 60, 0.1)"
        }
        "weekend" = @{
            "backgroundColor" = "rgba(127, 140, 141, 0.1)"
            "textColor" = "#95A5A6"
        }
        "conflict" = @{
            "backgroundColor" = "rgba(231, 76, 60, 0.3)"
            "borderColor" = $AccentColor
            "borderWidth" = "2px"
            "animation" = "pulse"
        }
    }
    "layout" = @{
        "monthView" = @{
            "showWeekNumbers" = $true
            "showWeekends" = $true
            "firstDayOfWeek" = 1  # Monday
        }
        "weekView" = @{
            "timeSlots" = 24
            "startHour" = 6
            "endHour" = 18
            "showAllDay" = $true
        }
        "dayView" = @{
            "timeSlots" = 48  # 30-minute intervals
            "showTimeline" = $true
        }
    }
    "features" = @{
        "tooltips" = @{
            "enabled" = $true
            "showDetails" = $true
            "backgroundColor" = "#2C3E50"
            "textColor" = $TextColor
        }
        "filtering" = @{
            "enabled" = $true
            "showFilters" = @("Status", "Event Type", "Unit", "Priority")
        }
        "export" = @{
            "enabled" = $true
            "formats" = @("PDF", "Excel", "iCal")
        }
        "notifications" = @{
            "enabled" = $true
            "conflictAlert" = $true
            "upcomingEvents" = $true
        }
    }
}

# Create Power BI custom visual configuration
$powerBIConfig = @{
    "visual" = @{
        "displayName" = "Military Mission Calendar"
        "description" = "Custom calendar visual for military mission scheduling"
        "supportUrl" = "https://github.com/OrryLee/mission-scheduling-system"
        "gitHubUrl" = "https://github.com/OrryLee/mission-scheduling-system"
    }
    "dataRoles" = @(
        @{
            "displayName" = "Event Name"
            "name" = "eventName"
            "kind" = "Grouping"
        },
        @{
            "displayName" = "Start Date"
            "name" = "startDate"
            "kind" = "Grouping"
        },
        @{
            "displayName" = "End Date"
            "name" = "endDate"
            "kind" = "Grouping"
        },
        @{
            "displayName" = "Status"
            "name" = "status"
            "kind" = "Grouping"
        },
        @{
            "displayName" = "Event Type"
            "name" = "eventType"
            "kind" = "Grouping"
        },
        @{
            "displayName" = "Unit"
            "name" = "unit"
            "kind" = "Grouping"
        },
        @{
            "displayName" = "Personnel"
            "name" = "personnel"
            "kind" = "Grouping"
        }
    )
    "objects" = @{
        "calendarSettings" = @{
            "displayName" = "Calendar Settings"
            "properties" = @{
                "backgroundColor" = @{
                    "displayName" = "Background Color"
                    "type" = @{ "fill" = @{ "solid" = @{ "color" = $true } } }
                }
                "textColor" = @{
                    "displayName" = "Text Color"
                    "type" = @{ "fill" = @{ "solid" = @{ "color" = $true } } }
                }
                "gridColor" = @{
                    "displayName" = "Grid Color"
                    "type" = @{ "fill" = @{ "solid" = @{ "color" = $true } } }
                }
                "showWeekends" = @{
                    "displayName" = "Show Weekends"
                    "type" = @{ "bool" = $true }
                }
                "firstDayOfWeek" = @{
                    "displayName" = "First Day of Week"
                    "type" = @{ "enumeration" = @(
                        @{ "displayName" = "Sunday"; "value" = "0" },
                        @{ "displayName" = "Monday"; "value" = "1" }
                    )}
                }
            }
        }
        "eventSettings" = @{
            "displayName" = "Event Settings"
            "properties" = @{
                "showConflicts" = @{
                    "displayName" = "Highlight Conflicts"
                    "type" = @{ "bool" = $true }
                }
                "conflictColor" = @{
                    "displayName" = "Conflict Color"
                    "type" = @{ "fill" = @{ "solid" = @{ "color" = $true } } }
                }
                "eventOpacity" = @{
                    "displayName" = "Event Opacity"
                    "type" = @{ "numeric" = $true }
                }
            }
        }
    }
}

# Save configurations to files
$themeFile = "calendar_theme.json"
$configFile = "powerbi_calendar_config.json"

$calendarTheme | ConvertTo-Json -Depth 10 | Out-File -FilePath $themeFile -Encoding UTF8
$powerBIConfig | ConvertTo-Json -Depth 10 | Out-File -FilePath $configFile -Encoding UTF8

Write-Host "✅ Calendar theme saved to: $themeFile" -ForegroundColor Green
Write-Host "✅ Power BI config saved to: $configFile" -ForegroundColor Green

# Create CSS for custom styling
$customCSS = @"
/* Military Mission Calendar Custom Styles */
.military-calendar {
    background: linear-gradient(135deg, $BackgroundColor 0%, #34495E 100%);
    border-radius: 8px;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
    font-family: 'Segoe UI', Arial, sans-serif;
}

.calendar-header {
    background-color: $HeaderColor;
    color: $TextColor;
    padding: 12px;
    border-radius: 8px 8px 0 0;
    text-align: center;
    font-weight: bold;
    font-size: 18px;
}

.calendar-subtitle {
    font-size: 14px;
    opacity: 0.8;
    margin-top: 4px;
}

.calendar-grid {
    border-collapse: collapse;
    width: 100%;
}

.calendar-cell {
    border: 1px solid $GridColor;
    padding: 8px;
    vertical-align: top;
    background-color: rgba(255, 255, 255, 0.05);
    min-height: 80px;
}

.calendar-cell.weekend {
    background-color: rgba(127, 140, 141, 0.1);
}

.calendar-cell.today {
    border: 2px solid $AccentColor;
    background-color: rgba(231, 76, 60, 0.1);
}

.event-item {
    margin: 2px 0;
    padding: 4px 6px;
    border-radius: 4px;
    font-size: 11px;
    cursor: pointer;
    transition: all 0.2s ease;
}

.event-item:hover {
    transform: translateY(-1px);
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
}

.event-planned { background-color: #F39C12; color: white; }
.event-active { background-color: #27AE60; color: white; }
.event-completed { background-color: #3498DB; color: white; }
.event-cancelled { background-color: #E74C3C; color: white; }
.event-conflict { 
    background-color: rgba(231, 76, 60, 0.3);
    border: 2px solid $AccentColor;
    animation: pulse 2s infinite;
}

@keyframes pulse {
    0% { opacity: 1; }
    50% { opacity: 0.7; }
    100% { opacity: 1; }
}

.navigation-button {
    background-color: $AccentColor;
    color: $TextColor;
    border: none;
    padding: 8px 12px;
    border-radius: 4px;
    cursor: pointer;
    transition: background-color 0.2s ease;
}

.navigation-button:hover {
    background-color: #C0392B;
}

.filter-panel {
    background-color: rgba(52, 73, 94, 0.9);
    padding: 12px;
    border-radius: 4px;
    margin-bottom: 12px;
}

.filter-item {
    display: inline-block;
    margin: 4px 8px 4px 0;
    padding: 4px 8px;
    background-color: rgba(255, 255, 255, 0.1);
    border-radius: 4px;
    color: $TextColor;
    font-size: 12px;
}

.tooltip {
    background-color: #2C3E50;
    color: $TextColor;
    padding: 8px 12px;
    border-radius: 4px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
    font-size: 12px;
    max-width: 250px;
}
"@

$customCSS | Out-File -FilePath "calendar_styles.css" -Encoding UTF8

Write-Host "✅ Custom CSS saved to: calendar_styles.css" -ForegroundColor Green

# Create JavaScript for calendar functionality
$calendarJS = @"
// Military Mission Calendar JavaScript
class MilitaryCalendar {
    constructor(container, options = {}) {
        this.container = container;
        this.options = {
            theme: 'military',
            showConflicts: true,
            highlightToday: true,
            enableFiltering: true,
            ...options
        };
        this.events = [];
        this.currentDate = new Date();
        this.init();
    }

    init() {
        this.createCalendarStructure();
        this.bindEvents();
        this.render();
    }

    createCalendarStructure() {
        this.container.innerHTML = `
            <div class="military-calendar">
                <div class="calendar-header">
                    <div class="calendar-title">$CalendarTitle</div>
                    <div class="calendar-subtitle">$UnitName</div>
                </div>
                <div class="calendar-navigation">
                    <button class="navigation-button" id="prevMonth">‹ Previous</button>
                    <span class="current-month"></span>
                    <button class="navigation-button" id="nextMonth">Next ›</button>
                </div>
                <div class="filter-panel" id="filterPanel"></div>
                <div class="calendar-body">
                    <table class="calendar-grid" id="calendarGrid"></table>
                </div>
            </div>
        `;
    }

    bindEvents() {
        document.getElementById('prevMonth').addEventListener('click', () => {
            this.currentDate.setMonth(this.currentDate.getMonth() - 1);
            this.render();
        });

        document.getElementById('nextMonth').addEventListener('click', () => {
            this.currentDate.setMonth(this.currentDate.getMonth() + 1);
            this.render();
        });
    }

    addEvent(event) {
        this.events.push({
            id: event.id || Date.now(),
            name: event.name,
            startDate: new Date(event.startDate),
            endDate: new Date(event.endDate),
            status: event.status || 'planned',
            type: event.type || 'training',
            unit: event.unit || '',
            personnel: event.personnel || [],
            description: event.description || ''
        });
        this.render();
    }

    detectConflicts() {
        const conflicts = [];
        for (let i = 0; i < this.events.length; i++) {
            for (let j = i + 1; j < this.events.length; j++) {
                const event1 = this.events[i];
                const event2 = this.events[j];
                
                // Check for personnel conflicts
                const sharedPersonnel = event1.personnel.filter(p => 
                    event2.personnel.includes(p)
                );
                
                if (sharedPersonnel.length > 0) {
                    // Check for date overlap
                    if (this.datesOverlap(event1.startDate, event1.endDate, 
                                        event2.startDate, event2.endDate)) {
                        conflicts.push({
                            event1: event1,
                            event2: event2,
                            personnel: sharedPersonnel,
                            type: 'personnel_overlap'
                        });
                    }
                }
            }
        }
        return conflicts;
    }

    datesOverlap(start1, end1, start2, end2) {
        return start1 <= end2 && start2 <= end1;
    }

    render() {
        this.renderCalendarGrid();
        this.renderEvents();
        this.highlightConflicts();
        this.updateNavigation();
    }

    renderCalendarGrid() {
        const grid = document.getElementById('calendarGrid');
        const year = this.currentDate.getFullYear();
        const month = this.currentDate.getMonth();
        
        // Create calendar grid HTML
        let html = '<thead><tr>';
        const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
        dayNames.forEach(day => {
            html += `<th>${day}</th>`;
        });
        html += '</tr></thead><tbody>';
        
        const firstDay = new Date(year, month, 1);
        const lastDay = new Date(year, month + 1, 0);
        const startDate = new Date(firstDay);
        startDate.setDate(startDate.getDate() - firstDay.getDay());
        
        for (let week = 0; week < 6; week++) {
            html += '<tr>';
            for (let day = 0; day < 7; day++) {
                const currentDate = new Date(startDate);
                currentDate.setDate(startDate.getDate() + (week * 7) + day);
                
                const isCurrentMonth = currentDate.getMonth() === month;
                const isToday = this.isToday(currentDate);
                const isWeekend = day === 0 || day === 6;
                
                let cellClass = 'calendar-cell';
                if (!isCurrentMonth) cellClass += ' other-month';
                if (isToday) cellClass += ' today';
                if (isWeekend) cellClass += ' weekend';
                
                html += `<td class="${cellClass}" data-date="${currentDate.toISOString().split('T')[0]}">
                    <div class="date-number">${currentDate.getDate()}</div>
                    <div class="events-container" id="events-${currentDate.toISOString().split('T')[0]}"></div>
                </td>`;
            }
            html += '</tr>';
        }
        
        html += '</tbody>';
        grid.innerHTML = html;
    }

    renderEvents() {
        // Clear existing events
        document.querySelectorAll('.events-container').forEach(container => {
            container.innerHTML = '';
        });
        
        // Render each event
        this.events.forEach(event => {
            const startDate = event.startDate.toISOString().split('T')[0];
            const container = document.getElementById(`events-${startDate}`);
            
            if (container) {
                const eventElement = document.createElement('div');
                eventElement.className = `event-item event-${event.status}`;
                eventElement.innerHTML = event.name;
                eventElement.title = `${event.name}\n${event.description}\nStatus: ${event.status}\nUnit: ${event.unit}`;
                
                container.appendChild(eventElement);
            }
        });
    }

    highlightConflicts() {
        if (!this.options.showConflicts) return;
        
        const conflicts = this.detectConflicts();
        conflicts.forEach(conflict => {
            // Add conflict styling to affected events
            document.querySelectorAll('.event-item').forEach(element => {
                if (element.innerHTML === conflict.event1.name || 
                    element.innerHTML === conflict.event2.name) {
                    element.classList.add('event-conflict');
                }
            });
        });
    }

    updateNavigation() {
        const monthNames = [
            'January', 'February', 'March', 'April', 'May', 'June',
            'July', 'August', 'September', 'October', 'November', 'December'
        ];
        
        document.querySelector('.current-month').textContent = 
            `${monthNames[this.currentDate.getMonth()]} ${this.currentDate.getFullYear()}`;
    }

    isToday(date) {
        const today = new Date();
        return date.toDateString() === today.toDateString();
    }
}

// Export for use in Power BI custom visual
if (typeof module !== 'undefined' && module.exports) {
    module.exports = MilitaryCalendar;
}
"@

$calendarJS | Out-File -FilePath "military_calendar.js" -Encoding UTF8

Write-Host "✅ JavaScript saved to: military_calendar.js" -ForegroundColor Green

Write-Host "`n🎉 Calendar Background Setup Complete!" -ForegroundColor Green
Write-Host "📁 Files created:" -ForegroundColor Cyan
Write-Host "   - $themeFile (Theme configuration)" -ForegroundColor White
Write-Host "   - $configFile (Power BI configuration)" -ForegroundColor White
Write-Host "   - calendar_styles.css (Custom styling)" -ForegroundColor White
Write-Host "   - military_calendar.js (Calendar functionality)" -ForegroundColor White

Write-Host "`n🎨 Theme Colors:" -ForegroundColor Cyan
Write-Host "   - Background: $BackgroundColor" -ForegroundColor White
Write-Host "   - Header: $HeaderColor" -ForegroundColor White
Write-Host "   - Text: $TextColor" -ForegroundColor White
Write-Host "   - Accent: $AccentColor" -ForegroundColor White
Write-Host "   - Grid: $GridColor" -ForegroundColor White
