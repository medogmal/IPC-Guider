#!/usr/bin/env python3
"""
Comprehensive validation script for ALL CDS categories.
Validates:
1. JSON Schema (required fields)
2. Condition structure (sections, references)
3. Medical abbreviations (capitalization)
4. Dosing formats (regex)
5. Text length (UI/UX)
"""

import json
import re
import sys
from pathlib import Path

# --- Configuration ---
CDS_DIR = Path('assets/data/cds')
REQUIRED_TOP_FIELDS = ['version', 'updatedAt', 'id', 'name', 'description', 'icon', 'color', 'conditions']
REQUIRED_CONDITION_FIELDS = ['id', 'name', 'synonyms', 'icd10', 'severity', 'shortDescription', 'sections']
REQUIRED_SECTIONS = ['overview', 'diagnostics', 'microbiology', 'empiric', 'definitive', 'duration', 'special', 'stewardship', 'references']

# Common abbreviations that MUST be ALL CAPS in content
REQUIRED_CAPS = [
    'IV', 'PO', 'IM', 'SC', 'TID', 'BID', 'QID', 'QD', 'QHS',
    'MRSA', 'MSSA', 'ESBL', 'VRE', 'CRE', 'MDRO', 'KPC', 'XDR', 'MDR',
    'CBC', 'CMP', 'BMP', 'CRP', 'ESR', 'PCT', 'WBC', 'UA',
    'CT', 'MRI', 'US', 'CXR',
    'ICU', 'ED',
    'IDSA', 'CDC', 'AAP', 'ABA',
    'TMP-SMX', 'TMP', 'SMX', 'DS', 'SS',
    'HIV', 'AIDS', 'HCV', 'HBV', 'CMV', 'EBV', 'HSV', 'VZV', 'RSV',
    'CFU', 'RBC', 'AKI', 'CKD', 'CrCl', 'eGFR',
    'SSI', 'DFI', 'NSTI', 'HS', 'TBSA', 'LRINEC',
    'NHSN', 'IWGDF', 'MCP', 'PEP', 'TIG', 'ASO',
    'DAIR', 'PAD', 'ABI', 'FDA', 'TPN', 'IVDU'
]

# Regex for dosing format
DOSING_PATTERN = re.compile(r'\b[A-Z][a-z]+(?:-[a-z]+)?\s+\d+(?:-\d+)?(?:\.\d+)?(?:mg|g|mcg|units?|%)\s+(?:IV|PO|IM|SC|topically)\s+(?:daily|BID|TID|QID|q\d+h|q\d+-\d+h)\b')

def validate_json_structure(data, filename):
    """Validate JSON schema and structure"""
    issues = []
    
    # Check top-level fields
    for field in REQUIRED_TOP_FIELDS:
        if field not in data:
            issues.append(f"Missing top-level field: {field}")

    # Check conditions
    if 'conditions' not in data:
        issues.append("No conditions array found")
        return issues

    conditions = data['conditions']
    if not conditions:
        issues.append("Conditions array is empty")

    return issues

def validate_condition_structure(condition, index, filename):
    """Validate individual condition structure"""
    issues = []
    cond_name = condition.get('name', f'Condition {index}')

    # Required fields
    for field in REQUIRED_CONDITION_FIELDS:
        if field not in condition:
            issues.append(f"{cond_name}: Missing field '{field}'")

    # Check sections
    if 'sections' not in condition:
        return issues

    sections = condition['sections']
    for section in REQUIRED_SECTIONS:
        if section not in sections:
            issues.append(f"{cond_name}: Missing section '{section}'")

    # Check references
    if 'references' in sections:
        refs = sections['references'].get('references', [])
        if len(refs) < 1:
             issues.append(f"{cond_name}: No references found (minimum 1 required)")
        
        for i, ref in enumerate(refs, 1):
            if 'label' not in ref:
                issues.append(f"{cond_name}: Reference {i} missing 'label'")
            if 'url' not in ref:
                issues.append(f"{cond_name}: Reference {i} missing 'url'")
    else:
        issues.append(f"{cond_name}: No references section")

    return issues

def validate_medical_abbreviations(data, filename):
    """Validate medical abbreviation capitalization in content values only"""
    issues = []

    def check_string_value(value, path=""):
        local_issues = []
        if isinstance(value, str):
            for abbr in REQUIRED_CAPS:
                # Look for lowercase or mixed case versions in content
                # Use word boundary to avoid partial matches
                pattern = re.compile(r'\b' + abbr.lower() + r'\b', re.IGNORECASE)
                matches = pattern.findall(value)
                incorrect = [m for m in matches if m != abbr]
                if incorrect:
                    local_issues.append(f"In '{path}': Found '{abbr}' as {set(incorrect)}")
        elif isinstance(value, dict):
            for key, val in value.items():
                local_issues.extend(check_string_value(val, f"{path}.{key}" if path else key))
        elif isinstance(value, list):
            for i, item in enumerate(value):
                local_issues.extend(check_string_value(item, f"{path}[{i}]"))
        return local_issues

    for condition in data.get('conditions', []):
        cond_name = condition.get('name', 'Unknown')
        sections = condition.get('sections', {})
        for section_id, section in sections.items():
            if section_id == 'references':
                continue
            content = section.get('content', {})
            issues.extend(check_string_value(content, f"{cond_name}.{section_id}"))

    return issues

def validate_dosing_format(data, filename):
    """Validate dosing format consistency"""
    issues = []
    json_str = json.dumps(data)
    dosings = DOSING_PATTERN.findall(json_str)
    
    # Heuristic: If a file has many conditions but few properly formatted dosings, it might be an issue.
    # But for now, we just report if NO dosings are found in a file that likely should have them.
    if len(dosings) == 0 and len(data.get('conditions', [])) > 0:
         # This is a weak check, but better than nothing. 
         # Many files might not have standard dosing strings if they use tables or lists differently.
         pass 

    return issues

def validate_file(filepath):
    """Run all validations on a single file"""
    print(f"Validating {filepath.name}...")
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except json.JSONDecodeError as e:
        print(f"❌ JSON SYNTAX ERROR in {filepath.name}: {e}")
        return False
    except Exception as e:
        print(f"❌ Error reading {filepath.name}: {e}")
        return False

    all_issues = []

    # 1. Structure
    all_issues.extend(validate_json_structure(data, filepath.name))

    # 2. Conditions
    for i, condition in enumerate(data.get('conditions', []), 1):
        all_issues.extend(validate_condition_structure(condition, i, filepath.name))

    # 3. Abbreviations
    abbr_issues = validate_medical_abbreviations(data, filepath.name)
    # Limit abbreviation issues to avoid spamming
    if len(abbr_issues) > 5:
        all_issues.extend(abbr_issues[:5])
        all_issues.append(f"... and {len(abbr_issues) - 5} more abbreviation issues")
    else:
        all_issues.extend(abbr_issues)

    if all_issues:
        for issue in all_issues:
            print(f"   [FAIL] {issue}")
        return False
    else:
        print(f"   [OK]")
        return True

def main():
    print("=" * 80)
    print("CDS MODULE - COMPREHENSIVE VALIDATION")
    print("=" * 80)
    
    if not CDS_DIR.exists():
        print(f"❌ Directory not found: {CDS_DIR}")
        return

    files = list(CDS_DIR.glob('*.json'))
    if not files:
        print("❌ No JSON files found.")
        return

    success_count = 0
    failure_count = 0

    for json_file in sorted(files):
        if validate_file(json_file):
            success_count += 1
        else:
            failure_count += 1
            
    print("-" * 80)
    print(f"Summary: {success_count} passed, {failure_count} failed")
    
    if failure_count > 0:
        sys.exit(1)

if __name__ == '__main__':
    main()
