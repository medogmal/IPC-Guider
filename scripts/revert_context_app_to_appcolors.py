#!/usr/bin/env python3
"""
Revert all context.appX back to AppColors.X
This script reverts the theme-aware color changes back to direct AppColors usage.
"""

import os
import re
from pathlib import Path

# Mapping of context.appX to AppColors.X
REPLACEMENTS = {
    'context.appBackground': 'AppColors.background',
    'context.appSurface': 'AppColors.surface',
    'context.appSurfaceVariant': 'AppColors.surfaceVariant',
    'context.appSurfaceElevated': 'AppColors.surfaceVariant',  # Note: surfaceElevated doesn't exist in AppColors
    
    'context.appTextPrimary': 'AppColors.textPrimary',
    'context.appTextSecondary': 'AppColors.textSecondary',
    'context.appTextTertiary': 'AppColors.textTertiary',
    
    'context.appPrimary': 'AppColors.primary',
    'context.appPrimaryLight': 'AppColors.primaryLight',
    'context.appPrimaryDark': 'AppColors.primaryDark',
    
    'context.appSecondary': 'AppColors.secondary',
    'context.appSecondaryLight': 'AppColors.secondaryLight',
    'context.appSecondaryDark': 'AppColors.secondaryDark',
    
    'context.appSuccess': 'AppColors.success',
    'context.appSuccessLight': 'AppColors.successLight',
    'context.appWarning': 'AppColors.warning',
    'context.appWarningLight': 'AppColors.warningLight',
    'context.appError': 'AppColors.error',
    'context.appErrorLight': 'AppColors.errorLight',
    'context.appInfo': 'AppColors.info',
    'context.appInfoLight': 'AppColors.infoLight',
    
    'context.appAirborne': 'AppColors.airborne',
    'context.appDroplet': 'AppColors.droplet',
    'context.appContact': 'AppColors.contact',
    'context.appEnteric': 'AppColors.enteric',
    'context.appProtective': 'AppColors.protective',
    
    'context.appNeutral': 'AppColors.neutral',
    'context.appNeutralLight': 'AppColors.neutralLight',
    'context.appNeutralLighter': 'AppColors.neutralLighter',
    'context.appNeutralDark': 'AppColors.neutralDark',
    
    'context.appInteractive': 'AppColors.interactive',
    'context.appInteractiveLight': 'AppColors.interactiveLight',
    'context.appInteractiveDark': 'AppColors.interactiveDark',
    'context.appInteractiveBorderLight': 'AppColors.interactiveBorderLight',
    'context.appInteractiveBorderDark': 'AppColors.interactiveBorderDark',
}

def process_file(file_path):
    """Process a single Dart file and revert context.appX to AppColors.X"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        replacements_made = 0
        
        # Apply all replacements
        for old_pattern, new_pattern in REPLACEMENTS.items():
            count = content.count(old_pattern)
            if count > 0:
                content = content.replace(old_pattern, new_pattern)
                replacements_made += count
        
        # Only write if changes were made
        if content != original_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            return replacements_made
        
        return 0
    except Exception as e:
        print(f"❌ Error processing {file_path}: {e}")
        return 0

def main():
    print("🔄 Reverting context.appX back to AppColors.X...\n")
    print("=" * 60)
    
    # Find all Dart files in lib directory
    lib_dir = Path('lib')
    dart_files = list(lib_dir.rglob('*.dart'))
    
    total_replacements = 0
    files_modified = 0
    
    for dart_file in dart_files:
        replacements = process_file(dart_file)
        if replacements > 0:
            files_modified += 1
            total_replacements += replacements
            print(f"✅ {dart_file}")
            print(f"   └─ {replacements} replacements")
    
    print("=" * 60)
    print(f"\n🎉 REVERT COMPLETE!")
    print(f"   📁 Files modified: {files_modified}")
    print(f"   🔄 Total replacements: {total_replacements}\n")

if __name__ == '__main__':
    main()

