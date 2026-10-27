import 'dart:convert';

/// Representa una porción dividida de una transacción asignada a una categoría específica.
class TransactionCategorySplit {
  String? splitId;
  String categoryFk;
  String? subCategoryFk;
  double amount;
  String note;

  TransactionCategorySplit({
    this.splitId,
    required this.categoryFk,
    this.subCategoryFk,
    required this.amount,
    this.note = "",
  });

  Map<String, dynamic> toMap() => {
        'splitId': splitId,
        'categoryFk': categoryFk,
        'subCategoryFk': subCategoryFk,
        'amount': amount,
        'note': note,
      };

  factory TransactionCategorySplit.fromMap(Map<String, dynamic> map) =>
      TransactionCategorySplit(
        splitId: map['splitId'],
        categoryFk: map['categoryFk'] ?? '',
        subCategoryFk: map['subCategoryFk'],
        amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
        note: map['note'] ?? '',
      );
}

/// Helper para serializar y deserializar divisiones de transacciones
/// garantizando compatibilidad 100% offline y retrocompatible con la base de datos de Cashew.
class SplitTransactionHelper {
  static const String splitTagStart = "<!--CASHEW_SPLITS:";
  static const String splitTagEnd = "-->";

  /// Codifica la lista de divisiones dentro del campo note manteniendo la nota legible del usuario.
  static String encodeNoteWithSplits(
      String? cleanNote, List<TransactionCategorySplit> splits) {
    String base = (cleanNote ?? "").trim();
    if (splits.isEmpty) return base;

    List<Map<String, dynamic>> serialized =
        splits.map((s) => s.toMap()).toList();
    String jsonPayload = jsonEncode(serialized);
    return "$base\n$splitTagStart$jsonPayload$splitTagEnd".trim();
  }

  /// Extrae la nota de texto visible y las divisiones asociadas.
  static ({String cleanNote, List<TransactionCategorySplit> splits})
      decodeNoteWithSplits(String? rawNote) {
    if (rawNote == null || !rawNote.contains(splitTagStart)) {
      return (cleanNote: rawNote ?? "", splits: <TransactionCategorySplit>[]);
    }

    try {
      int startIdx = rawNote.indexOf(splitTagStart);
      int endIdx = rawNote.indexOf(splitTagEnd, startIdx);

      if (startIdx != -1 && endIdx != -1) {
        String cleanText = rawNote.substring(0, startIdx).trim();
        String jsonStr = rawNote.substring(
            startIdx + splitTagStart.length, endIdx);
        List<dynamic> list = jsonDecode(jsonStr);
        List<TransactionCategorySplit> splits = list
            .map((item) => TransactionCategorySplit.fromMap(item))
            .toList();
        return (cleanNote: cleanText, splits: splits);
      }
    } catch (e) {
      print("Error parseando splits de la nota: $e");
    }

    return (cleanNote: rawNote, splits: <TransactionCategorySplit>[]);
  }

  /// Valida que la suma de los montos divididos coincida exactamente con el total de la transacción.
  static ({bool isValid, double difference}) validateSplitSum(
      double totalAmount, List<TransactionCategorySplit> splits) {
    if (splits.isEmpty) return (isValid: true, difference: 0.0);
    double sum = splits.fold(0.0, (acc, curr) => acc + curr.amount);
    double diff = (totalAmount.abs() - sum.abs());
    return (isValid: diff.abs() < 0.001, difference: diff);
  }
}
