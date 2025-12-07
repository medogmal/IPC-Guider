import json
from pathlib import Path
import sys

# Force UTF-8 output for Windows consoles
sys.stdout.reconfigure(encoding='utf-8')

CDS_DIR = Path('assets/data/cds')

def audit_file(filepath):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except Exception as e:
        print(f"Error reading {filepath.name}: {e}")
        return

    filename = filepath.name
    conditions = data.get('conditions', [])
    
    print(f"\n--- {filename} ({len(conditions)} conditions) ---")
    
    suspicious_markers = ['TODO', 'FIXME', 'PENDING', 'INSERT', 'LOREM', 'IPSUM']
    
    for condition in conditions:
        cond_name = condition.get('name', 'Unknown')
        sections = condition.get('sections', {})
        
        for section_id, section in sections.items():
            if section_id == 'references':
                continue
                
            content = section.get('content', {})
            
            # Helper to recursively check content
            def check_content(obj, path):
                issues = []
                if isinstance(obj, str):
                    # Check for markers
                    for marker in suspicious_markers:
                        if marker in obj.upper():
                            issues.append(f"  [MARKER] Found '{marker}' in {path}")
                    
                    # Check for shortness (heuristic)
                    words = obj.split()
                    if len(words) < 3 and len(obj) > 0:
                         # Ignore common short strings like "None" or "N/A" if they are valid, but flag them for review
                         if obj.lower() not in ['none', 'n/a', 'none.', 'not applicable', 'not applicable.']:
                            issues.append(f"  [SHORT] Very short content in {path}: '{obj}'")
                    
                    if len(obj.strip()) == 0:
                        issues.append(f"  [EMPTY] Empty string in {path}")
                        
                elif isinstance(obj, dict):
                    for k, v in obj.items():
                        issues.extend(check_content(v, f"{path}.{k}"))
                elif isinstance(obj, list):
                    for i, v in enumerate(obj):
                        issues.extend(check_content(v, f"{path}[{i}]"))
                return issues

            issues = check_content(content, f"{cond_name}.{section_id}")
            for issue in issues:
                print(issue)

def main():
    if not CDS_DIR.exists():
        print("Directory not found")
        return

    files = sorted(list(CDS_DIR.glob('*.json')))
    for f in files:
        audit_file(f)

if __name__ == '__main__':
    main()
