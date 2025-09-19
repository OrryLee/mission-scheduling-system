#!/usr/bin/env python3

import pandas as pd
import openpyxl
import sys

def analyze_excel_file(file_path):
    """Analyze Excel file structure and content"""
    
    print(f"Analyzing Excel file: {file_path}")
    print("=" * 50)
    
    try:
        # Load the workbook to get sheet names
        workbook = openpyxl.load_workbook(file_path)
        sheet_names = workbook.sheetnames
        
        print(f"Number of sheets: {len(sheet_names)}")
        print(f"Sheet names: {sheet_names}")
        print()
        
        # Analyze each sheet
        for sheet_name in sheet_names:
            print(f"SHEET: {sheet_name}")
            print("-" * 30)
            
            # Read the sheet
            df = pd.read_excel(file_path, sheet_name=sheet_name)
            
            print(f"Dimensions: {df.shape[0]} rows x {df.shape[1]} columns")
            print(f"Columns: {list(df.columns)}")
            print()
            
            # Show data types
            print("Data types:")
            for col in df.columns:
                print(f"  {col}: {df[col].dtype}")
            print()
            
            # Show first few rows
            print("First 5 rows:")
            print(df.head().to_string())
            print()
            
            # Show sample data for each column
            print("Sample data by column:")
            for col in df.columns:
                non_null_values = df[col].dropna()
                if len(non_null_values) > 0:
                    sample_values = non_null_values.head(3).tolist()
                    print(f"  {col}: {sample_values}")
                else:
                    print(f"  {col}: [No data]")
            print()
            print("=" * 50)
            
    except Exception as e:
        print(f"Error analyzing file: {e}")

if __name__ == "__main__":
    file_path = "/home/ubuntu/upload/formpowrbicop.xlsx"
    analyze_excel_file(file_path)
