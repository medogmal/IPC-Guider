import 'package:flutter/material.dart';
import '../presentation/widgets/interactive_tools_card.dart';

/// Centralized mapping of outbreak investigation steps to their relevant interactive tools.
/// 
/// This mapping is based on CDC/WHO outbreak investigation methodology and infection
/// control best practices. Each step is mapped to tools that are clinically appropriate
/// and enhance the outbreak investigation workflow.
class StepToolsMapping {
  /// Map of step IDs to their associated interactive tools
  static const Map<String, List<InteractiveTool>> stepTools = {
    // Step 1: Recognize a Potential Outbreak
    // Tools for comparing current rates vs. baseline and visualizing clustering patterns
    'step_01_recognize': [
      InteractiveTool(
        name: 'Histogram Tool',
        route: '/outbreak/analytics/histogram',
        icon: Icons.bar_chart,
      ),
      InteractiveTool(
        name: 'Comparison Tool',
        route: '/outbreak/analytics/comparison',
        icon: Icons.compare_outlined,
      ),
    ],
    
    // Step 2: Verify Diagnosis and Confirm the Outbreak
    // Tools for statistical verification and ruling out pseudo-outbreaks
    'step_02_verify': [
      InteractiveTool(
        name: 'P-Value Calculator',
        route: '/outbreak/analytics/p-value',
        icon: Icons.analytics_outlined,
      ),
      InteractiveTool(
        name: 'Sensitivity & Specificity Calculator',
        route: '/outbreak/analytics/enhanced-sensitivity-specificity',
        icon: Icons.medical_services_outlined,
      ),
    ],
    
    // Step 3: Alert Key Individuals
    // No interactive tools needed - this is an administrative/communication step
    
    // Step 4: Establish a Case Definition
    // Structured tool to create clinical, laboratory, and epidemiological criteria
    'step_04_case_definition': [
      InteractiveTool(
        name: 'Case Definition Builder',
        route: '/outbreak/analytics/case-definition',
        icon: Icons.description_outlined,
      ),
    ],
    
    // Step 5: Case Finding (Line Listing)
    // Tools for documenting all cases and tracking exposed contacts
    'step_05_case_finding': [
      InteractiveTool(
        name: 'Line List Tool',
        route: '/outbreak/analytics/line-list',
        icon: Icons.table_chart_outlined,
      ),
      InteractiveTool(
        name: 'Contact Tracing Tool',
        route: '/outbreak/analytics/contact-tracing',
        icon: Icons.people_outline,
      ),
    ],
    
    // Step 7: Generate Hypotheses
    // Tools for visualizing patterns (person, place, time) and identifying common exposures
    'step_07_hypotheses': [
      InteractiveTool(
        name: 'Epidemic Curve Generator',
        route: '/outbreak/analytics/enhanced-epidemic-curve',
        icon: Icons.timeline_outlined,
      ),
      InteractiveTool(
        name: 'Outbreak Timeline Tool',
        route: '/outbreak/analytics/timeline',
        icon: Icons.schedule_outlined,
      ),
      InteractiveTool(
        name: 'Histogram Tool',
        route: '/outbreak/analytics/histogram',
        icon: Icons.bar_chart,
      ),
    ],
    
    // Step 8: Analytical Studies to Evaluate Hypotheses
    // Tools for testing hypotheses with case-control or cohort studies
    'step_08_analytical_studies': [
      InteractiveTool(
        name: 'Relative Risk Calculator',
        route: '/outbreak/analytics/relative-risk',
        icon: Icons.compare_arrows_outlined,
      ),
      InteractiveTool(
        name: 'Odds Ratio Calculator',
        route: '/outbreak/analytics/odds-ratio',
        icon: Icons.balance_outlined,
      ),
      InteractiveTool(
        name: 'Attack Rate Calculator',
        route: '/outbreak/analytics/attack-rate',
        icon: Icons.trending_up_outlined,
      ),
      InteractiveTool(
        name: 'Secondary Attack Rate Calculator',
        route: '/outbreak/analytics/secondary-attack-rate',
        icon: Icons.people_outline,
      ),
      InteractiveTool(
        name: 'Sample Size Calculator',
        route: '/outbreak/analytics/sample-size',
        icon: Icons.people_outline,
      ),
    ],
    
    // Step 9: Immediate Control Measures
    // Tools for implementing and tracking control interventions
    'step_09_control_measures': [
      InteractiveTool(
        name: 'Control Checklist',
        route: '/outbreak/analytics/control-checklist',
        icon: Icons.checklist_outlined,
      ),
      InteractiveTool(
        name: 'Risk Assessment Tool',
        route: '/outbreak/analytics/risk-assessment',
        icon: Icons.assessment_outlined,
      ),
      InteractiveTool(
        name: 'Disinfectant Selection Tool',
        route: '/outbreak/analytics/disinfectant-selection',
        icon: Icons.cleaning_services_outlined,
      ),
    ],
  };
  
  /// Get the list of interactive tools for a specific step
  /// 
  /// Returns an empty list if no tools are mapped to the step
  static List<InteractiveTool> getToolsForStep(String stepId) {
    return stepTools[stepId] ?? [];
  }
  
  /// Get all steps that have interactive tools
  static List<String> getStepsWithTools() {
    return stepTools.keys.toList();
  }
  
  /// Get the total number of tools available across all steps
  static int getTotalToolsCount() {
    return stepTools.values.fold(0, (sum, tools) => sum + tools.length);
  }
}

