#!/usr/bin/env python3
"""
Script to convert hardcoded AppColors to theme-aware context.appX colors.
This script processes all Dart files in the project and replaces AppColors.X with context.appX.
"""

import re
import os
from pathlib import Path
from typing import List, Tuple

# Color mappings from AppColors.X to context.appX
COLOR_MAPPINGS = {
    'AppColors.primary': 'context.appPrimary',
    'AppColors.primaryLight': 'context.appPrimaryLight',
    'AppColors.primaryDark': 'context.appPrimaryDark',
    'AppColors.secondary': 'context.appSecondary',
    'AppColors.background': 'context.appBackground',
    'AppColors.surface': 'context.appSurface',
    'AppColors.surfaceVariant': 'context.appSurfaceVariant',
    'AppColors.surfaceElevated': 'context.appSurfaceElevated',
    'AppColors.error': 'context.appError',
    'AppColors.success': 'context.appSuccess',
    'AppColors.warning': 'context.appWarning',
    'AppColors.info': 'context.appInfo',
    'AppColors.textPrimary': 'context.appTextPrimary',
    'AppColors.textSecondary': 'context.appTextSecondary',
    'AppColors.textTertiary': 'context.appTextTertiary',
    'AppColors.interactive': 'context.appInteractive',
    'AppColors.border': 'context.appBorder',
    'AppColors.divider': 'context.appDivider',
}

def convert_file(file_path: Path) -> Tuple[int, bool]:
    """
    Convert AppColors references to context.appX in a single file.
    Returns: (number_of_replacements, was_modified)
    """
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        replacements = 0
        
        # Replace each color mapping
        for old_color, new_color in COLOR_MAPPINGS.items():
            # Count occurrences
            count = content.count(old_color)
            if count > 0:
                content = content.replace(old_color, new_color)
                replacements += count
        
        # Only write if changes were made
        if content != original_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            return replacements, True
        
        return 0, False
    
    except Exception as e:
        print(f"❌ Error processing {file_path}: {e}")
        return 0, False

def find_dart_files(root_dir: Path, exclude_dirs: List[str] = None) -> List[Path]:
    """Find all Dart files in the project, excluding specified directories."""
    if exclude_dirs is None:
        exclude_dirs = ['.dart_tool', 'build', '.git', 'node_modules']
    
    dart_files = []
    for dart_file in root_dir.rglob('*.dart'):
        # Skip excluded directories
        if any(excluded in dart_file.parts for excluded in exclude_dirs):
            continue
        dart_files.append(dart_file)
    
    return dart_files

def main():
    """Main function to convert all Dart files."""
    # Get project root (assuming script is in scripts/ directory)
    script_dir = Path(__file__).parent
    project_root = script_dir.parent
    
    print("🔍 Scanning for Dart files...")
    dart_files = find_dart_files(project_root / 'lib')
    print(f"📁 Found {len(dart_files)} Dart files\n")
    
    print("🔄 Converting AppColors to theme-aware colors...\n")
    print("=" * 80)
    
    total_replacements = 0
    modified_files = 0
    
    for dart_file in dart_files:
        replacements, was_modified = convert_file(dart_file)
        
        if was_modified:
            modified_files += 1
            total_replacements += replacements
            relative_path = dart_file.relative_to(project_root)
            print(f"✅ {relative_path}")
            print(f"   └─ {replacements} replacements")
    
    print("=" * 80)
    print(f"\n🎉 CONVERSION COMPLETE!")
    print(f"   📝 Modified files: {modified_files}/{len(dart_files)}")
    print(f"   🔄 Total replacements: {total_replacements}")
    
    if modified_files > 0:
        print(f"\n💡 Next steps:")
        print(f"   1. Run 'flutter analyze' to check for any issues")
        print(f"   2. Test the app in both light and dark modes")
        print(f"   3. Hot restart the app to see changes")

if __name__ == '__main__':
    main()

