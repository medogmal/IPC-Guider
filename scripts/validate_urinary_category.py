#!/usr/bin/env python3
"""
Comprehensive validation script for Urinary & Genitourinary Infections category
Validates: JSON schema, scientific content, medical terminology, and UI/UX compliance
"""

import json
import re
from pathlib import Path

def validate_json_structure(data):
    """Validate JSON schema and structure"""
    issues = []
    warnings = []
    
    # Check top-level fields
    required_top = ['version', 'updatedAt', 'id', 'name', 'description', 'icon', 'color', 'conditions']
    for field in required_top:
        if field not in data:
            issues.append(f"Missing top-level field: {field}")
    
    # Check version
    if data.get('version') != 2:
        warnings.append(f"Version is {data.get('version')}, expected 2")
    
    # Check conditions
    if 'conditions' not in data:
        issues.append("No conditions array found")
        return issues, warnings
    
    conditions = data['conditions']
    if len(conditions) != 10:
        warnings.append(f"Expected 10 conditions, found {len(conditions)}")
    
    return issues, warnings

def validate_condition_structure(condition, index):
    """Validate individual condition structure"""
    issues = []
    warnings = []
    
    cond_name = condition.get('name', f'Condition {index}')
    
    # Required fields
    required_fields = ['id', 'name', 'synonyms', 'icd10', 'severity', 'shortDescription', 'sections']
    for field in required_fields:
        if field not in condition:
            issues.append(f"{cond_name}: Missing field '{field}'")
    
    # Check sections
    if 'sections' not in condition:
        return issues, warnings
    
    sections = condition['sections']
    required_sections = ['overview', 'diagnostics', 'microbiology', 'empiric', 'definitive', 'duration', 'special', 'stewardship', 'references']
    
    for section in required_sections:
        if section not in sections:
            issues.append(f"{cond_name}: Missing section '{section}'")
    
    # Check references
    if 'references' in sections:
        refs = sections['references'].get('references', [])
        if len(refs) < 3:
            issues.append(f"{cond_name}: Only {len(refs)} references (minimum 3 required)")
        
        # Check reference structure
        for i, ref in enumerate(refs, 1):
            if 'label' not in ref:
                issues.append(f"{cond_name}: Reference {i} missing 'label'")
            if 'url' not in ref:
                issues.append(f"{cond_name}: Reference {i} missing 'url'")
    else:
        issues.append(f"{cond_name}: No references section")
    
    return issues, warnings

def validate_medical_abbreviations(data):
    """Validate medical abbreviation capitalization in content values only"""
    issues = []

    # Common abbreviations that MUST be ALL CAPS in content
    required_caps = [
        'UTI', 'CAUTI', 'IV', 'PO', 'IM', 'SC', 'TID', 'BID', 'QID', 'QD', 'QHS',
        'MRSA', 'MSSA', 'ESBL', 'VRE', 'CRE', 'MDRO', 'KPC',
        'CBC', 'CMP', 'BMP', 'CRP', 'ESR', 'PCT', 'WBC', 'UA',
        'CT', 'MRI', 'US', 'CXR',
        'ICU', 'ED',
        'IDSA', 'AUA', 'EAU',
        'TMP-SMX', 'TMP', 'SMX', 'DS', 'SS',
        'HIV', 'AIDS', 'HCV', 'HBV', 'CMV', 'EBV', 'HSV', 'VZV', 'RSV',
        'GBS', 'IAP', 'ASB', 'TURP', 'DRE', 'PSA', 'BPH', 'CPPS',
        'CFU', 'WBC', 'RBC', 'AKI', 'CKD', 'CrCl', 'eGFR'
    ]

    def check_string_value(value, path=""):
        """Recursively check string values for abbreviation capitalization"""
        local_issues = []
        if isinstance(value, str):
            for abbr in required_caps:
                # Look for lowercase or mixed case versions in content
                pattern = re.compile(r'\b' + abbr.lower() + r'\b', re.IGNORECASE)
                matches = pattern.findall(value)
                incorrect = [m for m in matches if m != abbr]
                if incorrect:
                    local_issues.append(f"In '{path}': Found '{abbr}' as {set(incorrect)}")
        elif isinstance(value, dict):
            for key, val in value.items():
                # Skip checking field names (keys), only check values
                local_issues.extend(check_string_value(val, f"{path}.{key}" if path else key))
        elif isinstance(value, list):
            for i, item in enumerate(value):
                local_issues.extend(check_string_value(item, f"{path}[{i}]"))
        return local_issues

    # Only check content values, not URLs or field names
    for condition in data.get('conditions', []):
        cond_name = condition.get('name', 'Unknown')
        sections = condition.get('sections', {})
        for section_id, section in sections.items():
            if section_id == 'references':
                continue  # Skip references section (has URLs)
            content = section.get('content', {})
            issues.extend(check_string_value(content, f"{cond_name}.{section_id}"))

    return issues[:10]  # Return first 10 issues only

def validate_dosing_format(data):
    """Validate dosing format consistency"""
    issues = []
    warnings = []
    
    # Expected format: "Drug dose unit route frequency"
    # Examples: "Ciprofloxacin 500mg PO BID", "Ceftriaxone 1-2g IV daily"
    
    dosing_pattern = re.compile(r'\b[A-Z][a-z]+(?:-[a-z]+)?\s+\d+(?:-\d+)?(?:\.\d+)?(?:mg|g|mcg|units?)\s+(?:IV|PO|IM|SC)\s+(?:daily|BID|TID|QID|q\d+h|q\d+-\d+h)\b')
    
    json_str = json.dumps(data, indent=2)
    
    # Find all dosing mentions
    dosings = dosing_pattern.findall(json_str)
    
    if len(dosings) < 50:  # Expect many dosing instructions
        warnings.append(f"Only found {len(dosings)} properly formatted dosing instructions (expected >50)")
    
    return issues, warnings

def validate_text_length(data):
    """Validate text lengths for UI/UX (overflow potential)"""
    issues = []
    warnings = []
    
    # Check condition names (should be reasonable for cards)
    for condition in data.get('conditions', []):
        name = condition.get('name', '')
        if len(name) > 50:
            warnings.append(f"Long condition name (may overflow): '{name}' ({len(name)} chars)")
        
        short_desc = condition.get('shortDescription', '')
        if len(short_desc) > 150:
            warnings.append(f"Long shortDescription for '{name}': {len(short_desc)} chars (may overflow on cards)")
    
    # Check category description
    cat_desc = data.get('description', '')
    if len(cat_desc) > 100:
        warnings.append(f"Long category description: {len(cat_desc)} chars")
    
    return issues, warnings

def main():
    print("=" * 80)
    print("URINARY & GENITOURINARY INFECTIONS CATEGORY - COMPREHENSIVE VALIDATION")
    print("=" * 80)
    print()
    
    # Load JSON
    json_path = Path('assets/data/cds/urinary-genitourinary.v1.json')
    try:
        with open(json_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        print("✅ JSON file loaded successfully")
    except json.JSONDecodeError as e:
        print(f"❌ JSON SYNTAX ERROR: {e}")
        return
    except FileNotFoundError:
        print(f"❌ File not found: {json_path}")
        return
    
    print()
    
    # 1. JSON Structure Validation
    print("1. JSON STRUCTURE VALIDATION")
    print("-" * 80)
    issues, warnings = validate_json_structure(data)
    if issues:
        for issue in issues:
            print(f"   ❌ {issue}")
    if warnings:
        for warning in warnings:
            print(f"   ⚠️  {warning}")
    if not issues and not warnings:
        print("   ✅ All structural checks passed")
    print()
    
    # 2. Condition Structure Validation
    print("2. CONDITION STRUCTURE VALIDATION")
    print("-" * 80)
    all_issues = []
    all_warnings = []

    for i, condition in enumerate(data.get('conditions', []), 1):
        issues, warnings = validate_condition_structure(condition, i)
        all_issues.extend(issues)
        all_warnings.extend(warnings)

    if all_issues:
        for issue in all_issues:
            print(f"   ❌ {issue}")
    if all_warnings:
        for warning in all_warnings:
            print(f"   ⚠️  {warning}")
    if not all_issues and not all_warnings:
        print(f"   ✅ All {len(data.get('conditions', []))} conditions have correct structure")
    print()

    # 3. Medical Abbreviation Validation
    print("3. MEDICAL ABBREVIATION VALIDATION")
    print("-" * 80)
    issues = validate_medical_abbreviations(data)
    if issues:
        for issue in issues[:10]:  # Show first 10
            print(f"   ❌ {issue}")
        if len(issues) > 10:
            print(f"   ... and {len(issues) - 10} more issues")
    else:
        print("   ✅ All medical abbreviations properly capitalized")
    print()

    # 4. Dosing Format Validation
    print("4. DOSING FORMAT VALIDATION")
    print("-" * 80)
    issues, warnings = validate_dosing_format(data)
    if issues:
        for issue in issues:
            print(f"   ❌ {issue}")
    if warnings:
        for warning in warnings:
            print(f"   ⚠️  {warning}")
    if not issues and not warnings:
        print("   ✅ Dosing format validation passed")
    print()

    # 5. Text Length Validation (UI/UX)
    print("5. TEXT LENGTH VALIDATION (UI/UX)")
    print("-" * 80)
    issues, warnings = validate_text_length(data)
    if issues:
        for issue in issues:
            print(f"   ❌ {issue}")
    if warnings:
        for warning in warnings:
            print(f"   ⚠️  {warning}")
    if not issues and not warnings:
        print("   ✅ All text lengths appropriate for UI")
    print()

    # Summary
    print("=" * 80)
    print("VALIDATION SUMMARY")
    print("=" * 80)
    print(f"Category: {data.get('name', 'UNKNOWN')}")
    print(f"Version: {data.get('version', 'UNKNOWN')}")
    print(f"Conditions: {len(data.get('conditions', []))}")
    print(f"File Size: {json_path.stat().st_size / 1024:.2f} KB")
    print()

    # Count total sections and references
    total_sections = 0
    total_refs = 0
    for condition in data.get('conditions', []):
        sections = condition.get('sections', {})
        total_sections += len(sections)
        if 'references' in sections:
            total_refs += len(sections['references'].get('references', []))

    print(f"Total Sections: {total_sections}")
    print(f"Total References: {total_refs}")
    print()
    print("✅ VALIDATION COMPLETE")

if __name__ == '__main__':
    main()

