class AccountingCalculations {
  const AccountingCalculations._();

  static double lineAmount({
    required double quantity,
    required double unitPrice,
  }) {
    return quantity * unitPrice;
  }

  static double percentageAmount({
    required double baseAmount,
    required double ratePercent,
  }) {
    return (baseAmount * ratePercent) / 100;
  }

  static double proportionalAmount({
    required double amount,
    required double originalQuantity,
    required double remainingQuantity,
  }) {
    if (originalQuantity <= 0 || remainingQuantity <= 0) return 0;
    return amount * remainingQuantity / originalQuantity;
  }

  static double netAmount({
    required double lineAmount,
    required double discountAmount,
    required double taxAmount,
    double additionalDiscount = 0,
  }) {
    return lineAmount - discountAmount + taxAmount - additionalDiscount;
  }

  static double sum(Iterable<double> values) {
    return values.fold<double>(0, (total, value) => total + value);
  }

  static double documentNetTotal({
    required double totalAfterLineAdjustments,
    required double documentDiscount,
  }) {
    return totalAfterLineAdjustments - documentDiscount;
  }

  static double invoiceNetAfterReturns({
    required double netPrice,
    required double priceReturn,
  }) {
    final remaining = netPrice - priceReturn;
    return remaining < 0 ? 0 : remaining;
  }

  static double productInventoryTotal({
    required double quantity,
    required double? lastPrice,
  }) {
    return quantity * (lastPrice ?? 0);
  }

  static double tenderNetPrice(Iterable<double> selectedDocumentNetPrices) {
    return sum(selectedDocumentNetPrices);
  }

  static bool canReduceInventoryToCount({
    required double currentQuantity,
    required double countedQuantity,
  }) {
    return currentQuantity > 0 &&
        countedQuantity >= 0 &&
        countedQuantity <= currentQuantity;
  }
}
