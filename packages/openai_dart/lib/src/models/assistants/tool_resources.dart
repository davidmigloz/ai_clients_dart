import 'package:meta/meta.dart';

/// Resources available to an assistant's tools.
///
/// Different tools require different resources:
/// - Code interpreter needs file IDs
/// - File search needs vector store IDs
@immutable
class ToolResources {
  /// Creates a [ToolResources].
  const ToolResources({this.codeInterpreter, this.fileSearch});

  /// Creates a [ToolResources] from JSON.
  factory ToolResources.fromJson(Map<String, dynamic> json) {
    return ToolResources(
      codeInterpreter: json['code_interpreter'] != null
          ? CodeInterpreterResources.fromJson(
              json['code_interpreter'] as Map<String, dynamic>,
            )
          : null,
      fileSearch: json['file_search'] != null
          ? FileSearchResources.fromJson(
              json['file_search'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Resources for the code interpreter tool.
  final CodeInterpreterResources? codeInterpreter;

  /// Resources for the file search tool.
  final FileSearchResources? fileSearch;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (codeInterpreter != null) 'code_interpreter': codeInterpreter!.toJson(),
    if (fileSearch != null) 'file_search': fileSearch!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolResources &&
          runtimeType == other.runtimeType &&
          codeInterpreter == other.codeInterpreter &&
          fileSearch == other.fileSearch;

  @override
  int get hashCode => Object.hash(codeInterpreter, fileSearch);

  @override
  String toString() => 'ToolResources(...)';
}

/// Resources for the code interpreter tool.
@immutable
class CodeInterpreterResources {
  /// Creates a [CodeInterpreterResources].
  const CodeInterpreterResources({this.fileIds});

  /// Creates a [CodeInterpreterResources] from JSON.
  factory CodeInterpreterResources.fromJson(Map<String, dynamic> json) {
    return CodeInterpreterResources(
      fileIds: (json['file_ids'] as List<dynamic>?)?.cast<String>(),
    );
  }

  /// File IDs available to the code interpreter.
  ///
  /// Maximum of 20 files.
  final List<String>? fileIds;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {if (fileIds != null) 'file_ids': fileIds};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CodeInterpreterResources && runtimeType == other.runtimeType;

  @override
  int get hashCode => fileIds.hashCode;

  @override
  String toString() =>
      'CodeInterpreterResources(${fileIds?.length ?? 0} files)';
}

/// Resources for the file search tool.
@immutable
class FileSearchResources {
  /// Creates a [FileSearchResources].
  const FileSearchResources({this.vectorStoreIds, this.vectorStores});

  /// Creates a [FileSearchResources] from JSON.
  factory FileSearchResources.fromJson(Map<String, dynamic> json) {
    return FileSearchResources(
      vectorStoreIds: (json['vector_store_ids'] as List<dynamic>?)
          ?.cast<String>(),
      vectorStores: (json['vector_stores'] as List<dynamic>?)
          ?.map((e) => VectorStoreConfig.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Vector store IDs to use for file search.
  ///
  /// Maximum of 1 vector store per assistant.
  final List<String>? vectorStoreIds;

  /// Vector store configurations for creating new stores.
  ///
  /// Maximum of 1 store. This is used only during assistant creation.
  final List<VectorStoreConfig>? vectorStores;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (vectorStoreIds != null) 'vector_store_ids': vectorStoreIds,
    if (vectorStores != null)
      'vector_stores': vectorStores!.map((v) => v.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileSearchResources && runtimeType == other.runtimeType;

  @override
  int get hashCode => Object.hash(vectorStoreIds, vectorStores);

  @override
  String toString() =>
      'FileSearchResources(vectorStoreIds: ${vectorStoreIds?.length ?? 0})';
}

/// Configuration for creating a vector store.
@immutable
class VectorStoreConfig {
  /// Creates a [VectorStoreConfig].
  const VectorStoreConfig({this.fileIds, this.chunkingStrategy, this.metadata});

  /// Creates a [VectorStoreConfig] from JSON.
  factory VectorStoreConfig.fromJson(Map<String, dynamic> json) {
    return VectorStoreConfig(
      fileIds: (json['file_ids'] as List<dynamic>?)?.cast<String>(),
      chunkingStrategy: json['chunking_strategy'] != null
          ? ChunkingStrategy.fromJson(
              json['chunking_strategy'] as Map<String, dynamic>,
            )
          : null,
      metadata: (json['metadata'] as Map<String, dynamic>?)
          ?.cast<String, String>(),
    );
  }

  /// File IDs to add to the vector store.
  final List<String>? fileIds;

  /// The chunking strategy to use.
  final ChunkingStrategy? chunkingStrategy;

  /// Metadata for the vector store.
  final Map<String, String>? metadata;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (fileIds != null) 'file_ids': fileIds,
    if (chunkingStrategy != null)
      'chunking_strategy': chunkingStrategy!.toJson(),
    if (metadata != null) 'metadata': metadata,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VectorStoreConfig && runtimeType == other.runtimeType;

  @override
  int get hashCode => fileIds.hashCode;

  @override
  String toString() => 'VectorStoreConfig(${fileIds?.length ?? 0} files)';
}

/// A chunking strategy for file processing.
sealed class ChunkingStrategy {
  /// Creates a [ChunkingStrategy] from JSON.
  factory ChunkingStrategy.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'auto' => const AutoChunkingStrategy(),
      'static' => StaticChunkingStrategy.fromJson(json),
      _ => throw FormatException('Unknown chunking strategy: $type'),
    };
  }

  /// Creates an auto chunking strategy.
  static ChunkingStrategy auto() => const AutoChunkingStrategy();

  /// Creates a static chunking strategy.
  static ChunkingStrategy static$({
    required int maxChunkSizeTokens,
    required int chunkOverlapTokens,
  }) => StaticChunkingStrategy(
    maxChunkSizeTokens: maxChunkSizeTokens,
    chunkOverlapTokens: chunkOverlapTokens,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Auto chunking strategy.
@immutable
class AutoChunkingStrategy implements ChunkingStrategy {
  /// Creates an [AutoChunkingStrategy].
  const AutoChunkingStrategy();

  @override
  Map<String, dynamic> toJson() => {'type': 'auto'};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AutoChunkingStrategy && runtimeType == other.runtimeType;

  @override
  int get hashCode => 'auto'.hashCode;

  @override
  String toString() => 'AutoChunkingStrategy()';
}

/// Static chunking strategy with fixed parameters.
@immutable
class StaticChunkingStrategy implements ChunkingStrategy {
  /// Creates a [StaticChunkingStrategy].
  const StaticChunkingStrategy({
    required this.maxChunkSizeTokens,
    required this.chunkOverlapTokens,
  });

  /// Creates a [StaticChunkingStrategy] from JSON.
  factory StaticChunkingStrategy.fromJson(Map<String, dynamic> json) {
    final static$ = json['static'] as Map<String, dynamic>;
    return StaticChunkingStrategy(
      maxChunkSizeTokens: static$['max_chunk_size_tokens'] as int,
      chunkOverlapTokens: static$['chunk_overlap_tokens'] as int,
    );
  }

  /// Maximum number of tokens per chunk.
  ///
  /// Range: 100-4096.
  final int maxChunkSizeTokens;

  /// Number of tokens to overlap between chunks.
  ///
  /// Must be less than or equal to half of maxChunkSizeTokens.
  final int chunkOverlapTokens;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'static',
    'static': {
      'max_chunk_size_tokens': maxChunkSizeTokens,
      'chunk_overlap_tokens': chunkOverlapTokens,
    },
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StaticChunkingStrategy &&
          runtimeType == other.runtimeType &&
          maxChunkSizeTokens == other.maxChunkSizeTokens;

  @override
  int get hashCode => maxChunkSizeTokens.hashCode;

  @override
  String toString() =>
      'StaticChunkingStrategy(maxChunkSizeTokens: $maxChunkSizeTokens)';
}
