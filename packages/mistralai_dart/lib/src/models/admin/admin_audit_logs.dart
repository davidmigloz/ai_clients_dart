import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Administrative audit log.
@immutable
class AdminAuditLog {
  /// Creates a [AdminAuditLog].
  const AdminAuditLog({
    required this.actorMetadata,
    required this.actorType,
    required this.createdAt,
    required this.eventMetadata,
    required this.eventType,
    required this.logId,
    this.organizationUuid,
    required this.targetMetadata,
    required this.targetType,
    this.workspaceUuid,
  });

  /// Details about who performed the action.
  final Map<String, String> actorMetadata;

  /// Type of actor that performed the action.
  final AdminAuditActorType actorType;

  /// Time when the audit log entry was created.
  final String createdAt;

  /// Details about the recorded action.
  final Map<String, String> eventMetadata;

  /// Type of action recorded in the audit log.
  final AdminAuditEventType eventType;

  /// Audit log entry ID.
  final int logId;

  /// Organization ID for the audit log entry.
  final String? organizationUuid;

  /// Details about the affected resource.
  final Map<String, String> targetMetadata;

  /// Type of resource affected by the action.
  final AdminAuditTargetType targetType;

  /// Workspace ID for the audit log entry.
  final String? workspaceUuid;

  /// Parses a [AdminAuditLog] from JSON.
  factory AdminAuditLog.fromJson(Map<String, dynamic> json) {
    if (json['actor_metadata'] == null) {
      throw const FormatException('AdminAuditLog: missing actor_metadata');
    }
    if (json['actor_type'] == null) {
      throw const FormatException('AdminAuditLog: missing actor_type');
    }
    if (json['created_at'] == null) {
      throw const FormatException('AdminAuditLog: missing created_at');
    }
    if (json['event_metadata'] == null) {
      throw const FormatException('AdminAuditLog: missing event_metadata');
    }
    if (json['event_type'] == null) {
      throw const FormatException('AdminAuditLog: missing event_type');
    }
    if (json['log_id'] == null) {
      throw const FormatException('AdminAuditLog: missing log_id');
    }
    if (json['target_metadata'] == null) {
      throw const FormatException('AdminAuditLog: missing target_metadata');
    }
    if (json['target_type'] == null) {
      throw const FormatException('AdminAuditLog: missing target_type');
    }
    return AdminAuditLog(
      actorMetadata: (json['actor_metadata'] as Map<String, dynamic>).map(
        (key, item) => MapEntry(key, item as String),
      ),
      actorType: AdminAuditActorType.fromJson(json['actor_type'] as String),
      createdAt: json['created_at'] as String,
      eventMetadata: (json['event_metadata'] as Map<String, dynamic>).map(
        (key, item) => MapEntry(key, item as String),
      ),
      eventType: AdminAuditEventType.fromJson(json['event_type'] as String),
      logId: json['log_id'] as int,
      organizationUuid: json['organization_uuid'] == null
          ? null
          : json['organization_uuid'] as String,
      targetMetadata: (json['target_metadata'] as Map<String, dynamic>).map(
        (key, item) => MapEntry(key, item as String),
      ),
      targetType: AdminAuditTargetType.fromJson(json['target_type'] as String),
      workspaceUuid: json['workspace_uuid'] == null
          ? null
          : json['workspace_uuid'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'actor_metadata': actorMetadata,
    'actor_type': actorType.toJson(),
    'created_at': createdAt,
    'event_metadata': eventMetadata,
    'event_type': eventType.toJson(),
    'log_id': logId,
    'organization_uuid': ?organizationUuid,
    'target_metadata': targetMetadata,
    'target_type': targetType.toJson(),
    'workspace_uuid': ?workspaceUuid,
  };

  /// Creates a copy with the given fields replaced.
  AdminAuditLog copyWith({
    Map<String, String>? actorMetadata,
    AdminAuditActorType? actorType,
    String? createdAt,
    Map<String, String>? eventMetadata,
    AdminAuditEventType? eventType,
    int? logId,
    Object? organizationUuid = unsetCopyWithValue,
    Map<String, String>? targetMetadata,
    AdminAuditTargetType? targetType,
    Object? workspaceUuid = unsetCopyWithValue,
  }) => AdminAuditLog(
    actorMetadata: actorMetadata ?? this.actorMetadata,
    actorType: actorType ?? this.actorType,
    createdAt: createdAt ?? this.createdAt,
    eventMetadata: eventMetadata ?? this.eventMetadata,
    eventType: eventType ?? this.eventType,
    logId: logId ?? this.logId,
    organizationUuid: organizationUuid == unsetCopyWithValue
        ? this.organizationUuid
        : organizationUuid as String?,
    targetMetadata: targetMetadata ?? this.targetMetadata,
    targetType: targetType ?? this.targetType,
    workspaceUuid: workspaceUuid == unsetCopyWithValue
        ? this.workspaceUuid
        : workspaceUuid as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminAuditLog &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(actorMetadata, other.actorMetadata) &&
          actorType == other.actorType &&
          createdAt == other.createdAt &&
          valuesDeepEqual(eventMetadata, other.eventMetadata) &&
          eventType == other.eventType &&
          logId == other.logId &&
          organizationUuid == other.organizationUuid &&
          valuesDeepEqual(targetMetadata, other.targetMetadata) &&
          targetType == other.targetType &&
          workspaceUuid == other.workspaceUuid;

  @override
  int get hashCode => Object.hashAll([
    valueDeepHashCode(actorMetadata),
    actorType,
    createdAt,
    valueDeepHashCode(eventMetadata),
    eventType,
    logId,
    organizationUuid,
    valueDeepHashCode(targetMetadata),
    targetType,
    workspaceUuid,
  ]);

  @override
  String toString() =>
      'AdminAuditLog('
      'actorMetadata: ${actorMetadata.length}, '
      'actorType: $actorType, '
      'createdAt: $createdAt, '
      'eventMetadata: ${eventMetadata.length}, '
      'eventType: $eventType, '
      'logId: $logId, '
      'organizationUuid: $organizationUuid, '
      'targetMetadata: ${targetMetadata.length}, '
      'targetType: $targetType, '
      'workspaceUuid: $workspaceUuid)';
}

/// Values for AdminAuditActorType.
enum AdminAuditActorType {
  /// Represents HUMAN.
  human('HUMAN'),

  /// Represents API_KEY.
  apiKey('API_KEY'),

  /// Represents ADMIN_API_KEY.
  adminApiKey('ADMIN_API_KEY'),

  /// Represents SERVICE_ACCOUNT.
  serviceAccount('SERVICE_ACCOUNT'),

  /// Represents OTHER.
  other('OTHER'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const AdminAuditActorType(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static AdminAuditActorType fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// Values for AdminAuditEventType.
enum AdminAuditEventType {
  /// Represents user.create.
  userCreate('user.create'),

  /// Represents user.delete.
  userDelete('user.delete'),

  /// Represents user.log_in.
  userLogIn('user.log_in'),

  /// Represents user.info.update.
  userInfoUpdate('user.info.update'),

  /// Represents user.password.update.
  userPasswordUpdate('user.password.update'),

  /// Represents user.phone_number.verify.
  userPhoneNumberVerify('user.phone_number.verify'),

  /// Represents user.deactivate.
  userDeactivate('user.deactivate'),

  /// Represents user.reactivate.
  userReactivate('user.reactivate'),

  /// Represents user.organization.leave.
  userOrganizationLeave('user.organization.leave'),

  /// Represents user.organization.role.update.
  userOrganizationRoleUpdate('user.organization.role.update'),

  /// Represents user.organization.delete.
  userOrganizationDelete('user.organization.delete'),

  /// Represents user.organization.join.
  userOrganizationJoin('user.organization.join'),

  /// Represents organization.create.
  organizationCreate('organization.create'),

  /// Represents organization.delete.
  organizationDelete('organization.delete'),

  /// Represents organization.update.
  organizationUpdate('organization.update'),

  /// Represents organization.members.export.
  organizationMembersExport('organization.members.export'),

  /// Represents organization.invite.send.
  organizationInviteSend('organization.invite.send'),

  /// Represents organization.invite.resend.
  organizationInviteResend('organization.invite.resend'),

  /// Represents organization.invite.accepted.
  organizationInviteAccepted('organization.invite.accepted'),

  /// Represents organization.invite.revoked.
  organizationInviteRevoked('organization.invite.revoked'),

  /// Represents organization.join_by_email_domain.
  organizationJoinByEmailDomain('organization.join_by_email_domain'),

  /// Represents organization.domain_verification.disable.
  organizationDomainVerificationDisable(
    'organization.domain_verification.disable',
  ),

  /// Represents organization.domain_verification.enable.
  organizationDomainVerificationEnable(
    'organization.domain_verification.enable',
  ),

  /// Represents organization.email_domain_authentication.enable.
  organizationEmailDomainAuthenticationEnable(
    'organization.email_domain_authentication.enable',
  ),

  /// Represents organization.email_domain_authentication.disable.
  organizationEmailDomainAuthenticationDisable(
    'organization.email_domain_authentication.disable',
  ),

  /// Represents organization.saml_authentication.enable.
  organizationSamlAuthenticationEnable(
    'organization.saml_authentication.enable',
  ),

  /// Represents organization.saml_authentication.disable.
  organizationSamlAuthenticationDisable(
    'organization.saml_authentication.disable',
  ),

  /// Represents organization.saml_authentication.sso_user_provisioning.update.
  organizationSamlAuthenticationSsoUserProvisioningUpdate(
    'organization.saml_authentication.sso_user_provisioning.update',
  ),

  /// Represents organization.scim_sync.trigger.
  organizationScimSyncTrigger('organization.scim_sync.trigger'),

  /// Represents organization.scim.secret.rotate.
  organizationScimSecretRotate('organization.scim.secret.rotate'),

  /// Represents organization.seat_auto_assign.enable.
  organizationSeatAutoAssignEnable('organization.seat_auto_assign.enable'),

  /// Represents organization.seat_auto_assign.disable.
  organizationSeatAutoAssignDisable('organization.seat_auto_assign.disable'),

  /// Represents organization.kind.update.
  organizationKindUpdate('organization.kind.update'),

  /// Represents organization.sso_seat_auto_assign.enable.
  organizationSsoSeatAutoAssignEnable(
    'organization.sso_seat_auto_assign.enable',
  ),

  /// Represents organization.sso_seat_auto_assign.disable.
  organizationSsoSeatAutoAssignDisable(
    'organization.sso_seat_auto_assign.disable',
  ),

  /// Represents workspace.create.
  workspaceCreate('workspace.create'),

  /// Represents workspace.update.
  workspaceUpdate('workspace.update'),

  /// Represents workspace.delete.
  workspaceDelete('workspace.delete'),

  /// Represents workspace.members.export.
  workspaceMembersExport('workspace.members.export'),

  /// Represents workspace.member.add.
  workspaceMemberAdd('workspace.member.add'),

  /// Represents workspace.member.remove.
  workspaceMemberRemove('workspace.member.remove'),

  /// Represents workspace.member.role.update.
  workspaceMemberRoleUpdate('workspace.member.role.update'),

  /// Represents user_group.create.
  userGroupCreate('user_group.create'),

  /// Represents user_group.update.
  userGroupUpdate('user_group.update'),

  /// Represents user_group.delete.
  userGroupDelete('user_group.delete'),

  /// Represents user_group.member.add.
  userGroupMemberAdd('user_group.member.add'),

  /// Represents user_group.member.remove.
  userGroupMemberRemove('user_group.member.remove'),

  /// Represents user_group.workspace.provision.
  userGroupWorkspaceProvision('user_group.workspace.provision'),

  /// Represents user_group.workspace.deprovision.
  userGroupWorkspaceDeprovision('user_group.workspace.deprovision'),

  /// Represents user_group.workspace.update.
  userGroupWorkspaceUpdate('user_group.workspace.update'),

  /// Represents billing.information.updated.
  billingInformationUpdated('billing.information.updated'),

  /// Represents billing.payment_method.added.
  billingPaymentMethodAdded('billing.payment_method.added'),

  /// Represents billing.payment_method.removed.
  billingPaymentMethodRemoved('billing.payment_method.removed'),

  /// Represents billing.payment_method.default_changed.
  billingPaymentMethodDefaultChanged('billing.payment_method.default_changed'),

  /// Represents billing.invoice.retried.
  billingInvoiceRetried('billing.invoice.retried'),

  /// Represents billing.subscription.subscribe.
  billingSubscriptionSubscribe('billing.subscription.subscribe'),

  /// Represents billing.subscription.unsubscribe.
  billingSubscriptionUnsubscribe('billing.subscription.unsubscribe'),

  /// Represents billing.subscription.cancel_unsubscribe.
  billingSubscriptionCancelUnsubscribe(
    'billing.subscription.cancel_unsubscribe',
  ),

  /// Represents billing.subscription.add_seats.
  billingSubscriptionAddSeats('billing.subscription.add_seats'),

  /// Represents billing.subscription.remove_seats.
  billingSubscriptionRemoveSeats('billing.subscription.remove_seats'),

  /// Represents billing.subscription.termination_date.updated.
  billingSubscriptionTerminationDateUpdated(
    'billing.subscription.termination_date.updated',
  ),

  /// Represents billing.credits.added.
  billingCreditsAdded('billing.credits.added'),

  /// Represents billing.gift_code.used.
  billingGiftCodeUsed('billing.gift_code.used'),

  /// Represents billing.credit_coupon.used.
  billingCreditCouponUsed('billing.credit_coupon.used'),

  /// Represents billing.subscription_coupon.used.
  billingSubscriptionCouponUsed('billing.subscription_coupon.used'),

  /// Represents billing.monthly_limit.updated.
  billingMonthlyLimitUpdated('billing.monthly_limit.updated'),

  /// Represents billing.workspace_monthly_limit.updated.
  billingWorkspaceMonthlyLimitUpdated(
    'billing.workspace_monthly_limit.updated',
  ),

  /// Represents billing.shared_budget_override.updated.
  billingSharedBudgetOverrideUpdated('billing.shared_budget_override.updated'),

  /// Represents billing.spending_limit.created.
  billingSpendingLimitCreated('billing.spending_limit.created'),

  /// Represents billing.spending_limit.updated.
  billingSpendingLimitUpdated('billing.spending_limit.updated'),

  /// Represents billing.spending_limit.deleted.
  billingSpendingLimitDeleted('billing.spending_limit.deleted'),

  /// Represents billing.auto_recharge.updated.
  billingAutoRechargeUpdated('billing.auto_recharge.updated'),

  /// Represents billing.seat.grant.
  billingSeatGrant('billing.seat.grant'),

  /// Represents billing.seat.revoke.
  billingSeatRevoke('billing.seat.revoke'),

  /// Represents billing.priority_service_tier.updated.
  billingPriorityServiceTierUpdated('billing.priority_service_tier.updated'),

  /// Represents billing.priority_service_tier.removed.
  billingPriorityServiceTierRemoved('billing.priority_service_tier.removed'),

  /// Represents le_chat.conversation.created.
  leChatConversationCreated('le_chat.conversation.created'),

  /// Represents le_chat.temporary_conversation.created.
  leChatTemporaryConversationCreated('le_chat.temporary_conversation.created'),

  /// Represents le_chat.temporary_conversation.converted.
  leChatTemporaryConversationConverted(
    'le_chat.temporary_conversation.converted',
  ),

  /// Represents le_chat.conversation.deleted.
  leChatConversationDeleted('le_chat.conversation.deleted'),

  /// Represents le_chat.conversation_batch.deleted.
  leChatConversationBatchDeleted('le_chat.conversation_batch.deleted'),

  /// Represents le_chat.conversation.public_sharing.enabled.
  leChatConversationPublicSharingEnabled(
    'le_chat.conversation.public_sharing.enabled',
  ),

  /// Represents le_chat.conversation.public_sharing.disabled.
  leChatConversationPublicSharingDisabled(
    'le_chat.conversation.public_sharing.disabled',
  ),

  /// Represents le_chat.flash_answers.enabled.
  leChatFlashAnswersEnabled('le_chat.flash_answers.enabled'),

  /// Represents le_chat.flash_answers.disabled.
  leChatFlashAnswersDisabled('le_chat.flash_answers.disabled'),

  /// Represents le_chat.localisation_sharing.enabled.
  leChatLocalisationSharingEnabled('le_chat.localisation_sharing.enabled'),

  /// Represents le_chat.localisation_sharing.disabled.
  leChatLocalisationSharingDisabled('le_chat.localisation_sharing.disabled'),

  /// Represents le_chat.memories.enabled.
  leChatMemoriesEnabled('le_chat.memories.enabled'),

  /// Represents le_chat.memories.disabled.
  leChatMemoriesDisabled('le_chat.memories.disabled'),

  /// Represents le_chat.data.training_enabled.
  leChatDataTrainingEnabled('le_chat.data.training_enabled'),

  /// Represents le_chat.data.training_disabled.
  leChatDataTrainingDisabled('le_chat.data.training_disabled'),

  /// Represents le_chat.actions.external_link.
  leChatActionsExternalLink('le_chat.actions.external_link'),

  /// Represents admin_api_key.created.
  adminApiKeyCreated('admin_api_key.created'),

  /// Represents admin_api_key.delete.
  adminApiKeyDelete('admin_api_key.delete'),

  /// Represents api_key.create.
  apiKeyCreate('api_key.create'),

  /// Represents api_key.rotate.
  apiKeyRotate('api_key.rotate'),

  /// Represents api_key.delete.
  apiKeyDelete('api_key.delete'),

  /// Represents api_key_policy.update.
  apiKeyPolicyUpdate('api_key_policy.update'),

  /// Represents secret_store.entry.create.
  secretStoreEntryCreate('secret_store.entry.create'),

  /// Represents secret_store.entry.update.
  secretStoreEntryUpdate('secret_store.entry.update'),

  /// Represents secret_store.entry.delete.
  secretStoreEntryDelete('secret_store.entry.delete'),

  /// Represents service_account.create.
  serviceAccountCreate('service_account.create'),

  /// Represents service_account.update.
  serviceAccountUpdate('service_account.update'),

  /// Represents service_account.delete.
  serviceAccountDelete('service_account.delete'),

  /// Represents service_account.client_secret.create.
  serviceAccountClientSecretCreate('service_account.client_secret.create'),

  /// Represents service_account.client_secret.delete.
  serviceAccountClientSecretDelete('service_account.client_secret.delete'),

  /// Represents service_account.roles.set.
  serviceAccountRolesSet('service_account.roles.set'),

  /// Represents workload_identity.credential_registration.create.
  workloadIdentityCredentialRegistrationCreate(
    'workload_identity.credential_registration.create',
  ),

  /// Represents workload_identity.credential.create.
  workloadIdentityCredentialCreate('workload_identity.credential.create'),

  /// Represents trusted_issuer.create.
  trustedIssuerCreate('trusted_issuer.create'),

  /// Represents trusted_issuer.update.
  trustedIssuerUpdate('trusted_issuer.update'),

  /// Represents trusted_issuer.delete.
  trustedIssuerDelete('trusted_issuer.delete'),

  /// Represents agent.create.
  agentCreate('agent.create'),

  /// Represents agent.delete.
  agentDelete('agent.delete'),

  /// Represents agent.update.
  agentUpdate('agent.update'),

  /// Represents skill.create.
  skillCreate('skill.create'),

  /// Represents skill.delete.
  skillDelete('skill.delete'),

  /// Represents skill.enable.
  skillEnable('skill.enable'),

  /// Represents skill.disable.
  skillDisable('skill.disable'),

  /// Represents skill.update.
  skillUpdate('skill.update'),

  /// Represents skill.share.
  skillShare('skill.share'),

  /// Represents skill.unshare.
  skillUnshare('skill.unshare'),

  /// Represents skill.load.
  skillLoad('skill.load'),

  /// Represents skill.force_load.
  skillForceLoad('skill.force_load'),

  /// Represents skill.version.create.
  skillVersionCreate('skill.version.create'),

  /// Represents plugin.create.
  pluginCreate('plugin.create'),

  /// Represents plugin.update.
  pluginUpdate('plugin.update'),

  /// Represents plugin.delete.
  pluginDelete('plugin.delete'),

  /// Represents prompt.create.
  promptCreate('prompt.create'),

  /// Represents prompt.delete.
  promptDelete('prompt.delete'),

  /// Represents prompt.update.
  promptUpdate('prompt.update'),

  /// Represents prompt.version.create.
  promptVersionCreate('prompt.version.create'),

  /// Represents knowledge_base.create.
  knowledgeBaseCreate('knowledge_base.create'),

  /// Represents knowledge_base.delete.
  knowledgeBaseDelete('knowledge_base.delete'),

  /// Represents knowledge_base.update.
  knowledgeBaseUpdate('knowledge_base.update'),

  /// Represents knowledge_base.load.
  knowledgeBaseLoad('knowledge_base.load'),

  /// Represents knowledge_base.version.create.
  knowledgeBaseVersionCreate('knowledge_base.version.create'),

  /// Represents custom_voice.create.
  customVoiceCreate('custom_voice.create'),

  /// Represents custom_voice.update.
  customVoiceUpdate('custom_voice.update'),

  /// Represents custom_voice.delete.
  customVoiceDelete('custom_voice.delete'),

  /// Represents capability_registry.create.
  capabilityRegistryCreate('capability_registry.create'),

  /// Represents capability_registry.default_workspace_access.enable.
  capabilityRegistryDefaultWorkspaceAccessEnable(
    'capability_registry.default_workspace_access.enable',
  ),

  /// Represents capability_registry.default_workspace_access.disable.
  capabilityRegistryDefaultWorkspaceAccessDisable(
    'capability_registry.default_workspace_access.disable',
  ),

  /// Represents capability_registry.workspace_access.enable.
  capabilityRegistryWorkspaceAccessEnable(
    'capability_registry.workspace_access.enable',
  ),

  /// Represents capability_registry.workspace_access.disable.
  capabilityRegistryWorkspaceAccessDisable(
    'capability_registry.workspace_access.disable',
  ),

  /// Represents capability_registry.workspace_access.remove.
  capabilityRegistryWorkspaceAccessRemove(
    'capability_registry.workspace_access.remove',
  ),

  /// Represents capability.version.create.
  capabilityVersionCreate('capability.version.create'),

  /// Represents capability.version.disable.
  capabilityVersionDisable('capability.version.disable'),

  /// Represents capability.version.enable.
  capabilityVersionEnable('capability.version.enable'),

  /// Represents capability.disable.
  capabilityDisable('capability.disable'),

  /// Represents capability.enable.
  capabilityEnable('capability.enable'),

  /// Represents feature_permission.override.created.
  featurePermissionOverrideCreated('feature_permission.override.created'),

  /// Represents feature_permission.override.deleted.
  featurePermissionOverrideDeleted('feature_permission.override.deleted'),

  /// Represents resource.share.
  resourceShare('resource.share'),

  /// Represents resource.unshare.
  resourceUnshare('resource.unshare'),

  /// Represents la_plateforme.training.enabled.
  laPlateformeTrainingEnabled('la_plateforme.training.enabled'),

  /// Represents la_plateforme.training.disabled.
  laPlateformeTrainingDisabled('la_plateforme.training.disabled'),

  /// Represents cloud_runtime.app.created.
  cloudRuntimeAppCreated('cloud_runtime.app.created'),

  /// Represents cloud_runtime.app.updated.
  cloudRuntimeAppUpdated('cloud_runtime.app.updated'),

  /// Represents cloud_runtime.app.deleted.
  cloudRuntimeAppDeleted('cloud_runtime.app.deleted'),

  /// Represents cloud_runtime.app.paused.
  cloudRuntimeAppPaused('cloud_runtime.app.paused'),

  /// Represents cloud_runtime.app.resumed.
  cloudRuntimeAppResumed('cloud_runtime.app.resumed'),

  /// Represents cloud_runtime.deployment.created.
  cloudRuntimeDeploymentCreated('cloud_runtime.deployment.created'),

  /// Represents cloud_runtime.deployment.succeeded.
  cloudRuntimeDeploymentSucceeded('cloud_runtime.deployment.succeeded'),

  /// Represents cloud_runtime.deployment.canceled.
  cloudRuntimeDeploymentCanceled('cloud_runtime.deployment.canceled'),

  /// Represents cloud_runtime.deployment.stopped.
  cloudRuntimeDeploymentStopped('cloud_runtime.deployment.stopped'),

  /// Represents cloud_runtime.deployment.failed.
  cloudRuntimeDeploymentFailed('cloud_runtime.deployment.failed'),

  /// Represents cloud_runtime.deployment.autoscaled.
  cloudRuntimeDeploymentAutoscaled('cloud_runtime.deployment.autoscaled'),

  /// Represents cloud_runtime.domain.created.
  cloudRuntimeDomainCreated('cloud_runtime.domain.created'),

  /// Represents cloud_runtime.domain.updated.
  cloudRuntimeDomainUpdated('cloud_runtime.domain.updated'),

  /// Represents cloud_runtime.domain.deleted.
  cloudRuntimeDomainDeleted('cloud_runtime.domain.deleted'),

  /// Represents cloud_runtime.secret.created.
  cloudRuntimeSecretCreated('cloud_runtime.secret.created'),

  /// Represents cloud_runtime.secret.updated.
  cloudRuntimeSecretUpdated('cloud_runtime.secret.updated'),

  /// Represents cloud_runtime.secret.deleted.
  cloudRuntimeSecretDeleted('cloud_runtime.secret.deleted'),

  /// Represents cloud_runtime.service.created.
  cloudRuntimeServiceCreated('cloud_runtime.service.created'),

  /// Represents cloud_runtime.service.paused.
  cloudRuntimeServicePaused('cloud_runtime.service.paused'),

  /// Represents cloud_runtime.service.resumed.
  cloudRuntimeServiceResumed('cloud_runtime.service.resumed'),

  /// Represents cloud_runtime.service.deleted.
  cloudRuntimeServiceDeleted('cloud_runtime.service.deleted'),

  /// Represents cloud_runtime.service.manually_scaled.
  cloudRuntimeServiceManuallyScaled('cloud_runtime.service.manually_scaled'),

  /// Represents cloud_runtime.service.manual_scaling_deleted.
  cloudRuntimeServiceManualScalingDeleted(
    'cloud_runtime.service.manual_scaling_deleted',
  ),

  /// Represents cloud_runtime.persistent_volume.created.
  cloudRuntimePersistentVolumeCreated(
    'cloud_runtime.persistent_volume.created',
  ),

  /// Represents cloud_runtime.persistent_volume.deleted.
  cloudRuntimePersistentVolumeDeleted(
    'cloud_runtime.persistent_volume.deleted',
  ),

  /// Represents cloud_runtime.persistent_volume.attached.
  cloudRuntimePersistentVolumeAttached(
    'cloud_runtime.persistent_volume.attached',
  ),

  /// Represents cloud_runtime.persistent_volume.detached.
  cloudRuntimePersistentVolumeDetached(
    'cloud_runtime.persistent_volume.detached',
  ),

  /// Represents fine_tuning_job.create.
  fineTuningJobCreate('fine_tuning_job.create'),

  /// Represents fine_tuning_job.cancel.
  fineTuningJobCancel('fine_tuning_job.cancel'),

  /// Represents batch_job.create.
  batchJobCreate('batch_job.create'),

  /// Represents batch_job.cancel.
  batchJobCancel('batch_job.cancel'),

  /// Represents batch_job.delete.
  batchJobDelete('batch_job.delete'),

  /// Represents data_capture.extract_job.create.
  dataCaptureExtractJobCreate('data_capture.extract_job.create'),

  /// Represents data_capture.extract_job.cancel.
  dataCaptureExtractJobCancel('data_capture.extract_job.cancel'),

  /// Represents dataset.create.
  datasetCreate('dataset.create'),

  /// Represents dataset.delete.
  datasetDelete('dataset.delete'),

  /// Represents library.create.
  libraryCreate('library.create'),

  /// Represents library.delete.
  libraryDelete('library.delete'),

  /// Represents library.update.
  libraryUpdate('library.update'),

  /// Represents library.share.
  libraryShare('library.share'),

  /// Represents library.unshare.
  libraryUnshare('library.unshare'),

  /// Represents library.document.create.
  libraryDocumentCreate('library.document.create'),

  /// Represents library.document.delete.
  libraryDocumentDelete('library.document.delete'),

  /// Represents library.document.bulk_delete.
  libraryDocumentBulkDelete('library.document.bulk_delete'),

  /// Represents library.document.update.
  libraryDocumentUpdate('library.document.update'),

  /// Represents library.document.reprocess.
  libraryDocumentReprocess('library.document.reprocess'),

  /// Represents integration.connected.
  integrationConnected('integration.connected'),

  /// Represents integration.disconnected.
  integrationDisconnected('integration.disconnected'),

  /// Represents indexing.workflow.completed.
  indexingWorkflowCompleted('indexing.workflow.completed'),

  /// Represents indexing.deleted.
  indexingDeleted('indexing.deleted'),

  /// Represents connection.admin.setup_index.
  connectionAdminSetupIndex('connection.admin.setup_index'),

  /// Represents connection.admin.deleted.
  connectionAdminDeleted('connection.admin.deleted'),

  /// Represents integration.activated_for_org.
  integrationActivatedForOrg('integration.activated_for_org'),

  /// Represents integration.deactivated_for_org.
  integrationDeactivatedForOrg('integration.deactivated_for_org'),

  /// Represents integration.activated_for_workspace.
  integrationActivatedForWorkspace('integration.activated_for_workspace'),

  /// Represents integration.deactivated_for_workspace.
  integrationDeactivatedForWorkspace('integration.deactivated_for_workspace'),

  /// Represents integration.activated_for_user.
  integrationActivatedForUser('integration.activated_for_user'),

  /// Represents integration.deactivated_for_user.
  integrationDeactivatedForUser('integration.deactivated_for_user'),

  /// Represents integration.created.
  integrationCreated('integration.created'),

  /// Represents integration.updated.
  integrationUpdated('integration.updated'),

  /// Represents integration.deleted.
  integrationDeleted('integration.deleted'),

  /// Represents integration.tool_called.
  integrationToolCalled('integration.tool_called'),

  /// Represents integration.tool_activated.
  integrationToolActivated('integration.tool_activated'),

  /// Represents integration.tool_deactivated.
  integrationToolDeactivated('integration.tool_deactivated'),

  /// Represents integration.credentials.created_or_updated.
  integrationCredentialsCreatedOrUpdated(
    'integration.credentials.created_or_updated',
  ),

  /// Represents integration.credentials.deleted.
  integrationCredentialsDeleted('integration.credentials.deleted'),

  /// Represents integration.credentials.revoked.
  integrationCredentialsRevoked('integration.credentials.revoked'),

  /// Represents integration.credentials.revocation_failed.
  integrationCredentialsRevocationFailed(
    'integration.credentials.revocation_failed',
  ),

  /// Represents integration.preferences.created_or_updated.
  integrationPreferencesCreatedOrUpdated(
    'integration.preferences.created_or_updated',
  ),

  /// Represents integration.preferences.deleted.
  integrationPreferencesDeleted('integration.preferences.deleted'),

  /// Represents integration.authentication_method.created_or_updated.
  integrationAuthenticationMethodCreatedOrUpdated(
    'integration.authentication_method.created_or_updated',
  ),

  /// Represents integration.connection.created.
  integrationConnectionCreated('integration.connection.created'),

  /// Represents integration.shared.
  integrationShared('integration.shared'),

  /// Represents integration.unshared.
  integrationUnshared('integration.unshared'),

  /// Represents connectors_gateway.tool_called.
  connectorsGatewayToolCalled('connectors_gateway.tool_called'),

  /// Represents connectors_debugger.tool_called.
  connectorsDebuggerToolCalled('connectors_debugger.tool_called'),

  /// Represents crawler.config.create.
  crawlerConfigCreate('crawler.config.create'),

  /// Represents crawler.config.update.
  crawlerConfigUpdate('crawler.config.update'),

  /// Represents crawler.config.delete.
  crawlerConfigDelete('crawler.config.delete'),

  /// Represents crawler.run.create.
  crawlerRunCreate('crawler.run.create'),

  /// Represents crawler.run.cancel.
  crawlerRunCancel('crawler.run.cancel'),

  /// Represents web_search.filter_config.update.
  webSearchFilterConfigUpdate('web_search.filter_config.update'),

  /// Represents web_search.filter_domain.add.
  webSearchFilterDomainAdd('web_search.filter_domain.add'),

  /// Represents web_search.filter_domain.remove.
  webSearchFilterDomainRemove('web_search.filter_domain.remove'),

  /// Represents web_filters.config.update.
  webFiltersConfigUpdate('web_filters.config.update'),

  /// Represents web_filters.domain.add.
  webFiltersDomainAdd('web_filters.domain.add'),

  /// Represents web_filters.domain.remove.
  webFiltersDomainRemove('web_filters.domain.remove'),

  /// Represents secrets_manager.secret.created.
  secretsManagerSecretCreated('secrets_manager.secret.created'),

  /// Represents secrets_manager.secret.updated.
  secretsManagerSecretUpdated('secrets_manager.secret.updated'),

  /// Represents secrets_manager.secret.revealed.
  secretsManagerSecretRevealed('secrets_manager.secret.revealed'),

  /// Represents secrets_manager.secret.metadata_updated.
  secretsManagerSecretMetadataUpdated(
    'secrets_manager.secret.metadata_updated',
  ),

  /// Represents secrets_manager.secret.deleted.
  secretsManagerSecretDeleted('secrets_manager.secret.deleted'),

  /// Represents secrets_manager.secret.destroyed.
  secretsManagerSecretDestroyed('secrets_manager.secret.destroyed'),

  /// Represents secrets_manager.secret.version.deleted.
  secretsManagerSecretVersionDeleted('secrets_manager.secret.version.deleted'),

  /// Represents secrets_manager.secret.version.restored.
  secretsManagerSecretVersionRestored(
    'secrets_manager.secret.version.restored',
  ),

  /// Represents rate_limit.rule.create.
  rateLimitRuleCreate('rate_limit.rule.create'),

  /// Represents rate_limit.rule.update.
  rateLimitRuleUpdate('rate_limit.rule.update'),

  /// Represents rate_limit.rule.delete.
  rateLimitRuleDelete('rate_limit.rule.delete'),

  /// Represents workflow.execution.started.
  workflowExecutionStarted('workflow.execution.started'),

  /// Represents workflow.execution.canceled.
  workflowExecutionCanceled('workflow.execution.canceled'),

  /// Represents workflow.execution.terminated.
  workflowExecutionTerminated('workflow.execution.terminated'),

  /// Represents workflow.execution.completed.
  workflowExecutionCompleted('workflow.execution.completed'),

  /// Represents workflow.execution.failed.
  workflowExecutionFailed('workflow.execution.failed'),

  /// Represents workflow.execution.signal.
  workflowExecutionSignal('workflow.execution.signal'),

  /// Represents workflow.execution.query.
  workflowExecutionQuery('workflow.execution.query'),

  /// Represents workflow.execution.update.
  workflowExecutionUpdate('workflow.execution.update'),

  /// Represents workflow.worker.registered.
  workflowWorkerRegistered('workflow.worker.registered'),

  /// Represents workflow.schedule.created.
  workflowScheduleCreated('workflow.schedule.created'),

  /// Represents workflow.schedule.updated.
  workflowScheduleUpdated('workflow.schedule.updated'),

  /// Represents workflow.schedule.paused.
  workflowSchedulePaused('workflow.schedule.paused'),

  /// Represents workflow.schedule.resumed.
  workflowScheduleResumed('workflow.schedule.resumed'),

  /// Represents workflow.schedule.deleted.
  workflowScheduleDeleted('workflow.schedule.deleted'),

  /// Represents workflow.schedule.triggered.
  workflowScheduleTriggered('workflow.schedule.triggered'),

  /// Represents workflow.archived.
  workflowArchived('workflow.archived'),

  /// Represents workflow.unarchived.
  workflowUnarchived('workflow.unarchived'),

  /// Represents workflow.deployment.authorized_credential.granted.
  workflowDeploymentAuthorizedCredentialGranted(
    'workflow.deployment.authorized_credential.granted',
  ),

  /// Represents workflow.deployment.authorized_credential.revoked.
  workflowDeploymentAuthorizedCredentialRevoked(
    'workflow.deployment.authorized_credential.revoked',
  ),

  /// Represents workflow.managed_deployment.created.
  workflowManagedDeploymentCreated('workflow.managed_deployment.created'),

  /// Represents workflow.managed_deployment.updated.
  workflowManagedDeploymentUpdated('workflow.managed_deployment.updated'),

  /// Represents workflow.managed_deployment.stopped.
  workflowManagedDeploymentStopped('workflow.managed_deployment.stopped'),

  /// Represents workflow.managed_deployment.started.
  workflowManagedDeploymentStarted('workflow.managed_deployment.started'),

  /// Represents workflow.managed_deployment.restarted.
  workflowManagedDeploymentRestarted('workflow.managed_deployment.restarted'),

  /// Represents workflow.managed_deployment.deleted.
  workflowManagedDeploymentDeleted('workflow.managed_deployment.deleted'),

  /// Represents workflow.managed_deployment.credential.provisioned.
  workflowManagedDeploymentCredentialProvisioned(
    'workflow.managed_deployment.credential.provisioned',
  ),

  /// Represents workflow.managed_deployment.credential.revoked.
  workflowManagedDeploymentCredentialRevoked(
    'workflow.managed_deployment.credential.revoked',
  ),

  /// Represents workflow.managed_deployment.status.changed.
  workflowManagedDeploymentStatusChanged(
    'workflow.managed_deployment.status.changed',
  ),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const AdminAuditEventType(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static AdminAuditEventType fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// Values for AdminAuditTargetType.
enum AdminAuditTargetType {
  /// Represents USER.
  user('USER'),

  /// Represents USER_GROUP.
  userGroup('USER_GROUP'),

  /// Represents ORGANIZATION.
  organization('ORGANIZATION'),

  /// Represents WORKSPACE.
  workspace('WORKSPACE'),

  /// Represents API_KEY.
  apiKey('API_KEY'),

  /// Represents ADMIN_API_KEY.
  adminApiKey('ADMIN_API_KEY'),

  /// Represents API_KEY_POLICY.
  apiKeyPolicy('API_KEY_POLICY'),

  /// Represents SERVICE_ACCOUNT.
  serviceAccount('SERVICE_ACCOUNT'),

  /// Represents AGENT.
  agent('AGENT'),

  /// Represents SKILL.
  skill('SKILL'),

  /// Represents PLUGIN.
  plugin('PLUGIN'),

  /// Represents PROMPT.
  prompt('PROMPT'),

  /// Represents KNOWLEDGE_BASE.
  knowledgeBase('KNOWLEDGE_BASE'),

  /// Represents CUSTOM_VOICE.
  customVoice('CUSTOM_VOICE'),

  /// Represents CAPABILITY_REGISTRY.
  capabilityRegistry('CAPABILITY_REGISTRY'),

  /// Represents CAPABILITY.
  capability('CAPABILITY'),

  /// Represents DATASET.
  dataset('DATASET'),

  /// Represents FINE_TUNING_JOB.
  fineTuningJob('FINE_TUNING_JOB'),

  /// Represents BATCH_JOB.
  batchJob('BATCH_JOB'),

  /// Represents DATA_CAPTURE_EXTRACT_JOB.
  dataCaptureExtractJob('DATA_CAPTURE_EXTRACT_JOB'),

  /// Represents LE_CHAT_CONVERSATION.
  leChatConversation('LE_CHAT_CONVERSATION'),

  /// Represents LE_CHAT_MEMORIES.
  leChatMemories('LE_CHAT_MEMORIES'),

  /// Represents LE_CHAT_FLASH_ANSWERS.
  leChatFlashAnswers('LE_CHAT_FLASH_ANSWERS'),

  /// Represents LE_CHAT_LOCALISATION.
  leChatLocalisation('LE_CHAT_LOCALISATION'),

  /// Represents LE_CHAT_DATA.
  leChatData('LE_CHAT_DATA'),

  /// Represents INVOICE.
  invoice('INVOICE'),

  /// Represents WALLET.
  wallet('WALLET'),

  /// Represents MONTHLY_LIMIT.
  monthlyLimit('MONTHLY_LIMIT'),

  /// Represents WORKSPACE_MONTHLY_LIMIT.
  workspaceMonthlyLimit('WORKSPACE_MONTHLY_LIMIT'),

  /// Represents SPENDING_LIMIT.
  spendingLimit('SPENDING_LIMIT'),

  /// Represents SHARED_BUDGET.
  sharedBudget('SHARED_BUDGET'),

  /// Represents AUTO_RECHARGE.
  autoRecharge('AUTO_RECHARGE'),

  /// Represents PAYMENT_METHOD.
  paymentMethod('PAYMENT_METHOD'),

  /// Represents SUBSCRIPTION.
  subscription('SUBSCRIPTION'),

  /// Represents BILLING_INFO.
  billingInfo('BILLING_INFO'),

  /// Represents LIBRARY.
  library('LIBRARY'),

  /// Represents LIBRARY_DOCUMENT.
  libraryDocument('LIBRARY_DOCUMENT'),

  /// Represents INTEGRATION.
  integration('INTEGRATION'),

  /// Represents CONNECTORS_GATEWAY.
  connectorsGateway('CONNECTORS_GATEWAY'),

  /// Represents CONNECTORS_DEBUGGER.
  connectorsDebugger('CONNECTORS_DEBUGGER'),

  /// Represents FEATURE_PERMISSION.
  featurePermission('FEATURE_PERMISSION'),

  /// Represents SECRET_STORE_ENTRY.
  secretStoreEntry('SECRET_STORE_ENTRY'),

  /// Represents CRAWLER_CONFIG.
  crawlerConfig('CRAWLER_CONFIG'),

  /// Represents WEB_SEARCH_FILTER.
  webSearchFilter('WEB_SEARCH_FILTER'),

  /// Represents WEB_FILTERS.
  webFilters('WEB_FILTERS'),

  /// Represents SHARED_RESOURCE.
  sharedResource('SHARED_RESOURCE'),

  /// Represents RATE_LIMIT_RULE.
  rateLimitRule('RATE_LIMIT_RULE'),

  /// Represents APP.
  app('APP'),

  /// Represents DEPLOYMENT.
  deployment('DEPLOYMENT'),

  /// Represents DOMAIN.
  domain('DOMAIN'),

  /// Represents PERSISTENT_VOLUME.
  persistentVolume('PERSISTENT_VOLUME'),

  /// Represents SECRET.
  secret('SECRET'),

  /// Represents SERVICE.
  service('SERVICE'),

  /// Represents TRUSTED_ISSUER.
  trustedIssuer('TRUSTED_ISSUER'),

  /// Represents WORKFLOW.
  workflow('WORKFLOW'),

  /// Represents SCHEDULE.
  schedule('SCHEDULE'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const AdminAuditTargetType(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static AdminAuditTargetType fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// Sort order for Admin audit log events.
enum AdminAuditLogSort {
  /// Oldest events first.
  ascending('ascending'),

  /// Most recent events first.
  descending('descending');

  const AdminAuditLogSort(this.value);

  /// The wire value.
  final String value;
}
