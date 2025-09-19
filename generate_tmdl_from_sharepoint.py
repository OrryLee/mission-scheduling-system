#!/usr/bin/env python3
"""
Mission Scheduling TMDL Generator
Generates TMDL model definition from SharePoint list schemas
"""

import json
import os
from datetime import datetime
from typing import Dict, List, Any

class TMDLGenerator:
    def __init__(self, sharepoint_site_url: str):
        self.sharepoint_site_url = sharepoint_site_url
        self.model_name = "MissionSchedulingModel"
        
    def generate_column_definition(self, column_name: str, column_type: str, 
                                 source_column: str = None, expression: str = None) -> str:
        """Generate TMDL column definition"""
        if source_column is None:
            source_column = column_name
            
        data_type_mapping = {
            'text': 'string',
            'number': 'int64',
            'datetime': 'dateTime',
            'boolean': 'boolean',
            'choice': 'string'
        }
        
        tmdl_type = data_type_mapping.get(column_type.lower(), 'string')
        
        column_def = f"""  column {column_name}
    dataType: {tmdl_type}
    lineageTag: {column_name.lower().replace('_', '-')}-column
    summarizeBy: {'sum' if tmdl_type == 'int64' else 'none'}"""
    
        if expression:
            column_def += f"\n    expression: {expression}"
        else:
            column_def += f"\n    sourceColumn: {source_column}"
            
        if tmdl_type == 'dateTime':
            column_def += f"\n    formatString: mm/dd/yyyy h:mm AM/PM"
            
        return column_def

    def generate_table_definition(self, table_name: str, columns: List[Dict], 
                                list_name: str = None) -> str:
        """Generate TMDL table definition"""
        if list_name is None:
            list_name = table_name
            
        table_def = f"""table {table_name}
  lineageTag: {table_name.lower().replace('_', '-')}-table

"""
        
        # Add columns
        for col in columns:
            column_def = self.generate_column_definition(
                col['name'], col['type'], col.get('source'), col.get('expression')
            )
            table_def += column_def + "\n\n"
        
        # Add partition
        api_url = f"{self.sharepoint_site_url}/_api/web/lists/getbytitle('{list_name}')/items"
        table_def += f"""  partition {table_name}
    mode: import
    source:
      type: web
      url: "{api_url}"
      
"""
        return table_def

    def generate_measures(self) -> str:
        """Generate DAX measures for mission scheduling"""
        measures = [
            {
                'name': 'Total Missions',
                'expression': 'COUNTROWS(Mission_Calendar)',
                'description': 'Total number of missions'
            },
            {
                'name': 'Active Missions',
                'expression': 'CALCULATE(COUNTROWS(Mission_Calendar), Mission_Calendar[Status] = "Active")',
                'description': 'Number of active missions'
            },
            {
                'name': 'Personnel Conflicts',
                'expression': 'COUNTROWS(Conflict_Log)',
                'description': 'Total personnel conflicts detected'
            },
            {
                'name': 'Unresolved Conflicts',
                'expression': 'CALCULATE(COUNTROWS(Conflict_Log), Conflict_Log[Resolution_Status] = "Unresolved")',
                'description': 'Number of unresolved conflicts'
            },
            {
                'name': 'Mission Utilization %',
                'expression': 'DIVIDE(CALCULATE(COUNTROWS(Mission_Calendar), Mission_Calendar[Status] IN {"Active", "Planned"}), COUNTROWS(Mission_Calendar), 0) * 100',
                'format': '0.0"%"',
                'description': 'Percentage of missions that are active or planned'
            }
        ]
        
        measures_def = "// Measures\n"
        for measure in measures:
            measures_def += f"""measure '{measure['name']}' = {measure['expression']}
  lineageTag: {measure['name'].lower().replace(' ', '-').replace('%', 'percent')}-measure"""
            if measure.get('format'):
                measures_def += f"\n  formatString: {measure['format']}"
            measures_def += "\n\n"
            
        return measures_def

    def generate_relationships(self) -> str:
        """Generate table relationships"""
        relationships = """// Relationships
relationship Personnel_DOD_ID from Conflict_Log to Personnel_Roster[DOD_ID]
  crossFilteringBehavior: bothDirections

relationship Mission_Name from Mission_Requirements[Mission_ID] to Mission_Calendar[Mission_Name]
  crossFilteringBehavior: bothDirections

relationship Start_Date from Mission_Calendar to DateTable[Date]
  crossFilteringBehavior: oneToMany

"""
        return relationships

    def generate_date_table(self) -> str:
        """Generate date table definition"""
        date_table = """table DateTable
  lineageTag: date-table
  dataCategory: Time

  column Date
    dataType: dateTime
    lineageTag: date-column
    summarizeBy: none
    sourceColumn: Date
    formatString: mm/dd/yyyy

  column Year
    dataType: int64
    lineageTag: year-column
    summarizeBy: none
    expression: YEAR(DateTable[Date])

  column Month
    dataType: int64
    lineageTag: month-column
    summarizeBy: none
    expression: MONTH(DateTable[Date])

  column MonthName
    dataType: string
    lineageTag: month-name-column
    summarizeBy: none
    expression: FORMAT(DateTable[Date], "MMMM")

  column Quarter
    dataType: int64
    lineageTag: quarter-column
    summarizeBy: none
    expression: QUARTER(DateTable[Date])

  column WeekOfYear
    dataType: int64
    lineageTag: week-of-year-column
    summarizeBy: none
    expression: WEEKNUM(DateTable[Date])

  column DayOfWeek
    dataType: int64
    lineageTag: day-of-week-column
    summarizeBy: none
    expression: WEEKDAY(DateTable[Date])

  column DayName
    dataType: string
    lineageTag: day-name-column
    summarizeBy: none
    expression: FORMAT(DateTable[Date], "dddd")

  column IsWeekend
    dataType: boolean
    lineageTag: is-weekend-column
    summarizeBy: none
    expression: DateTable[DayOfWeek] IN {1, 7}

  partition DateTable
    mode: import
    source:
      type: calculated
      expression: 
        ADDCOLUMNS(
          CALENDAR(DATE(2024, 1, 1), DATE(2026, 12, 31)),
          "Date", [Date]
        )

"""
        return date_table

    def generate_full_tmdl(self) -> str:
        """Generate complete TMDL model"""
        
        # Define table schemas
        personnel_columns = [
            {'name': 'DOD_ID', 'type': 'text'},
            {'name': 'Last_Name', 'type': 'text'},
            {'name': 'First_Name', 'type': 'text'},
            {'name': 'Rank', 'type': 'choice'},
            {'name': 'MOS', 'type': 'text'},
            {'name': 'Unit', 'type': 'text'},
            {'name': 'Contact_Email', 'type': 'text'},
            {'name': 'Status', 'type': 'choice'},
            {'name': 'Full_Name', 'type': 'text', 'expression': 'Personnel_Roster[First_Name] & " " & Personnel_Roster[Last_Name]'}
        ]
        
        mission_columns = [
            {'name': 'Mission_Name', 'type': 'text'},
            {'name': 'Mission_Description', 'type': 'text'},
            {'name': 'Mission_Type', 'type': 'choice'},
            {'name': 'Start_Date', 'type': 'datetime'},
            {'name': 'End_Date', 'type': 'datetime'},
            {'name': 'Assigned_Personnel', 'type': 'text'},
            {'name': 'Unit', 'type': 'text'},
            {'name': 'Status', 'type': 'choice'},
            {'name': 'Priority', 'type': 'choice'},
            {'name': 'Location', 'type': 'text'},
            {'name': 'Duration_Days', 'type': 'number', 'expression': 'DATEDIFF(Mission_Calendar[Start_Date], Mission_Calendar[End_Date], DAY) + 1'}
        ]
        
        requirements_columns = [
            {'name': 'Mission_ID', 'type': 'text'},
            {'name': 'Required_MOS', 'type': 'text'},
            {'name': 'Required_Billet', 'type': 'text'},
            {'name': 'Slots_Needed', 'type': 'number'},
            {'name': 'Slots_Filled', 'type': 'number'},
            {'name': 'Requirement_Status', 'type': 'choice'}
        ]
        
        conflict_columns = [
            {'name': 'Personnel_DOD_ID', 'type': 'text'},
            {'name': 'Personnel_Name', 'type': 'text'},
            {'name': 'Mission_1_Name', 'type': 'text'},
            {'name': 'Mission_2_Name', 'type': 'text'},
            {'name': 'Conflict_Type', 'type': 'choice'},
            {'name': 'Detected_Date', 'type': 'datetime'},
            {'name': 'Resolution_Status', 'type': 'choice'},
            {'name': 'Resolution_Notes', 'type': 'text'}
        ]
        
        # Generate TMDL
        tmdl = f"""model {self.model_name}
  culture: en-US
  defaultPowerBIDataSourceVersion: powerBI_V3
  sourceQueryCulture: en-US
  dataAccessOptions
    legacyRedirects
    returnErrorValuesAsNull

"""
        
        # Add tables
        tmdl += self.generate_table_definition('Personnel_Roster', personnel_columns)
        tmdl += self.generate_table_definition('Mission_Calendar', mission_columns)
        tmdl += self.generate_table_definition('Mission_Requirements', requirements_columns)
        tmdl += self.generate_table_definition('Conflict_Log', conflict_columns)
        tmdl += self.generate_date_table()
        
        # Add relationships
        tmdl += self.generate_relationships()
        
        # Add measures
        tmdl += self.generate_measures()
        
        # Add annotations
        tmdl += """annotation PBI_QueryOrder = ["Personnel_Roster", "Mission_Calendar", "Mission_Requirements", "Conflict_Log", "DateTable"]

annotation PBI_ProTooling = ["DevMode"]"""
        
        return tmdl

def main():
    """Main function to generate TMDL"""
    sharepoint_url = "https://armyeitaas.sharepoint-mil.us/teams/2-358ARGrizzlies"
    
    generator = TMDLGenerator(sharepoint_url)
    tmdl_content = generator.generate_full_tmdl()
    
    # Write to file
    output_file = "mission_scheduling_generated.tmdl"
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(tmdl_content)
    
    print(f"✅ TMDL model generated: {output_file}")
    print(f"📊 Model: {generator.model_name}")
    print(f"🔗 SharePoint: {sharepoint_url}")
    print(f"📅 Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")

if __name__ == "__main__":
    main()
