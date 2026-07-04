import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// A content block extracted from a document page (block extraction).
///
/// Populated on [OcrPage.blocks] when `includeBlocks` is enabled on the
/// request. Each block carries a paragraph-level bounding box, its extracted
/// `content`, and a structural [type] label. Blocks are returned in reading
/// order.
///
/// This is a sealed union; switch over the concrete subtypes:
/// [OcrTextBlock], [OcrTitleBlock], [OcrListBlock], [OcrTableBlock],
/// [OcrImageBlock], [OcrEquationBlock], [OcrCaptionBlock], [OcrCodeBlock],
/// [OcrReferencesBlock], [OcrAsideTextBlock], [OcrHeaderBlock],
/// [OcrFooterBlock], [OcrSignatureBlock], and [UnknownOcrBlock] (forward
/// compatibility).
@immutable
sealed class OcrBlock {
  /// Creates an [OcrBlock].
  const OcrBlock();

  /// The structural label of the block (the `type` discriminator).
  String get type;

  /// Creates an [OcrBlock] from JSON, dispatching on the `type` discriminator.
  ///
  /// Unrecognized types are preserved as [UnknownOcrBlock] for forward
  /// compatibility; this never throws on an unknown discriminator.
  factory OcrBlock.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'text' => OcrTextBlock.fromJson(json),
        'title' => OcrTitleBlock.fromJson(json),
        'list' => OcrListBlock.fromJson(json),
        'table' => OcrTableBlock.fromJson(json),
        'image' => OcrImageBlock.fromJson(json),
        'equation' => OcrEquationBlock.fromJson(json),
        'caption' => OcrCaptionBlock.fromJson(json),
        'code' => OcrCodeBlock.fromJson(json),
        'references' => OcrReferencesBlock.fromJson(json),
        'aside_text' => OcrAsideTextBlock.fromJson(json),
        'header' => OcrHeaderBlock.fromJson(json),
        'footer' => OcrFooterBlock.fromJson(json),
        'signature' => OcrSignatureBlock.fromJson(json),
        _ => UnknownOcrBlock(json),
      };

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Text paragraph block extracted from a document page.
@immutable
class OcrTextBlock extends OcrBlock {
  /// The structural label of the block (`text`).
  @override
  String get type => 'text';

  /// X coordinate of the top-left corner of the bounding box.
  final int topLeftX;

  /// Y coordinate of the top-left corner of the bounding box.
  final int topLeftY;

  /// X coordinate of the bottom-right corner of the bounding box.
  final int bottomRightX;

  /// Y coordinate of the bottom-right corner of the bounding box.
  final int bottomRightY;

  /// The extracted content of the block.
  final String content;

  /// Creates an [OcrTextBlock].
  const OcrTextBlock({
    required this.topLeftX,
    required this.topLeftY,
    required this.bottomRightX,
    required this.bottomRightY,
    required this.content,
  });

  /// Creates an [OcrTextBlock] from JSON.
  ///
  /// Throws a [FormatException] if the `type` discriminator is not `text`,
  /// or if any required field is missing or null.
  factory OcrTextBlock.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type != 'text') {
      throw FormatException('OcrTextBlock: expected type "text", got "$type"');
    }
    final topLeftX = json['top_left_x'];
    if (topLeftX is! int) {
      throw const FormatException(
        'OcrTextBlock: missing required field "top_left_x"',
      );
    }
    final topLeftY = json['top_left_y'];
    if (topLeftY is! int) {
      throw const FormatException(
        'OcrTextBlock: missing required field "top_left_y"',
      );
    }
    final bottomRightX = json['bottom_right_x'];
    if (bottomRightX is! int) {
      throw const FormatException(
        'OcrTextBlock: missing required field "bottom_right_x"',
      );
    }
    final bottomRightY = json['bottom_right_y'];
    if (bottomRightY is! int) {
      throw const FormatException(
        'OcrTextBlock: missing required field "bottom_right_y"',
      );
    }
    final content = json['content'];
    if (content is! String) {
      throw const FormatException(
        'OcrTextBlock: missing required field "content"',
      );
    }
    return OcrTextBlock(
      topLeftX: topLeftX,
      topLeftY: topLeftY,
      bottomRightX: bottomRightX,
      bottomRightY: bottomRightY,
      content: content,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'top_left_x': topLeftX,
    'top_left_y': topLeftY,
    'bottom_right_x': bottomRightX,
    'bottom_right_y': bottomRightY,
    'content': content,
  };

  /// Creates a copy with the specified fields replaced.
  OcrTextBlock copyWith({
    int? topLeftX,
    int? topLeftY,
    int? bottomRightX,
    int? bottomRightY,
    String? content,
  }) => OcrTextBlock(
    topLeftX: topLeftX ?? this.topLeftX,
    topLeftY: topLeftY ?? this.topLeftY,
    bottomRightX: bottomRightX ?? this.bottomRightX,
    bottomRightY: bottomRightY ?? this.bottomRightY,
    content: content ?? this.content,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OcrTextBlock &&
          runtimeType == other.runtimeType &&
          topLeftX == other.topLeftX &&
          topLeftY == other.topLeftY &&
          bottomRightX == other.bottomRightX &&
          bottomRightY == other.bottomRightY &&
          content == other.content;

  @override
  int get hashCode => Object.hash(
    type,
    topLeftX,
    topLeftY,
    bottomRightX,
    bottomRightY,
    content,
  );

  @override
  String toString() =>
      'OcrTextBlock(topLeft: ($topLeftX, $topLeftY), '
      'bottomRight: ($bottomRightX, $bottomRightY), '
      'content: ${content.length} chars)';
}

/// Title / heading block extracted from a document page.
@immutable
class OcrTitleBlock extends OcrBlock {
  /// The structural label of the block (`title`).
  @override
  String get type => 'title';

  /// X coordinate of the top-left corner of the bounding box.
  final int topLeftX;

  /// Y coordinate of the top-left corner of the bounding box.
  final int topLeftY;

  /// X coordinate of the bottom-right corner of the bounding box.
  final int bottomRightX;

  /// Y coordinate of the bottom-right corner of the bounding box.
  final int bottomRightY;

  /// The extracted content of the block.
  final String content;

  /// Creates an [OcrTitleBlock].
  const OcrTitleBlock({
    required this.topLeftX,
    required this.topLeftY,
    required this.bottomRightX,
    required this.bottomRightY,
    required this.content,
  });

  /// Creates an [OcrTitleBlock] from JSON.
  ///
  /// Throws a [FormatException] if the `type` discriminator is not `title`,
  /// or if any required field is missing or null.
  factory OcrTitleBlock.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type != 'title') {
      throw FormatException(
        'OcrTitleBlock: expected type "title", got "$type"',
      );
    }
    final topLeftX = json['top_left_x'];
    if (topLeftX is! int) {
      throw const FormatException(
        'OcrTitleBlock: missing required field "top_left_x"',
      );
    }
    final topLeftY = json['top_left_y'];
    if (topLeftY is! int) {
      throw const FormatException(
        'OcrTitleBlock: missing required field "top_left_y"',
      );
    }
    final bottomRightX = json['bottom_right_x'];
    if (bottomRightX is! int) {
      throw const FormatException(
        'OcrTitleBlock: missing required field "bottom_right_x"',
      );
    }
    final bottomRightY = json['bottom_right_y'];
    if (bottomRightY is! int) {
      throw const FormatException(
        'OcrTitleBlock: missing required field "bottom_right_y"',
      );
    }
    final content = json['content'];
    if (content is! String) {
      throw const FormatException(
        'OcrTitleBlock: missing required field "content"',
      );
    }
    return OcrTitleBlock(
      topLeftX: topLeftX,
      topLeftY: topLeftY,
      bottomRightX: bottomRightX,
      bottomRightY: bottomRightY,
      content: content,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'top_left_x': topLeftX,
    'top_left_y': topLeftY,
    'bottom_right_x': bottomRightX,
    'bottom_right_y': bottomRightY,
    'content': content,
  };

  /// Creates a copy with the specified fields replaced.
  OcrTitleBlock copyWith({
    int? topLeftX,
    int? topLeftY,
    int? bottomRightX,
    int? bottomRightY,
    String? content,
  }) => OcrTitleBlock(
    topLeftX: topLeftX ?? this.topLeftX,
    topLeftY: topLeftY ?? this.topLeftY,
    bottomRightX: bottomRightX ?? this.bottomRightX,
    bottomRightY: bottomRightY ?? this.bottomRightY,
    content: content ?? this.content,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OcrTitleBlock &&
          runtimeType == other.runtimeType &&
          topLeftX == other.topLeftX &&
          topLeftY == other.topLeftY &&
          bottomRightX == other.bottomRightX &&
          bottomRightY == other.bottomRightY &&
          content == other.content;

  @override
  int get hashCode => Object.hash(
    type,
    topLeftX,
    topLeftY,
    bottomRightX,
    bottomRightY,
    content,
  );

  @override
  String toString() =>
      'OcrTitleBlock(topLeft: ($topLeftX, $topLeftY), '
      'bottomRight: ($bottomRightX, $bottomRightY), '
      'content: ${content.length} chars)';
}

/// List block extracted from a document page.
@immutable
class OcrListBlock extends OcrBlock {
  /// The structural label of the block (`list`).
  @override
  String get type => 'list';

  /// X coordinate of the top-left corner of the bounding box.
  final int topLeftX;

  /// Y coordinate of the top-left corner of the bounding box.
  final int topLeftY;

  /// X coordinate of the bottom-right corner of the bounding box.
  final int bottomRightX;

  /// Y coordinate of the bottom-right corner of the bounding box.
  final int bottomRightY;

  /// The extracted content of the block.
  final String content;

  /// Creates an [OcrListBlock].
  const OcrListBlock({
    required this.topLeftX,
    required this.topLeftY,
    required this.bottomRightX,
    required this.bottomRightY,
    required this.content,
  });

  /// Creates an [OcrListBlock] from JSON.
  ///
  /// Throws a [FormatException] if the `type` discriminator is not `list`,
  /// or if any required field is missing or null.
  factory OcrListBlock.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type != 'list') {
      throw FormatException('OcrListBlock: expected type "list", got "$type"');
    }
    final topLeftX = json['top_left_x'];
    if (topLeftX is! int) {
      throw const FormatException(
        'OcrListBlock: missing required field "top_left_x"',
      );
    }
    final topLeftY = json['top_left_y'];
    if (topLeftY is! int) {
      throw const FormatException(
        'OcrListBlock: missing required field "top_left_y"',
      );
    }
    final bottomRightX = json['bottom_right_x'];
    if (bottomRightX is! int) {
      throw const FormatException(
        'OcrListBlock: missing required field "bottom_right_x"',
      );
    }
    final bottomRightY = json['bottom_right_y'];
    if (bottomRightY is! int) {
      throw const FormatException(
        'OcrListBlock: missing required field "bottom_right_y"',
      );
    }
    final content = json['content'];
    if (content is! String) {
      throw const FormatException(
        'OcrListBlock: missing required field "content"',
      );
    }
    return OcrListBlock(
      topLeftX: topLeftX,
      topLeftY: topLeftY,
      bottomRightX: bottomRightX,
      bottomRightY: bottomRightY,
      content: content,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'top_left_x': topLeftX,
    'top_left_y': topLeftY,
    'bottom_right_x': bottomRightX,
    'bottom_right_y': bottomRightY,
    'content': content,
  };

  /// Creates a copy with the specified fields replaced.
  OcrListBlock copyWith({
    int? topLeftX,
    int? topLeftY,
    int? bottomRightX,
    int? bottomRightY,
    String? content,
  }) => OcrListBlock(
    topLeftX: topLeftX ?? this.topLeftX,
    topLeftY: topLeftY ?? this.topLeftY,
    bottomRightX: bottomRightX ?? this.bottomRightX,
    bottomRightY: bottomRightY ?? this.bottomRightY,
    content: content ?? this.content,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OcrListBlock &&
          runtimeType == other.runtimeType &&
          topLeftX == other.topLeftX &&
          topLeftY == other.topLeftY &&
          bottomRightX == other.bottomRightX &&
          bottomRightY == other.bottomRightY &&
          content == other.content;

  @override
  int get hashCode => Object.hash(
    type,
    topLeftX,
    topLeftY,
    bottomRightX,
    bottomRightY,
    content,
  );

  @override
  String toString() =>
      'OcrListBlock(topLeft: ($topLeftX, $topLeftY), '
      'bottomRight: ($bottomRightX, $bottomRightY), '
      'content: ${content.length} chars)';
}

/// Table block extracted from a document page.
@immutable
class OcrTableBlock extends OcrBlock {
  /// The structural label of the block (`table`).
  @override
  String get type => 'table';

  /// X coordinate of the top-left corner of the bounding box.
  final int topLeftX;

  /// Y coordinate of the top-left corner of the bounding box.
  final int topLeftY;

  /// X coordinate of the bottom-right corner of the bounding box.
  final int bottomRightX;

  /// Y coordinate of the bottom-right corner of the bounding box.
  final int bottomRightY;

  /// The extracted content of the block.
  final String content;

  /// Identifier of the corresponding table in [OcrPage.tables],
  /// when tables are extracted; `null` otherwise.
  final String? tableId;

  /// Creates an [OcrTableBlock].
  const OcrTableBlock({
    required this.topLeftX,
    required this.topLeftY,
    required this.bottomRightX,
    required this.bottomRightY,
    required this.content,
    this.tableId,
  });

  /// Creates an [OcrTableBlock] from JSON.
  ///
  /// Throws a [FormatException] if the `type` discriminator is not `table`,
  /// or if any required field is missing or null.
  factory OcrTableBlock.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type != 'table') {
      throw FormatException(
        'OcrTableBlock: expected type "table", got "$type"',
      );
    }
    final topLeftX = json['top_left_x'];
    if (topLeftX is! int) {
      throw const FormatException(
        'OcrTableBlock: missing required field "top_left_x"',
      );
    }
    final topLeftY = json['top_left_y'];
    if (topLeftY is! int) {
      throw const FormatException(
        'OcrTableBlock: missing required field "top_left_y"',
      );
    }
    final bottomRightX = json['bottom_right_x'];
    if (bottomRightX is! int) {
      throw const FormatException(
        'OcrTableBlock: missing required field "bottom_right_x"',
      );
    }
    final bottomRightY = json['bottom_right_y'];
    if (bottomRightY is! int) {
      throw const FormatException(
        'OcrTableBlock: missing required field "bottom_right_y"',
      );
    }
    final content = json['content'];
    if (content is! String) {
      throw const FormatException(
        'OcrTableBlock: missing required field "content"',
      );
    }
    return OcrTableBlock(
      topLeftX: topLeftX,
      topLeftY: topLeftY,
      bottomRightX: bottomRightX,
      bottomRightY: bottomRightY,
      content: content,
      tableId: json['table_id'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'top_left_x': topLeftX,
    'top_left_y': topLeftY,
    'bottom_right_x': bottomRightX,
    'bottom_right_y': bottomRightY,
    'content': content,
    if (tableId != null) 'table_id': tableId,
  };

  /// Creates a copy with the specified fields replaced.
  ///
  /// Pass `null` explicitly to clear nullable fields.
  OcrTableBlock copyWith({
    int? topLeftX,
    int? topLeftY,
    int? bottomRightX,
    int? bottomRightY,
    String? content,
    Object? tableId = unsetCopyWithValue,
  }) => OcrTableBlock(
    topLeftX: topLeftX ?? this.topLeftX,
    topLeftY: topLeftY ?? this.topLeftY,
    bottomRightX: bottomRightX ?? this.bottomRightX,
    bottomRightY: bottomRightY ?? this.bottomRightY,
    content: content ?? this.content,
    tableId: tableId == unsetCopyWithValue ? this.tableId : tableId as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OcrTableBlock &&
          runtimeType == other.runtimeType &&
          topLeftX == other.topLeftX &&
          topLeftY == other.topLeftY &&
          bottomRightX == other.bottomRightX &&
          bottomRightY == other.bottomRightY &&
          content == other.content &&
          tableId == other.tableId;

  @override
  int get hashCode => Object.hash(
    type,
    topLeftX,
    topLeftY,
    bottomRightX,
    bottomRightY,
    content,
    tableId,
  );

  @override
  String toString() =>
      'OcrTableBlock(topLeft: ($topLeftX, $topLeftY), '
      'bottomRight: ($bottomRightX, $bottomRightY), '
      'content: ${content.length} chars, tableId: $tableId)';
}

/// Image block extracted from a document page.
@immutable
class OcrImageBlock extends OcrBlock {
  /// The structural label of the block (`image`).
  @override
  String get type => 'image';

  /// X coordinate of the top-left corner of the bounding box.
  final int topLeftX;

  /// Y coordinate of the top-left corner of the bounding box.
  final int topLeftY;

  /// X coordinate of the bottom-right corner of the bounding box.
  final int bottomRightX;

  /// Y coordinate of the bottom-right corner of the bounding box.
  final int bottomRightY;

  /// The extracted content of the block.
  final String content;

  /// Identifier of the corresponding image in [OcrPage.images].
  final String imageId;

  /// Creates an [OcrImageBlock].
  const OcrImageBlock({
    required this.topLeftX,
    required this.topLeftY,
    required this.bottomRightX,
    required this.bottomRightY,
    required this.content,
    required this.imageId,
  });

  /// Creates an [OcrImageBlock] from JSON.
  ///
  /// Throws a [FormatException] if the `type` discriminator is not `image`,
  /// or if any required field is missing or null.
  factory OcrImageBlock.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type != 'image') {
      throw FormatException(
        'OcrImageBlock: expected type "image", got "$type"',
      );
    }
    final topLeftX = json['top_left_x'];
    if (topLeftX is! int) {
      throw const FormatException(
        'OcrImageBlock: missing required field "top_left_x"',
      );
    }
    final topLeftY = json['top_left_y'];
    if (topLeftY is! int) {
      throw const FormatException(
        'OcrImageBlock: missing required field "top_left_y"',
      );
    }
    final bottomRightX = json['bottom_right_x'];
    if (bottomRightX is! int) {
      throw const FormatException(
        'OcrImageBlock: missing required field "bottom_right_x"',
      );
    }
    final bottomRightY = json['bottom_right_y'];
    if (bottomRightY is! int) {
      throw const FormatException(
        'OcrImageBlock: missing required field "bottom_right_y"',
      );
    }
    final content = json['content'];
    if (content is! String) {
      throw const FormatException(
        'OcrImageBlock: missing required field "content"',
      );
    }
    final imageId = json['image_id'];
    if (imageId is! String) {
      throw const FormatException(
        'OcrImageBlock: missing required field "image_id"',
      );
    }
    return OcrImageBlock(
      topLeftX: topLeftX,
      topLeftY: topLeftY,
      bottomRightX: bottomRightX,
      bottomRightY: bottomRightY,
      content: content,
      imageId: imageId,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'top_left_x': topLeftX,
    'top_left_y': topLeftY,
    'bottom_right_x': bottomRightX,
    'bottom_right_y': bottomRightY,
    'content': content,
    'image_id': imageId,
  };

  /// Creates a copy with the specified fields replaced.
  OcrImageBlock copyWith({
    int? topLeftX,
    int? topLeftY,
    int? bottomRightX,
    int? bottomRightY,
    String? content,
    String? imageId,
  }) => OcrImageBlock(
    topLeftX: topLeftX ?? this.topLeftX,
    topLeftY: topLeftY ?? this.topLeftY,
    bottomRightX: bottomRightX ?? this.bottomRightX,
    bottomRightY: bottomRightY ?? this.bottomRightY,
    content: content ?? this.content,
    imageId: imageId ?? this.imageId,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OcrImageBlock &&
          runtimeType == other.runtimeType &&
          topLeftX == other.topLeftX &&
          topLeftY == other.topLeftY &&
          bottomRightX == other.bottomRightX &&
          bottomRightY == other.bottomRightY &&
          content == other.content &&
          imageId == other.imageId;

  @override
  int get hashCode => Object.hash(
    type,
    topLeftX,
    topLeftY,
    bottomRightX,
    bottomRightY,
    content,
    imageId,
  );

  @override
  String toString() =>
      'OcrImageBlock(topLeft: ($topLeftX, $topLeftY), '
      'bottomRight: ($bottomRightX, $bottomRightY), '
      'content: ${content.length} chars, imageId: $imageId)';
}

/// Equation block extracted from a document page.
@immutable
class OcrEquationBlock extends OcrBlock {
  /// The structural label of the block (`equation`).
  @override
  String get type => 'equation';

  /// X coordinate of the top-left corner of the bounding box.
  final int topLeftX;

  /// Y coordinate of the top-left corner of the bounding box.
  final int topLeftY;

  /// X coordinate of the bottom-right corner of the bounding box.
  final int bottomRightX;

  /// Y coordinate of the bottom-right corner of the bounding box.
  final int bottomRightY;

  /// The extracted content of the block.
  final String content;

  /// Creates an [OcrEquationBlock].
  const OcrEquationBlock({
    required this.topLeftX,
    required this.topLeftY,
    required this.bottomRightX,
    required this.bottomRightY,
    required this.content,
  });

  /// Creates an [OcrEquationBlock] from JSON.
  ///
  /// Throws a [FormatException] if the `type` discriminator is not `equation`,
  /// or if any required field is missing or null.
  factory OcrEquationBlock.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type != 'equation') {
      throw FormatException(
        'OcrEquationBlock: expected type "equation", got "$type"',
      );
    }
    final topLeftX = json['top_left_x'];
    if (topLeftX is! int) {
      throw const FormatException(
        'OcrEquationBlock: missing required field "top_left_x"',
      );
    }
    final topLeftY = json['top_left_y'];
    if (topLeftY is! int) {
      throw const FormatException(
        'OcrEquationBlock: missing required field "top_left_y"',
      );
    }
    final bottomRightX = json['bottom_right_x'];
    if (bottomRightX is! int) {
      throw const FormatException(
        'OcrEquationBlock: missing required field "bottom_right_x"',
      );
    }
    final bottomRightY = json['bottom_right_y'];
    if (bottomRightY is! int) {
      throw const FormatException(
        'OcrEquationBlock: missing required field "bottom_right_y"',
      );
    }
    final content = json['content'];
    if (content is! String) {
      throw const FormatException(
        'OcrEquationBlock: missing required field "content"',
      );
    }
    return OcrEquationBlock(
      topLeftX: topLeftX,
      topLeftY: topLeftY,
      bottomRightX: bottomRightX,
      bottomRightY: bottomRightY,
      content: content,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'top_left_x': topLeftX,
    'top_left_y': topLeftY,
    'bottom_right_x': bottomRightX,
    'bottom_right_y': bottomRightY,
    'content': content,
  };

  /// Creates a copy with the specified fields replaced.
  OcrEquationBlock copyWith({
    int? topLeftX,
    int? topLeftY,
    int? bottomRightX,
    int? bottomRightY,
    String? content,
  }) => OcrEquationBlock(
    topLeftX: topLeftX ?? this.topLeftX,
    topLeftY: topLeftY ?? this.topLeftY,
    bottomRightX: bottomRightX ?? this.bottomRightX,
    bottomRightY: bottomRightY ?? this.bottomRightY,
    content: content ?? this.content,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OcrEquationBlock &&
          runtimeType == other.runtimeType &&
          topLeftX == other.topLeftX &&
          topLeftY == other.topLeftY &&
          bottomRightX == other.bottomRightX &&
          bottomRightY == other.bottomRightY &&
          content == other.content;

  @override
  int get hashCode => Object.hash(
    type,
    topLeftX,
    topLeftY,
    bottomRightX,
    bottomRightY,
    content,
  );

  @override
  String toString() =>
      'OcrEquationBlock(topLeft: ($topLeftX, $topLeftY), '
      'bottomRight: ($bottomRightX, $bottomRightY), '
      'content: ${content.length} chars)';
}

/// Caption block extracted from a document page.
@immutable
class OcrCaptionBlock extends OcrBlock {
  /// The structural label of the block (`caption`).
  @override
  String get type => 'caption';

  /// X coordinate of the top-left corner of the bounding box.
  final int topLeftX;

  /// Y coordinate of the top-left corner of the bounding box.
  final int topLeftY;

  /// X coordinate of the bottom-right corner of the bounding box.
  final int bottomRightX;

  /// Y coordinate of the bottom-right corner of the bounding box.
  final int bottomRightY;

  /// The extracted content of the block.
  final String content;

  /// Creates an [OcrCaptionBlock].
  const OcrCaptionBlock({
    required this.topLeftX,
    required this.topLeftY,
    required this.bottomRightX,
    required this.bottomRightY,
    required this.content,
  });

  /// Creates an [OcrCaptionBlock] from JSON.
  ///
  /// Throws a [FormatException] if the `type` discriminator is not `caption`,
  /// or if any required field is missing or null.
  factory OcrCaptionBlock.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type != 'caption') {
      throw FormatException(
        'OcrCaptionBlock: expected type "caption", got "$type"',
      );
    }
    final topLeftX = json['top_left_x'];
    if (topLeftX is! int) {
      throw const FormatException(
        'OcrCaptionBlock: missing required field "top_left_x"',
      );
    }
    final topLeftY = json['top_left_y'];
    if (topLeftY is! int) {
      throw const FormatException(
        'OcrCaptionBlock: missing required field "top_left_y"',
      );
    }
    final bottomRightX = json['bottom_right_x'];
    if (bottomRightX is! int) {
      throw const FormatException(
        'OcrCaptionBlock: missing required field "bottom_right_x"',
      );
    }
    final bottomRightY = json['bottom_right_y'];
    if (bottomRightY is! int) {
      throw const FormatException(
        'OcrCaptionBlock: missing required field "bottom_right_y"',
      );
    }
    final content = json['content'];
    if (content is! String) {
      throw const FormatException(
        'OcrCaptionBlock: missing required field "content"',
      );
    }
    return OcrCaptionBlock(
      topLeftX: topLeftX,
      topLeftY: topLeftY,
      bottomRightX: bottomRightX,
      bottomRightY: bottomRightY,
      content: content,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'top_left_x': topLeftX,
    'top_left_y': topLeftY,
    'bottom_right_x': bottomRightX,
    'bottom_right_y': bottomRightY,
    'content': content,
  };

  /// Creates a copy with the specified fields replaced.
  OcrCaptionBlock copyWith({
    int? topLeftX,
    int? topLeftY,
    int? bottomRightX,
    int? bottomRightY,
    String? content,
  }) => OcrCaptionBlock(
    topLeftX: topLeftX ?? this.topLeftX,
    topLeftY: topLeftY ?? this.topLeftY,
    bottomRightX: bottomRightX ?? this.bottomRightX,
    bottomRightY: bottomRightY ?? this.bottomRightY,
    content: content ?? this.content,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OcrCaptionBlock &&
          runtimeType == other.runtimeType &&
          topLeftX == other.topLeftX &&
          topLeftY == other.topLeftY &&
          bottomRightX == other.bottomRightX &&
          bottomRightY == other.bottomRightY &&
          content == other.content;

  @override
  int get hashCode => Object.hash(
    type,
    topLeftX,
    topLeftY,
    bottomRightX,
    bottomRightY,
    content,
  );

  @override
  String toString() =>
      'OcrCaptionBlock(topLeft: ($topLeftX, $topLeftY), '
      'bottomRight: ($bottomRightX, $bottomRightY), '
      'content: ${content.length} chars)';
}

/// Code block extracted from a document page.
@immutable
class OcrCodeBlock extends OcrBlock {
  /// The structural label of the block (`code`).
  @override
  String get type => 'code';

  /// X coordinate of the top-left corner of the bounding box.
  final int topLeftX;

  /// Y coordinate of the top-left corner of the bounding box.
  final int topLeftY;

  /// X coordinate of the bottom-right corner of the bounding box.
  final int bottomRightX;

  /// Y coordinate of the bottom-right corner of the bounding box.
  final int bottomRightY;

  /// The extracted content of the block.
  final String content;

  /// Creates an [OcrCodeBlock].
  const OcrCodeBlock({
    required this.topLeftX,
    required this.topLeftY,
    required this.bottomRightX,
    required this.bottomRightY,
    required this.content,
  });

  /// Creates an [OcrCodeBlock] from JSON.
  ///
  /// Throws a [FormatException] if the `type` discriminator is not `code`,
  /// or if any required field is missing or null.
  factory OcrCodeBlock.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type != 'code') {
      throw FormatException('OcrCodeBlock: expected type "code", got "$type"');
    }
    final topLeftX = json['top_left_x'];
    if (topLeftX is! int) {
      throw const FormatException(
        'OcrCodeBlock: missing required field "top_left_x"',
      );
    }
    final topLeftY = json['top_left_y'];
    if (topLeftY is! int) {
      throw const FormatException(
        'OcrCodeBlock: missing required field "top_left_y"',
      );
    }
    final bottomRightX = json['bottom_right_x'];
    if (bottomRightX is! int) {
      throw const FormatException(
        'OcrCodeBlock: missing required field "bottom_right_x"',
      );
    }
    final bottomRightY = json['bottom_right_y'];
    if (bottomRightY is! int) {
      throw const FormatException(
        'OcrCodeBlock: missing required field "bottom_right_y"',
      );
    }
    final content = json['content'];
    if (content is! String) {
      throw const FormatException(
        'OcrCodeBlock: missing required field "content"',
      );
    }
    return OcrCodeBlock(
      topLeftX: topLeftX,
      topLeftY: topLeftY,
      bottomRightX: bottomRightX,
      bottomRightY: bottomRightY,
      content: content,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'top_left_x': topLeftX,
    'top_left_y': topLeftY,
    'bottom_right_x': bottomRightX,
    'bottom_right_y': bottomRightY,
    'content': content,
  };

  /// Creates a copy with the specified fields replaced.
  OcrCodeBlock copyWith({
    int? topLeftX,
    int? topLeftY,
    int? bottomRightX,
    int? bottomRightY,
    String? content,
  }) => OcrCodeBlock(
    topLeftX: topLeftX ?? this.topLeftX,
    topLeftY: topLeftY ?? this.topLeftY,
    bottomRightX: bottomRightX ?? this.bottomRightX,
    bottomRightY: bottomRightY ?? this.bottomRightY,
    content: content ?? this.content,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OcrCodeBlock &&
          runtimeType == other.runtimeType &&
          topLeftX == other.topLeftX &&
          topLeftY == other.topLeftY &&
          bottomRightX == other.bottomRightX &&
          bottomRightY == other.bottomRightY &&
          content == other.content;

  @override
  int get hashCode => Object.hash(
    type,
    topLeftX,
    topLeftY,
    bottomRightX,
    bottomRightY,
    content,
  );

  @override
  String toString() =>
      'OcrCodeBlock(topLeft: ($topLeftX, $topLeftY), '
      'bottomRight: ($bottomRightX, $bottomRightY), '
      'content: ${content.length} chars)';
}

/// References block extracted from a document page.
@immutable
class OcrReferencesBlock extends OcrBlock {
  /// The structural label of the block (`references`).
  @override
  String get type => 'references';

  /// X coordinate of the top-left corner of the bounding box.
  final int topLeftX;

  /// Y coordinate of the top-left corner of the bounding box.
  final int topLeftY;

  /// X coordinate of the bottom-right corner of the bounding box.
  final int bottomRightX;

  /// Y coordinate of the bottom-right corner of the bounding box.
  final int bottomRightY;

  /// The extracted content of the block.
  final String content;

  /// Creates an [OcrReferencesBlock].
  const OcrReferencesBlock({
    required this.topLeftX,
    required this.topLeftY,
    required this.bottomRightX,
    required this.bottomRightY,
    required this.content,
  });

  /// Creates an [OcrReferencesBlock] from JSON.
  ///
  /// Throws a [FormatException] if the `type` discriminator is not `references`,
  /// or if any required field is missing or null.
  factory OcrReferencesBlock.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type != 'references') {
      throw FormatException(
        'OcrReferencesBlock: expected type "references", got "$type"',
      );
    }
    final topLeftX = json['top_left_x'];
    if (topLeftX is! int) {
      throw const FormatException(
        'OcrReferencesBlock: missing required field "top_left_x"',
      );
    }
    final topLeftY = json['top_left_y'];
    if (topLeftY is! int) {
      throw const FormatException(
        'OcrReferencesBlock: missing required field "top_left_y"',
      );
    }
    final bottomRightX = json['bottom_right_x'];
    if (bottomRightX is! int) {
      throw const FormatException(
        'OcrReferencesBlock: missing required field "bottom_right_x"',
      );
    }
    final bottomRightY = json['bottom_right_y'];
    if (bottomRightY is! int) {
      throw const FormatException(
        'OcrReferencesBlock: missing required field "bottom_right_y"',
      );
    }
    final content = json['content'];
    if (content is! String) {
      throw const FormatException(
        'OcrReferencesBlock: missing required field "content"',
      );
    }
    return OcrReferencesBlock(
      topLeftX: topLeftX,
      topLeftY: topLeftY,
      bottomRightX: bottomRightX,
      bottomRightY: bottomRightY,
      content: content,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'top_left_x': topLeftX,
    'top_left_y': topLeftY,
    'bottom_right_x': bottomRightX,
    'bottom_right_y': bottomRightY,
    'content': content,
  };

  /// Creates a copy with the specified fields replaced.
  OcrReferencesBlock copyWith({
    int? topLeftX,
    int? topLeftY,
    int? bottomRightX,
    int? bottomRightY,
    String? content,
  }) => OcrReferencesBlock(
    topLeftX: topLeftX ?? this.topLeftX,
    topLeftY: topLeftY ?? this.topLeftY,
    bottomRightX: bottomRightX ?? this.bottomRightX,
    bottomRightY: bottomRightY ?? this.bottomRightY,
    content: content ?? this.content,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OcrReferencesBlock &&
          runtimeType == other.runtimeType &&
          topLeftX == other.topLeftX &&
          topLeftY == other.topLeftY &&
          bottomRightX == other.bottomRightX &&
          bottomRightY == other.bottomRightY &&
          content == other.content;

  @override
  int get hashCode => Object.hash(
    type,
    topLeftX,
    topLeftY,
    bottomRightX,
    bottomRightY,
    content,
  );

  @override
  String toString() =>
      'OcrReferencesBlock(topLeft: ($topLeftX, $topLeftY), '
      'bottomRight: ($bottomRightX, $bottomRightY), '
      'content: ${content.length} chars)';
}

/// Aside text block extracted from a document page.
@immutable
class OcrAsideTextBlock extends OcrBlock {
  /// The structural label of the block (`aside_text`).
  @override
  String get type => 'aside_text';

  /// X coordinate of the top-left corner of the bounding box.
  final int topLeftX;

  /// Y coordinate of the top-left corner of the bounding box.
  final int topLeftY;

  /// X coordinate of the bottom-right corner of the bounding box.
  final int bottomRightX;

  /// Y coordinate of the bottom-right corner of the bounding box.
  final int bottomRightY;

  /// The extracted content of the block.
  final String content;

  /// Creates an [OcrAsideTextBlock].
  const OcrAsideTextBlock({
    required this.topLeftX,
    required this.topLeftY,
    required this.bottomRightX,
    required this.bottomRightY,
    required this.content,
  });

  /// Creates an [OcrAsideTextBlock] from JSON.
  ///
  /// Throws a [FormatException] if the `type` discriminator is not `aside_text`,
  /// or if any required field is missing or null.
  factory OcrAsideTextBlock.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type != 'aside_text') {
      throw FormatException(
        'OcrAsideTextBlock: expected type "aside_text", got "$type"',
      );
    }
    final topLeftX = json['top_left_x'];
    if (topLeftX is! int) {
      throw const FormatException(
        'OcrAsideTextBlock: missing required field "top_left_x"',
      );
    }
    final topLeftY = json['top_left_y'];
    if (topLeftY is! int) {
      throw const FormatException(
        'OcrAsideTextBlock: missing required field "top_left_y"',
      );
    }
    final bottomRightX = json['bottom_right_x'];
    if (bottomRightX is! int) {
      throw const FormatException(
        'OcrAsideTextBlock: missing required field "bottom_right_x"',
      );
    }
    final bottomRightY = json['bottom_right_y'];
    if (bottomRightY is! int) {
      throw const FormatException(
        'OcrAsideTextBlock: missing required field "bottom_right_y"',
      );
    }
    final content = json['content'];
    if (content is! String) {
      throw const FormatException(
        'OcrAsideTextBlock: missing required field "content"',
      );
    }
    return OcrAsideTextBlock(
      topLeftX: topLeftX,
      topLeftY: topLeftY,
      bottomRightX: bottomRightX,
      bottomRightY: bottomRightY,
      content: content,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'top_left_x': topLeftX,
    'top_left_y': topLeftY,
    'bottom_right_x': bottomRightX,
    'bottom_right_y': bottomRightY,
    'content': content,
  };

  /// Creates a copy with the specified fields replaced.
  OcrAsideTextBlock copyWith({
    int? topLeftX,
    int? topLeftY,
    int? bottomRightX,
    int? bottomRightY,
    String? content,
  }) => OcrAsideTextBlock(
    topLeftX: topLeftX ?? this.topLeftX,
    topLeftY: topLeftY ?? this.topLeftY,
    bottomRightX: bottomRightX ?? this.bottomRightX,
    bottomRightY: bottomRightY ?? this.bottomRightY,
    content: content ?? this.content,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OcrAsideTextBlock &&
          runtimeType == other.runtimeType &&
          topLeftX == other.topLeftX &&
          topLeftY == other.topLeftY &&
          bottomRightX == other.bottomRightX &&
          bottomRightY == other.bottomRightY &&
          content == other.content;

  @override
  int get hashCode => Object.hash(
    type,
    topLeftX,
    topLeftY,
    bottomRightX,
    bottomRightY,
    content,
  );

  @override
  String toString() =>
      'OcrAsideTextBlock(topLeft: ($topLeftX, $topLeftY), '
      'bottomRight: ($bottomRightX, $bottomRightY), '
      'content: ${content.length} chars)';
}

/// Header block extracted from a document page.
@immutable
class OcrHeaderBlock extends OcrBlock {
  /// The structural label of the block (`header`).
  @override
  String get type => 'header';

  /// X coordinate of the top-left corner of the bounding box.
  final int topLeftX;

  /// Y coordinate of the top-left corner of the bounding box.
  final int topLeftY;

  /// X coordinate of the bottom-right corner of the bounding box.
  final int bottomRightX;

  /// Y coordinate of the bottom-right corner of the bounding box.
  final int bottomRightY;

  /// The extracted content of the block.
  final String content;

  /// Creates an [OcrHeaderBlock].
  const OcrHeaderBlock({
    required this.topLeftX,
    required this.topLeftY,
    required this.bottomRightX,
    required this.bottomRightY,
    required this.content,
  });

  /// Creates an [OcrHeaderBlock] from JSON.
  ///
  /// Throws a [FormatException] if the `type` discriminator is not `header`,
  /// or if any required field is missing or null.
  factory OcrHeaderBlock.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type != 'header') {
      throw FormatException(
        'OcrHeaderBlock: expected type "header", got "$type"',
      );
    }
    final topLeftX = json['top_left_x'];
    if (topLeftX is! int) {
      throw const FormatException(
        'OcrHeaderBlock: missing required field "top_left_x"',
      );
    }
    final topLeftY = json['top_left_y'];
    if (topLeftY is! int) {
      throw const FormatException(
        'OcrHeaderBlock: missing required field "top_left_y"',
      );
    }
    final bottomRightX = json['bottom_right_x'];
    if (bottomRightX is! int) {
      throw const FormatException(
        'OcrHeaderBlock: missing required field "bottom_right_x"',
      );
    }
    final bottomRightY = json['bottom_right_y'];
    if (bottomRightY is! int) {
      throw const FormatException(
        'OcrHeaderBlock: missing required field "bottom_right_y"',
      );
    }
    final content = json['content'];
    if (content is! String) {
      throw const FormatException(
        'OcrHeaderBlock: missing required field "content"',
      );
    }
    return OcrHeaderBlock(
      topLeftX: topLeftX,
      topLeftY: topLeftY,
      bottomRightX: bottomRightX,
      bottomRightY: bottomRightY,
      content: content,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'top_left_x': topLeftX,
    'top_left_y': topLeftY,
    'bottom_right_x': bottomRightX,
    'bottom_right_y': bottomRightY,
    'content': content,
  };

  /// Creates a copy with the specified fields replaced.
  OcrHeaderBlock copyWith({
    int? topLeftX,
    int? topLeftY,
    int? bottomRightX,
    int? bottomRightY,
    String? content,
  }) => OcrHeaderBlock(
    topLeftX: topLeftX ?? this.topLeftX,
    topLeftY: topLeftY ?? this.topLeftY,
    bottomRightX: bottomRightX ?? this.bottomRightX,
    bottomRightY: bottomRightY ?? this.bottomRightY,
    content: content ?? this.content,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OcrHeaderBlock &&
          runtimeType == other.runtimeType &&
          topLeftX == other.topLeftX &&
          topLeftY == other.topLeftY &&
          bottomRightX == other.bottomRightX &&
          bottomRightY == other.bottomRightY &&
          content == other.content;

  @override
  int get hashCode => Object.hash(
    type,
    topLeftX,
    topLeftY,
    bottomRightX,
    bottomRightY,
    content,
  );

  @override
  String toString() =>
      'OcrHeaderBlock(topLeft: ($topLeftX, $topLeftY), '
      'bottomRight: ($bottomRightX, $bottomRightY), '
      'content: ${content.length} chars)';
}

/// Footer block extracted from a document page.
@immutable
class OcrFooterBlock extends OcrBlock {
  /// The structural label of the block (`footer`).
  @override
  String get type => 'footer';

  /// X coordinate of the top-left corner of the bounding box.
  final int topLeftX;

  /// Y coordinate of the top-left corner of the bounding box.
  final int topLeftY;

  /// X coordinate of the bottom-right corner of the bounding box.
  final int bottomRightX;

  /// Y coordinate of the bottom-right corner of the bounding box.
  final int bottomRightY;

  /// The extracted content of the block.
  final String content;

  /// Creates an [OcrFooterBlock].
  const OcrFooterBlock({
    required this.topLeftX,
    required this.topLeftY,
    required this.bottomRightX,
    required this.bottomRightY,
    required this.content,
  });

  /// Creates an [OcrFooterBlock] from JSON.
  ///
  /// Throws a [FormatException] if the `type` discriminator is not `footer`,
  /// or if any required field is missing or null.
  factory OcrFooterBlock.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type != 'footer') {
      throw FormatException(
        'OcrFooterBlock: expected type "footer", got "$type"',
      );
    }
    final topLeftX = json['top_left_x'];
    if (topLeftX is! int) {
      throw const FormatException(
        'OcrFooterBlock: missing required field "top_left_x"',
      );
    }
    final topLeftY = json['top_left_y'];
    if (topLeftY is! int) {
      throw const FormatException(
        'OcrFooterBlock: missing required field "top_left_y"',
      );
    }
    final bottomRightX = json['bottom_right_x'];
    if (bottomRightX is! int) {
      throw const FormatException(
        'OcrFooterBlock: missing required field "bottom_right_x"',
      );
    }
    final bottomRightY = json['bottom_right_y'];
    if (bottomRightY is! int) {
      throw const FormatException(
        'OcrFooterBlock: missing required field "bottom_right_y"',
      );
    }
    final content = json['content'];
    if (content is! String) {
      throw const FormatException(
        'OcrFooterBlock: missing required field "content"',
      );
    }
    return OcrFooterBlock(
      topLeftX: topLeftX,
      topLeftY: topLeftY,
      bottomRightX: bottomRightX,
      bottomRightY: bottomRightY,
      content: content,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'top_left_x': topLeftX,
    'top_left_y': topLeftY,
    'bottom_right_x': bottomRightX,
    'bottom_right_y': bottomRightY,
    'content': content,
  };

  /// Creates a copy with the specified fields replaced.
  OcrFooterBlock copyWith({
    int? topLeftX,
    int? topLeftY,
    int? bottomRightX,
    int? bottomRightY,
    String? content,
  }) => OcrFooterBlock(
    topLeftX: topLeftX ?? this.topLeftX,
    topLeftY: topLeftY ?? this.topLeftY,
    bottomRightX: bottomRightX ?? this.bottomRightX,
    bottomRightY: bottomRightY ?? this.bottomRightY,
    content: content ?? this.content,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OcrFooterBlock &&
          runtimeType == other.runtimeType &&
          topLeftX == other.topLeftX &&
          topLeftY == other.topLeftY &&
          bottomRightX == other.bottomRightX &&
          bottomRightY == other.bottomRightY &&
          content == other.content;

  @override
  int get hashCode => Object.hash(
    type,
    topLeftX,
    topLeftY,
    bottomRightX,
    bottomRightY,
    content,
  );

  @override
  String toString() =>
      'OcrFooterBlock(topLeft: ($topLeftX, $topLeftY), '
      'bottomRight: ($bottomRightX, $bottomRightY), '
      'content: ${content.length} chars)';
}

/// Signature block extracted from a document page.
@immutable
class OcrSignatureBlock extends OcrBlock {
  /// The structural label of the block (`signature`).
  @override
  String get type => 'signature';

  /// X coordinate of the top-left corner of the bounding box.
  final int topLeftX;

  /// Y coordinate of the top-left corner of the bounding box.
  final int topLeftY;

  /// X coordinate of the bottom-right corner of the bounding box.
  final int bottomRightX;

  /// Y coordinate of the bottom-right corner of the bounding box.
  final int bottomRightY;

  /// The extracted content of the block.
  final String content;

  /// Creates an [OcrSignatureBlock].
  const OcrSignatureBlock({
    required this.topLeftX,
    required this.topLeftY,
    required this.bottomRightX,
    required this.bottomRightY,
    required this.content,
  });

  /// Creates an [OcrSignatureBlock] from JSON.
  ///
  /// Throws a [FormatException] if the `type` discriminator is not `signature`,
  /// or if any required field is missing or null.
  factory OcrSignatureBlock.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type != 'signature') {
      throw FormatException(
        'OcrSignatureBlock: expected type "signature", got "$type"',
      );
    }
    final topLeftX = json['top_left_x'];
    if (topLeftX is! int) {
      throw const FormatException(
        'OcrSignatureBlock: missing required field "top_left_x"',
      );
    }
    final topLeftY = json['top_left_y'];
    if (topLeftY is! int) {
      throw const FormatException(
        'OcrSignatureBlock: missing required field "top_left_y"',
      );
    }
    final bottomRightX = json['bottom_right_x'];
    if (bottomRightX is! int) {
      throw const FormatException(
        'OcrSignatureBlock: missing required field "bottom_right_x"',
      );
    }
    final bottomRightY = json['bottom_right_y'];
    if (bottomRightY is! int) {
      throw const FormatException(
        'OcrSignatureBlock: missing required field "bottom_right_y"',
      );
    }
    final content = json['content'];
    if (content is! String) {
      throw const FormatException(
        'OcrSignatureBlock: missing required field "content"',
      );
    }
    return OcrSignatureBlock(
      topLeftX: topLeftX,
      topLeftY: topLeftY,
      bottomRightX: bottomRightX,
      bottomRightY: bottomRightY,
      content: content,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'top_left_x': topLeftX,
    'top_left_y': topLeftY,
    'bottom_right_x': bottomRightX,
    'bottom_right_y': bottomRightY,
    'content': content,
  };

  /// Creates a copy with the specified fields replaced.
  OcrSignatureBlock copyWith({
    int? topLeftX,
    int? topLeftY,
    int? bottomRightX,
    int? bottomRightY,
    String? content,
  }) => OcrSignatureBlock(
    topLeftX: topLeftX ?? this.topLeftX,
    topLeftY: topLeftY ?? this.topLeftY,
    bottomRightX: bottomRightX ?? this.bottomRightX,
    bottomRightY: bottomRightY ?? this.bottomRightY,
    content: content ?? this.content,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OcrSignatureBlock &&
          runtimeType == other.runtimeType &&
          topLeftX == other.topLeftX &&
          topLeftY == other.topLeftY &&
          bottomRightX == other.bottomRightX &&
          bottomRightY == other.bottomRightY &&
          content == other.content;

  @override
  int get hashCode => Object.hash(
    type,
    topLeftX,
    topLeftY,
    bottomRightX,
    bottomRightY,
    content,
  );

  @override
  String toString() =>
      'OcrSignatureBlock(topLeft: ($topLeftX, $topLeftY), '
      'bottomRight: ($bottomRightX, $bottomRightY), '
      'content: ${content.length} chars)';
}

/// Fallback block for an unrecognized `type`, preserving the raw JSON.
///
/// Ensures forward compatibility when the API introduces new block types.
@immutable
class UnknownOcrBlock extends OcrBlock {
  /// Creates an [UnknownOcrBlock] wrapping the raw JSON map.
  UnknownOcrBlock(Map<String, dynamic> raw)
    : _raw = Map<String, dynamic>.unmodifiable(raw);

  final Map<String, dynamic> _raw;

  /// The raw JSON data for the unrecognized block.
  Map<String, dynamic> get raw => _raw;

  @override
  String get type {
    final rawType = _raw['type'];
    return rawType is String ? rawType : 'unknown';
  }

  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(_raw);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownOcrBlock &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(_raw, other._raw);

  @override
  int get hashCode => mapDeepHashCode(_raw);

  @override
  String toString() => 'UnknownOcrBlock(type: $type)';
}
