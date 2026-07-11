part of 'tools.dart';

/// Converts a string to a [ComputerUseSafetyPolicy] using the interactions
/// spec's lowercase `snake_case` wire format (as opposed to the main spec's
/// `UPPER_SNAKE_CASE` format).
ComputerUseSafetyPolicy interactionComputerUseSafetyPolicyFromString(
  String? value,
) {
  return switch (value) {
    'financial_transactions' => ComputerUseSafetyPolicy.financialTransactions,
    'sensitive_data_modification' =>
      ComputerUseSafetyPolicy.sensitiveDataModification,
    'communication_tool' => ComputerUseSafetyPolicy.communicationTool,
    'account_creation' => ComputerUseSafetyPolicy.accountCreation,
    'data_modification' => ComputerUseSafetyPolicy.dataModification,
    'user_consent_management' => ComputerUseSafetyPolicy.userConsentManagement,
    'legal_terms_and_agreements' =>
      ComputerUseSafetyPolicy.legalTermsAndAgreements,
    _ => ComputerUseSafetyPolicy.unspecified,
  };
}

/// Converts a [ComputerUseSafetyPolicy] to the interactions spec's lowercase
/// `snake_case` wire format.
String interactionComputerUseSafetyPolicyToString(
  ComputerUseSafetyPolicy policy,
) {
  return switch (policy) {
    ComputerUseSafetyPolicy.financialTransactions => 'financial_transactions',
    ComputerUseSafetyPolicy.sensitiveDataModification =>
      'sensitive_data_modification',
    ComputerUseSafetyPolicy.communicationTool => 'communication_tool',
    ComputerUseSafetyPolicy.accountCreation => 'account_creation',
    ComputerUseSafetyPolicy.dataModification => 'data_modification',
    ComputerUseSafetyPolicy.userConsentManagement => 'user_consent_management',
    ComputerUseSafetyPolicy.legalTermsAndAgreements =>
      'legal_terms_and_agreements',
    ComputerUseSafetyPolicy.unspecified => 'unspecified',
  };
}

/// A tool that allows the model to interact with the computer.
class ComputerUseTool extends InteractionTool {
  @override
  String get type => 'computer_use';

  /// The environment being operated.
  ///
  /// Currently only 'browser' is supported.
  final String? environment;

  /// The list of predefined functions that are excluded from the model call.
  final List<String>? excludedPredefinedFunctions;

  /// Whether to enable the prompt injection detection check on the
  /// computer-use request.
  final bool? enablePromptInjectionDetection;

  /// Optional. Disabled safety policies for computer use.
  final List<ComputerUseSafetyPolicy>? disabledSafetyPolicies;

  /// Creates a [ComputerUseTool] instance.
  const ComputerUseTool({
    this.environment,
    this.excludedPredefinedFunctions,
    this.enablePromptInjectionDetection,
    this.disabledSafetyPolicies,
  });

  /// Creates a [ComputerUseTool] from JSON.
  factory ComputerUseTool.fromJson(
    Map<String, dynamic> json,
  ) => ComputerUseTool(
    environment: json['environment'] as String?,
    excludedPredefinedFunctions:
        (json['excluded_predefined_functions'] as List<dynamic>?)
            ?.cast<String>(),
    enablePromptInjectionDetection:
        json['enable_prompt_injection_detection'] as bool?,
    disabledSafetyPolicies: (json['disabled_safety_policies'] as List<dynamic>?)
        ?.map((e) => interactionComputerUseSafetyPolicyFromString(e as String?))
        .toList(),
  );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (environment != null) 'environment': environment,
    if (excludedPredefinedFunctions != null)
      'excluded_predefined_functions': excludedPredefinedFunctions,
    if (enablePromptInjectionDetection != null)
      'enable_prompt_injection_detection': enablePromptInjectionDetection,
    if (disabledSafetyPolicies != null)
      'disabled_safety_policies': disabledSafetyPolicies!
          .map(interactionComputerUseSafetyPolicyToString)
          .toList(),
  };
}
