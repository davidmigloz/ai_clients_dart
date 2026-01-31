// ignore_for_file: avoid_print
@Tags(['integration'])
library;

import 'dart:async';
import 'dart:io';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  String? apiKey;
  OpenAIClient? client;

  // Track created videos for cleanup
  final createdVideoIds = <String>[];

  // Environment variable for expensive tests
  final runExpensiveTests =
      Platform.environment['OPENAI_RUN_VIDEO_TESTS'] == 'true';

  setUpAll(() {
    apiKey = Platform.environment['OPENAI_API_KEY'];
    if (apiKey == null || apiKey!.isEmpty) {
      print('OPENAI_API_KEY not set. Integration tests will be skipped.');
    } else {
      client = OpenAIClient(
        config: OpenAIConfig(authProvider: ApiKeyProvider(apiKey!)),
      );
    }
  });

  tearDownAll(() async {
    // Delete all created videos
    for (final videoId in createdVideoIds) {
      try {
        await client!.videos.delete(videoId);
        print('Cleaned up video: $videoId');
      } on OpenAIException catch (e) {
        print('Failed to cleanup video $videoId: ${e.message}');
      }
    }
    client?.close();
  });

  /// Helper to create a video with Sora access check.
  /// Returns null if Sora access is not available (403 or permission error).
  Future<Video?> createVideoWithAccessCheck() async {
    try {
      final video = await client!.videos.create(
        const CreateVideoRequest(
          prompt: 'A simple red ball bouncing on white background',
          model: 'sora-2',
          seconds: VideoSeconds.s4, // Minimum duration for cost efficiency
        ),
      );
      createdVideoIds.add(video.id);
      return video;
    } on PermissionDeniedException {
      // Sora access not available
      return null;
    } on ApiException catch (e) {
      if (e.statusCode == 403 ||
          (e.message.contains('access')) ||
          (e.message.contains('permission'))) {
        return null;
      }
      rethrow;
    }
  }

  /// Helper to poll for video completion.
  Future<Video> waitForCompletion(
    String videoId, {
    Duration timeout = const Duration(minutes: 10),
    Duration pollInterval = const Duration(seconds: 15),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      final video = await client!.videos.retrieve(videoId);
      if (video.isCompleted || video.isFailed) return video;
      print('Video ${video.id}: ${video.progress}% - ${video.status}');
      await Future<void>.delayed(pollInterval);
    }
    throw RequestTimeoutException(
      message: 'Video generation timed out after $timeout',
      timeout: timeout,
    );
  }

  group('Videos - List', () {
    test(
      'lists videos',
      timeout: const Timeout(Duration(minutes: 1)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final videos = await client!.videos.list();

        expect(videos.object, 'list');
        expect(videos.data, isA<List<Video>>());
        expect(videos.hasMore, isA<bool>());

        // Verify structure if there are videos
        if (videos.data.isNotEmpty) {
          final video = videos.data.first;
          expect(video.id, isNotEmpty);
          expect(video.object, 'video');
          expect(video.model, isNotEmpty);
          expect(
            video.status,
            anyOf(
              VideoStatus.queued,
              VideoStatus.inProgress,
              VideoStatus.completed,
              VideoStatus.failed,
            ),
          );
        }
      },
    );

    test(
      'lists videos with pagination',
      timeout: const Timeout(Duration(minutes: 1)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // List with limit
        final videos = await client!.videos.list(limit: 5);

        expect(videos.data.length, lessThanOrEqualTo(5));
        expect(videos.hasMore, isA<bool>());

        // Test with order parameter
        final videosDesc = await client!.videos.list(limit: 5, order: 'desc');
        expect(videosDesc.data.length, lessThanOrEqualTo(5));

        // If pagination is available, test with after cursor
        if (videos.lastId != null && videos.hasMore) {
          final nextPage = await client!.videos.list(
            limit: 5,
            after: videos.lastId,
          );
          expect(nextPage.data, isA<List<Video>>());
        }
      },
    );
  });

  group('Videos - Create & Retrieve', () {
    test(
      'creates a video job',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final video = await createVideoWithAccessCheck();

        if (video == null) {
          markTestSkipped('Sora access not available');
          return;
        }

        expect(video.id, isNotEmpty);
        expect(video.object, 'video');
        expect(video.model, contains('sora'));
        // Initial status should be queued or in_progress
        expect(video.status, anyOf(VideoStatus.queued, VideoStatus.inProgress));
        expect(video.progress, greaterThanOrEqualTo(0));
        expect(video.createdAt, greaterThan(0));
        expect(video.size, isA<VideoSize>());
        expect(video.seconds, VideoSeconds.s4);
      },
    );

    test(
      'retrieves a video by ID',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final created = await createVideoWithAccessCheck();

        if (created == null) {
          markTestSkipped('Sora access not available');
          return;
        }

        final retrieved = await client!.videos.retrieve(created.id);

        expect(retrieved.id, created.id);
        expect(retrieved.object, 'video');
        expect(retrieved.model, created.model);
        expect(retrieved.createdAt, created.createdAt);
        expect(retrieved.size, created.size);
        expect(retrieved.seconds, created.seconds);
      },
    );

    test(
      'validates video model fields',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final video = await createVideoWithAccessCheck();

        if (video == null) {
          markTestSkipped('Sora access not available');
          return;
        }

        // Validate all fields are present and correctly typed
        expect(video.id, isNotEmpty);
        expect(video.object, equals('video'));
        expect(video.model, isNotEmpty);
        expect(video.status, isA<VideoStatus>());
        expect(video.progress, isA<int>());
        expect(video.progress, inInclusiveRange(0, 100));
        expect(video.createdAt, isA<int>());
        expect(video.createdAt, greaterThan(0));
        expect(video.size, isA<VideoSize>());
        expect(video.seconds, isA<VideoSeconds>());

        // Prompt should be available
        expect(video.prompt, isNotNull);
        expect(video.prompt, contains('ball'));

        // Not a remix
        expect(video.remixedFromVideoId, isNull);
      },
    );

    test(
      'validates video helper methods',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final video = await createVideoWithAccessCheck();

        if (video == null) {
          markTestSkipped('Sora access not available');
          return;
        }

        // Test helper getters
        expect(video.createdAtDateTime, isA<DateTime>());
        expect(
          video.createdAtDateTime.millisecondsSinceEpoch,
          video.createdAt * 1000,
        );

        // isCompleted and isFailed should reflect status
        if (video.status == VideoStatus.completed) {
          expect(video.isCompleted, isTrue);
          expect(video.isFailed, isFalse);
        } else if (video.status == VideoStatus.failed) {
          expect(video.isCompleted, isFalse);
          expect(video.isFailed, isTrue);
        } else {
          expect(video.isCompleted, isFalse);
          expect(video.isFailed, isFalse);
        }

        // isRemix should be false for non-remixed videos
        expect(video.isRemix, isFalse);
      },
    );
  });

  group('Videos - Delete', () {
    test(
      'deletes a video',
      timeout: const Timeout(Duration(minutes: 5)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final video = await createVideoWithAccessCheck();

        if (video == null) {
          markTestSkipped('Sora access not available');
          return;
        }

        // Remove from cleanup list since we're deleting it manually
        createdVideoIds.remove(video.id);

        // Wait for video to reach a deletable state (completed or failed)
        // Videos cannot be deleted while still processing
        var current = video;
        const maxAttempts = 20; // ~5 minutes with 15s intervals
        var attempts = 0;

        while (!current.isCompleted &&
            !current.isFailed &&
            attempts < maxAttempts) {
          await Future<void>.delayed(const Duration(seconds: 15));
          current = await client!.videos.retrieve(video.id);
          attempts++;
          print(
            'Waiting for video to be deletable: '
            '${current.status} (${current.progress}%) - attempt $attempts',
          );
        }

        if (!current.isCompleted && !current.isFailed) {
          // Still processing after max wait - add back to cleanup and skip
          createdVideoIds.add(video.id);
          markTestSkipped(
            'Video still processing after ${maxAttempts * 15}s - '
            'cannot test deletion',
          );
          return;
        }

        final result = await client!.videos.delete(video.id);

        expect(result.id, video.id);
        expect(result.deleted, isTrue);
        expect(result.object, 'video.deleted');
      },
    );
  });

  group(
    'Videos - Full Generation Workflow',
    skip: runExpensiveTests
        ? null
        : 'Video generation is expensive - '
              'set OPENAI_RUN_VIDEO_TESTS=true to enable',
    () {
      // Store completed video ID for dependent tests
      String? completedVideoId;

      test(
        'creates video and waits for completion',
        timeout: const Timeout(Duration(minutes: 15)),
        () async {
          if (apiKey == null) {
            markTestSkipped('API key not available');
            return;
          }

          final video = await createVideoWithAccessCheck();

          if (video == null) {
            markTestSkipped('Sora access not available');
            return;
          }

          print('Created video: ${video.id}');
          print(
            'Initial status: ${video.status}, progress: ${video.progress}%',
          );

          // Wait for completion
          final completed = await waitForCompletion(video.id);

          expect(completed.isCompleted, isTrue);
          expect(completed.isFailed, isFalse);
          expect(completed.progress, 100);
          expect(completed.completedAt, isNotNull);
          expect(completed.completedAtDateTime, isA<DateTime>());
          expect(completed.expiresAt, isNotNull);

          // Store for dependent tests
          completedVideoId = completed.id;

          print('Video completed: ${completed.id}');
          print('Completion time: ${completed.completedAtDateTime}');
        },
      );

      test(
        'downloads video content',
        timeout: const Timeout(Duration(minutes: 5)),
        () async {
          if (apiKey == null) {
            markTestSkipped('API key not available');
            return;
          }

          if (completedVideoId == null) {
            markTestSkipped('No completed video available');
            return;
          }

          final content = await client!.videos.retrieveContent(
            completedVideoId!,
          );

          expect(content, isNotEmpty);
          expect(content.length, greaterThan(1000)); // Should be at least 1KB

          // Verify it looks like an MP4 file (starts with ftyp or mdat box)
          // MP4 typically starts with ftypXXXX or similar
          print('Downloaded video: ${content.length} bytes');
        },
      );

      test(
        'downloads thumbnail variant',
        timeout: const Timeout(Duration(minutes: 2)),
        () async {
          if (apiKey == null) {
            markTestSkipped('API key not available');
            return;
          }

          if (completedVideoId == null) {
            markTestSkipped('No completed video available');
            return;
          }

          final thumbnail = await client!.videos.retrieveContent(
            completedVideoId!,
            variant: VideoContentVariant.thumbnail,
          );

          expect(thumbnail, isNotEmpty);
          expect(thumbnail.length, greaterThan(100)); // Should be at least 100B

          print('Downloaded thumbnail: ${thumbnail.length} bytes');
        },
      );

      test(
        'downloads spritesheet variant',
        timeout: const Timeout(Duration(minutes: 2)),
        () async {
          if (apiKey == null) {
            markTestSkipped('API key not available');
            return;
          }

          if (completedVideoId == null) {
            markTestSkipped('No completed video available');
            return;
          }

          final spritesheet = await client!.videos.retrieveContent(
            completedVideoId!,
            variant: VideoContentVariant.spritesheet,
          );

          expect(spritesheet, isNotEmpty);
          expect(spritesheet.length, greaterThan(100));

          print('Downloaded spritesheet: ${spritesheet.length} bytes');
        },
      );

      test(
        'creates a remix of completed video',
        timeout: const Timeout(Duration(minutes: 15)),
        () async {
          if (apiKey == null) {
            markTestSkipped('API key not available');
            return;
          }

          if (completedVideoId == null) {
            markTestSkipped('No completed video available');
            return;
          }

          final remix = await client!.videos.remix(
            completedVideoId!,
            const CreateVideoRemixRequest(
              prompt: 'Same scene but the ball is blue and bouncing faster',
            ),
          );

          createdVideoIds.add(remix.id);

          expect(remix.id, isNotEmpty);
          expect(remix.id, isNot(completedVideoId));
          expect(remix.object, 'video');
          expect(remix.isRemix, isTrue);
          expect(remix.remixedFromVideoId, completedVideoId);

          print('Created remix: ${remix.id}');
          print('Remixed from: ${remix.remixedFromVideoId}');
        },
      );
    },
  );

  group('Videos - Error Handling', () {
    test(
      'throws on invalid video ID (retrieve)',
      timeout: const Timeout(Duration(minutes: 1)),
      () {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        expect(
          () => client!.videos.retrieve('invalid-video-id-12345'),
          throwsA(isA<OpenAIException>()),
        );
      },
    );

    test(
      'throws on invalid video ID (delete)',
      timeout: const Timeout(Duration(minutes: 1)),
      () {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        expect(
          () => client!.videos.delete('invalid-video-id-12345'),
          throwsA(isA<OpenAIException>()),
        );
      },
    );
  });
}
