// lib/services/visa_checklist_service.dart
// Static lookup table for passport-origin -> destination-country pairs.
// Zero network queries, compile-time constant data.

class VisaChecklistService {
  static const Map<String, Map<String, String>> _visaRules = {
    'Pakistan': {
      'UAE': 'Visa on arrival for many nationalities — verify your specific passport type.',
      'Turkey': 'e-Visa required — apply online before travel.',
      'France': 'Schengen visa required — apply at least 15 days before travel.',
      'Maldives': 'Visa on arrival (30 days) for most nationalities.',
      'Italy': 'Schengen visa required — apply at least 15 days before travel.',
      'Japan': 'eVisa or embassy visa required prior to departure.',
      'United States': 'B1/B2 tourist visa required — interview at embassy needed.',
      'Saudi Arabia': 'e-Visa or Visa on Arrival available for tourism.',
    },
    'United States': {
      'France': 'Visa-free for up to 90 days (ETIAS registration required).',
      'Italy': 'Visa-free for up to 90 days (ETIAS registration required).',
      'Japan': 'Visa-free for up to 90 days.',
      'UAE': 'Visa-free for 30 days on arrival.',
      'Pakistan': 'e-Visa required — apply online prior to travel.',
    },
    'United Kingdom': {
      'France': 'Visa-free for up to 90 days in Schengen zone.',
      'UAE': 'Visa on arrival for 30 days.',
      'Pakistan': 'e-Visa required online.',
    },
  };

  static String? checkRequirement(String originCountry, String destCountry) {
    return _visaRules[originCountry]?[destCountry];
  }

  /// Generates a simple packing checklist based on destination category + season.
  static List<String> generatePackingList(String category, String bestTime) {
    final base = ['Passport & visa documents', 'Phone charger', 'Travel adapter', 'Medications'];
    if (category == 'Mountain') base.addAll(['Warm jacket', 'Hiking shoes', 'Sunscreen (altitude)']);
    if (category == 'Beach') base.addAll(['Swimwear', 'Sunscreen', 'Light clothing']);
    if (category == 'Historic' || category == 'City') base.addAll(['Comfortable walking shoes', 'Modest clothing for religious sites']);
    return base;
  }
}
