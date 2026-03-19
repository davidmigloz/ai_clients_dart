import 'package:meta/meta.dart';

import '../../common/equality_helpers.dart';
import '../config/click_button.dart';

/// An action performed by the computer use tool.
///
/// ## Supported Actions
///
/// - [ClickAction] - Click at coordinates
/// - [DoubleClickAction] - Double-click at coordinates
/// - [DragAction] - Drag along a path
/// - [KeyPressAction] - Press keyboard keys
/// - [MoveAction] - Move cursor to coordinates
/// - [ScreenshotAction] - Take a screenshot
/// - [ScrollAction] - Scroll at coordinates
/// - [TypeAction] - Type text
/// - [WaitAction] - Wait for a duration
sealed class ComputerAction {
  /// Creates a [ComputerAction].
  const ComputerAction();

  /// Creates a [ComputerAction] from JSON.
  factory ComputerAction.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'click' => ClickAction.fromJson(json),
      'double_click' => DoubleClickAction.fromJson(json),
      'drag' => DragAction.fromJson(json),
      'keypress' => KeyPressAction.fromJson(json),
      'move' => MoveAction.fromJson(json),
      'screenshot' => const ScreenshotAction(),
      'scroll' => ScrollAction.fromJson(json),
      'type' => TypeAction.fromJson(json),
      'wait' => const WaitAction(),
      _ => throw FormatException('Unknown ComputerAction type: $type'),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A click action at specific coordinates.
@immutable
class ClickAction extends ComputerAction {
  /// The mouse button to click.
  final ClickButton button;

  /// The x coordinate.
  final int x;

  /// The y coordinate.
  final int y;

  /// Creates a [ClickAction].
  const ClickAction({required this.button, required this.x, required this.y});

  /// Creates a [ClickAction] from JSON.
  factory ClickAction.fromJson(Map<String, dynamic> json) {
    return ClickAction(
      button: ClickButton.fromJson(json['button'] as String),
      x: json['x'] as int,
      y: json['y'] as int,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'click',
    'button': button.toJson(),
    'x': x,
    'y': y,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClickAction &&
          runtimeType == other.runtimeType &&
          button == other.button &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => Object.hash(button, x, y);

  @override
  String toString() => 'ClickAction(button: $button, x: $x, y: $y)';
}

/// A double-click action at specific coordinates.
@immutable
class DoubleClickAction extends ComputerAction {
  /// The x coordinate.
  final int x;

  /// The y coordinate.
  final int y;

  /// Creates a [DoubleClickAction].
  const DoubleClickAction({required this.x, required this.y});

  /// Creates a [DoubleClickAction] from JSON.
  factory DoubleClickAction.fromJson(Map<String, dynamic> json) {
    return DoubleClickAction(x: json['x'] as int, y: json['y'] as int);
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'double_click', 'x': x, 'y': y};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoubleClickAction &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'DoubleClickAction(x: $x, y: $y)';
}

/// A drag action along a path of coordinates.
@immutable
class DragAction extends ComputerAction {
  /// The path of coordinates to drag along.
  final List<Map<String, dynamic>> path;

  /// Creates a [DragAction].
  const DragAction({required this.path});

  /// Creates a [DragAction] from JSON.
  factory DragAction.fromJson(Map<String, dynamic> json) {
    return DragAction(
      path: (json['path'] as List)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'drag', 'path': path};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DragAction &&
          runtimeType == other.runtimeType &&
          listOfMapsDeepEqual(path, other.path);

  @override
  int get hashCode => listOfMapsHashCode(path);

  @override
  String toString() => 'DragAction(path: $path)';
}

/// A keypress action to press keyboard keys.
@immutable
class KeyPressAction extends ComputerAction {
  /// The keys to press.
  final List<String> keys;

  /// Creates a [KeyPressAction].
  const KeyPressAction({required this.keys});

  /// Creates a [KeyPressAction] from JSON.
  factory KeyPressAction.fromJson(Map<String, dynamic> json) {
    return KeyPressAction(keys: (json['keys'] as List).cast<String>());
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'keypress', 'keys': keys};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KeyPressAction &&
          runtimeType == other.runtimeType &&
          listsEqual(keys, other.keys);

  @override
  int get hashCode => Object.hashAll(keys);

  @override
  String toString() => 'KeyPressAction(keys: $keys)';
}

/// A move action to move the cursor to coordinates.
@immutable
class MoveAction extends ComputerAction {
  /// The x coordinate.
  final int x;

  /// The y coordinate.
  final int y;

  /// Creates a [MoveAction].
  const MoveAction({required this.x, required this.y});

  /// Creates a [MoveAction] from JSON.
  factory MoveAction.fromJson(Map<String, dynamic> json) {
    return MoveAction(x: json['x'] as int, y: json['y'] as int);
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'move', 'x': x, 'y': y};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoveAction &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'MoveAction(x: $x, y: $y)';
}

/// A screenshot action to capture the current screen.
@immutable
class ScreenshotAction extends ComputerAction {
  /// Creates a [ScreenshotAction].
  const ScreenshotAction();

  @override
  Map<String, dynamic> toJson() => const {'type': 'screenshot'};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ScreenshotAction;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'ScreenshotAction()';
}

/// A scroll action at specific coordinates.
@immutable
class ScrollAction extends ComputerAction {
  /// The x coordinate.
  final int x;

  /// The y coordinate.
  final int y;

  /// The horizontal scroll amount.
  final int scrollX;

  /// The vertical scroll amount.
  final int scrollY;

  /// Creates a [ScrollAction].
  const ScrollAction({
    required this.x,
    required this.y,
    required this.scrollX,
    required this.scrollY,
  });

  /// Creates a [ScrollAction] from JSON.
  factory ScrollAction.fromJson(Map<String, dynamic> json) {
    return ScrollAction(
      x: json['x'] as int,
      y: json['y'] as int,
      scrollX: json['scroll_x'] as int,
      scrollY: json['scroll_y'] as int,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'scroll',
    'x': x,
    'y': y,
    'scroll_x': scrollX,
    'scroll_y': scrollY,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScrollAction &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y &&
          scrollX == other.scrollX &&
          scrollY == other.scrollY;

  @override
  int get hashCode => Object.hash(x, y, scrollX, scrollY);

  @override
  String toString() =>
      'ScrollAction(x: $x, y: $y, scrollX: $scrollX, scrollY: $scrollY)';
}

/// A type action to type text.
@immutable
class TypeAction extends ComputerAction {
  /// The text to type.
  final String text;

  /// Creates a [TypeAction].
  const TypeAction({required this.text});

  /// Creates a [TypeAction] from JSON.
  factory TypeAction.fromJson(Map<String, dynamic> json) {
    return TypeAction(text: json['text'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'type', 'text': text};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TypeAction &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'TypeAction(text: $text)';
}

/// A wait action to pause execution.
@immutable
class WaitAction extends ComputerAction {
  /// Creates a [WaitAction].
  const WaitAction();

  @override
  Map<String, dynamic> toJson() => const {'type': 'wait'};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is WaitAction;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'WaitAction()';
}
