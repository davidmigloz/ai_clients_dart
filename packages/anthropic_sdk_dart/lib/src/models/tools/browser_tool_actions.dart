part of 'toolset_action.dart';

/// The `navigate` action from the browser toolset.
final class BrowserNavigateAction extends ToolsetAction {
  BrowserNavigateAction._(Map<String, dynamic> input)
    : super._('browser', 'navigate', input);

  /// The tab identifier.
  String? get tabId => input['tab_id'] as String?;

  /// The requested navigation URL.
  String get url => input['url'] as String;
}

/// The `list_tabs` action from the browser toolset.
final class BrowserListTabsAction extends ToolsetAction {
  BrowserListTabsAction._(Map<String, dynamic> input)
    : super._('browser', 'list_tabs', input);
}

/// The `new_tab` action from the browser toolset.
final class BrowserNewTabAction extends ToolsetAction {
  BrowserNewTabAction._(Map<String, dynamic> input)
    : super._('browser', 'new_tab', input);
}

/// The `switch_tab` action from the browser toolset.
final class BrowserSwitchTabAction extends ToolsetAction {
  BrowserSwitchTabAction._(Map<String, dynamic> input)
    : super._('browser', 'switch_tab', input);

  /// The tab identifier.
  String get tabId => input['tab_id'] as String;
}

/// The `close_tab` action from the browser toolset.
final class BrowserCloseTabAction extends ToolsetAction {
  BrowserCloseTabAction._(Map<String, dynamic> input)
    : super._('browser', 'close_tab', input);

  /// The tab identifier.
  String get tabId => input['tab_id'] as String;
}

/// The `read_page` action from the browser toolset.
final class BrowserReadPageAction extends ToolsetAction {
  BrowserReadPageAction._(Map<String, dynamic> input)
    : super._('browser', 'read_page', input);

  /// The requested depth of the accessibility tree.
  int? get depth => input['depth'] as int?;

  /// The requested filter for page elements.
  String? get filter => input['filter'] as String?;

  /// The element reference for reading a subtree.
  String? get ref => input['ref'] as String?;

  /// The tab identifier.
  String? get tabId => input['tab_id'] as String?;
}

/// The `get_page_text` action from the browser toolset.
final class BrowserGetPageTextAction extends ToolsetAction {
  BrowserGetPageTextAction._(Map<String, dynamic> input)
    : super._('browser', 'get_page_text', input);

  /// The tab identifier.
  String? get tabId => input['tab_id'] as String?;
}

/// The `read_console` action from the browser toolset.
final class BrowserReadConsoleAction extends ToolsetAction {
  BrowserReadConsoleAction._(Map<String, dynamic> input)
    : super._('browser', 'read_console', input);

  /// The tab identifier.
  String? get tabId => input['tab_id'] as String?;
}

/// The `read_network` action from the browser toolset.
final class BrowserReadNetworkAction extends ToolsetAction {
  BrowserReadNetworkAction._(Map<String, dynamic> input)
    : super._('browser', 'read_network', input);

  /// The tab identifier.
  String? get tabId => input['tab_id'] as String?;
}

/// The `find` action from the browser toolset.
final class BrowserFindAction extends ToolsetAction {
  BrowserFindAction._(Map<String, dynamic> input)
    : super._('browser', 'find', input);

  /// The query for finding elements.
  String get query => input['query'] as String;

  /// The tab identifier.
  String? get tabId => input['tab_id'] as String?;
}

/// The `form_input` action from the browser toolset.
final class BrowserFormInputAction extends ToolsetAction {
  BrowserFormInputAction._(Map<String, dynamic> input)
    : super._('browser', 'form_input', input);

  /// The tab identifier.
  String? get tabId => input['tab_id'] as String?;

  /// The location or element targeted by the action.
  BrowserRefTarget get target =>
      BrowserRefTarget.fromJson(input['target'] as Map<String, dynamic>);

  /// The value for the form control.
  BrowserFormValue get value => BrowserFormValue.fromJson(input['value']);
}

/// The `file_upload` action from the browser toolset.
final class BrowserFileUploadAction extends ToolsetAction {
  BrowserFileUploadAction._(Map<String, dynamic> input)
    : super._('browser', 'file_upload', input);

  /// The staged file identifiers.
  List<String>? get documentIds =>
      (input['document_ids'] as List<Object?>?)?.cast<String>();

  /// The file paths requested by the model.
  List<String>? get paths => (input['paths'] as List<Object?>?)?.cast<String>();

  /// The tab identifier.
  String? get tabId => input['tab_id'] as String?;

  /// The location or element targeted by the action.
  BrowserRefTarget get target =>
      BrowserRefTarget.fromJson(input['target'] as Map<String, dynamic>);
}

/// The `scroll_to` action from the browser toolset.
final class BrowserScrollToAction extends ToolsetAction {
  BrowserScrollToAction._(Map<String, dynamic> input)
    : super._('browser', 'scroll_to', input);

  /// The tab identifier.
  String? get tabId => input['tab_id'] as String?;

  /// The location or element targeted by the action.
  BrowserRefTarget get target =>
      BrowserRefTarget.fromJson(input['target'] as Map<String, dynamic>);
}

/// The `screenshot` action from the browser toolset.
final class BrowserScreenshotAction extends ToolsetAction {
  BrowserScreenshotAction._(Map<String, dynamic> input)
    : super._('browser', 'screenshot', input);

  /// The tab identifier.
  String? get tabId => input['tab_id'] as String?;
}

/// The `zoom` action from the browser toolset.
final class BrowserZoomAction extends ToolsetAction {
  BrowserZoomAction._(Map<String, dynamic> input)
    : super._('browser', 'zoom', input);

  /// The requested screenshot rectangle.
  List<int> get region => (input['region'] as List<Object?>).cast<int>();

  /// The tab identifier.
  String? get tabId => input['tab_id'] as String?;
}

/// The `left_click` action from the browser toolset.
final class BrowserLeftClickAction extends ToolsetAction {
  BrowserLeftClickAction._(Map<String, dynamic> input)
    : super._('browser', 'left_click', input);

  /// The keys to hold during the action.
  String? get modifiers => input['modifiers'] as String?;

  /// The tab identifier.
  String? get tabId => input['tab_id'] as String?;

  /// The location or element targeted by the action.
  BrowserClickTarget get target =>
      BrowserClickTarget.fromJson(input['target'] as Map<String, dynamic>);
}

/// The `right_click` action from the browser toolset.
final class BrowserRightClickAction extends ToolsetAction {
  BrowserRightClickAction._(Map<String, dynamic> input)
    : super._('browser', 'right_click', input);

  /// The keys to hold during the action.
  String? get modifiers => input['modifiers'] as String?;

  /// The tab identifier.
  String? get tabId => input['tab_id'] as String?;

  /// The location or element targeted by the action.
  BrowserClickTarget get target =>
      BrowserClickTarget.fromJson(input['target'] as Map<String, dynamic>);
}

/// The `middle_click` action from the browser toolset.
final class BrowserMiddleClickAction extends ToolsetAction {
  BrowserMiddleClickAction._(Map<String, dynamic> input)
    : super._('browser', 'middle_click', input);

  /// The keys to hold during the action.
  String? get modifiers => input['modifiers'] as String?;

  /// The tab identifier.
  String? get tabId => input['tab_id'] as String?;

  /// The location or element targeted by the action.
  BrowserClickTarget get target =>
      BrowserClickTarget.fromJson(input['target'] as Map<String, dynamic>);
}

/// The `double_click` action from the browser toolset.
final class BrowserDoubleClickAction extends ToolsetAction {
  BrowserDoubleClickAction._(Map<String, dynamic> input)
    : super._('browser', 'double_click', input);

  /// The keys to hold during the action.
  String? get modifiers => input['modifiers'] as String?;

  /// The tab identifier.
  String? get tabId => input['tab_id'] as String?;

  /// The location or element targeted by the action.
  BrowserClickTarget get target =>
      BrowserClickTarget.fromJson(input['target'] as Map<String, dynamic>);
}

/// The `triple_click` action from the browser toolset.
final class BrowserTripleClickAction extends ToolsetAction {
  BrowserTripleClickAction._(Map<String, dynamic> input)
    : super._('browser', 'triple_click', input);

  /// The keys to hold during the action.
  String? get modifiers => input['modifiers'] as String?;

  /// The tab identifier.
  String? get tabId => input['tab_id'] as String?;

  /// The location or element targeted by the action.
  BrowserClickTarget get target =>
      BrowserClickTarget.fromJson(input['target'] as Map<String, dynamic>);
}

/// The `hover` action from the browser toolset.
final class BrowserHoverAction extends ToolsetAction {
  BrowserHoverAction._(Map<String, dynamic> input)
    : super._('browser', 'hover', input);

  /// The tab identifier.
  String? get tabId => input['tab_id'] as String?;

  /// The location or element targeted by the action.
  BrowserClickTarget get target =>
      BrowserClickTarget.fromJson(input['target'] as Map<String, dynamic>);
}

/// The `left_click_drag` action from the browser toolset.
final class BrowserLeftClickDragAction extends ToolsetAction {
  BrowserLeftClickDragAction._(Map<String, dynamic> input)
    : super._('browser', 'left_click_drag', input);

  /// The starting point in viewport coordinates.
  BrowserCoordinateTarget get start =>
      BrowserCoordinateTarget.fromJson(input['from'] as Map<String, dynamic>);

  /// The tab identifier.
  String? get tabId => input['tab_id'] as String?;

  /// The location or element targeted by the action.
  BrowserCoordinateTarget get target =>
      BrowserCoordinateTarget.fromJson(input['target'] as Map<String, dynamic>);
}

/// The `left_mouse_down` action from the browser toolset.
final class BrowserLeftMouseDownAction extends ToolsetAction {
  BrowserLeftMouseDownAction._(Map<String, dynamic> input)
    : super._('browser', 'left_mouse_down', input);

  /// The tab identifier.
  String? get tabId => input['tab_id'] as String?;

  /// The location or element targeted by the action.
  BrowserCoordinateTarget get target =>
      BrowserCoordinateTarget.fromJson(input['target'] as Map<String, dynamic>);
}

/// The `left_mouse_up` action from the browser toolset.
final class BrowserLeftMouseUpAction extends ToolsetAction {
  BrowserLeftMouseUpAction._(Map<String, dynamic> input)
    : super._('browser', 'left_mouse_up', input);

  /// The tab identifier.
  String? get tabId => input['tab_id'] as String?;

  /// The location or element targeted by the action.
  BrowserCoordinateTarget get target =>
      BrowserCoordinateTarget.fromJson(input['target'] as Map<String, dynamic>);
}

/// The `mouse_move` action from the browser toolset.
final class BrowserMouseMoveAction extends ToolsetAction {
  BrowserMouseMoveAction._(Map<String, dynamic> input)
    : super._('browser', 'mouse_move', input);

  /// The tab identifier.
  String? get tabId => input['tab_id'] as String?;

  /// The location or element targeted by the action.
  BrowserCoordinateTarget get target =>
      BrowserCoordinateTarget.fromJson(input['target'] as Map<String, dynamic>);
}

/// The `scroll` action from the browser toolset.
final class BrowserScrollAction extends ToolsetAction {
  BrowserScrollAction._(Map<String, dynamic> input)
    : super._('browser', 'scroll', input);

  /// The requested scroll distance.
  int? get scrollAmount => input['scroll_amount'] as int?;

  /// The direction reported by the model.
  String get scrollDirection => input['scroll_direction'] as String;

  /// The tab identifier.
  String? get tabId => input['tab_id'] as String?;

  /// The location or element targeted by the action.
  BrowserCoordinateTarget get target =>
      BrowserCoordinateTarget.fromJson(input['target'] as Map<String, dynamic>);
}

/// The `type` action from the browser toolset.
final class BrowserTypeAction extends ToolsetAction {
  BrowserTypeAction._(Map<String, dynamic> input)
    : super._('browser', 'type', input);

  /// The tab identifier.
  String? get tabId => input['tab_id'] as String?;

  /// The text, key combination or script supplied by the model.
  String get text => input['text'] as String;
}

/// The `key` action from the browser toolset.
final class BrowserKeyAction extends ToolsetAction {
  BrowserKeyAction._(Map<String, dynamic> input)
    : super._('browser', 'key', input);

  /// The requested key repeat count.
  int? get repeat => input['repeat'] as int?;

  /// The tab identifier.
  String? get tabId => input['tab_id'] as String?;

  /// The text, key combination or script supplied by the model.
  String get text => input['text'] as String;
}

/// The `hold_key` action from the browser toolset.
final class BrowserHoldKeyAction extends ToolsetAction {
  BrowserHoldKeyAction._(Map<String, dynamic> input)
    : super._('browser', 'hold_key', input);

  /// The requested duration for the action.
  num get duration => input['duration'] as num;

  /// The tab identifier.
  String? get tabId => input['tab_id'] as String?;

  /// The text, key combination or script supplied by the model.
  String get text => input['text'] as String;
}

/// The `wait` action from the browser toolset.
final class BrowserWaitAction extends ToolsetAction {
  BrowserWaitAction._(Map<String, dynamic> input)
    : super._('browser', 'wait', input);

  /// The requested duration for the action.
  num get duration => input['duration'] as num;

  /// The tab identifier.
  String? get tabId => input['tab_id'] as String?;
}

/// The `javascript_exec` action from the browser toolset.
final class BrowserJavascriptExecAction extends ToolsetAction {
  BrowserJavascriptExecAction._(Map<String, dynamic> input)
    : super._('browser', 'javascript_exec', input);

  /// The tab identifier.
  String? get tabId => input['tab_id'] as String?;

  /// The text, key combination or script supplied by the model.
  String get text => input['text'] as String;
}
