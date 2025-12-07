# AMS Color Refactor - Automated Batch Processing Guide

## 📋 Overview

This guide explains how to use the automated batch processing script to complete the AMS color refactor across the remaining 22 content screens (1,051 hardcoded colors).

---

## 🎯 What This Script Does

The `batch_color_refactor.ps1` script automates the replacement of hardcoded color values with semantic color tokens across all remaining AMS content screens.

**Key Features**:
- ✅ **Automatic Backup**: Creates timestamped backup before any changes
- ✅ **Semantic Mapping**: Replaces colors based on AMS_COLOR_STYLE_GUIDE.md rules
- ✅ **Compilation Verification**: Runs `flutter analyze` after processing
- ✅ **Progress Reporting**: Shows detailed progress for each file
- ✅ **Error Handling**: Captures and reports any processing errors
- ✅ **Rollback Capability**: Easy restoration from backup if needed

---

## 🚀 Quick Start

### Prerequisites
- PowerShell 5.1+ (Windows)
- Flutter SDK installed and in PATH
- Working directory: `c:\Users\yzdy1\ipc_guider - Copy`

### Execution Steps

1. **Open PowerShell** (as Administrator recommended):
   ```powershell
   cd "c:\Users\yzdy1\ipc_guider - Copy"
   ```

2. **Run the script**:
   ```powershell
   .\scripts\batch_color_refactor.ps1
   ```

3. **Review the output**:
   - Backup location will be displayed
   - Progress for each file will be shown
   - Final summary with total replacements

4. **Verify results**:
   ```bash
   flutter analyze
   flutter run
   ```

---

## 📊 What Gets Processed

### Files (22 screens)

**Medium Screens (3 files, ~75 colors)**:
- `consumption_metrics_screen.dart` (25 colors)
- `process_outcome_measures_screen.dart` (25 colors)
- `benchmarking_reporting_screen.dart` (31 colors)

**Large Screens (19 files, ~976 colors)**:
- `what_is_antibiogram_screen.dart` (37)
- `continuous_improvement_screen.dart` (37)
- `rational_use_screen.dart` (40)
- `clinical_implications_screen.dart` (41)
- `resistance_mechanisms_screen.dart` (46)
- `audit_feedback_screen.dart` (47)
- `understanding_resistance_screen.dart` (49)
- `empiric_definitive_screen.dart` (52)
- `clinical_pathways_screen.dart` (53)
- `interpreting_antibiogram_screen.dart` (53)
- `dosing_optimization_screen.dart` (54)
- `education_behavioral_screen.dart` (54)
- `antibiogram_construction_screen.dart` (56)
- `preauthorization_screen.dart` (56)
- `genetic_basis_screen.dart` (57)
- `iv_to_oral_screen.dart` (57)
- `antibiogram_guided_prescribing_screen.dart` (62)
- `special_populations_screen.dart` (65)
- `duration_therapy_screen.dart` (69)

---

## 🎨 Color Mapping Rules

The script applies the following semantic color mappings based on the AMS Color Style Guide:

| Original Hex Color | Semantic Token | Use Case |
|:-------------------|:---------------|:---------|
| `0xFFF44336` (Red) | `AppColors.error` | Critical resistance mechanisms |
| `0xFFD32F2F` (Dark Red) | `AppColors.error` | Priority pathogens (CRE, VRE) |
| `0xFFE91E63` (Pink) | `AppColors.error` | Critical warnings |
| `0xFFFF9800` (Orange) | `AppColors.warning` | Special considerations |
| `0xFFFF6F00` (Dark Orange) | `AppColors.warning` | Cautions |
| `0xFF4CAF50` (Green) | `AppColors.success` | Best practices |
| `0xFF059669` (Dark Green) | `AppColors.success` | Quality control |
| `0xFF2196F3` (Blue) | `AppColors.info` | Laboratory standards |
| `0xFF1976D2` (Dark Blue) | `AppColors.info` | Guidelines |
| `0xFF00BCD4` (Cyan) | `AppColors.info` | Informational content |
| `0xFF4A90A4` (Teal) | `AppColors.primary` | Clinical concepts |
| `0xFF009688` (Dark Teal) | `AppColors.primary` | General clinical |
| `0xFF9C27B0` (Purple) | `AppColors.info` | Replaced with blue |
| `0xFF673AB7` (Deep Purple) | `AppColors.info` | Replaced with blue |
| `0xFF795548` (Brown) | `AppColors.error` | Critical pathogens |

---

## 🔍 Expected Output

### Console Output Example

```
========================================
AMS Color Refactor - Batch Processor
========================================

[STEP 1] Creating backup...
✅ Backed up 22 files to: backups\color_refactor_20251119_143022

[STEP 2] Processing files...

Processing: consumption_metrics_screen.dart
  ✅ Replaced 25 colors

Processing: process_outcome_measures_screen.dart
  ✅ Replaced 25 colors

...

[STEP 3] Verifying compilation...

✅ Compilation successful - 0 new errors

========================================
BATCH PROCESSING COMPLETE
========================================

📊 Summary:
  • Files processed: 22 / 22
  • Total replacements: 1051
  • Backup location: backups\color_refactor_20251119_143022

✅ Next Steps:
  1. Run: flutter analyze
  2. Run: flutter run (test app functionality)
  3. Verify UI/UX visually
  4. If issues found, restore from: backups\color_refactor_20251119_143022

========================================
```

---

## 🛡️ Safety Features

### 1. Automatic Backup
- **Location**: `backups\color_refactor_YYYYMMDD_HHMMSS\`
- **Contents**: All 22 files before any modifications
- **Retention**: Manual cleanup (not auto-deleted)

### 2. Compilation Verification
- Runs `flutter analyze` after all replacements
- Reports any new errors or warnings
- Does NOT auto-rollback (manual decision)

### 3. Error Handling
- Captures file processing errors
- Reports failed files in summary
- Continues processing remaining files

---

## 🔄 Rollback Procedure

If you need to restore the original files:

### Option 1: Manual Restore (Recommended)
```powershell
# Copy backup files back to original location
$backupPath = "backups\color_refactor_YYYYMMDD_HHMMSS"
$contentPath = "lib\features\stewardship\presentation\content"

Copy-Item -Path "$backupPath\*" -Destination $contentPath -Force
```

### Option 2: Git Restore (if committed)
```bash
git checkout lib/features/stewardship/presentation/content/
```

---

## ✅ Verification Checklist

After running the script, verify the following:

### 1. Compilation
```bash
flutter analyze
# Expected: 0 new errors (57 pre-existing deprecation warnings OK)
```

### 2. Visual Inspection
```bash
flutter run
```
- Navigate to Antimicrobial Stewardship module
- Open 3-5 random screens
- Verify colors look professional and semantically correct
- Check:
  - ✅ Red for critical resistance/pathogens
  - ✅ Amber for special considerations
  - ✅ Green for best practices
  - ✅ Blue for informational content
  - ✅ Teal for clinical concepts

### 3. Functionality Testing
- ✅ All screens load without crashes
- ✅ Navigation works (back button, links)
- ✅ References open correctly
- ✅ Cards render properly
- ✅ No layout issues

### 4. Accessibility
- ✅ Text remains readable (contrast ratios maintained)
- ✅ RTL layout works (if applicable)
- ✅ Text scaling works (increase font size in settings)

---

## 🐛 Troubleshooting

### Issue: Script execution policy error
**Error**: `cannot be loaded because running scripts is disabled`

**Solution**:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Issue: Flutter not found
**Error**: `flutter : The term 'flutter' is not recognized`

**Solution**:
1. Verify Flutter is installed: `flutter --version`
2. Add Flutter to PATH if needed
3. Restart PowerShell

### Issue: Compilation errors after processing
**Symptom**: `flutter analyze` shows new errors

**Solution**:
1. Review error messages
2. Check if errors are related to color changes
3. If yes, restore from backup and report issue
4. If no, errors may be pre-existing

### Issue: Colors look wrong visually
**Symptom**: Colors don't match semantic meaning

**Solution**:
1. Review AMS_COLOR_STYLE_GUIDE.md
2. Check specific screen content
3. May need manual adjustment for edge cases
4. Report specific screens for review

---

## 📞 Support

If you encounter issues:

1. **Check the backup**: Verify backup was created successfully
2. **Review logs**: Check PowerShell output for error messages
3. **Test incrementally**: Restore backup, process 1-2 files manually
4. **Report issues**: Document specific files/errors for review

---

## 📚 Related Documentation

- **Style Guide**: `docs/AMS_COLOR_STYLE_GUIDE.md`
- **Implementation Tracking**: `docs/AMS_COLOR_REFACTOR_IMPLEMENTATION.md`
- **Design Tokens**: `lib/core/design/design_tokens.dart`

---

**Last Updated**: 2025-11-19  
**Script Version**: 1.0  
**Tested On**: Windows 11, PowerShell 5.1, Flutter 3.x

