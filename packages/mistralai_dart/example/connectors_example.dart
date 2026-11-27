// ignore_for_file: avoid_print
import 'dart:io';

import 'package:mistralai_dart/mistralai_dart.dart';

/// Lists configured connectors and discovers a selected connector's tools.
Future<void> main() async {
  final env = Platform.environment;
  final apiKey = env['MISTRAL_API_KEY'];
  if (apiKey == null) {
    print('Set MISTRAL_API_KEY with the connector scope you need.');
    return;
  }

  final client = MistralClient.withApiKey(apiKey);
  try {
    final connectors = client.connectors;
    final page = await connectors.list(
      queryFilters: const ConnectorsQueryFilters(supportsMcp: true),
      pageSize: 20,
    );
    for (final connector in page.items) {
      print('${connector.name} (${connector.protocol?.value})');
    }
    if (page.pagination.nextCursor != null) {
      print('Next cursor ${page.pagination.nextCursor}');
    }

    final connectorId = env['MISTRAL_CONNECTOR_ID'];
    if (connectorId != null) {
      final connector = await connectors.get(connectorIdOrName: connectorId);
      final source = connector.openapiSpec?.source;
      print('OpenAPI source ${source?.toJson()}');

      final tools = await connectors.listMcpTools(
        connectorIdOrName: connector.id,
      );
      for (final tool in tools) {
        print('${tool.name} ${tool.description ?? ''}');
      }
    }

    final httpServer = env['MISTRAL_NEW_HTTP_CONNECTOR_SERVER'];
    if (httpServer != null) {
      final created = await connectors.create(
        request: CreateConnectorRequest(
          protocol: 'http',
          name: 'example-http-connector',
          description: 'Connector for an example HTTP API',
          server: httpServer,
        ),
      );
      print('Created private connector ${created.id}');
    }
  } finally {
    client.close();
  }
}
