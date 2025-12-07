# History Integration Verification Script
# Verifies that all 47 interactive tools are properly integrated with unified history

Write-Host "`n╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     HISTORY INTEGRATION VERIFICATION SCRIPT                    ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

$ErrorCount = 0
$WarningCount = 0
$SuccessCount = 0

# Define all 29 calculators
$calculators = @(
    "clabsi_calculator.dart",
    "cauti_calculator.dart",
    "ssi_calculator.dart",
    "vae_calculator.dart",
    "blood_culture_contamination_calculator.dart",
    "sick_leave_rate_calculator.dart",
    "nsi_rate_calculator.dart",
    "pep_percentage_calculator.dart",
    "appropriate_specimen_calculator.dart",
    "tat_compliance_calculator.dart",
    "rejection_rate_calculator.dart",
    "ddd_calculator.dart",
    "dur_calculator.dart",
    "colonization_pressure_calculator.dart",
    "mdro_incidence_calculator.dart",
    "antibiotic_utilization_calculator.dart",
    "dot_calculator.dart",
    "culture_guided_therapy_calculator.dart",
    "deescalation_rate_calculator.dart",
    "bundle_compliance_calculator.dart",
    "infection_reduction_calculator.dart",
    "ipc_audit_score_calculator.dart",
    "isolation_compliance_calculator.dart",
    "observation_compliance_calculator.dart",
    "screening_yield_calculator.dart",
    "vaccination_coverage_calculator.dart",
    "environmental_positivity_rate_calculator.dart",
    "disinfection_compliance_calculator.dart",
    "sterilization_failure_rate_calculator.dart"
)

Write-Host "📊 PHASE 1: Verifying Calculator Imports" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════════`n" -ForegroundColor Yellow

foreach ($calc in $calculators) {
    $filePath = "lib/features/calculator/presentation/calculators/$calc"
    
    if (Test-Path $filePath) {
        $content = Get-Content $filePath -Raw
        
        # Check for unified history imports
        $hasHistoryEntry = $content -match "import.*history_entry\.dart"
        $hasHistoryRepo = $content -match "import.*history_repository\.dart"
        
        # Check for old imports (should be removed)
        $hasSharedPrefs = $content -match "import.*shared_preferences"
        $hasDartConvert = $content -match "import 'dart:convert'"
        
        # Check for HistoryEntry.fromCalculator usage
        $hasFromCalculator = $content -match "HistoryEntry\.fromCalculator"
        
        if ($hasHistoryEntry -and $hasHistoryRepo -and $hasFromCalculator -and -not $hasSharedPrefs) {
            Write-Host "  ✅ $calc" -ForegroundColor Green
            $SuccessCount++
        } else {
            Write-Host "  ❌ $calc" -ForegroundColor Red
            if (-not $hasHistoryEntry) { Write-Host "     Missing: history_entry.dart import" -ForegroundColor Red }
            if (-not $hasHistoryRepo) { Write-Host "     Missing: history_repository.dart import" -ForegroundColor Red }
            if (-not $hasFromCalculator) { Write-Host "     Missing: HistoryEntry.fromCalculator usage" -ForegroundColor Red }
            if ($hasSharedPrefs) { Write-Host "     Found: shared_preferences import (should be removed)" -ForegroundColor Red }
            $ErrorCount++
        }
    } else {
        Write-Host "  ⚠️  $calc - FILE NOT FOUND" -ForegroundColor Yellow
        $WarningCount++
    }
}

Write-Host "`n📊 PHASE 2: Verifying Outbreak Tools" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════════`n" -ForegroundColor Yellow

$outbreakTools = @(
    "attack_rate_tool.dart",
    "secondary_attack_rate_tool.dart",
    "case_fatality_rate_tool.dart",
    "incidence_rate_tool.dart",
    "prevalence_rate_tool.dart",
    "odds_ratio_tool.dart",
    "relative_risk_tool.dart",
    "chi_square_tool.dart",
    "confidence_interval_tool.dart",
    "sample_size_tool.dart",
    "epidemic_curve_tool.dart",
    "spot_map_tool.dart",
    "line_list_tool.dart",
    "contact_tracing_tool.dart",
    "outbreak_detection_tool.dart",
    "reproduction_number_tool.dart",
    "doubling_time_tool.dart",
    "generation_time_tool.dart"
)

$outbreakToolsPath = "lib/features/outbreak/presentation/tools"

foreach ($tool in $outbreakTools) {
    $filePath = "$outbreakToolsPath/$tool"
    
    if (Test-Path $filePath) {
        $content = Get-Content $filePath -Raw
        
        # Check for unified history usage
        $hasHistoryEntry = $content -match "HistoryEntry\.fromOutbreakTool" -or $content -match "HistoryEntry\.fromCalculator"
        $hasHistoryRepo = $content -match "HistoryRepository"
        
        if ($hasHistoryEntry -and $hasHistoryRepo) {
            Write-Host "  ✅ $tool" -ForegroundColor Green
            $SuccessCount++
        } else {
            Write-Host "  ⚠️  $tool - May need verification" -ForegroundColor Yellow
            $WarningCount++
        }
    } else {
        Write-Host "  ⚠️  $tool - FILE NOT FOUND" -ForegroundColor Yellow
        $WarningCount++
    }
}

Write-Host "`n📊 PHASE 3: Verifying History Infrastructure" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════════`n" -ForegroundColor Yellow

$infrastructureFiles = @{
    "History Model" = "lib/features/outbreak/data/models/history_entry.dart"
    "History Repository" = "lib/features/outbreak/data/repositories/history_repository.dart"
    "History Service" = "lib/features/outbreak/data/services/history_service.dart"
    "History Export Service" = "lib/features/outbreak/data/services/history_export_service.dart"
    "History Providers" = "lib/features/outbreak/data/providers/history_providers.dart"
    "History Screen" = "lib/features/outbreak/presentation/screens/history_hub_screen.dart"
    "History Card" = "lib/features/home/widgets/history_card.dart"
    "History Export Dialog" = "lib/features/outbreak/presentation/widgets/history_export_dialog.dart"
}

foreach ($item in $infrastructureFiles.GetEnumerator()) {
    if (Test-Path $item.Value) {
        Write-Host "  ✅ $($item.Key)" -ForegroundColor Green
        $SuccessCount++
    } else {
        Write-Host "  ❌ $($item.Key) - NOT FOUND" -ForegroundColor Red
        $ErrorCount++
    }
}

Write-Host "`n📊 PHASE 4: Verifying Router Configuration" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════════`n" -ForegroundColor Yellow

$routerPath = "lib/app/router.dart"
if (Test-Path $routerPath) {
    $routerContent = Get-Content $routerPath -Raw
    
    # Check for /history route
    if ($routerContent -match "path: '/history'") {
        Write-Host "  ✅ /history route configured" -ForegroundColor Green
        $SuccessCount++
    } else {
        Write-Host "  ❌ /history route NOT FOUND" -ForegroundColor Red
        $ErrorCount++
    }
    
    # Check for HistoryHubScreen
    if ($routerContent -match "HistoryHubScreen") {
        Write-Host "  ✅ HistoryHubScreen referenced" -ForegroundColor Green
        $SuccessCount++
    } else {
        Write-Host "  ❌ HistoryHubScreen NOT FOUND" -ForegroundColor Red
        $ErrorCount++
    }
} else {
    Write-Host "  ❌ router.dart NOT FOUND" -ForegroundColor Red
    $ErrorCount++
}

Write-Host "`n📊 PHASE 5: Verifying Home Screen Integration" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════════`n" -ForegroundColor Yellow

$homeScreenPath = "lib/features/home/presentation/home_screen.dart"
if (Test-Path $homeScreenPath) {
    $homeContent = Get-Content $homeScreenPath -Raw
    
    # Check for HistoryCard import
    if ($homeContent -match "import.*history_card\.dart") {
        Write-Host "  ✅ HistoryCard imported" -ForegroundColor Green
        $SuccessCount++
    } else {
        Write-Host "  ❌ HistoryCard import NOT FOUND" -ForegroundColor Red
        $ErrorCount++
    }
    
    # Check for HistoryCard usage
    if ($homeContent -match "HistoryCard\(\)") {
        Write-Host "  ✅ HistoryCard used in home screen" -ForegroundColor Green
        $SuccessCount++
    } else {
        Write-Host "  ❌ HistoryCard NOT USED" -ForegroundColor Red
        $ErrorCount++
    }
} else {
    Write-Host "  ❌ home_screen.dart NOT FOUND" -ForegroundColor Red
    $ErrorCount++
}

Write-Host "`n╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                    VERIFICATION SUMMARY                        ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

Write-Host "✅ Success: $SuccessCount" -ForegroundColor Green
Write-Host "⚠️  Warnings: $WarningCount" -ForegroundColor Yellow
Write-Host "❌ Errors: $ErrorCount" -ForegroundColor Red

$totalChecks = $SuccessCount + $WarningCount + $ErrorCount
$successRate = [math]::Round(($SuccessCount / $totalChecks) * 100, 2)

Write-Host "`nSuccess Rate: $successRate%" -ForegroundColor $(if ($successRate -ge 90) { "Green" } elseif ($successRate -ge 70) { "Yellow" } else { "Red" })

if ($ErrorCount -eq 0 -and $WarningCount -eq 0) {
    Write-Host "`n🎉 ALL CHECKS PASSED! History integration is complete." -ForegroundColor Green
} elseif ($ErrorCount -eq 0) {
    Write-Host "`n⚠️  All critical checks passed, but there are warnings to review." -ForegroundColor Yellow
} else {
    Write-Host "`n❌ There are errors that need to be fixed." -ForegroundColor Red
}

Write-Host ""

