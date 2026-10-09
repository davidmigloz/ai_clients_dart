import 'dart:convert';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  test(
    'DeletedAgentSessionArtifact.deleted: replacement, full equality/hash and copy presence',
    () {
      final original = DeletedAgentSessionArtifact.fromJson(
        jsonDecode(
              r'''{"deleted":true,"id":"artifact_synthetic","object":"agent.session.artifact.deleted"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = DeletedAgentSessionArtifact.fromJson(
        jsonDecode(
              r'''{"deleted":false,"id":"artifact_synthetic","object":"agent.session.artifact.deleted"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(deleted: replacement.deleted);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'DeletedAgentSessionArtifact.id: replacement, full equality/hash and copy presence',
    () {
      final original = DeletedAgentSessionArtifact.fromJson(
        jsonDecode(
              r'''{"deleted":true,"id":"artifact_synthetic","object":"agent.session.artifact.deleted"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = DeletedAgentSessionArtifact.fromJson(
        jsonDecode(
              r'''{"deleted":true,"id":"artifact_synthetic_alternate","object":"agent.session.artifact.deleted"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(id: replacement.id);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentEnvironmentFileList.data: replacement, full equality/hash and copy presence',
    () {
      final original = AgentEnvironmentFileList.fromJson(
        jsonDecode(
              r'''{"data":[{"environment_id":"environment_synthetic","object":"agent.environment.file","path":"/workspace/PRIVATE-file-café🚀.bin","size_bytes":9}],"has_more":true,"next":"PRIVATE-opaque-page/%2F?🚀","object":"page"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentEnvironmentFileList.fromJson(
        jsonDecode(
              r'''{"data":[{"object":"agent.environment.file","environment_id":"environment_synthetic","path":"/workspace/PRIVATE-file-café🚀.bin","size_bytes":0}],"has_more":true,"next":"PRIVATE-opaque-page/%2F?🚀","object":"page"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(data: replacement.data);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentEnvironmentFileList.hasMore: replacement, full equality/hash and copy presence',
    () {
      final original = AgentEnvironmentFileList.fromJson(
        jsonDecode(
              r'''{"data":[{"environment_id":"environment_synthetic","object":"agent.environment.file","path":"/workspace/PRIVATE-file-café🚀.bin","size_bytes":9}],"has_more":true,"next":"PRIVATE-opaque-page/%2F?🚀","object":"page"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentEnvironmentFileList.fromJson(
        jsonDecode(
              r'''{"data":[{"environment_id":"environment_synthetic","object":"agent.environment.file","path":"/workspace/PRIVATE-file-café🚀.bin","size_bytes":9}],"has_more":false,"next":"PRIVATE-opaque-page/%2F?🚀","object":"page"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(hasMore: replacement.hasMore);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentEnvironmentFileList.next: replacement, full equality/hash and copy presence',
    () {
      final original = AgentEnvironmentFileList.fromJson(
        jsonDecode(
              r'''{"data":[{"environment_id":"environment_synthetic","object":"agent.environment.file","path":"/workspace/PRIVATE-file-café🚀.bin","size_bytes":9}],"has_more":true,"next":"PRIVATE-opaque-page/%2F?🚀","object":"page"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentEnvironmentFileList.fromJson(
        jsonDecode(
              r'''{"data":[{"environment_id":"environment_synthetic","object":"agent.environment.file","path":"/workspace/PRIVATE-file-café🚀.bin","size_bytes":9}],"has_more":true,"next":"PRIVATE-opaque-page/%2F?🚀_alternate","object":"page"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(next: replacement.next);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(next: null);
      expect(cleared.toJson().containsKey('next'), isTrue);
      expect(cleared.toJson()['next'], isNull);
      expect(() => original.copyWith(next: Object()), throwsFormatException);
    },
  );
  test(
    'AgentEnvironmentFile.environmentId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentEnvironmentFile.fromJson(
        jsonDecode(
              r'''{"environment_id":"environment_synthetic","object":"agent.environment.file","path":"/workspace/PRIVATE-file-café🚀.bin","size_bytes":9}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentEnvironmentFile.fromJson(
        jsonDecode(
              r'''{"environment_id":"environment_synthetic_alternate","object":"agent.environment.file","path":"/workspace/PRIVATE-file-café🚀.bin","size_bytes":9}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(
        environmentId: replacement.environmentId,
      );
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentEnvironmentFile.path: replacement, full equality/hash and copy presence',
    () {
      final original = AgentEnvironmentFile.fromJson(
        jsonDecode(
              r'''{"environment_id":"environment_synthetic","object":"agent.environment.file","path":"/workspace/PRIVATE-file-café🚀.bin","size_bytes":9}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentEnvironmentFile.fromJson(
        jsonDecode(
              r'''{"environment_id":"environment_synthetic","object":"agent.environment.file","path":"/workspace/PRIVATE-file-café🚀.bin_alternate","size_bytes":9}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(path: replacement.path);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentEnvironmentFile.sizeBytes: replacement, full equality/hash and copy presence',
    () {
      final original = AgentEnvironmentFile.fromJson(
        jsonDecode(
              r'''{"environment_id":"environment_synthetic","object":"agent.environment.file","path":"/workspace/PRIVATE-file-café🚀.bin","size_bytes":9}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentEnvironmentFile.fromJson(
        jsonDecode(
              r'''{"environment_id":"environment_synthetic","object":"agent.environment.file","path":"/workspace/PRIVATE-file-café🚀.bin","size_bytes":10}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(sizeBytes: replacement.sizeBytes);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionHostedEnvironmentFileConfigFileId.fileId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionHostedEnvironmentFileConfigFileId.fromJson(
        jsonDecode(
              r'''{"file_id":"file_synthetic","path":"/workspace/PRIVATE-file-café🚀.bin","type":"file_id"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionHostedEnvironmentFileConfigFileId.fromJson(
        jsonDecode(
              r'''{"file_id":"file_synthetic_alternate","path":"/workspace/PRIVATE-file-café🚀.bin","type":"file_id"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(fileId: replacement.fileId);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionHostedEnvironmentFileConfigFileId.path: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionHostedEnvironmentFileConfigFileId.fromJson(
        jsonDecode(
              r'''{"file_id":"file_synthetic","path":"/workspace/PRIVATE-file-café🚀.bin","type":"file_id"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionHostedEnvironmentFileConfigFileId.fromJson(
        jsonDecode(
              r'''{"file_id":"file_synthetic","path":"/workspace/PRIVATE-file-café🚀.bin_alternate","type":"file_id"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(path: replacement.path);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionHostedEnvironmentFileConfigInline.data: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionHostedEnvironmentFileConfigInline.fromJson(
        jsonDecode(
              r'''{"data":"AP+AAA0KQUJD","path":"/workspace/PRIVATE-file-café🚀.bin","type":"inline"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionHostedEnvironmentFileConfigInline.fromJson(
        jsonDecode(
              r'''{"data":"U0VDT05E","path":"/workspace/PRIVATE-file-café🚀.bin","type":"inline"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(data: replacement.data);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionHostedEnvironmentFileConfigInline.path: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionHostedEnvironmentFileConfigInline.fromJson(
        jsonDecode(
              r'''{"data":"AP+AAA0KQUJD","path":"/workspace/PRIVATE-file-café🚀.bin","type":"inline"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionHostedEnvironmentFileConfigInline.fromJson(
        jsonDecode(
              r'''{"data":"AP+AAA0KQUJD","path":"/workspace/PRIVATE-file-café🚀.bin_alternate","type":"inline"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(path: replacement.path);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionArtifactList.data: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionArtifactList.fromJson(
        jsonDecode(
              r'''{"data":[{"created_at":1700000000,"environment_id":"environment_synthetic","id":"artifact_synthetic","object":"agent.session.artifact","path":"/workspace/outputs/PRIVATE-artifact-café🚀.bin","session_id":"session_synthetic","size_bytes":9,"turn_id":"turn_completed"}],"first_id":"artifact_synthetic","has_more":true,"last_id":"artifact_synthetic","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionArtifactList.fromJson(
        jsonDecode(
              r'''{"data":[{"id":"artifact_synthetic","object":"agent.session.artifact","session_id":"session_synthetic","environment_id":"environment_synthetic","turn_id":"turn_completed","path":"/workspace/outputs/PRIVATE-artifact-café🚀.bin","size_bytes":0,"created_at":0}],"first_id":"artifact_synthetic","has_more":true,"last_id":"artifact_synthetic","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(data: replacement.data);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionArtifactList.firstId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionArtifactList.fromJson(
        jsonDecode(
              r'''{"data":[{"created_at":1700000000,"environment_id":"environment_synthetic","id":"artifact_synthetic","object":"agent.session.artifact","path":"/workspace/outputs/PRIVATE-artifact-café🚀.bin","session_id":"session_synthetic","size_bytes":9,"turn_id":"turn_completed"}],"first_id":"artifact_synthetic","has_more":true,"last_id":"artifact_synthetic","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionArtifactList.fromJson(
        jsonDecode(
              r'''{"data":[{"created_at":1700000000,"environment_id":"environment_synthetic","id":"artifact_synthetic","object":"agent.session.artifact","path":"/workspace/outputs/PRIVATE-artifact-café🚀.bin","session_id":"session_synthetic","size_bytes":9,"turn_id":"turn_completed"}],"first_id":"artifact_synthetic_alternate","has_more":true,"last_id":"artifact_synthetic","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(firstId: replacement.firstId);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(firstId: null);
      expect(cleared.toJson().containsKey('first_id'), isTrue);
      expect(cleared.toJson()['first_id'], isNull);
      expect(() => original.copyWith(firstId: Object()), throwsFormatException);
    },
  );
  test(
    'AgentSessionArtifactList.hasMore: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionArtifactList.fromJson(
        jsonDecode(
              r'''{"data":[{"created_at":1700000000,"environment_id":"environment_synthetic","id":"artifact_synthetic","object":"agent.session.artifact","path":"/workspace/outputs/PRIVATE-artifact-café🚀.bin","session_id":"session_synthetic","size_bytes":9,"turn_id":"turn_completed"}],"first_id":"artifact_synthetic","has_more":true,"last_id":"artifact_synthetic","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionArtifactList.fromJson(
        jsonDecode(
              r'''{"data":[{"created_at":1700000000,"environment_id":"environment_synthetic","id":"artifact_synthetic","object":"agent.session.artifact","path":"/workspace/outputs/PRIVATE-artifact-café🚀.bin","session_id":"session_synthetic","size_bytes":9,"turn_id":"turn_completed"}],"first_id":"artifact_synthetic","has_more":false,"last_id":"artifact_synthetic","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(hasMore: replacement.hasMore);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionArtifactList.lastId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionArtifactList.fromJson(
        jsonDecode(
              r'''{"data":[{"created_at":1700000000,"environment_id":"environment_synthetic","id":"artifact_synthetic","object":"agent.session.artifact","path":"/workspace/outputs/PRIVATE-artifact-café🚀.bin","session_id":"session_synthetic","size_bytes":9,"turn_id":"turn_completed"}],"first_id":"artifact_synthetic","has_more":true,"last_id":"artifact_synthetic","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionArtifactList.fromJson(
        jsonDecode(
              r'''{"data":[{"created_at":1700000000,"environment_id":"environment_synthetic","id":"artifact_synthetic","object":"agent.session.artifact","path":"/workspace/outputs/PRIVATE-artifact-café🚀.bin","session_id":"session_synthetic","size_bytes":9,"turn_id":"turn_completed"}],"first_id":"artifact_synthetic","has_more":true,"last_id":"artifact_synthetic_alternate","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(lastId: replacement.lastId);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(lastId: null);
      expect(cleared.toJson().containsKey('last_id'), isTrue);
      expect(cleared.toJson()['last_id'], isNull);
      expect(() => original.copyWith(lastId: Object()), throwsFormatException);
    },
  );
  test(
    'AgentSessionArtifact.createdAt: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionArtifact.fromJson(
        jsonDecode(
              r'''{"created_at":1700000000,"environment_id":"environment_synthetic","id":"artifact_synthetic","object":"agent.session.artifact","path":"/workspace/outputs/PRIVATE-artifact-café🚀.bin","session_id":"session_synthetic","size_bytes":9,"turn_id":"turn_completed"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionArtifact.fromJson(
        jsonDecode(
              r'''{"created_at":1700000001,"environment_id":"environment_synthetic","id":"artifact_synthetic","object":"agent.session.artifact","path":"/workspace/outputs/PRIVATE-artifact-café🚀.bin","session_id":"session_synthetic","size_bytes":9,"turn_id":"turn_completed"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(createdAt: replacement.createdAt);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionArtifact.environmentId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionArtifact.fromJson(
        jsonDecode(
              r'''{"created_at":1700000000,"environment_id":"environment_synthetic","id":"artifact_synthetic","object":"agent.session.artifact","path":"/workspace/outputs/PRIVATE-artifact-café🚀.bin","session_id":"session_synthetic","size_bytes":9,"turn_id":"turn_completed"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionArtifact.fromJson(
        jsonDecode(
              r'''{"created_at":1700000000,"environment_id":"environment_synthetic_alternate","id":"artifact_synthetic","object":"agent.session.artifact","path":"/workspace/outputs/PRIVATE-artifact-café🚀.bin","session_id":"session_synthetic","size_bytes":9,"turn_id":"turn_completed"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(
        environmentId: replacement.environmentId,
      );
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionArtifact.id: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionArtifact.fromJson(
        jsonDecode(
              r'''{"created_at":1700000000,"environment_id":"environment_synthetic","id":"artifact_synthetic","object":"agent.session.artifact","path":"/workspace/outputs/PRIVATE-artifact-café🚀.bin","session_id":"session_synthetic","size_bytes":9,"turn_id":"turn_completed"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionArtifact.fromJson(
        jsonDecode(
              r'''{"created_at":1700000000,"environment_id":"environment_synthetic","id":"artifact_synthetic_alternate","object":"agent.session.artifact","path":"/workspace/outputs/PRIVATE-artifact-café🚀.bin","session_id":"session_synthetic","size_bytes":9,"turn_id":"turn_completed"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(id: replacement.id);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionArtifact.path: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionArtifact.fromJson(
        jsonDecode(
              r'''{"created_at":1700000000,"environment_id":"environment_synthetic","id":"artifact_synthetic","object":"agent.session.artifact","path":"/workspace/outputs/PRIVATE-artifact-café🚀.bin","session_id":"session_synthetic","size_bytes":9,"turn_id":"turn_completed"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionArtifact.fromJson(
        jsonDecode(
              r'''{"created_at":1700000000,"environment_id":"environment_synthetic","id":"artifact_synthetic","object":"agent.session.artifact","path":"/workspace/outputs/PRIVATE-artifact-café🚀.bin_alternate","session_id":"session_synthetic","size_bytes":9,"turn_id":"turn_completed"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(path: replacement.path);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionArtifact.sessionId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionArtifact.fromJson(
        jsonDecode(
              r'''{"created_at":1700000000,"environment_id":"environment_synthetic","id":"artifact_synthetic","object":"agent.session.artifact","path":"/workspace/outputs/PRIVATE-artifact-café🚀.bin","session_id":"session_synthetic","size_bytes":9,"turn_id":"turn_completed"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionArtifact.fromJson(
        jsonDecode(
              r'''{"created_at":1700000000,"environment_id":"environment_synthetic","id":"artifact_synthetic","object":"agent.session.artifact","path":"/workspace/outputs/PRIVATE-artifact-café🚀.bin","session_id":"session_synthetic_alternate","size_bytes":9,"turn_id":"turn_completed"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(sessionId: replacement.sessionId);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionArtifact.sizeBytes: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionArtifact.fromJson(
        jsonDecode(
              r'''{"created_at":1700000000,"environment_id":"environment_synthetic","id":"artifact_synthetic","object":"agent.session.artifact","path":"/workspace/outputs/PRIVATE-artifact-café🚀.bin","session_id":"session_synthetic","size_bytes":9,"turn_id":"turn_completed"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionArtifact.fromJson(
        jsonDecode(
              r'''{"created_at":1700000000,"environment_id":"environment_synthetic","id":"artifact_synthetic","object":"agent.session.artifact","path":"/workspace/outputs/PRIVATE-artifact-café🚀.bin","session_id":"session_synthetic","size_bytes":10,"turn_id":"turn_completed"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(sizeBytes: replacement.sizeBytes);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionArtifact.turnId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionArtifact.fromJson(
        jsonDecode(
              r'''{"created_at":1700000000,"environment_id":"environment_synthetic","id":"artifact_synthetic","object":"agent.session.artifact","path":"/workspace/outputs/PRIVATE-artifact-café🚀.bin","session_id":"session_synthetic","size_bytes":9,"turn_id":"turn_completed"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionArtifact.fromJson(
        jsonDecode(
              r'''{"created_at":1700000000,"environment_id":"environment_synthetic","id":"artifact_synthetic","object":"agent.session.artifact","path":"/workspace/outputs/PRIVATE-artifact-café🚀.bin","session_id":"session_synthetic","size_bytes":9,"turn_id":"turn_completed_alternate"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(turnId: replacement.turnId);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
}
