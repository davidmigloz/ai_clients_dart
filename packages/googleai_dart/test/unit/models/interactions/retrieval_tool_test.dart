import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('RetrievalTool', () {
    test('round-trips ExaAISearch and ParallelAISearch configs', () {
      const tool = RetrievalTool(
        retrievalTypes: ['exa_ai_search', 'parallel_ai_search'],
        exaAiSearchConfig: ExaAISearchConfig(
          apiKey: 'exa-key',
          customConfig: {'num_results': 5},
        ),
        parallelAiSearchConfig: ParallelAISearchConfig(apiKey: 'parallel-key'),
      );

      final restored = InteractionTool.fromJson(tool.toJson()) as RetrievalTool;
      expect(restored.retrievalTypes, ['exa_ai_search', 'parallel_ai_search']);
      expect(restored.exaAiSearchConfig!.apiKey, 'exa-key');
      expect(restored.exaAiSearchConfig!.customConfig!['num_results'], 5);
      expect(restored.parallelAiSearchConfig!.apiKey, 'parallel-key');
    });

    test('round-trips a nested RagStoreConfig', () {
      const tool = RetrievalTool(
        retrievalTypes: ['rag_store'],
        ragStoreConfig: RagStoreConfig(
          ragResources: [
            RagResource(ragCorpus: 'corpora/c1', ragFileIds: ['f1']),
          ],
          ragRetrievalConfig: RagRetrievalConfig(
            topK: 7,
            filter: Filter(
              metadataFilter: 'k = "v"',
              vectorSimilarityThreshold: 0.8,
            ),
            hybridSearch: HybridSearch(alpha: 0.5),
            ranking: RankService(modelName: 'rank-model'),
          ),
          similarityTopK: 3,
          vectorDistanceThreshold: 0.2,
        ),
      );

      final restored = InteractionTool.fromJson(tool.toJson()) as RetrievalTool;
      final rag = restored.ragStoreConfig!;
      expect(rag.ragResources!.single.ragCorpus, 'corpora/c1');
      expect(rag.ragResources!.single.ragFileIds, ['f1']);
      expect(rag.similarityTopK, 3);
      expect(rag.vectorDistanceThreshold, 0.2);

      final cfg = rag.ragRetrievalConfig!;
      expect(cfg.topK, 7);
      expect(cfg.filter!.metadataFilter, 'k = "v"');
      expect(cfg.filter!.vectorSimilarityThreshold, 0.8);
      expect(cfg.hybridSearch!.alpha, 0.5);
      expect(cfg.ranking!.modelName, 'rank-model');
      expect(cfg.ranking!.rankingConfig, 'rank_service');
    });

    test('omits unset configs from JSON', () {
      const tool = RetrievalTool(retrievalTypes: ['vertex_ai_search']);
      final json = tool.toJson();
      expect(json['type'], 'retrieval');
      expect(json.containsKey('exa_ai_search_config'), isFalse);
      expect(json.containsKey('parallel_ai_search_config'), isFalse);
      expect(json.containsKey('rag_store_config'), isFalse);
    });
  });
}
