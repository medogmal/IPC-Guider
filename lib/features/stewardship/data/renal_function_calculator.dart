import 'dart:math';
import '../domain/models/renal_function.dart';

/// Renal Function Calculator
/// Implements Cockcroft-Gault, MDRD, and CKD-EPI formulas
class RenalFunctionCalculator {
  /// Calculate CrCl using Cockcroft-Gault formula
  /// CrCl (mL/min) = [(140 - age) × weight × (0.85 if female)] / (72 × SCr)
  /// 
  /// Most widely used for drug dosing
  static double calculateCockcroftGault(PatientInfo patient) {
    final genderFactor = patient.isMale ? 1.0 : 0.85;
    final crCl = ((140 - patient.age) * patient.weight * genderFactor) /
        (72 * patient.serumCreatinine);
    return crCl;
  }

  /// Calculate eGFR using MDRD formula (2021 update - race-free)
  /// eGFR (mL/min/1.73m²) = 175 × SCr^(-1.154) × age^(-0.203) × (0.742 if female)
  ///
  /// Common in lab reports
  /// Note: Race coefficient removed per 2021 NKF-ASN Task Force recommendations
  static double calculateMdrd(PatientInfo patient) {
    final genderFactor = patient.isMale ? 1.0 : 0.742;
    final eGfr = 175 *
        pow(patient.serumCreatinine, -1.154) *
        pow(patient.age, -0.203) *
        genderFactor;
    return eGfr.toDouble();
  }

  /// Calculate eGFR using CKD-EPI formula (2021 update - race-free)
  /// Most accurate for CKD staging
  ///
  /// eGFR = 141 × min(SCr/κ, 1)^α × max(SCr/κ, 1)^(-1.209) × 0.993^age × (1.018 if female)
  /// where κ = 0.7 (female) or 0.9 (male)
  /// and α = -0.329 (female) or -0.411 (male)
  /// Note: Race coefficient removed per 2021 NKF-ASN Task Force recommendations
  static double calculateCkdEpi(PatientInfo patient) {
    final kappa = patient.isMale ? 0.9 : 0.7;
    final alpha = patient.isMale ? -0.411 : -0.329;
    final genderFactor = patient.isMale ? 1.0 : 1.018;

    final scrKappa = patient.serumCreatinine / kappa;
    final minTerm = pow(min(scrKappa, 1.0), alpha);
    final maxTerm = pow(max(scrKappa, 1.0), -1.209);
    final ageTerm = pow(0.993, patient.age);

    final eGfr = 141 * minTerm * maxTerm * ageTerm * genderFactor;
    return eGfr.toDouble();
  }

  /// Calculate all renal function parameters
  static RenalFunctionResult calculateAll(
    PatientInfo patient, {
    String preferredMethod = 'cockcroft-gault',
  }) {
    final crCl = calculateCockcroftGault(patient);
    final eGfrMdrd = calculateMdrd(patient);
    final eGfrCkdEpi = calculateCkdEpi(patient);

    // Determine category based on preferred method
    double primaryValue;
    switch (preferredMethod) {
      case 'mdrd':
        primaryValue = eGfrMdrd;
        break;
      case 'ckd-epi':
        primaryValue = eGfrCkdEpi;
        break;
      case 'cockcroft-gault':
      default:
        primaryValue = crCl;
        break;
    }

    final category = RenalCategory.fromCrCl(primaryValue);

    return RenalFunctionResult(
      crClCockcroftGault: crCl,
      eGfrMdrd: eGfrMdrd,
      eGfrCkdEpi: eGfrCkdEpi,
      category: category,
      calculationMethod: preferredMethod,
    );
  }

  /// Validate patient info
  static String? validatePatientInfo(PatientInfo patient) {
    if (patient.age < 18 || patient.age > 120) {
      return 'Age must be between 18 and 120 years';
    }
    if (patient.weight < 30 || patient.weight > 300) {
      return 'Weight must be between 30 and 300 kg';
    }
    if (patient.serumCreatinine < 0.1 || patient.serumCreatinine > 20) {
      return 'Serum creatinine must be between 0.1 and 20 mg/dL';
    }
    return null;
  }

  /// Get renal function interpretation
  static String getInterpretation(RenalCategory category) {
    switch (category) {
      case RenalCategory.normal:
        return 'Normal kidney function. Standard antibiotic dosing typically appropriate.';
      case RenalCategory.mild:
        return 'Mild kidney impairment. Most antibiotics require no adjustment, but monitor closely.';
      case RenalCategory.moderate:
        return 'Moderate kidney impairment. Many antibiotics require dose reduction or interval extension.';
      case RenalCategory.severe:
        return 'Severe kidney impairment. Most antibiotics require significant dose adjustment.';
      case RenalCategory.esrd:
        return 'End-stage renal disease. Careful dose adjustment required. Consider hemodialysis/CRRT status.';
    }
  }

  /// Get color for renal category
  static String getCategoryColor(RenalCategory category) {
    switch (category) {
      case RenalCategory.normal:
        return 'success';
      case RenalCategory.mild:
        return 'info';
      case RenalCategory.moderate:
        return 'warning';
      case RenalCategory.severe:
        return 'error';
      case RenalCategory.esrd:
        return 'error';
    }
  }
}

