part of 'toolset_action.dart';

/// The `key` action from the computer toolset.
final class ComputerKeyAction extends ToolsetAction {
  ComputerKeyAction._(Map<String, dynamic> input)
    : super._('computer', 'key', input);

  /// The requested key repeat count.
  int? get repeat => input['repeat'] as int?;

  /// The text, key combination or script supplied by the model.
  String get text => input['text'] as String;
}

/// The `hold_key` action from the computer toolset.
final class ComputerHoldKeyAction extends ToolsetAction {
  ComputerHoldKeyAction._(Map<String, dynamic> input)
    : super._('computer', 'hold_key', input);

  /// The requested duration for the action.
  int get duration => input['duration'] as int;

  /// The text, key combination or script supplied by the model.
  String get text => input['text'] as String;
}

/// The `type` action from the computer toolset.
final class ComputerTypeAction extends ToolsetAction {
  ComputerTypeAction._(Map<String, dynamic> input)
    : super._('computer', 'type', input);

  /// The text, key combination or script supplied by the model.
  String get text => input['text'] as String;
}

/// The `cursor_position` action from the computer toolset.
final class ComputerCursorPositionAction extends ToolsetAction {
  ComputerCursorPositionAction._(Map<String, dynamic> input)
    : super._('computer', 'cursor_position', input);
}

/// The `mouse_move` action from the computer toolset.
final class ComputerMouseMoveAction extends ToolsetAction {
  ComputerMouseMoveAction._(Map<String, dynamic> input)
    : super._('computer', 'mouse_move', input);

  /// The requested screen coordinate.
  List<int> get coordinate =>
      (input['coordinate'] as List<Object?>).cast<int>();
}

/// The `left_mouse_down` action from the computer toolset.
final class ComputerLeftMouseDownAction extends ToolsetAction {
  ComputerLeftMouseDownAction._(Map<String, dynamic> input)
    : super._('computer', 'left_mouse_down', input);
}

/// The `left_mouse_up` action from the computer toolset.
final class ComputerLeftMouseUpAction extends ToolsetAction {
  ComputerLeftMouseUpAction._(Map<String, dynamic> input)
    : super._('computer', 'left_mouse_up', input);
}

/// The `left_click` action from the computer toolset.
final class ComputerLeftClickAction extends ToolsetAction {
  ComputerLeftClickAction._(Map<String, dynamic> input)
    : super._('computer', 'left_click', input);

  /// The requested screen coordinate.
  List<int>? get coordinate =>
      (input['coordinate'] as List<Object?>?)?.cast<int>();

  /// The text, key combination or script supplied by the model.
  String? get text => input['text'] as String?;
}

/// The `left_click_drag` action from the computer toolset.
final class ComputerLeftClickDragAction extends ToolsetAction {
  ComputerLeftClickDragAction._(Map<String, dynamic> input)
    : super._('computer', 'left_click_drag', input);

  /// The requested screen coordinate.
  List<int> get coordinate =>
      (input['coordinate'] as List<Object?>).cast<int>();

  /// The starting screen coordinate.
  List<int> get startCoordinate =>
      (input['start_coordinate'] as List<Object?>).cast<int>();

  /// The text, key combination or script supplied by the model.
  String? get text => input['text'] as String?;
}

/// The `right_click` action from the computer toolset.
final class ComputerRightClickAction extends ToolsetAction {
  ComputerRightClickAction._(Map<String, dynamic> input)
    : super._('computer', 'right_click', input);

  /// The requested screen coordinate.
  List<int>? get coordinate =>
      (input['coordinate'] as List<Object?>?)?.cast<int>();

  /// The text, key combination or script supplied by the model.
  String? get text => input['text'] as String?;
}

/// The `middle_click` action from the computer toolset.
final class ComputerMiddleClickAction extends ToolsetAction {
  ComputerMiddleClickAction._(Map<String, dynamic> input)
    : super._('computer', 'middle_click', input);

  /// The requested screen coordinate.
  List<int>? get coordinate =>
      (input['coordinate'] as List<Object?>?)?.cast<int>();

  /// The text, key combination or script supplied by the model.
  String? get text => input['text'] as String?;
}

/// The `double_click` action from the computer toolset.
final class ComputerDoubleClickAction extends ToolsetAction {
  ComputerDoubleClickAction._(Map<String, dynamic> input)
    : super._('computer', 'double_click', input);

  /// The requested screen coordinate.
  List<int>? get coordinate =>
      (input['coordinate'] as List<Object?>?)?.cast<int>();

  /// The text, key combination or script supplied by the model.
  String? get text => input['text'] as String?;
}

/// The `triple_click` action from the computer toolset.
final class ComputerTripleClickAction extends ToolsetAction {
  ComputerTripleClickAction._(Map<String, dynamic> input)
    : super._('computer', 'triple_click', input);

  /// The requested screen coordinate.
  List<int>? get coordinate =>
      (input['coordinate'] as List<Object?>?)?.cast<int>();

  /// The text, key combination or script supplied by the model.
  String? get text => input['text'] as String?;
}

/// The `scroll` action from the computer toolset.
final class ComputerScrollAction extends ToolsetAction {
  ComputerScrollAction._(Map<String, dynamic> input)
    : super._('computer', 'scroll', input);

  /// The requested screen coordinate.
  List<int>? get coordinate =>
      (input['coordinate'] as List<Object?>?)?.cast<int>();

  /// The requested scroll distance.
  int get scrollAmount => input['scroll_amount'] as int;

  /// The direction reported by the model.
  String get scrollDirection => input['scroll_direction'] as String;

  /// The text, key combination or script supplied by the model.
  String? get text => input['text'] as String?;
}

/// The `wait` action from the computer toolset.
final class ComputerWaitAction extends ToolsetAction {
  ComputerWaitAction._(Map<String, dynamic> input)
    : super._('computer', 'wait', input);

  /// The requested duration for the action.
  int get duration => input['duration'] as int;
}

/// The `screenshot` action from the computer toolset.
final class ComputerScreenshotAction extends ToolsetAction {
  ComputerScreenshotAction._(Map<String, dynamic> input)
    : super._('computer', 'screenshot', input);
}

/// The `zoom` action from the computer toolset.
final class ComputerZoomAction extends ToolsetAction {
  ComputerZoomAction._(Map<String, dynamic> input)
    : super._('computer', 'zoom', input);

  /// The requested screenshot rectangle.
  List<int> get region => (input['region'] as List<Object?>).cast<int>();
}
