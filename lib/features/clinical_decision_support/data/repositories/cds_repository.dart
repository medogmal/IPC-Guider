import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/cds_category.dart';

/// Repository for Clinical Decision Support data
class CDSRepository {
  // Cache for loaded categories
  final Map<String, CDSCategory> _categoryCache = {};

  /// Get all category metadata (without loading full content)
  Future<List<CDSCategory>> getAllCategories() async {
    return [
      CDSCategory(
        id: 'lower-respiratory',
        name: 'Lower Respiratory Infections',
        description: 'Pneumonia, bronchitis, and lower airway infections',
        icon: Icons.air,
        color: Color(0xFF2196F3),
      ),
      CDSCategory(
        id: 'upper-respiratory',
        name: 'Upper Respiratory Infections',
        description: 'Pharyngitis, sinusitis, otitis, and upper airway infections',
        icon: Icons.face,
        color: Color(0xFF03A9F4),
      ),
      CDSCategory(
        id: 'ent-infections',
        name: 'ENT Infections (Ear, Nose, Throat)',
        description: 'Bacterial and viral infections of the ear, nose, and throat',
        icon: Icons.hearing,
        color: Color(0xFFFF5722),
      ),
      CDSCategory(
        id: 'urinary-genitourinary',
        name: 'Urinary & Genitourinary',
        description: 'UTI, pyelonephritis, prostatitis, catheter-associated',
        icon: Icons.water_drop,
        color: Color(0xFFFF9800),
      ),
      CDSCategory(
        id: 'sexually-transmitted-infections',
        name: 'Female Pelvic & STI Syndromes',
        description: 'PID, cervicitis, STIs, and gynecologic infections',
        icon: Icons.favorite,
        color: Color(0xFFE91E63),
      ),
      CDSCategory(
        id: 'skin-soft-tissue',
        name: 'Skin & Soft Tissue Infections',
        description: 'Cellulitis, abscess, diabetic foot, necrotizing',
        icon: Icons.accessibility_new,
        color: Color(0xFF9C27B0),
      ),
      CDSCategory(
        id: 'intra-abdominal-infections',
        name: 'Intra-Abdominal & Hepatobiliary',
        description: 'Peritonitis, cholecystitis, cholangitis, liver abscess',
        icon: Icons.restaurant,
        color: Color(0xFF4CAF50),
      ),
      CDSCategory(
        id: 'gastrointestinal-diarrheal',
        name: 'Gastrointestinal & Diarrheal Infections',
        description: 'Infectious diarrhea, gastroenteritis, C. difficile, and foodborne illnesses',
        icon: Icons.restaurant,
        color: Color(0xFFFF9800),
      ),
      CDSCategory(
        id: 'bloodstream-infections',
        name: 'Bloodstream Infections',
        description: 'Sepsis, bacteremia, catheter-related infections',
        icon: Icons.bloodtype,
        color: Color(0xFFF44336),
      ),
      CDSCategory(
        id: 'cardiovascular-infections',
        name: 'Cardiovascular Infections',
        description: 'Endocarditis, myocarditis, pericarditis, and cardiac device infections',
        icon: Icons.favorite,
        color: Color(0xFFE91E63),
      ),
      CDSCategory(
        id: 'cns-infections',
        name: 'CNS & Neurologic Infections',
        description: 'Meningitis, encephalitis, brain abscess, epidural abscess',
        icon: Icons.psychology,
        color: Color(0xFF673AB7),
      ),
      CDSCategory(
        id: 'bone-joint-infections',
        name: 'Bone & Joint Infections',
        description: 'Osteomyelitis, septic arthritis, prosthetic joint infection',
        icon: Icons.accessibility,
        color: Color(0xFF795548),
      ),
      CDSCategory(
        id: 'eye-infections',
        name: 'Ophthalmologic & Orbital',
        description: 'Conjunctivitis, keratitis, endophthalmitis, orbital cellulitis',
        icon: Icons.visibility,
        color: Color(0xFF3F51B5),
      ),
      CDSCategory(
        id: 'obstetric-infections',
        name: 'Obstetric Infections',
        description: 'Pregnancy-specific infections including chorioamnionitis, postpartum endometritis, GBS prophylaxis',
        icon: Icons.pregnant_woman,
        color: Color(0xFFE91E63),
      ),
      CDSCategory(
        id: 'immunocompromised-infections',
        name: 'Fever & Immunocompromised',
        description: 'Febrile neutropenia, fever in HIV, transplant, FUO',
        icon: Icons.thermostat,
        color: Color(0xFFFF5722),
      ),
      CDSCategory(
        id: 'fever-syndromes',
        name: 'Fever Syndromes',
        description: 'Diagnostic approaches to fever syndromes including FUO, neutropenic fever, postoperative fever',
        icon: Icons.thermostat,
        color: Color(0xFFFFC107),
      ),
      CDSCategory(
        id: 'travel-tropical-medicine',
        name: 'Tropical, Travel & Zoonotic',
        description: 'Malaria, dengue, rickettsial, brucellosis, leptospirosis',
        icon: Icons.flight,
        color: Color(0xFF009688),
      ),
      CDSCategory(
        id: 'zoonotic-infections',
        name: 'Zoonotic Infections',
        description: 'Infections transmitted from animals to humans',
        icon: Icons.pets,
        color: Color(0xFF8D6E63),
      ),
      CDSCategory(
        id: 'surgical-prophylaxis',
        name: 'Surgical Prophylaxis',
        description: 'Pre-operative antibiotics for various procedures',
        icon: Icons.medical_services,
        color: Color(0xFF607D8B),
      ),
    ];
  }

  /// Load a specific category with full content
  Future<CDSCategory> loadCategory(String categoryId) async {
    // Check cache first
    if (_categoryCache.containsKey(categoryId)) {
      return _categoryCache[categoryId]!;
    }

    try {
      // Load JSON file
      final jsonString = await rootBundle.loadString(
        'assets/data/cds/$categoryId.v1.json',
      );
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      final category = CDSCategory.fromJson(jsonData);

      // Cache the loaded category
      _categoryCache[categoryId] = category;

      return category;
    } catch (e) {
      throw Exception('Failed to load category $categoryId: $e');
    }
  }

  /// Search conditions across all categories
  Future<List<Map<String, dynamic>>> searchConditions(String query) async {
    if (query.isEmpty) return [];

    final results = <Map<String, dynamic>>[];
    final categories = await getAllCategories();

    for (final category in categories) {
      try {
        final fullCategory = await loadCategory(category.id);
        for (final condition in fullCategory.conditions) {
          // Search in name
          if (condition.name.toLowerCase().contains(query.toLowerCase())) {
            results.add({
              'category': fullCategory,
              'condition': condition,
            });
            continue;
          }

          // Search in synonyms
          for (final synonym in condition.synonyms) {
            if (synonym.toLowerCase().contains(query.toLowerCase())) {
              results.add({
                'category': fullCategory,
                'condition': condition,
              });
              break;
            }
          }
        }
      } catch (e) {
        // Skip categories that fail to load
        continue;
      }
    }

    return results;
  }

  /// Clear cache
  void clearCache() {
    _categoryCache.clear();
  }
}

