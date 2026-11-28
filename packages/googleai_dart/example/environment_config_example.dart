// ignore_for_file: avoid_print

import 'package:googleai_dart/googleai_dart.dart';

Future<void> main(List<String> args) async {
  if (args.length > 1) {
    print(
      'Usage: dart run example/environment_config_example.dart [source-id]',
    );
    return;
  }

  final client = GoogleAIClient.fromEnvironment(apiVersion: ApiVersion.v1beta);
  try {
    final request = args.isEmpty
        ? const CreateEnvironmentRequest(
            mode: EnvironmentMode.onDemand,
            env: EnvironmentVariables.map({
              'APP_MODE': EnvVar.literal('production'),
              'LOG_LEVEL': EnvVar(value: 'info'),
            }),
          )
        : CreateEnvironmentRequest(fromEnvironment: args.single);
    final environment = await client.environments.create(environment: request);
    print('Environment ID: ${environment.id}');
  } finally {
    client.close();
  }
}
