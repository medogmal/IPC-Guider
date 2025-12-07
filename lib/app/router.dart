import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/design/design_tokens.dart';

import '../features/home/presentation/home_screen.dart';
import '../features/isolation/presentation/isolation_list_screen.dart';
import '../features/isolation/presentation/isolation_detail_screen.dart';
import '../features/isolation/presentation/general_principles_screen.dart';
import '../features/quiz/presentation/quiz_screen.dart';

// Calculator imports
import '../features/calculator/presentation/calculator_home_screen.dart';
import '../features/calculator/presentation/calculator_formula_screen.dart';
import '../features/calculator/presentation/calculators/clabsi_calculator.dart';
import '../features/calculator/presentation/calculators/cauti_calculator.dart';
import '../features/calculator/presentation/calculators/vae_calculator.dart';
import '../features/calculator/presentation/calculators/ssi_calculator.dart';
import '../features/calculator/presentation/calculators/dur_calculator.dart';
import '../features/calculator/presentation/calculators/mdro_incidence_calculator.dart';
import '../features/calculator/presentation/calculators/colonization_pressure_calculator.dart';
import '../features/calculator/presentation/calculators/screening_yield_calculator.dart';
import '../features/calculator/presentation/calculators/infection_reduction_calculator.dart';
import '../features/calculator/presentation/calculators/isolation_compliance_calculator.dart';
import '../features/calculator/presentation/calculators/dot_calculator.dart';
import '../features/calculator/presentation/calculators/ddd_calculator.dart';
import '../features/calculator/presentation/calculators/antibiotic_utilization_calculator.dart';
import '../features/calculator/presentation/calculators/deescalation_rate_calculator.dart';
import '../features/calculator/presentation/calculators/culture_guided_therapy_calculator.dart';
import '../features/calculator/presentation/calculators/bundle_compliance_calculator.dart';
import '../features/calculator/presentation/calculators/ipc_audit_score_calculator.dart';
import '../features/calculator/presentation/calculators/observation_compliance_calculator.dart';
import '../features/calculator/presentation/calculators/compliance_trend_tracker.dart';
import '../features/calculator/presentation/calculators/blood_culture_contamination_calculator.dart';
import '../features/calculator/presentation/calculators/appropriate_specimen_calculator.dart';
import '../features/calculator/presentation/calculators/tat_compliance_calculator.dart';
import '../features/calculator/presentation/calculators/rejection_rate_calculator.dart';
import '../features/calculator/presentation/calculators/vaccination_coverage_calculator.dart';
import '../features/calculator/presentation/calculators/nsi_rate_calculator.dart';
import '../features/calculator/presentation/calculators/pep_percentage_calculator.dart';
import '../features/calculator/presentation/calculators/sick_leave_rate_calculator.dart';
import '../features/calculator/presentation/calculators/environmental_positivity_rate_calculator.dart';
import '../features/calculator/presentation/calculators/disinfection_compliance_calculator.dart';
import '../features/calculator/presentation/calculators/sterilization_failure_rate_calculator.dart';

// Settings, Profile, and About imports
import '../features/settings/presentation/settings_screen.dart';
import '../features/settings/presentation/history_cleanup_screen.dart';
import '../features/settings/presentation/quick_actions_settings_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/about/presentation/about_screen.dart';
import '../features/outbreak/presentation/outbreak_home_screen.dart';
import '../features/outbreak/presentation/foundations_screen.dart';
import '../features/outbreak/presentation/detection_screen.dart';
import '../features/outbreak/presentation/analytics_screen.dart';
import '../features/outbreak/presentation/outbreak_groups_screen.dart';
import '../features/outbreak/presentation/group_detail_screen.dart';

// Clinical Decision Support imports
import '../features/clinical_decision_support/presentation/screens/cds_home_screen.dart';
import '../features/clinical_decision_support/presentation/screens/cds_category_screen.dart';
import '../features/clinical_decision_support/presentation/screens/cds_condition_detail_screen.dart';
import '../features/outbreak/presentation/pathogen_detail_screen.dart';
import '../features/outbreak/data/models/pathogen_detail.dart';
import '../features/outbreak/presentation/control_screen.dart';
import '../features/outbreak/presentation/operations_screen.dart';
import '../features/outbreak/presentation/outbreak_detail_screen.dart';
import '../features/outbreak/presentation/content/infection_colonization_screen.dart';
import '../features/outbreak/presentation/content/case_carrier_screen.dart';
import '../features/outbreak/presentation/content/disease_levels_screen.dart';
import '../features/outbreak/presentation/content/chain_infection_screen.dart';
import '../features/outbreak/presentation/content/susceptibility_screen.dart';
import '../features/outbreak/presentation/content/breaking_chain_screen.dart';
import '../features/outbreak/presentation/content/prevention_levels_screen.dart';
import '../features/outbreak/presentation/content/immediate_measures_screen.dart';
import '../features/outbreak/presentation/content/environmental_measures_screen.dart';
import '../features/placeholder/presentation/placeholder_screen.dart';
import '../features/bundle/presentation/screens/bundle_screen.dart';
import '../features/bundle/presentation/screens/bundle_detail_screen.dart';
import '../features/bundle/presentation/screens/bundle_references_screen.dart';
import '../features/bundle/presentation/screens/tools/bundle_tools_hub_screen.dart';
import '../features/bundle/presentation/screens/tools/bundle_audit_tool_screen.dart';
import '../features/bundle/presentation/screens/tools/bundle_gap_analysis_tool_screen.dart';
import '../features/bundle/presentation/screens/tools/bundle_risk_assessment_tool_screen.dart';
import '../features/bundle/presentation/screens/tools/bundle_performance_dashboard_screen.dart';
import '../features/bundle/presentation/screens/tools/sepsis_bundle_checker_screen.dart';
import '../features/bundle/presentation/screens/tools/bundle_comparison_tool_screen.dart';
import '../features/bundle/data/models/bundle.dart';

// Hand Hygiene imports
import '../features/hand_hygiene/presentation/screens/hand_hygiene_home_screen.dart';
import '../features/hand_hygiene/presentation/screens/hand_hygiene_section_detail_screen.dart';
import '../features/hand_hygiene/presentation/screens/hand_hygiene_page_detail_screen.dart';
import '../features/hand_hygiene/presentation/screens/hand_hygiene_references_screen.dart';
import '../features/hand_hygiene/presentation/screens/tools/hand_hygiene_tools_hub_screen.dart';
import '../features/hand_hygiene/presentation/screens/tools/product_usage_tracker_screen.dart';
import '../features/hand_hygiene/presentation/screens/tools/who_observation_tool_screen.dart';
import '../features/hand_hygiene/presentation/screens/tools/dispenser_placement_optimizer_screen.dart';

// Antimicrobial Stewardship imports
import '../features/stewardship/presentation/screens/stewardship_home_screen.dart';
import '../features/stewardship/presentation/screens/stewardship_section_detail_screen.dart';
import '../features/stewardship/presentation/screens/stewardship_tools_hub_screen.dart';
import '../features/stewardship/presentation/screens/tools/antibiogram_builder_screen.dart';
import '../features/stewardship/presentation/screens/tools/renal_dose_calculator_screen.dart';
import '../features/stewardship/presentation/screens/tools/spectrum_visualizer_screen.dart';
import '../features/stewardship/presentation/screens/tools/surgical_prophylaxis_advisor_screen.dart';
import '../features/stewardship/presentation/screens/tools/allergy_checker_screen.dart';
import '../features/stewardship/presentation/screens/tools/mdro_risk_calculator_screen.dart';
// Section 1: Fundamentals
import '../features/stewardship/presentation/content/what_is_ams_screen.dart';
import '../features/stewardship/presentation/content/stewardship_team_screen.dart';
import '../features/stewardship/presentation/content/stewardship_strategies_screen.dart';
import '../features/stewardship/presentation/content/measuring_success_screen.dart';
import '../features/stewardship/presentation/content/barriers_enablers_screen.dart';
// Section 2: Antimicrobial Resistance Mechanisms
import '../features/stewardship/presentation/content/understanding_resistance_screen.dart';
import '../features/stewardship/presentation/content/resistance_mechanisms_screen.dart';
import '../features/stewardship/presentation/content/genetic_basis_screen.dart';
import '../features/stewardship/presentation/content/priority_mdros_screen.dart';
import '../features/stewardship/presentation/content/clinical_implications_screen.dart';
// Section 3: Antibiogram Development & Interpretation
import '../features/stewardship/presentation/content/what_is_antibiogram_screen.dart';
import '../features/stewardship/presentation/content/antibiogram_construction_screen.dart';
import '../features/stewardship/presentation/content/interpreting_antibiogram_screen.dart';
import '../features/stewardship/presentation/content/antibiogram_guided_prescribing_screen.dart';
// Section 4: Prescribing Principles & Guidelines
import '../features/stewardship/presentation/content/rational_use_screen.dart';
import '../features/stewardship/presentation/content/empiric_definitive_screen.dart';
import '../features/stewardship/presentation/content/dosing_optimization_screen.dart';
import '../features/stewardship/presentation/content/iv_to_oral_screen.dart';
import '../features/stewardship/presentation/content/duration_therapy_screen.dart';
import '../features/stewardship/presentation/content/special_populations_screen.dart';
import '../features/stewardship/presentation/content/surgical_prophylaxis_screen.dart';
// Section 5: Stewardship Interventions
import '../features/stewardship/presentation/content/audit_feedback_screen.dart';
import '../features/stewardship/presentation/content/preauthorization_screen.dart';
import '../features/stewardship/presentation/content/clinical_pathways_screen.dart';
import '../features/stewardship/presentation/content/education_behavioral_screen.dart';

// Section 6: Monitoring & Reporting
import '../features/stewardship/presentation/content/consumption_metrics_screen.dart';
import '../features/stewardship/presentation/content/process_outcome_measures_screen.dart';
import '../features/stewardship/presentation/content/benchmarking_reporting_screen.dart';
import '../features/stewardship/presentation/content/continuous_improvement_screen.dart';

// Section 7: Laboratory Diagnostics & Antimicrobial Susceptibility Testing
import '../features/stewardship/presentation/content/clsi_breakpoints_screen.dart';
import '../features/stewardship/presentation/content/mic_testing_scenarios_screen.dart';
import '../features/stewardship/presentation/content/rapid_diagnostics_screen.dart';
import '../features/stewardship/presentation/content/resistance_ast_pitfalls_screen.dart';
import '../features/stewardship/presentation/content/intrinsic_resistance_screen.dart';

// Outbreak Detection Steps
import '../features/outbreak/presentation/steps/step_01_recognize_screen.dart';
import '../features/outbreak/presentation/steps/step_02_verify_screen.dart';
import '../features/outbreak/presentation/steps/step_03_alert_screen.dart';
import '../features/outbreak/presentation/steps/step_04_case_definition_screen.dart';
import '../features/outbreak/presentation/steps/step_05_case_finding_screen.dart';
import '../features/outbreak/presentation/steps/step_07_hypotheses_screen.dart';
import '../features/outbreak/presentation/steps/step_08_analytical_studies_screen.dart';
import '../features/outbreak/presentation/steps/step_09_control_measures_screen.dart';
import '../features/outbreak/presentation/steps/step_10_environmental_screen.dart';
import '../features/outbreak/presentation/steps/step_11_communication_screen.dart';
import '../features/outbreak/presentation/steps/step_12_surveillance_screen.dart';
import '../features/outbreak/presentation/thresholds_triggers_screen.dart';
import '../features/outbreak/presentation/surveillance_type_screen.dart';
import '../features/outbreak/presentation/tools/attack_rate_calculator.dart';
import '../features/outbreak/presentation/tools/relative_risk_calculator.dart';
import '../features/outbreak/presentation/tools/odds_ratio_calculator.dart';
import '../features/outbreak/presentation/tools/secondary_attack_rate_calculator.dart';
import '../features/outbreak/presentation/tools/case_fatality_rate_calculator.dart';
import '../features/outbreak/presentation/tools/enhanced_sensitivity_specificity_calculator.dart';
import '../features/outbreak/presentation/tools/p_value_calculator.dart';
import '../features/outbreak/presentation/tools/sample_size_calculator.dart';
import '../features/outbreak/presentation/tools/case_definition_builder.dart';
import '../features/outbreak/presentation/tools/line_list_tool.dart';
import '../features/outbreak/presentation/tools/histogram_tool.dart';
import '../features/outbreak/presentation/tools/enhanced_epidemic_curve_generator.dart';
import '../features/outbreak/presentation/tools/comparison_tool.dart';
import '../features/outbreak/presentation/tools/outbreak_timeline_tool.dart';
import '../features/outbreak/presentation/tools/control_checklist.dart';
import '../features/outbreak/presentation/tools/contact_tracing_tool.dart';
import '../features/outbreak/presentation/tools/risk_assessment_tool.dart';
import '../features/outbreak/presentation/tools/disinfectant_selection_tool.dart';
import '../features/outbreak/presentation/screens/history_hub_screen.dart';

// Operations & Management screen imports
import '../features/outbreak/presentation/operations/team_structure_screen.dart';
import '../features/outbreak/presentation/operations/risk_assessment_screen.dart';
import '../features/outbreak/presentation/operations/action_plan_screen.dart';
import '../features/outbreak/presentation/operations/meeting_documentation_screen.dart';
import '../features/outbreak/presentation/operations/stakeholder_communication_screen.dart';
import '../features/outbreak/presentation/operations/outbreak_checklist_screen.dart';
import '../features/outbreak/presentation/operations/resource_management_screen.dart';
import '../features/outbreak/presentation/operations/quality_monitoring_screen.dart';
import '../features/outbreak/presentation/operations/post_outbreak_evaluation_screen.dart';
import '../features/outbreak/presentation/operations/legal_compliance_screen.dart';
import '../features/outbreak/presentation/operations/training_competency_screen.dart';
import '../features/outbreak/presentation/operations/classification_screen.dart';
import '../features/outbreak/presentation/operations/end_outbreak_screen.dart';
import '../features/outbreak/presentation/operations/reporting_screen.dart';
import '../features/outbreak/presentation/operations/alerts_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/isolation',
        name: 'isolation',
        builder: (context, state) => const IsolationListScreen(),
        routes: [
          GoRoute(
            path: 'principles',
            name: 'isolationPrinciples',
            builder: (context, state) => const GeneralPrinciplesScreen(),
          ),
          GoRoute(
            path: ':id',
            name: 'isolationDetail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return IsolationDetailScreen(entityId: id);
            },
          ),
        ],
      ),

      GoRoute(
        path: '/quiz/:module',
        name: 'quizModule',
        builder: (context, state) {
          final module = state.pathParameters['module'] ?? 'isolation';
          return QuizScreen(moduleId: module, initialStage: 1);
        },
      ),

      // Calculator routes
      GoRoute(
        path: '/calculator',
        name: 'calculator',
        builder: (context, state) => const CalculatorHomeScreen(),
        routes: [
          GoRoute(
            path: 'formula/:id',
            name: 'calculatorFormula',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return CalculatorFormulaScreen(formulaId: id);
            },
          ),
          GoRoute(
            path: 'clabsi',
            name: 'clabsiCalculator',
            builder: (context, state) => const CLABSICalculator(),
          ),
          GoRoute(
            path: 'cauti',
            name: 'cautiCalculator',
            builder: (context, state) => const CAUTICalculator(),
          ),
          GoRoute(
            path: 'vae',
            name: 'vaeCalculator',
            builder: (context, state) => const VAECalculator(),
          ),
          GoRoute(
            path: 'ssi',
            name: 'ssiCalculator',
            builder: (context, state) => const SSICalculator(),
          ),
          GoRoute(
            path: 'dur',
            name: 'durCalculator',
            builder: (context, state) => const DURCalculator(),
          ),
          GoRoute(
            path: 'mdro-incidence',
            name: 'mdroIncidenceCalculator',
            builder: (context, state) => const MDROIncidenceCalculator(),
          ),
          GoRoute(
            path: 'colonization-pressure',
            name: 'colonizationPressureCalculator',
            builder: (context, state) => const ColonizationPressureCalculator(),
          ),
          GoRoute(
            path: 'screening-yield',
            name: 'screeningYieldCalculator',
            builder: (context, state) => const ScreeningYieldCalculator(),
          ),
          GoRoute(
            path: 'infection-reduction',
            name: 'infectionReductionCalculator',
            builder: (context, state) => const InfectionReductionCalculator(),
          ),
          GoRoute(
            path: 'isolation-compliance',
            name: 'isolationComplianceCalculator',
            builder: (context, state) => const IsolationComplianceCalculator(),
          ),
          GoRoute(
            path: 'dot',
            name: 'dotCalculator',
            builder: (context, state) => const DOTCalculator(),
          ),
          GoRoute(
            path: 'ddd',
            name: 'dddCalculator',
            builder: (context, state) => const DDDCalculator(),
          ),
          GoRoute(
            path: 'antibiotic-utilization',
            name: 'antibioticUtilizationCalculator',
            builder: (context, state) => const AntibioticUtilizationCalculator(),
          ),
          GoRoute(
            path: 'deescalation-rate',
            name: 'deescalationRateCalculator',
            builder: (context, state) => const DeescalationRateCalculator(),
          ),
          GoRoute(
            path: 'culture-guided-therapy',
            name: 'cultureGuidedTherapyCalculator',
            builder: (context, state) => const CultureGuidedTherapyCalculator(),
          ),
          GoRoute(
            path: 'bundle-compliance',
            name: 'bundleComplianceCalculator',
            builder: (context, state) => const BundleComplianceCalculator(),
          ),
          GoRoute(
            path: 'ipc-audit-score',
            name: 'ipcAuditScoreCalculator',
            builder: (context, state) => const IPCAuditScoreCalculator(),
          ),
          GoRoute(
            path: 'observation-compliance',
            name: 'observationComplianceCalculator',
            builder: (context, state) => const ObservationComplianceCalculator(),
          ),
          GoRoute(
            path: 'compliance-trend',
            name: 'complianceTrendTracker',
            builder: (context, state) => const ComplianceTrendTracker(),
          ),
          GoRoute(
            path: 'blood-culture-contamination',
            name: 'bloodCultureContaminationCalculator',
            builder: (context, state) => const BloodCultureContaminationCalculator(),
          ),
          GoRoute(
            path: 'appropriate-specimen',
            name: 'appropriateSpecimenCalculator',
            builder: (context, state) => const AppropriateSpecimenCalculator(),
          ),
          GoRoute(
            path: 'tat-compliance',
            name: 'tatComplianceCalculator',
            builder: (context, state) => const TATComplianceCalculator(),
          ),
          GoRoute(
            path: 'rejection-rate',
            name: 'rejectionRateCalculator',
            builder: (context, state) => const RejectionRateCalculator(),
          ),
          GoRoute(
            path: 'vaccination-coverage',
            name: 'vaccinationCoverageCalculator',
            builder: (context, state) => const VaccinationCoverageCalculator(),
          ),
          GoRoute(
            path: 'nsi-rate',
            name: 'nsiRateCalculator',
            builder: (context, state) => const NSIRateCalculator(),
          ),
          GoRoute(
            path: 'pep-percentage',
            name: 'pepPercentageCalculator',
            builder: (context, state) => const PEPPercentageCalculator(),
          ),
          GoRoute(
            path: 'sick-leave-rate',
            name: 'sickLeaveRateCalculator',
            builder: (context, state) => const SickLeaveRateCalculator(),
          ),
          GoRoute(
            path: 'environmental-positivity-rate',
            name: 'environmentalPositivityRateCalculator',
            builder: (context, state) => const EnvironmentalPositivityRateCalculator(),
          ),
          GoRoute(
            path: 'disinfection-compliance',
            name: 'disinfectionComplianceCalculator',
            builder: (context, state) => const DisinfectionComplianceCalculator(),
          ),
          GoRoute(
            path: 'sterilization-failure-rate',
            name: 'sterilizationFailureRateCalculator',
            builder: (context, state) => const SterilizationFailureRateCalculator(),
          ),

          // Outbreak & Epidemiologic Investigation Calculators (Dual Routing)
          // These calculators exist in outbreak module but are also accessible from calculator module
          GoRoute(
            path: 'attack-rate',
            name: 'calculatorAttackRate',
            builder: (context, state) => const AttackRateCalculator(),
          ),
          GoRoute(
            path: 'relative-risk',
            name: 'calculatorRelativeRisk',
            builder: (context, state) => const RelativeRiskCalculator(),
          ),
          GoRoute(
            path: 'odds-ratio',
            name: 'calculatorOddsRatio',
            builder: (context, state) => const OddsRatioCalculator(),
          ),
          GoRoute(
            path: 'epidemic-curve',
            name: 'calculatorEpidemicCurve',
            builder: (context, state) => const EpidemicCurveGenerator(),
          ),
          // New calculators
          GoRoute(
            path: 'secondary-attack-rate',
            name: 'secondaryAttackRate',
            builder: (context, state) => const SecondaryAttackRateCalculator(),
          ),
          GoRoute(
            path: 'case-fatality-rate',
            name: 'caseFatalityRate',
            builder: (context, state) => const CaseFatalityRateCalculator(),
          ),
        ],
      ),

      // Settings Route
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'history-cleanup',
            name: 'historyCleanup',
            builder: (context, state) => const HistoryCleanupScreen(),
          ),
          GoRoute(
            path: 'quick-actions',
            name: 'quickActionsSettings',
            builder: (context, state) => const QuickActionsSettingsScreen(),
          ),
        ],
      ),

      // Profile Route
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      // About Route
      GoRoute(
        path: '/about',
        name: 'about',
        builder: (context, state) => const AboutScreen(),
      ),

      // History Route (Unified for all tools)
      GoRoute(
        path: '/history',
        name: 'history',
        builder: (context, state) => const HistoryHubScreen(),
      ),

      // Outbreak & Epidemiology Module Routes
      GoRoute(
        path: '/outbreak',
        name: 'outbreak',
        builder: (context, state) => const OutbreakHomeScreen(),
        routes: [
          GoRoute(
            path: 'foundations',
            name: 'outbreakFoundations',
            builder: (context, state) => const FoundationsScreen(),
            routes: [
              GoRoute(
                path: 'infection-colonization',
                name: 'infectionColonization',
                builder: (context, state) => const InfectionColonizationScreen(),
              ),
              GoRoute(
                path: 'case-carrier',
                name: 'caseCarrier',
                builder: (context, state) => const CaseCarrierScreen(),
              ),
              GoRoute(
                path: 'disease-levels',
                name: 'diseaseLevels',
                builder: (context, state) => const DiseaseLevelsScreen(),
              ),
              GoRoute(
                path: 'chain-infection',
                name: 'chainInfection',
                builder: (context, state) => const ChainInfectionScreen(),
              ),
              GoRoute(
                path: 'susceptibility',
                name: 'susceptibility',
                builder: (context, state) => const SusceptibilityScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'detection',
            name: 'outbreakDetection',
            builder: (context, state) => const DetectionScreen(),
            routes: [
              GoRoute(
                path: 'thresholds',
                name: 'outbreakDetectionThresholds',
                builder: (context, state) => const ThresholdsTriggersScreen(),
              ),
              GoRoute(
                path: 'surveillance-type',
                name: 'outbreakDetectionSurveillanceType',
                builder: (context, state) => const SurveillanceTypeScreen(),
              ),
              GoRoute(
                path: 'recognize',
                name: 'outbreakDetectionRecognize',
                builder: (context, state) => const Step01RecognizeScreen(),
              ),
              GoRoute(
                path: 'verify',
                name: 'outbreakDetectionVerify',
                builder: (context, state) => const Step02VerifyScreen(),
              ),
              GoRoute(
                path: 'alert',
                name: 'outbreakDetectionAlert',
                builder: (context, state) => const Step03AlertScreen(),
              ),
              GoRoute(
                path: 'case-definition',
                name: 'outbreakDetectionCaseDefinition',
                builder: (context, state) => const Step04CaseDefinitionScreen(),
              ),
              GoRoute(
                path: 'case-finding',
                name: 'outbreakDetectionCaseFinding',
                builder: (context, state) => const Step05CaseFindingScreen(),
              ),
              GoRoute(
                path: 'hypotheses',
                name: 'outbreakDetectionHypotheses',
                builder: (context, state) => const Step07HypothesesScreen(),
              ),
              GoRoute(
                path: 'analytical-studies',
                name: 'outbreakDetectionAnalyticalStudies',
                builder: (context, state) => const Step08AnalyticalStudiesScreen(),
              ),
              GoRoute(
                path: 'control-measures',
                name: 'outbreakDetectionControlMeasures',
                builder: (context, state) => const Step09ControlMeasuresScreen(),
              ),
              GoRoute(
                path: 'environmental',
                name: 'outbreakDetectionEnvironmental',
                builder: (context, state) => const Step10EnvironmentalScreen(),
              ),
              GoRoute(
                path: 'communication',
                name: 'outbreakDetectionCommunication',
                builder: (context, state) => const Step11CommunicationScreen(),
              ),
              GoRoute(
                path: 'surveillance',
                name: 'outbreakDetectionSurveillance',
                builder: (context, state) => const Step12SurveillanceScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'analytics',
            name: 'outbreakAnalytics',
            builder: (context, state) => const AnalyticsScreen(),
            routes: [
              GoRoute(
                path: 'attack-rate',
                name: 'attackRateCalculator',
                builder: (context, state) => const AttackRateCalculator(),
              ),
              GoRoute(
                path: 'relative-risk',
                name: 'relativeRiskCalculator',
                builder: (context, state) => const RelativeRiskCalculator(),
              ),
              GoRoute(
                path: 'odds-ratio',
                name: 'oddsRatioCalculator',
                builder: (context, state) => const OddsRatioCalculator(),
              ),
              GoRoute(
                path: 'secondary-attack-rate',
                name: 'secondaryAttackRateCalculator',
                builder: (context, state) => const SecondaryAttackRateCalculator(),
              ),
              GoRoute(
                path: 'case-fatality-rate',
                name: 'caseFatalityRateCalculator',
                builder: (context, state) => const CaseFatalityRateCalculator(),
              ),
              GoRoute(
                path: 'enhanced-sensitivity-specificity',
                name: 'enhancedSensitivitySpecificityCalculator',
                builder: (context, state) => const SensitivitySpecificityCalculator(),
              ),
              GoRoute(
                path: 'p-value',
                name: 'pValueCalculator',
                builder: (context, state) => const PValueCalculator(),
              ),
              GoRoute(
                path: 'sample-size',
                name: 'sampleSizeCalculator',
                builder: (context, state) => const SampleSizeCalculator(),
              ),
              GoRoute(
                path: 'enhanced-epidemic-curve',
                name: 'enhancedEpidemicCurveGenerator',
                builder: (context, state) => const EpidemicCurveGenerator(),
              ),
              GoRoute(
                path: 'timeline',
                name: 'outbreakTimelineTool',
                builder: (context, state) => const OutbreakTimelineTool(),
              ),
              GoRoute(
                path: 'histogram',
                name: 'histogramTool',
                builder: (context, state) => const HistogramTool(),
              ),
              GoRoute(
                path: 'comparison',
                name: 'comparisonTool',
                builder: (context, state) => const ComparisonTool(),
              ),
              GoRoute(
                path: 'case-definition',
                name: 'caseDefinitionBuilder',
                builder: (context, state) => const CaseDefinitionBuilder(),
              ),
              GoRoute(
                path: 'line-list',
                name: 'lineListTool',
                builder: (context, state) => const LineListTool(),
              ),
              GoRoute(
                path: 'control-checklist',
                name: 'controlChecklist',
                builder: (context, state) => const ControlChecklist(),
              ),
              GoRoute(
                path: 'contact-tracing',
                name: 'contactTracingTool',
                builder: (context, state) => const ContactTracingTool(),
              ),
            ],
          ),
          GoRoute(
            path: 'groups',
            name: 'outbreakGroups',
            builder: (context, state) => const OutbreakGroupsScreen(),
            routes: [
              GoRoute(
                path: ':groupId',
                name: 'groupDetail',
                builder: (context, state) {
                  final groupId = state.pathParameters['groupId']!;
                  final extra = state.extra as Map<String, dynamic>?;

                  if (extra == null) {
                    return const Scaffold(
                      body: Center(child: Text('Invalid group data')),
                    );
                  }

                  final group = extra['group'];
                  final color = extra['color'] as Color;

                  return GroupDetailScreen(
                    groupId: groupId,
                    groupName: group.name,
                    dataFile: group.dataFile,
                    color: color,
                  );
                },
                routes: [
                  GoRoute(
                    path: 'pathogen/:pathogenId',
                    name: 'pathogenDetail',
                    builder: (context, state) {
                      final extra = state.extra as Map<String, dynamic>?;

                      if (extra == null) {
                        return const Scaffold(
                          body: Center(child: Text('Invalid pathogen data')),
                        );
                      }

                      final pathogen = extra['pathogen'] as PathogenDetail;
                      final groupName = extra['groupName'] as String;
                      final color = extra['color'] as Color;

                      return PathogenDetailScreen(
                        pathogen: pathogen,
                        groupName: groupName,
                        color: color,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          // Keep old pathogens route for backward compatibility (redirects to groups)
          GoRoute(
            path: 'pathogens',
            name: 'outbreakPathogens',
            builder: (context, state) => const OutbreakGroupsScreen(),
          ),
          GoRoute(
            path: 'control',
            name: 'outbreakControl',
            builder: (context, state) => const ControlScreen(),
            routes: [
              GoRoute(
                path: 'chain-breaking',
                name: 'breakingChain',
                builder: (context, state) => const BreakingChainScreen(),
              ),
              GoRoute(
                path: 'prevention-levels',
                name: 'preventionLevels',
                builder: (context, state) => const PreventionLevelsScreen(),
              ),
              GoRoute(
                path: 'immediate-measures',
                name: 'immediateMeasures',
                builder: (context, state) => const ImmediateMeasuresScreen(),
              ),
              GoRoute(
                path: 'environmental',
                name: 'outbreakEnvironmental',
                builder: (context, state) => const EnvironmentalMeasuresScreen(),
              ),
              GoRoute(
                path: 'risk-assessment',
                name: 'riskAssessment',
                builder: (context, state) => const RiskAssessmentTool(),
              ),
              GoRoute(
                path: 'disinfectant-selection',
                name: 'disinfectantSelection',
                builder: (context, state) => const DisinfectantSelectionTool(),
              ),
            ],
          ),
          GoRoute(
            path: 'operations',
            name: 'outbreakOperations',
            builder: (context, state) => const OperationsScreen(),
            routes: [
              GoRoute(
                path: 'team-structure',
                name: 'teamStructure',
                builder: (context, state) => const TeamStructureScreen(),
              ),
              GoRoute(
                path: 'risk-assessment',
                name: 'operationsRiskAssessment',
                builder: (context, state) => const RiskAssessmentScreen(),
              ),
              GoRoute(
                path: 'action-plan',
                name: 'actionPlan',
                builder: (context, state) => const ActionPlanScreen(),
              ),
              GoRoute(
                path: 'meeting-documentation',
                name: 'meetingDocumentation',
                builder: (context, state) => const MeetingDocumentationScreen(),
              ),
              GoRoute(
                path: 'stakeholder-communication',
                name: 'stakeholderCommunication',
                builder: (context, state) => const StakeholderCommunicationScreen(),
              ),
              GoRoute(
                path: 'outbreak-checklist',
                name: 'outbreakChecklist',
                builder: (context, state) => const OutbreakChecklistScreen(),
              ),
              GoRoute(
                path: 'resource-management',
                name: 'resourceManagement',
                builder: (context, state) => const ResourceManagementScreen(),
              ),
              GoRoute(
                path: 'quality-monitoring',
                name: 'qualityMonitoring',
                builder: (context, state) => const QualityMonitoringScreen(),
              ),
              GoRoute(
                path: 'post-outbreak-evaluation',
                name: 'postOutbreakEvaluation',
                builder: (context, state) => const PostOutbreakEvaluationScreen(),
              ),
              GoRoute(
                path: 'legal-compliance',
                name: 'legalCompliance',
                builder: (context, state) => const LegalComplianceScreen(),
              ),
              GoRoute(
                path: 'training-competency',
                name: 'trainingCompetency',
                builder: (context, state) => const TrainingCompetencyScreen(),
              ),
              GoRoute(
                path: 'classification',
                name: 'outbreakClassification',
                builder: (context, state) => const ClassificationScreen(),
              ),
              GoRoute(
                path: 'end-outbreak',
                name: 'endOutbreak',
                builder: (context, state) => const EndOutbreakScreen(),
              ),
              GoRoute(
                path: 'reporting',
                name: 'outbreakReporting',
                builder: (context, state) => const ReportingScreen(),
              ),
              GoRoute(
                path: 'alerts',
                name: 'outbreakAlerts',
                builder: (context, state) => const AlertsScreen(),
              ),
            ],
          ),
        ],
      ),

      // Bundle Module Routes
      GoRoute(
        path: '/bundles',
        name: 'bundles',
        builder: (context, state) => const BundleScreen(),
        routes: [
          GoRoute(
            path: 'detail',
            name: 'bundleDetail',
            builder: (context, state) {
              final bundle = state.extra as Bundle;
              return BundleDetailScreen(bundle: bundle);
            },
          ),
          GoRoute(
            path: 'references',
            name: 'bundleReferences',
            builder: (context, state) {
              final bundle = state.extra as Bundle;
              return BundleReferencesScreen(bundle: bundle);
            },
          ),
          // Bundle Tools Hub
          GoRoute(
            path: 'tools',
            name: 'bundleToolsHub',
            builder: (context, state) => const BundleToolsHubScreen(),
            routes: [
              // Phase 8A: Essential Tools
              GoRoute(
                path: 'audit',
                name: 'bundleAuditTool',
                builder: (context, state) => const BundleAuditToolScreen(),
              ),
              GoRoute(
                path: 'gap-analysis',
                name: 'bundleGapAnalysis',
                builder: (context, state) => const BundleGapAnalysisToolScreen(),
              ),
              GoRoute(
                path: 'risk-assessment',
                name: 'bundleRiskAssessment',
                builder: (context, state) => const BundleRiskAssessmentToolScreen(),
              ),
              GoRoute(
                path: 'dashboard',
                name: 'bundleDashboard',
                builder: (context, state) => const BundlePerformanceDashboardScreen(),
              ),
              // Phase 8B: Important Tools
              GoRoute(
                path: 'sepsis',
                name: 'sepsisBundleChecker',
                builder: (context, state) => const SepsisBundleCheckerScreen(),
              ),
              GoRoute(
                path: 'comparison',
                name: 'bundleComparison',
                builder: (context, state) => const BundleComparisonToolScreen(), // Phase 8B - COMPLETED
              ),
              // Phase 8C: Additional Tools
              GoRoute(
                path: 'timeline',
                name: 'bundleTimeline',
                builder: (context, state) => const PlaceholderScreen(
                  title: 'Bundle Timeline Tracker',
                  subtitle: 'Track bundle implementation over time',
                  icon: Icons.timeline_outlined,
                  iconColor: AppColors.info,
                ),
              ),
              GoRoute(
                path: 'education',
                name: 'bundleEducation',
                builder: (context, state) => const PlaceholderScreen(
                  title: 'Bundle Education Checklist',
                  subtitle: 'Staff competency assessment tool',
                  icon: Icons.school_outlined,
                  iconColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),

      // Hand Hygiene Module Routes
      GoRoute(
        path: '/hand-hygiene',
        name: 'handHygiene',
        builder: (context, state) => const HandHygieneHomeScreen(),
        routes: [
          GoRoute(
            path: 'section/:sectionId',
            name: 'handHygieneSection',
            builder: (context, state) {
              final sectionId = state.pathParameters['sectionId']!;
              return HandHygieneSectionDetailScreen(sectionId: sectionId);
            },
            routes: [
              GoRoute(
                path: 'page/:pageId',
                name: 'handHygienePage',
                builder: (context, state) {
                  final sectionId = state.pathParameters['sectionId']!;
                  final pageId = state.pathParameters['pageId']!;
                  return HandHygienePageDetailScreen(
                    sectionId: sectionId,
                    pageId: pageId,
                  );
                },
                routes: [
                  GoRoute(
                    path: 'references',
                    name: 'handHygieneReferences',
                    builder: (context, state) {
                      final sectionId = state.pathParameters['sectionId']!;
                      final pageId = state.pathParameters['pageId']!;
                      return HandHygieneReferencesScreen(
                        sectionId: sectionId,
                        pageId: pageId,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: 'tools',
            name: 'handHygieneTools',
            builder: (context, state) => const HandHygieneToolsHubScreen(),
            routes: [
              GoRoute(
                path: 'who-observation',
                name: 'whoObservationTool',
                builder: (context, state) => const WhoObservationToolScreen(),
              ),
              GoRoute(
                path: 'product-usage',
                name: 'productUsageTracker',
                builder: (context, state) => const ProductUsageTrackerScreen(),
              ),
              GoRoute(
                path: 'dispenser-placement',
                name: 'dispenserPlacementOptimizer',
                builder: (context, state) => const DispenserPlacementOptimizerScreen(),
              ),
            ],
          ),
        ],
      ),

      // Missing Core Module Routes - Placeholder screens
      GoRoute(
        path: '/environmental',
        name: 'environmental',
        builder: (context, state) => const PlaceholderScreen(
          title: 'Environmental Health & CSSD',
          subtitle: 'Cleaning, disinfection, sterilization',
          icon: Icons.cleaning_services_outlined,
          iconColor: AppColors.info,
        ),
      ),
      // Antimicrobial Stewardship Module Routes
      GoRoute(
        path: '/stewardship',
        name: 'stewardship',
        builder: (context, state) => const StewardshipHomeScreen(),
        routes: [
          GoRoute(
            path: 'section/:sectionId',
            name: 'stewardshipSection',
            builder: (context, state) {
              final sectionId = state.pathParameters['sectionId']!;
              return StewardshipSectionDetailScreen(sectionId: sectionId);
            },
            routes: [
              GoRoute(
                path: 'page/:pageId',
                name: 'stewardshipPage',
                builder: (context, state) {
                  final sectionId = state.pathParameters['sectionId']!;
                  final pageId = state.pathParameters['pageId']!;

                  // Route to dedicated screens for all 5 Fundamentals pages
                  if (sectionId == 'fundamentals') {
                    switch (pageId) {
                      case 'what-is-ams':
                        return const WhatIsAmsScreen();
                      case 'stewardship-team':
                        return const StewardshipTeamScreen();
                      case 'stewardship-strategies':
                        return const StewardshipStrategiesScreen();
                      case 'measuring-success':
                        return const MeasuringSuccessScreen();
                      case 'barriers-enablers':
                        return const BarriersEnablersScreen();
                    }
                  }

                  // Route to dedicated screens for all 5 Resistance Mechanisms pages
                  if (sectionId == 'resistance-mechanisms') {
                    switch (pageId) {
                      case 'understanding-resistance':
                        return const UnderstandingResistanceScreen();
                      case 'resistance-mechanisms':
                        return const ResistanceMechanismsScreen();
                      case 'genetic-basis':
                        return const GeneticBasisScreen();
                      case 'priority-mdros':
                        return const PriorityMdrosScreen();
                      case 'clinical-implications':
                        return const ClinicalImplicationsScreen();
                    }
                  }

                  // Route to dedicated screens for all 4 Antibiogram pages
                  if (sectionId == 'antibiogram') {
                    switch (pageId) {
                      case 'what-is-antibiogram':
                        return const WhatIsAntibiogramScreen();
                      case 'antibiogram-construction':
                        return const AntibiogramConstructionScreen();
                      case 'interpreting-antibiogram':
                        return const InterpretingAntibiogramScreen();
                      case 'antibiogram-guided-prescribing':
                        return const AntibiogramGuidedPrescribingScreen();
                    }
                  }

                  // Route to dedicated screens for all 7 Prescribing Principles pages
                  if (sectionId == 'prescribing-principles') {
                    switch (pageId) {
                      case 'rational-use':
                        return const RationalUseScreen();
                      case 'empiric-definitive':
                        return const EmpiricDefinitiveScreen();
                      case 'dosing-optimization':
                        return const DosingOptimizationScreen();
                      case 'iv-to-oral':
                        return const IvToOralScreen();
                      case 'duration-therapy':
                        return const DurationTherapyScreen();
                      case 'special-populations':
                        return const SpecialPopulationsScreen();
                      case 'surgical-prophylaxis':
                        return const SurgicalProphylaxisScreen();
                    }
                  }

                  // Route to dedicated screens for all 4 Stewardship Interventions pages
                  if (sectionId == 'stewardship-interventions') {
                    switch (pageId) {
                      case 'audit-feedback':
                        return const AuditFeedbackScreen();
                      case 'preauthorization':
                        return const PreauthorizationScreen();
                      case 'clinical-pathways':
                        return const ClinicalPathwaysScreen();
                      case 'education-behavioral':
                        return const EducationBehavioralScreen();
                    }
                  }

                  // Route to dedicated screens for all 4 Monitoring & Reporting pages
                  if (sectionId == 'monitoring-reporting') {
                    switch (pageId) {
                      case 'consumption-metrics':
                        return const ConsumptionMetricsScreen();
                      case 'process-outcome-measures':
                        return const ProcessOutcomeMeasuresScreen();
                      case 'benchmarking-reporting':
                        return const BenchmarkingReportingScreen();
                      case 'continuous-improvement':
                        return const ContinuousImprovementScreen();
                    }
                  }

                  // Section 7: Laboratory Diagnostics & Antimicrobial Susceptibility Testing
                  if (sectionId == 'lab-diagnostics') {
                    switch (pageId) {
                      case 'clsi-breakpoints':
                        return const ClsiBreakpointsScreen();
                      case 'mic-testing-scenarios':
                        return const MicTestingScenariosScreen();
                      case 'rapid-diagnostics':
                        return const RapidDiagnosticsScreen();
                      case 'resistance-ast-pitfalls':
                        return const ResistanceAstPitfallsScreen();
                      case 'intrinsic-resistance':
                        return const IntrinsicResistanceScreen();
                    }
                  }

                  // Fallback for future sections
                  return Scaffold(
                    appBar: AppBar(title: const Text('Page Not Found')),
                    body: const Center(
                      child: Text('This page is under construction.'),
                    ),
                  );
                },
              ),
            ],
          ),
          // Interactive Tools Hub
          GoRoute(
            path: 'tools',
            name: 'stewardshipTools',
            builder: (context, state) => const StewardshipToolsHubScreen(),
            routes: [
              // Antibiogram Builder
              GoRoute(
                path: 'antibiogram-builder',
                name: 'antibiogramBuilder',
                builder: (context, state) => const AntibiogramBuilderScreen(),
              ),
              // Renal Dose Calculator
              GoRoute(
                path: 'renal-dose',
                name: 'renalDoseCalculator',
                builder: (context, state) => const RenalDoseCalculatorScreen(),
              ),
              // Antibiotic Spectrum Visualizer
              GoRoute(
                path: 'spectrum-visualizer',
                name: 'spectrumVisualizer',
                builder: (context, state) => const SpectrumVisualizerScreen(),
              ),
              // Surgical Prophylaxis Advisor
              GoRoute(
                path: 'surgical-prophylaxis',
                name: 'surgicalProphylaxis',
                builder: (context, state) => const SurgicalProphylaxisAdvisorScreen(),
              ),
              // Allergy Cross-Reactivity Checker
              GoRoute(
                path: 'allergy-checker',
                name: 'allergyChecker',
                builder: (context, state) => const AllergyCheckerScreen(),
              ),
              // MDRO Risk Calculator
              GoRoute(
                path: 'mdro-risk',
                name: 'mdroRisk',
                builder: (context, state) => const MdroRiskCalculatorScreen(),
              ),
            ],
          ),
        ],
      ),

      // Clinical Decision Support Module Routes
      GoRoute(
        path: '/cds',
        name: 'cds',
        builder: (context, state) => const CDSHomeScreen(),
        routes: [
          GoRoute(
            path: 'category/:categoryId',
            name: 'cdsCategory',
            builder: (context, state) {
              final categoryId = state.pathParameters['categoryId']!;
              return CDSCategoryScreen(categoryId: categoryId);
            },
            routes: [
              GoRoute(
                path: 'condition/:conditionId',
                name: 'cdsCondition',
                builder: (context, state) {
                  final categoryId = state.pathParameters['categoryId']!;
                  final conditionId = state.pathParameters['conditionId']!;
                  return CDSConditionDetailScreen(
                    categoryId: categoryId,
                    conditionId: conditionId,
                  );
                },
              ),
            ],
          ),
        ],
      ),

      // Generic outbreak detail routes (for remaining subsections)
      GoRoute(
        path: '/outbreak/:section/:subsection',
        name: 'outbreakDetail',
        builder: (context, state) {
          final section = state.pathParameters['section']!;
          final subsection = state.pathParameters['subsection']!;
          return OutbreakDetailScreen(
            title: _formatTitle(subsection),
            subtitle: 'Content coming soon',
            icon: _getIconForSection(section),
            iconColor: _getColorForSection(section),
          );
        },
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Route error: ${state.error}'))),
  );
});

// Helper functions for dynamic outbreak routing
String _formatTitle(String subsection) {
  return subsection
      .split('-')
      .map((word) => word[0].toUpperCase() + word.substring(1))
      .join(' ');
}

IconData _getIconForSection(String section) {
  switch (section) {
    case 'foundations':
      return Icons.school_outlined;
    case 'detection':
      return Icons.search_outlined;
    case 'analytics':
      return Icons.calculate_outlined;
    case 'pathogens':
      return Icons.biotech_outlined;
    case 'control':
      return Icons.shield_outlined;
    case 'operations':
      return Icons.business_outlined;
    case 'interactive':
      return Icons.build_outlined;
    case 'reference':
      return Icons.menu_book_outlined;
    default:
      return Icons.info_outline;
  }
}

Color _getColorForSection(String section) {
  switch (section) {
    case 'foundations':
      return const Color(0xFF2196F3); // Blue
    case 'detection':
      return const Color(0xFFF44336); // Red
    case 'analytics':
      return const Color(0xFF2196F3); // Blue
    case 'pathogens':
      return const Color(0xFFF44336); // Red
    case 'control':
      return const Color(0xFF4CAF50); // Green
    case 'operations':
      return const Color(0xFFFF9800); // Orange
    case 'interactive':
      return const Color(0xFF2196F3); // Blue
    case 'reference':
      return const Color(0xFF00BCD4); // Cyan
    default:
      return const Color(0xFF2196F3); // Blue
  }
}
