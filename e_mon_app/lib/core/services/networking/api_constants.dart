class ApiConstants {
  static const String baseUrl = 'http://127.0.0.1:8000';
}

class ApiEndpoints {
  // Readings
  static const String readings = '/readings';

  // Auth
  static const String login = '/system-users/login';

  // Companies
  static const String companies = '/companies';
  static String company(int id) => '/companies/$id';

  // Business Units
  static const String businessUnits = '/business-units';
  static String businessUnit(int id) => '/business-units/$id';

  // Individual tax code (PUT / DELETE)
  static String taxCode(int id) => '/tax-codes/$id';
  static String cashFlowCategory(int id) => '/cash-flow-categories/$id';
  static String pettyCashCustodian(int id) => '/petty-cash-custodians/$id';
  static String financialStatement(int id) => '/financial-statements/$id';
  static String businessPartner(int id) => '/business-partners/$id';
  static String accountGroup(int id) => '/account-groups/$id';
  static String glAccount(int id) => '/gl-accounts/$id';
  static String tradeOrder(int id) => '/trade-orders/$id';
  static String tradeOrderEscalate(int id) => '/trade-orders/$id/escalate';
  static String tradeInvoice(int id) => '/trade-invoices/$id';
  static String tradeInvoiceCancel(int id) => '/trade-invoices/$id/cancel';
  static String tradeInvoiceRestoreCancellation(int id) =>
      '/trade-invoices/$id/restore-cancellation';
  static String tradeInvoiceEscalate(int id) => '/trade-invoices/$id/escalate';
  static String directVoucher(int id) => '/direct-vouchers/$id';
  static String product(int unitId, int productId) =>
      '/business-units/$unitId/products/$productId';

  // Scoped resources under a business unit
  static String chartOfAccounts(int unitId) =>
      '/business-units/$unitId/chart-of-accounts';
  static String taxCodes(int unitId) => '/business-units/$unitId/tax-codes';
  static String businessPartners(int unitId) =>
      '/business-units/$unitId/business-partners';
  static String businessPartnerTransactionLines(int unitId, int partnerId) =>
      '/business-units/$unitId/business-partners/$partnerId/transaction-lines';
  static String bankCashAccounts(int unitId) =>
      '/business-units/$unitId/cash-bank-accounts';
  static String bankCashAccount(int id) => '/cash-bank-accounts/$id';
  static String pettyCashFunds(int unitId) =>
      '/business-units/$unitId/petty-cash-funds';
  static String fixedAssets(int unitId) =>
      '/business-units/$unitId/fixed-assets';
  static String products(int unitId) => '/business-units/$unitId/products';
  static String warehouses(int unitId) => '/business-units/$unitId/warehouses';
  static String warehouse(int unitId, int warehouseId) =>
      '/business-units/$unitId/warehouses/$warehouseId';
  static String inventoryCount(int unitId) =>
      '/business-units/$unitId/inventory/count';
  static String inventoryTransfer(int unitId) =>
      '/business-units/$unitId/inventory/transfer';
  static String inventory(int unitId) => '/business-units/$unitId/inventory';
  static String fixedAssetDepreciations(int unitId, int assetId) =>
      '/business-units/$unitId/fixed-assets/$assetId/depreciations';
  static String pettyCashFundSettlement(int id) =>
      '/petty-cash-funds/$id/settlement';
  static String fundTransfers(int unitId) =>
      '/business-units/$unitId/fund-transfers';
  static String accountTransfer(int unitId) =>
      '/business-units/$unitId/fund-transfers/account-transfer';
  static String cashFlowCategories(int unitId) =>
      '/business-units/$unitId/cash-flow-categories';
  static String pettyCashCustodians(int unitId) =>
      '/business-units/$unitId/petty-cash-custodians';
  static String accountGroups(int unitId) =>
      '/business-units/$unitId/account-groups';
  static String accountGroupsTree(int unitId) =>
      '/business-units/$unitId/account-groups-tree';
  static String glAccounts(int unitId) => '/business-units/$unitId/gl-accounts';
  static String glAccountTransactions(int unitId, int accountId) =>
      '/business-units/$unitId/gl-accounts/$accountId/transactions';
  static String dailyRestrictions(int unitId) =>
      '/business-units/$unitId/daily-restrictions';
  static String dailyRestrictionParties(int unitId, int restrictionId) =>
      '/business-units/$unitId/daily-restrictions/$restrictionId/parties';
  static String tradeOrders(int unitId) =>
      '/business-units/$unitId/trade-orders';
  static String tradeOrderLines(int unitId, int orderId) =>
      '/business-units/$unitId/trade-orders/$orderId/lines';
  static String tradeInvoices(int unitId) =>
      '/business-units/$unitId/trade-invoices';
  static String tradeInvoiceLines(int unitId, int invoiceId) =>
      '/business-units/$unitId/trade-invoices/$invoiceId/lines';
  static String invoiceReturns(int unitId) =>
      '/business-units/$unitId/invoice-returns';
  static String invoiceReturnLines(int unitId, int invoiceReturnId) =>
      '/business-units/$unitId/invoice-returns/$invoiceReturnId/lines';
  static String invoiceVouchers(int unitId) =>
      '/business-units/$unitId/invoice-vouchers';
  static String directVouchers(int unitId) =>
      '/business-units/$unitId/direct-vouchers';
  static String financialVouchers(int unitId) =>
      '/business-units/$unitId/financial-vouchers';
  static String financialVoucherLines(int unitId, int voucherId) =>
      '/business-units/$unitId/financial-vouchers/$voucherId/lines';
  static String financialStatements(int unitId) =>
      '/business-units/$unitId/financial-statements';
  static String actionHistory(int unitId) =>
      '/business-units/$unitId/action-history';
  static String tenders(int unitId) => '/business-units/$unitId/tenders';
  static String tender(int unitId, int tenderId) =>
      '/business-units/$unitId/tenders/$tenderId';
  static String tenderLines(int unitId, int tenderId) =>
      '/business-units/$unitId/tenders/$tenderId/lines';
  static String tenderInsuranceClaim(int unitId, int tenderId) =>
      '/business-units/$unitId/tenders/$tenderId/insurance-claim';
  static String tenderReject(int unitId, int tenderId) =>
      '/business-units/$unitId/tenders/$tenderId/reject';
  static String tenderComplete(int unitId, int tenderId) =>
      '/business-units/$unitId/tenders/$tenderId/complete';

  // System Users
  static const String systemUsers = '/system-users';
  static String systemUser(int id) => '/system-users/$id';
}
