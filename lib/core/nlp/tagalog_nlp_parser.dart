class ParsedVoiceCommand {
  final String rawText;
  final String type; // 'utang', 'sale', 'payment', 'inquiry', 'unknown'
  final String? customerName;
  final double? amount;
  final List<String> matchedItems;
  final String confirmationResponse;

  ParsedVoiceCommand({
    required this.rawText,
    required this.type,
    this.customerName,
    this.amount,
    this.matchedItems = const [],
    required this.confirmationResponse,
  });
}

class TagalogNLPParser {
  /// Deterministic Tagalog NLP Parser
  /// Resolves commands in 0ms with zero cloud dependencies or latency
  static ParsedVoiceCommand parse(String input) {
    final text = input.trim();
    final lower = text.toLowerCase();

    // 1. Check for Utang (Credit)
    // Pattern: "Si [Name], utang [Amount] [Item]" or "[Name] utang [Amount]"
    if (lower.contains('utang') || lower.contains('lista') || lower.contains('pautang')) {
      final name = _extractCustomerName(text);
      final amount = _extractAmount(text);
      final items = _extractItems(lower);

      String confirmation;
      if (name != null && amount != null) {
        confirmation = "Ayos! Na-lista ko na ang ₱${amount.toStringAsFixed(0)} utang ni $name.";
      } else if (name != null) {
        confirmation = "Na-record ko ang utang ni $name.";
      } else {
        confirmation = "Na-lista ko na ang utang.";
      }

      return ParsedVoiceCommand(
        rawText: text,
        type: 'utang',
        customerName: name ?? 'Suki',
        amount: amount ?? 0.0,
        matchedItems: items,
        confirmationResponse: confirmation,
      );
    }

    // 2. Check for Payment (Bayad)
    // Pattern: "Nagbayad na si [Name] 200 pesos" or "Bayad ni [Name] 100"
    if (lower.contains('bayad') || lower.contains('nagbayad')) {
      final name = _extractCustomerName(text);
      final amount = _extractAmount(text);

      String confirmation = name != null && amount != null
          ? "Salamat! Nabawasan na ng ₱${amount.toStringAsFixed(0)} ang utang ni $name."
          : "Na-record ko na ang bayad.";

      return ParsedVoiceCommand(
        rawText: text,
        type: 'payment',
        customerName: name ?? 'Suki',
        amount: amount ?? 0.0,
        confirmationResponse: confirmation,
      );
    }

    // 3. Check for Cash Sale (Benta)
    // Pattern: "Benta ko tatlong sardinas 45 pesos" or "May bumili ng coke 20"
    if (lower.contains('benta') || lower.contains('bumili') || lower.contains('nabenta')) {
      final amount = _extractAmount(text);
      final items = _extractItems(lower);

      String confirmation = amount != null
          ? "Galing! Na-record ko ang ₱${amount.toStringAsFixed(0)} na benta."
          : "Na-record ko na ang benta.";

      return ParsedVoiceCommand(
        rawText: text,
        type: 'sale',
        amount: amount ?? 0.0,
        matchedItems: items,
        confirmationResponse: confirmation,
      );
    }

    // 4. Check for Business Insights Inquiry
    // Pattern: "Kumikita ba ako?" or "Magkano kinita ko?" or "Sino may utang?"
    if (lower.contains('kumikita') || lower.contains('kinita') || lower.contains('sino may utang') || lower.contains('paubos')) {
      return ParsedVoiceCommand(
        rawText: text,
        type: 'inquiry',
        confirmationResponse: "Sinusuri ko ang listahan ng tindahan...",
      );
    }

    // Fallback
    return ParsedVoiceCommand(
      rawText: text,
      type: 'unknown',
      confirmationResponse: "Pasensya na, paki-ulit po nang mas malinaw.",
    );
  }

  static String? _extractCustomerName(String text) {
    // Looks for "si [Name]" or "kay [Name]" or "ni [Name]"
    final reg = RegExp(r'\b(?:si|ni|kay)\s+([A-ZÀ-ÿa-z]+(?:\s+[A-ZÀ-ÿa-z]+)?)', caseSensitive: false);
    final match = reg.firstMatch(text);
    if (match != null && match.groupCount >= 1) {
      final candidate = match.group(1)!.trim();
      // Filter out common false positives like "mang", "aling" if isolated, or keep them with name
      return candidate;
    }
    return null;
  }

  static double? _extractAmount(String text) {
    // Matches "150 pesos", "₱150", "150", etc.
    final reg = RegExp(r'(?:₱|php)?\s*(\d+(?:\.\d+)?)\s*(?:pesos|piso|php)?', caseSensitive: false);
    final matches = reg.allMatches(text);
    for (final match in matches) {
      final valStr = match.group(1);
      if (valStr != null) {
        final val = double.tryParse(valStr);
        if (val != null && val > 0) return val;
      }
    }
    return null;
  }

  static List<String> _extractItems(String text) {
    final knownKeywords = [
      'sardinas', 'bigas', 'noodles', 'pancit canton', 'mami', 
      'kape', 'nescafe', 'kopiko', 'milo', 'coke', 'sprite', 
      'sabon', 'surf', 'corned beef', 'tuna'
    ];
    final items = <String>[];
    for (var k in knownKeywords) {
      if (text.contains(k)) {
        items.add(k);
      }
    }
    return items;
  }
}
