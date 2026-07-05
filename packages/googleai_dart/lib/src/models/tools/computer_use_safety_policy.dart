/// Safety policies that can be disabled for computer use.
enum ComputerUseSafetyPolicy {
  /// Unspecified safety policy.
  unspecified,

  /// Safety policy for financial transactions.
  financialTransactions,

  /// Safety policy for sensitive data modification.
  sensitiveDataModification,

  /// Safety policy for communication tools (e.g. Gmail, Chat, Meet).
  communicationTool,

  /// Safety policy for account creation.
  accountCreation,

  /// Safety policy for data modification.
  dataModification,

  /// Safety policy for user consent management.
  userConsentManagement,

  /// Safety policy for legal terms and agreements.
  legalTermsAndAgreements,
}

/// Converts a string to a [ComputerUseSafetyPolicy] enum value.
ComputerUseSafetyPolicy computerUseSafetyPolicyFromString(String? value) {
  return switch (value) {
    'FINANCIAL_TRANSACTIONS' => ComputerUseSafetyPolicy.financialTransactions,
    'SENSITIVE_DATA_MODIFICATION' =>
      ComputerUseSafetyPolicy.sensitiveDataModification,
    'COMMUNICATION_TOOL' => ComputerUseSafetyPolicy.communicationTool,
    'ACCOUNT_CREATION' => ComputerUseSafetyPolicy.accountCreation,
    'DATA_MODIFICATION' => ComputerUseSafetyPolicy.dataModification,
    'USER_CONSENT_MANAGEMENT' => ComputerUseSafetyPolicy.userConsentManagement,
    'LEGAL_TERMS_AND_AGREEMENTS' =>
      ComputerUseSafetyPolicy.legalTermsAndAgreements,
    _ => ComputerUseSafetyPolicy.unspecified,
  };
}

/// Converts a [ComputerUseSafetyPolicy] enum value to a string.
String computerUseSafetyPolicyToString(ComputerUseSafetyPolicy policy) {
  return switch (policy) {
    ComputerUseSafetyPolicy.financialTransactions => 'FINANCIAL_TRANSACTIONS',
    ComputerUseSafetyPolicy.sensitiveDataModification =>
      'SENSITIVE_DATA_MODIFICATION',
    ComputerUseSafetyPolicy.communicationTool => 'COMMUNICATION_TOOL',
    ComputerUseSafetyPolicy.accountCreation => 'ACCOUNT_CREATION',
    ComputerUseSafetyPolicy.dataModification => 'DATA_MODIFICATION',
    ComputerUseSafetyPolicy.userConsentManagement => 'USER_CONSENT_MANAGEMENT',
    ComputerUseSafetyPolicy.legalTermsAndAgreements =>
      'LEGAL_TERMS_AND_AGREEMENTS',
    ComputerUseSafetyPolicy.unspecified => 'SAFETY_POLICY_UNSPECIFIED',
  };
}
