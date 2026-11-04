import 'dart:convert';

/// Synthetic frozen-contract fixtures, never live credentials.
Map<String, dynamic> adminFixture(String name) =>
    Map<String, dynamic>.from((jsonDecode(_fixtures) as Map)[name] as Map);

const _fixtures = r'''
{
  "AwsExternalKeyParams": {
    "name": "synthetic-private",
    "type": "aws",
    "role_arn": "arn:aws:iam::123456789012:role/synthetic",
    "kms_arn": "synthetic-private",
    "external_id": "synthetic-private",
    "purpose": "ekm"
  },
  "AzureExternalKeyParams": {
    "name": "synthetic-private",
    "type": "azure",
    "tenant_id": "00000000-0000-0000-0000-000000000000",
    "vault_uri": "https://synthetic.vault.azure.net",
    "key_name": "org-synthetic--test",
    "purpose": "psp_decryption",
    "key_version": "00000000000000000000000000000000"
  },
  "GcpExternalKeyParams": {
    "name": "synthetic-private",
    "type": "gcp",
    "workload_identity_project_number": "123456789012",
    "workload_identity_pool_id": "synthetic-private",
    "workload_identity_provider_id": "synthetic-private",
    "kms_project_id": "synthetic-private",
    "kms_key_ring_name": "synthetic-private",
    "kms_key_name": "synthetic-private",
    "kms_key_location": "synthetic-private",
    "audience": "synthetic-private",
    "purpose": "psp_decryption",
    "kms_key_version": "1"
  },
  "ExternalKeyResource": {
    "object": "synthetic-private",
    "id": "synthetic-private",
    "type": "synthetic-private",
    "purpose": "ekm",
    "name": "synthetic-private",
    "api_project_ids": [
      "synthetic-private"
    ],
    "workspace_id": "synthetic-private",
    "created_at": 1,
    "role_arn": "arn:aws:iam::123456789012:role/synthetic",
    "external_id": "synthetic-private",
    "kms_arn": "synthetic-private",
    "workload_identity_project_number": "123456789012",
    "workload_identity_pool_id": "synthetic-private",
    "workload_identity_provider_id": "synthetic-private",
    "audience": "synthetic-private",
    "kms_project_id": "synthetic-private",
    "kms_key_ring_name": "synthetic-private",
    "kms_key_name": "synthetic-private",
    "kms_key_location": "synthetic-private",
    "kms_key_version": "1",
    "tenant_id": "00000000-0000-0000-0000-000000000000",
    "vault_uri": "https://synthetic.vault.azure.net",
    "key_name": "org-synthetic--test",
    "key_version": "00000000000000000000000000000000"
  },
  "ListExternalKeysResource": {
    "object": "list",
    "data": [
      {
        "object": "synthetic-private",
        "id": "synthetic-private",
        "type": "synthetic-private",
        "purpose": "ekm",
        "name": "synthetic-private",
        "api_project_ids": [
          "synthetic-private"
        ],
        "workspace_id": "synthetic-private",
        "created_at": 1,
        "role_arn": "arn:aws:iam::123456789012:role/synthetic",
        "external_id": "synthetic-private",
        "kms_arn": "synthetic-private",
        "workload_identity_project_number": "123456789012",
        "workload_identity_pool_id": "synthetic-private",
        "workload_identity_provider_id": "synthetic-private",
        "audience": "synthetic-private",
        "kms_project_id": "synthetic-private",
        "kms_key_ring_name": "synthetic-private",
        "kms_key_name": "synthetic-private",
        "kms_key_location": "synthetic-private",
        "kms_key_version": "1",
        "tenant_id": "00000000-0000-0000-0000-000000000000",
        "vault_uri": "https://synthetic.vault.azure.net",
        "key_name": "org-synthetic--test",
        "key_version": "00000000000000000000000000000000"
      }
    ],
    "first_id": "synthetic-private",
    "last_id": "synthetic-private",
    "has_more": true
  },
  "ValidateExternalKeyResource": {
    "status": "synthetic-private"
  },
  "AwsExternalStorageProviderParams": {
    "type": "aws",
    "bucket": "synthetic-private",
    "role_arn": "arn:aws:iam::123456789012:role/synthetic"
  },
  "AzureExternalStorageProviderParams": {
    "type": "azure",
    "tenant_id": "00000000-0000-0000-0000-000000000000",
    "subscription_id": "synthetic-private",
    "resource_group": "synthetic-private",
    "account_name": "synthetic-private",
    "container": "synthetic-private"
  },
  "GcpExternalStorageProviderParams": {
    "type": "gcp",
    "bucket": "synthetic-private",
    "workload_identity_project_number": "123456789012",
    "workload_identity_pool_id": "synthetic-private",
    "workload_identity_provider_id": "synthetic-private"
  },
  "OciExternalStorageProviderParams": {
    "type": "oci",
    "tenancy_ocid": "synthetic-private",
    "region": "synthetic-private",
    "bucket": "synthetic-private"
  },
  "AwsExternalStorageProviderResponse": {
    "type": "aws",
    "account_id": "synthetic-private",
    "region": "synthetic-private",
    "bucket": "synthetic-private",
    "role_arn": "arn:aws:iam::123456789012:role/synthetic",
    "external_id": "synthetic-private"
  },
  "AzureExternalStorageProviderResponse": {
    "type": "azure",
    "tenant_id": "00000000-0000-0000-0000-000000000000",
    "subscription_id": "synthetic-private",
    "resource_group": "synthetic-private",
    "account_name": "synthetic-private",
    "container": "synthetic-private",
    "region": "synthetic-private"
  },
  "GcpExternalStorageProviderResponse": {
    "type": "gcp",
    "bucket": "synthetic-private",
    "workload_identity_project_number": "123456789012",
    "workload_identity_pool_id": "synthetic-private",
    "workload_identity_provider_id": "synthetic-private",
    "region": "synthetic-private",
    "audience": "synthetic-private"
  },
  "OciExternalStorageProviderResponse": {
    "type": "oci",
    "tenancy_ocid": "synthetic-private",
    "region": "synthetic-private",
    "bucket": "synthetic-private"
  },
  "CreateExternalStorageBody": {
    "project_id": "synthetic-private",
    "provider": {
      "type": "aws",
      "bucket": "synthetic-private",
      "role_arn": "arn:aws:iam::123456789012:role/synthetic"
    }
  },
  "ExternalStorageResponse": {
    "object": "organization.external_storage",
    "id": "synthetic-private",
    "project_id": "synthetic-private",
    "provider": {
      "type": "aws",
      "account_id": "synthetic-private",
      "region": "synthetic-private",
      "bucket": "synthetic-private",
      "role_arn": "arn:aws:iam::123456789012:role/synthetic",
      "external_id": "synthetic-private"
    },
    "geography": "synthetic-private",
    "status": "pending",
    "created_at": 1
  },
  "ExternalStorageListResource": {
    "object": "list",
    "data": [
      {
        "object": "organization.external_storage",
        "id": "synthetic-private",
        "project_id": "synthetic-private",
        "provider": {
          "type": "aws",
          "account_id": "synthetic-private",
          "region": "synthetic-private",
          "bucket": "synthetic-private",
          "role_arn": "arn:aws:iam::123456789012:role/synthetic",
          "external_id": "synthetic-private"
        },
        "geography": "synthetic-private",
        "status": "pending",
        "created_at": 1
      }
    ],
    "first_id": "synthetic-private",
    "last_id": "synthetic-private",
    "has_more": true
  },
  "ExternalStorageDeletedResource": {
    "object": "organization.external_storage.deleted",
    "id": "synthetic-private",
    "deleted": true
  },
  "UpdateProjectApiKeyBody": {
    "expires_in_seconds": 1,
    "scopes": []
  },
  "ProjectApiKeyOwnerUser": {
    "id": "synthetic-private",
    "email": "synthetic-private",
    "name": "synthetic-private",
    "created_at": 1,
    "role": "synthetic-private"
  },
  "ProjectApiKeyOwnerServiceAccount": {
    "id": "synthetic-private",
    "name": "synthetic-private",
    "created_at": 1,
    "role": "synthetic-private"
  },
  "ProjectApiKeyOwner": {
    "type": "user",
    "user": {
      "id": "synthetic-private",
      "email": "synthetic-private",
      "name": "synthetic-private",
      "created_at": 1,
      "role": "synthetic-private"
    },
    "service_account": {
      "id": "synthetic-private",
      "name": "synthetic-private",
      "created_at": 1,
      "role": "synthetic-private"
    }
  },
  "ProjectApiKey": {
    "object": "organization.project.api_key",
    "redacted_value": "synthetic-private",
    "name": "synthetic-private",
    "created_at": 1,
    "expires_at": 1,
    "last_used_at": 1,
    "id": "synthetic-private",
    "owner_project_access": "active",
    "owner": {
      "type": "user",
      "user": {
        "id": "synthetic-private",
        "email": "synthetic-private",
        "name": "synthetic-private",
        "created_at": 1,
        "role": "synthetic-private"
      },
      "service_account": {
        "id": "synthetic-private",
        "name": "synthetic-private",
        "created_at": 1,
        "role": "synthetic-private"
      }
    }
  },
  "DecisionsUsageResult": {
    "api_source": "agents_api",
    "object": "organization.usage.decisions.result",
    "input_tokens": 1,
    "input_cached_tokens": 1,
    "input_cache_write_tokens": 1,
    "input_cache_write_30m_tokens": 1,
    "input_cache_write_12h_tokens": 1,
    "input_uncached_tokens": 1,
    "output_tokens": 1,
    "input_text_tokens": 1,
    "output_text_tokens": 1,
    "input_cached_text_tokens": 1,
    "input_audio_tokens": 1,
    "input_cached_audio_tokens": 1,
    "output_audio_tokens": 1,
    "input_image_tokens": 1,
    "input_cached_image_tokens": 1,
    "output_image_tokens": 1,
    "num_model_requests": 1,
    "project_id": "synthetic-private",
    "user_id": "synthetic-private",
    "api_key_id": "synthetic-private",
    "model": "synthetic-private",
    "batch": true,
    "service_tier": "synthetic-private"
  },
  "DecisionsUsageBucket": {
    "object": "bucket",
    "start_time": 1,
    "end_time": 1,
    "results": [
      {
        "api_source": "agents_api",
        "object": "organization.usage.decisions.result",
        "input_tokens": 1,
        "input_cached_tokens": 1,
        "input_cache_write_tokens": 1,
        "input_cache_write_30m_tokens": 1,
        "input_cache_write_12h_tokens": 1,
        "input_uncached_tokens": 1,
        "output_tokens": 1,
        "input_text_tokens": 1,
        "output_text_tokens": 1,
        "input_cached_text_tokens": 1,
        "input_audio_tokens": 1,
        "input_cached_audio_tokens": 1,
        "output_audio_tokens": 1,
        "input_image_tokens": 1,
        "input_cached_image_tokens": 1,
        "output_image_tokens": 1,
        "num_model_requests": 1,
        "project_id": "synthetic-private",
        "user_id": "synthetic-private",
        "api_key_id": "synthetic-private",
        "model": "synthetic-private",
        "batch": true,
        "service_tier": "synthetic-private"
      }
    ]
  },
  "PublicDecisionsUsageResponseResource": {
    "object": "page",
    "has_more": true,
    "next_page": "synthetic-private",
    "data": [
      {
        "object": "bucket",
        "start_time": 1,
        "end_time": 1,
        "results": [
          {
            "api_source": "agents_api",
            "object": "organization.usage.decisions.result",
            "input_tokens": 1,
            "input_cached_tokens": 1,
            "input_cache_write_tokens": 1,
            "input_cache_write_30m_tokens": 1,
            "input_cache_write_12h_tokens": 1,
            "input_uncached_tokens": 1,
            "output_tokens": 1,
            "input_text_tokens": 1,
            "output_text_tokens": 1,
            "input_cached_text_tokens": 1,
            "input_audio_tokens": 1,
            "input_cached_audio_tokens": 1,
            "output_audio_tokens": 1,
            "input_image_tokens": 1,
            "input_cached_image_tokens": 1,
            "output_image_tokens": 1,
            "num_model_requests": 1,
            "project_id": "synthetic-private",
            "user_id": "synthetic-private",
            "api_key_id": "synthetic-private",
            "model": "synthetic-private",
            "batch": true,
            "service_tier": "synthetic-private"
          }
        ]
      }
    ]
  }
}''';
