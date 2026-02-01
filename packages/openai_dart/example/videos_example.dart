// ignore_for_file: avoid_print, unreachable_from_main

import 'dart:io';

import 'package:openai_dart/openai_dart.dart';

/// Example demonstrating the Videos API (Sora) for video generation.
///
/// The Videos API allows you to:
/// - Generate videos from text prompts using Sora
/// - Poll for video completion status
/// - Download video content, thumbnails, and spritesheets
/// - Remix existing videos with new prompts
///
/// **Note**: Sora access requires special permissions on your OpenAI account.
/// Video generation can take several minutes and incurs usage costs.
///
/// To run this example, set the OPENAI_API_KEY environment variable:
/// ```bash
/// export OPENAI_API_KEY=your-api-key
/// dart run example/videos_example.dart
/// ```
Future<void> main() async {
  // Create client from environment variables
  final client = OpenAIClient.fromEnvironment();

  try {
    await listVideosExample(client);
    // Uncomment to run video generation (requires Sora access and incurs cost)
    // await createVideoExample(client);
    // await fullWorkflowExample(client);
  } finally {
    client.close();
  }
}

/// Example: List existing videos.
Future<void> listVideosExample(OpenAIClient client) async {
  print('=== List Videos Example ===\n');

  // List all videos
  final videos = await client.videos.list();

  print('Total videos found: ${videos.data.length}');
  print('Has more: ${videos.hasMore}');
  print('');

  // Display each video's status
  for (final video in videos.data) {
    print('Video: ${video.id}');
    print('  Model: ${video.model}');
    print('  Status: ${video.status}');
    print('  Progress: ${video.progress}%');
    print('  Size: ${video.size}');
    print('  Duration: ${video.seconds}');
    print('  Created: ${video.createdAtDateTime}');

    if (video.isCompleted) {
      print('  Completed: ${video.completedAtDateTime}');
    } else if (video.isFailed && video.error != null) {
      print('  Error: ${video.error!.message}');
    }
    print('');
  }

  // Example with pagination
  if (videos.hasMore && videos.lastId != null) {
    print('Fetching next page...');
    final nextPage = await client.videos.list(limit: 5, after: videos.lastId);
    print('Next page has ${nextPage.data.length} videos');
  }
  print('');
}

/// Example: Create a video and poll for completion.
///
/// **Warning**: This incurs usage costs and requires Sora access.
Future<void> createVideoExample(OpenAIClient client) async {
  print('=== Create Video Example ===\n');

  // Create a video generation request
  final video = await client.videos.create(
    const CreateVideoRequest(
      prompt:
          'A serene mountain lake at sunrise with mist rising '
          'from the water surface, cinematic quality',
      model: 'sora-2',
      size: VideoSize.size1280x720, // 720p
      seconds: VideoSeconds.s4, // 4 seconds (minimum for cost efficiency)
    ),
  );

  print('Created video job: ${video.id}');
  print('Initial status: ${video.status}');
  print('');

  // Poll for completion
  var current = video;
  while (!current.isCompleted && !current.isFailed) {
    print('Progress: ${current.progress}% - ${current.status}');
    await Future<void>.delayed(const Duration(seconds: 15));
    current = await client.videos.retrieve(video.id);
  }

  if (current.isCompleted) {
    print('Video completed successfully!');
    print('Completed at: ${current.completedAtDateTime}');
    print('Expires at: ${current.expiresAtDateTime}');
  } else {
    print('Video generation failed: ${current.error?.message}');
  }
  print('');
}

/// Example: Full workflow including content download.
///
/// **Warning**: This incurs usage costs and requires Sora access.
Future<void> fullWorkflowExample(OpenAIClient client) async {
  print('=== Full Video Workflow Example ===\n');

  // Step 1: Create a video
  print('Step 1: Creating video...');
  final video = await client.videos.create(
    const CreateVideoRequest(
      prompt: 'A red ball bouncing on a white surface, simple animation',
      model: 'sora-2',
      size: VideoSize.size1280x720,
      seconds: VideoSeconds.s4,
    ),
  );
  print('Created: ${video.id}');

  try {
    // Step 2: Wait for completion
    print('Step 2: Waiting for completion...');
    var current = video;
    const maxAttempts = 40; // ~10 minutes with 15s intervals
    var attempts = 0;

    while (!current.isCompleted &&
        !current.isFailed &&
        attempts < maxAttempts) {
      await Future<void>.delayed(const Duration(seconds: 15));
      current = await client.videos.retrieve(video.id);
      print('  Progress: ${current.progress}%');
      attempts++;
    }

    if (!current.isCompleted) {
      if (current.isFailed) {
        print('Video failed: ${current.error?.message}');
      } else {
        print('Timeout waiting for video completion');
      }
      return;
    }

    print('Video completed!');

    // Step 3: Download video content
    print('Step 3: Downloading video...');
    final videoContent = await client.videos.retrieveContent(current.id);
    print('Downloaded video: ${videoContent.length} bytes');

    // Save to file
    final videoFile = File('output_video.mp4');
    await videoFile.writeAsBytes(videoContent);
    print('Saved to: ${videoFile.path}');

    // Step 4: Download thumbnail
    print('Step 4: Downloading thumbnail...');
    final thumbnail = await client.videos.retrieveContent(
      current.id,
      variant: VideoContentVariant.thumbnail,
    );
    print('Downloaded thumbnail: ${thumbnail.length} bytes');

    final thumbnailFile = File('output_thumbnail.jpg');
    await thumbnailFile.writeAsBytes(thumbnail);
    print('Saved to: ${thumbnailFile.path}');

    // Step 5: Optional - Create a remix
    print('Step 5: Creating remix...');
    final remix = await client.videos.remix(
      current.id,
      const CreateVideoRemixRequest(
        prompt: 'Same scene but the ball is blue and glowing',
      ),
    );
    print('Created remix: ${remix.id}');
    print('Remixed from: ${remix.remixedFromVideoId}');
    print('Is remix: ${remix.isRemix}');

    // Step 6: Clean up - delete videos
    print('Step 6: Cleaning up...');

    // Wait for remix to be deletable (must be completed or failed)
    var remixCurrent = remix;
    attempts = 0;
    while (!remixCurrent.isCompleted &&
        !remixCurrent.isFailed &&
        attempts < maxAttempts) {
      await Future<void>.delayed(const Duration(seconds: 15));
      remixCurrent = await client.videos.retrieve(remix.id);
      attempts++;
    }

    // Delete remix
    final remixDeleted = await client.videos.delete(remix.id);
    print('Deleted remix: ${remixDeleted.deleted}');

    // Delete original
    final originalDeleted = await client.videos.delete(current.id);
    print('Deleted original: ${originalDeleted.deleted}');
  } catch (e) {
    // Attempt cleanup on error
    try {
      await client.videos.delete(video.id);
    } catch (_) {
      // Ignore cleanup errors
    }
    rethrow;
  }

  print('');
  print('Workflow complete!');
}
