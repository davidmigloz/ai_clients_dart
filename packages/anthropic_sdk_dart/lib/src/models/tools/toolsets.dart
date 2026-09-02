import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Per-member configuration shared by every member of the computer and
/// browser toolsets.
///
/// All 96 per-member spec schemas across both toolsets share exactly this
/// shape.
@immutable
class ToolsetMemberConfig {
  /// Whether this member is offered to the model. Default is per member,
  /// per the toolset's documentation. A member whose [enabled] resolves
  /// false is withheld from the served schema.
  final bool? enabled;

  /// Defer loading for this member.
  ///
  /// Must resolve to the same value on every enabled member of the toolset.
  final bool? deferLoading;

  /// Creates a [ToolsetMemberConfig].
  const ToolsetMemberConfig({this.enabled, this.deferLoading});

  /// Creates a [ToolsetMemberConfig] from JSON.
  factory ToolsetMemberConfig.fromJson(Map<String, dynamic> json) {
    return ToolsetMemberConfig(
      enabled: json['enabled'] as bool?,
      deferLoading: json['defer_loading'] as bool?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (enabled != null) 'enabled': enabled,
    if (deferLoading != null) 'defer_loading': deferLoading,
  };

  /// Creates a copy with replaced values.
  ToolsetMemberConfig copyWith({
    Object? enabled = unsetCopyWithValue,
    Object? deferLoading = unsetCopyWithValue,
  }) {
    return ToolsetMemberConfig(
      enabled: enabled == unsetCopyWithValue ? this.enabled : enabled as bool?,
      deferLoading: deferLoading == unsetCopyWithValue
          ? this.deferLoading
          : deferLoading as bool?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolsetMemberConfig &&
          runtimeType == other.runtimeType &&
          enabled == other.enabled &&
          deferLoading == other.deferLoading;

  @override
  int get hashCode => Object.hash(enabled, deferLoading);

  @override
  String toString() =>
      'ToolsetMemberConfig(enabled: $enabled, deferLoading: $deferLoading)';
}

/// Per-member configuration for `computer_toolset_20260801`: one optional
/// field per member tool, keyed by the member name (the same name the
/// member's `tool_use` blocks carry). Every member is an accepted key, and
/// a member's defaults apply wherever its key is absent. The `typeAction`
/// field maps to the wire key `type` (the `type` member action, renamed in
/// Dart to avoid clashing with the class's own notion of a type).
@immutable
class ComputerToolsetConfigs {
  /// Per-member override for the `cursor_position` member.
  final ToolsetMemberConfig? cursorPosition;

  /// Per-member override for the `double_click` member.
  final ToolsetMemberConfig? doubleClick;

  /// Per-member override for the `hold_key` member.
  final ToolsetMemberConfig? holdKey;

  /// Per-member override for the `key` member.
  final ToolsetMemberConfig? key;

  /// Per-member override for the `left_click` member.
  final ToolsetMemberConfig? leftClick;

  /// Per-member override for the `left_click_drag` member.
  final ToolsetMemberConfig? leftClickDrag;

  /// Per-member override for the `left_mouse_down` member.
  final ToolsetMemberConfig? leftMouseDown;

  /// Per-member override for the `left_mouse_up` member.
  final ToolsetMemberConfig? leftMouseUp;

  /// Per-member override for the `middle_click` member.
  final ToolsetMemberConfig? middleClick;

  /// Per-member override for the `mouse_move` member.
  final ToolsetMemberConfig? mouseMove;

  /// Per-member override for the `right_click` member.
  final ToolsetMemberConfig? rightClick;

  /// Per-member override for the `screenshot` member.
  final ToolsetMemberConfig? screenshot;

  /// Per-member override for the `scroll` member.
  final ToolsetMemberConfig? scroll;

  /// Per-member override for the `triple_click` member.
  final ToolsetMemberConfig? tripleClick;

  /// Per-member override for the `type` `type` member (renamed to avoid clashing with Dart's `type` keyword/convention).
  final ToolsetMemberConfig? typeAction;

  /// Per-member override for the `wait` member.
  final ToolsetMemberConfig? wait;

  /// Per-member override for the `zoom` member.
  final ToolsetMemberConfig? zoom;

  /// Creates [ComputerToolsetConfigs].
  const ComputerToolsetConfigs({
    this.cursorPosition,
    this.doubleClick,
    this.holdKey,
    this.key,
    this.leftClick,
    this.leftClickDrag,
    this.leftMouseDown,
    this.leftMouseUp,
    this.middleClick,
    this.mouseMove,
    this.rightClick,
    this.screenshot,
    this.scroll,
    this.tripleClick,
    this.typeAction,
    this.wait,
    this.zoom,
  });

  /// Creates [ComputerToolsetConfigs] from JSON.
  factory ComputerToolsetConfigs.fromJson(Map<String, dynamic> json) {
    return ComputerToolsetConfigs(
      cursorPosition: json['cursor_position'] != null
          ? ToolsetMemberConfig.fromJson(
              json['cursor_position'] as Map<String, dynamic>,
            )
          : null,
      doubleClick: json['double_click'] != null
          ? ToolsetMemberConfig.fromJson(
              json['double_click'] as Map<String, dynamic>,
            )
          : null,
      holdKey: json['hold_key'] != null
          ? ToolsetMemberConfig.fromJson(
              json['hold_key'] as Map<String, dynamic>,
            )
          : null,
      key: json['key'] != null
          ? ToolsetMemberConfig.fromJson(json['key'] as Map<String, dynamic>)
          : null,
      leftClick: json['left_click'] != null
          ? ToolsetMemberConfig.fromJson(
              json['left_click'] as Map<String, dynamic>,
            )
          : null,
      leftClickDrag: json['left_click_drag'] != null
          ? ToolsetMemberConfig.fromJson(
              json['left_click_drag'] as Map<String, dynamic>,
            )
          : null,
      leftMouseDown: json['left_mouse_down'] != null
          ? ToolsetMemberConfig.fromJson(
              json['left_mouse_down'] as Map<String, dynamic>,
            )
          : null,
      leftMouseUp: json['left_mouse_up'] != null
          ? ToolsetMemberConfig.fromJson(
              json['left_mouse_up'] as Map<String, dynamic>,
            )
          : null,
      middleClick: json['middle_click'] != null
          ? ToolsetMemberConfig.fromJson(
              json['middle_click'] as Map<String, dynamic>,
            )
          : null,
      mouseMove: json['mouse_move'] != null
          ? ToolsetMemberConfig.fromJson(
              json['mouse_move'] as Map<String, dynamic>,
            )
          : null,
      rightClick: json['right_click'] != null
          ? ToolsetMemberConfig.fromJson(
              json['right_click'] as Map<String, dynamic>,
            )
          : null,
      screenshot: json['screenshot'] != null
          ? ToolsetMemberConfig.fromJson(
              json['screenshot'] as Map<String, dynamic>,
            )
          : null,
      scroll: json['scroll'] != null
          ? ToolsetMemberConfig.fromJson(json['scroll'] as Map<String, dynamic>)
          : null,
      tripleClick: json['triple_click'] != null
          ? ToolsetMemberConfig.fromJson(
              json['triple_click'] as Map<String, dynamic>,
            )
          : null,
      typeAction: json['type'] != null
          ? ToolsetMemberConfig.fromJson(json['type'] as Map<String, dynamic>)
          : null,
      wait: json['wait'] != null
          ? ToolsetMemberConfig.fromJson(json['wait'] as Map<String, dynamic>)
          : null,
      zoom: json['zoom'] != null
          ? ToolsetMemberConfig.fromJson(json['zoom'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (cursorPosition != null) 'cursor_position': cursorPosition!.toJson(),
    if (doubleClick != null) 'double_click': doubleClick!.toJson(),
    if (holdKey != null) 'hold_key': holdKey!.toJson(),
    if (key != null) 'key': key!.toJson(),
    if (leftClick != null) 'left_click': leftClick!.toJson(),
    if (leftClickDrag != null) 'left_click_drag': leftClickDrag!.toJson(),
    if (leftMouseDown != null) 'left_mouse_down': leftMouseDown!.toJson(),
    if (leftMouseUp != null) 'left_mouse_up': leftMouseUp!.toJson(),
    if (middleClick != null) 'middle_click': middleClick!.toJson(),
    if (mouseMove != null) 'mouse_move': mouseMove!.toJson(),
    if (rightClick != null) 'right_click': rightClick!.toJson(),
    if (screenshot != null) 'screenshot': screenshot!.toJson(),
    if (scroll != null) 'scroll': scroll!.toJson(),
    if (tripleClick != null) 'triple_click': tripleClick!.toJson(),
    if (typeAction != null) 'type': typeAction!.toJson(),
    if (wait != null) 'wait': wait!.toJson(),
    if (zoom != null) 'zoom': zoom!.toJson(),
  };

  /// Creates a copy with replaced values.
  ComputerToolsetConfigs copyWith({
    Object? cursorPosition = unsetCopyWithValue,
    Object? doubleClick = unsetCopyWithValue,
    Object? holdKey = unsetCopyWithValue,
    Object? key = unsetCopyWithValue,
    Object? leftClick = unsetCopyWithValue,
    Object? leftClickDrag = unsetCopyWithValue,
    Object? leftMouseDown = unsetCopyWithValue,
    Object? leftMouseUp = unsetCopyWithValue,
    Object? middleClick = unsetCopyWithValue,
    Object? mouseMove = unsetCopyWithValue,
    Object? rightClick = unsetCopyWithValue,
    Object? screenshot = unsetCopyWithValue,
    Object? scroll = unsetCopyWithValue,
    Object? tripleClick = unsetCopyWithValue,
    Object? typeAction = unsetCopyWithValue,
    Object? wait = unsetCopyWithValue,
    Object? zoom = unsetCopyWithValue,
  }) {
    return ComputerToolsetConfigs(
      cursorPosition: cursorPosition == unsetCopyWithValue
          ? this.cursorPosition
          : cursorPosition as ToolsetMemberConfig?,
      doubleClick: doubleClick == unsetCopyWithValue
          ? this.doubleClick
          : doubleClick as ToolsetMemberConfig?,
      holdKey: holdKey == unsetCopyWithValue
          ? this.holdKey
          : holdKey as ToolsetMemberConfig?,
      key: key == unsetCopyWithValue ? this.key : key as ToolsetMemberConfig?,
      leftClick: leftClick == unsetCopyWithValue
          ? this.leftClick
          : leftClick as ToolsetMemberConfig?,
      leftClickDrag: leftClickDrag == unsetCopyWithValue
          ? this.leftClickDrag
          : leftClickDrag as ToolsetMemberConfig?,
      leftMouseDown: leftMouseDown == unsetCopyWithValue
          ? this.leftMouseDown
          : leftMouseDown as ToolsetMemberConfig?,
      leftMouseUp: leftMouseUp == unsetCopyWithValue
          ? this.leftMouseUp
          : leftMouseUp as ToolsetMemberConfig?,
      middleClick: middleClick == unsetCopyWithValue
          ? this.middleClick
          : middleClick as ToolsetMemberConfig?,
      mouseMove: mouseMove == unsetCopyWithValue
          ? this.mouseMove
          : mouseMove as ToolsetMemberConfig?,
      rightClick: rightClick == unsetCopyWithValue
          ? this.rightClick
          : rightClick as ToolsetMemberConfig?,
      screenshot: screenshot == unsetCopyWithValue
          ? this.screenshot
          : screenshot as ToolsetMemberConfig?,
      scroll: scroll == unsetCopyWithValue
          ? this.scroll
          : scroll as ToolsetMemberConfig?,
      tripleClick: tripleClick == unsetCopyWithValue
          ? this.tripleClick
          : tripleClick as ToolsetMemberConfig?,
      typeAction: typeAction == unsetCopyWithValue
          ? this.typeAction
          : typeAction as ToolsetMemberConfig?,
      wait: wait == unsetCopyWithValue
          ? this.wait
          : wait as ToolsetMemberConfig?,
      zoom: zoom == unsetCopyWithValue
          ? this.zoom
          : zoom as ToolsetMemberConfig?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComputerToolsetConfigs &&
          runtimeType == other.runtimeType &&
          cursorPosition == other.cursorPosition &&
          doubleClick == other.doubleClick &&
          holdKey == other.holdKey &&
          key == other.key &&
          leftClick == other.leftClick &&
          leftClickDrag == other.leftClickDrag &&
          leftMouseDown == other.leftMouseDown &&
          leftMouseUp == other.leftMouseUp &&
          middleClick == other.middleClick &&
          mouseMove == other.mouseMove &&
          rightClick == other.rightClick &&
          screenshot == other.screenshot &&
          scroll == other.scroll &&
          tripleClick == other.tripleClick &&
          typeAction == other.typeAction &&
          wait == other.wait &&
          zoom == other.zoom;

  @override
  int get hashCode => Object.hashAll([
    cursorPosition,
    doubleClick,
    holdKey,
    key,
    leftClick,
    leftClickDrag,
    leftMouseDown,
    leftMouseUp,
    middleClick,
    mouseMove,
    rightClick,
    screenshot,
    scroll,
    tripleClick,
    typeAction,
    wait,
    zoom,
  ]);

  @override
  String toString() =>
      'ComputerToolsetConfigs(cursorPosition: $cursorPosition, doubleClick: $doubleClick, holdKey: $holdKey, key: $key, leftClick: $leftClick, leftClickDrag: $leftClickDrag, leftMouseDown: $leftMouseDown, leftMouseUp: $leftMouseUp, middleClick: $middleClick, mouseMove: $mouseMove, rightClick: $rightClick, screenshot: $screenshot, scroll: $scroll, tripleClick: $tripleClick, typeAction: $typeAction, wait: $wait, zoom: $zoom)';
}

/// Per-member configuration for `browser_toolset_20260801`: one optional
/// field per member tool, keyed by the member name (the same name the
/// member's `tool_use` blocks carry). Every member is an accepted key, and
/// a member's defaults apply wherever its key is absent. The `typeAction`
/// field maps to the wire key `type` (the `type` member action, renamed in
/// Dart to avoid clashing with the class's own notion of a type).
@immutable
class BrowserToolsetConfigs {
  /// Per-member override for the `close_tab` member.
  final ToolsetMemberConfig? closeTab;

  /// Per-member override for the `double_click` member.
  final ToolsetMemberConfig? doubleClick;

  /// Per-member override for the `file_upload` member.
  final ToolsetMemberConfig? fileUpload;

  /// Per-member override for the `find` member.
  final ToolsetMemberConfig? find;

  /// Per-member override for the `form_input` member.
  final ToolsetMemberConfig? formInput;

  /// Per-member override for the `get_page_text` member.
  final ToolsetMemberConfig? getPageText;

  /// Per-member override for the `hold_key` member.
  final ToolsetMemberConfig? holdKey;

  /// Per-member override for the `hover` member.
  final ToolsetMemberConfig? hover;

  /// Per-member override for the `javascript_exec` member.
  final ToolsetMemberConfig? javascriptExec;

  /// Per-member override for the `key` member.
  final ToolsetMemberConfig? key;

  /// Per-member override for the `left_click` member.
  final ToolsetMemberConfig? leftClick;

  /// Per-member override for the `left_click_drag` member.
  final ToolsetMemberConfig? leftClickDrag;

  /// Per-member override for the `left_mouse_down` member.
  final ToolsetMemberConfig? leftMouseDown;

  /// Per-member override for the `left_mouse_up` member.
  final ToolsetMemberConfig? leftMouseUp;

  /// Per-member override for the `list_tabs` member.
  final ToolsetMemberConfig? listTabs;

  /// Per-member override for the `middle_click` member.
  final ToolsetMemberConfig? middleClick;

  /// Per-member override for the `mouse_move` member.
  final ToolsetMemberConfig? mouseMove;

  /// Per-member override for the `navigate` member.
  final ToolsetMemberConfig? navigate;

  /// Per-member override for the `new_tab` member.
  final ToolsetMemberConfig? newTab;

  /// Per-member override for the `read_console` member.
  final ToolsetMemberConfig? readConsole;

  /// Per-member override for the `read_network` member.
  final ToolsetMemberConfig? readNetwork;

  /// Per-member override for the `read_page` member.
  final ToolsetMemberConfig? readPage;

  /// Per-member override for the `right_click` member.
  final ToolsetMemberConfig? rightClick;

  /// Per-member override for the `screenshot` member.
  final ToolsetMemberConfig? screenshot;

  /// Per-member override for the `scroll` member.
  final ToolsetMemberConfig? scroll;

  /// Per-member override for the `scroll_to` member.
  final ToolsetMemberConfig? scrollTo;

  /// Per-member override for the `switch_tab` member.
  final ToolsetMemberConfig? switchTab;

  /// Per-member override for the `triple_click` member.
  final ToolsetMemberConfig? tripleClick;

  /// Per-member override for the `type` `type` member (renamed to avoid clashing with Dart's `type` keyword/convention).
  final ToolsetMemberConfig? typeAction;

  /// Per-member override for the `wait` member.
  final ToolsetMemberConfig? wait;

  /// Per-member override for the `zoom` member.
  final ToolsetMemberConfig? zoom;

  /// Creates [BrowserToolsetConfigs].
  const BrowserToolsetConfigs({
    this.closeTab,
    this.doubleClick,
    this.fileUpload,
    this.find,
    this.formInput,
    this.getPageText,
    this.holdKey,
    this.hover,
    this.javascriptExec,
    this.key,
    this.leftClick,
    this.leftClickDrag,
    this.leftMouseDown,
    this.leftMouseUp,
    this.listTabs,
    this.middleClick,
    this.mouseMove,
    this.navigate,
    this.newTab,
    this.readConsole,
    this.readNetwork,
    this.readPage,
    this.rightClick,
    this.screenshot,
    this.scroll,
    this.scrollTo,
    this.switchTab,
    this.tripleClick,
    this.typeAction,
    this.wait,
    this.zoom,
  });

  /// Creates [BrowserToolsetConfigs] from JSON.
  factory BrowserToolsetConfigs.fromJson(Map<String, dynamic> json) {
    return BrowserToolsetConfigs(
      closeTab: json['close_tab'] != null
          ? ToolsetMemberConfig.fromJson(
              json['close_tab'] as Map<String, dynamic>,
            )
          : null,
      doubleClick: json['double_click'] != null
          ? ToolsetMemberConfig.fromJson(
              json['double_click'] as Map<String, dynamic>,
            )
          : null,
      fileUpload: json['file_upload'] != null
          ? ToolsetMemberConfig.fromJson(
              json['file_upload'] as Map<String, dynamic>,
            )
          : null,
      find: json['find'] != null
          ? ToolsetMemberConfig.fromJson(json['find'] as Map<String, dynamic>)
          : null,
      formInput: json['form_input'] != null
          ? ToolsetMemberConfig.fromJson(
              json['form_input'] as Map<String, dynamic>,
            )
          : null,
      getPageText: json['get_page_text'] != null
          ? ToolsetMemberConfig.fromJson(
              json['get_page_text'] as Map<String, dynamic>,
            )
          : null,
      holdKey: json['hold_key'] != null
          ? ToolsetMemberConfig.fromJson(
              json['hold_key'] as Map<String, dynamic>,
            )
          : null,
      hover: json['hover'] != null
          ? ToolsetMemberConfig.fromJson(json['hover'] as Map<String, dynamic>)
          : null,
      javascriptExec: json['javascript_exec'] != null
          ? ToolsetMemberConfig.fromJson(
              json['javascript_exec'] as Map<String, dynamic>,
            )
          : null,
      key: json['key'] != null
          ? ToolsetMemberConfig.fromJson(json['key'] as Map<String, dynamic>)
          : null,
      leftClick: json['left_click'] != null
          ? ToolsetMemberConfig.fromJson(
              json['left_click'] as Map<String, dynamic>,
            )
          : null,
      leftClickDrag: json['left_click_drag'] != null
          ? ToolsetMemberConfig.fromJson(
              json['left_click_drag'] as Map<String, dynamic>,
            )
          : null,
      leftMouseDown: json['left_mouse_down'] != null
          ? ToolsetMemberConfig.fromJson(
              json['left_mouse_down'] as Map<String, dynamic>,
            )
          : null,
      leftMouseUp: json['left_mouse_up'] != null
          ? ToolsetMemberConfig.fromJson(
              json['left_mouse_up'] as Map<String, dynamic>,
            )
          : null,
      listTabs: json['list_tabs'] != null
          ? ToolsetMemberConfig.fromJson(
              json['list_tabs'] as Map<String, dynamic>,
            )
          : null,
      middleClick: json['middle_click'] != null
          ? ToolsetMemberConfig.fromJson(
              json['middle_click'] as Map<String, dynamic>,
            )
          : null,
      mouseMove: json['mouse_move'] != null
          ? ToolsetMemberConfig.fromJson(
              json['mouse_move'] as Map<String, dynamic>,
            )
          : null,
      navigate: json['navigate'] != null
          ? ToolsetMemberConfig.fromJson(
              json['navigate'] as Map<String, dynamic>,
            )
          : null,
      newTab: json['new_tab'] != null
          ? ToolsetMemberConfig.fromJson(
              json['new_tab'] as Map<String, dynamic>,
            )
          : null,
      readConsole: json['read_console'] != null
          ? ToolsetMemberConfig.fromJson(
              json['read_console'] as Map<String, dynamic>,
            )
          : null,
      readNetwork: json['read_network'] != null
          ? ToolsetMemberConfig.fromJson(
              json['read_network'] as Map<String, dynamic>,
            )
          : null,
      readPage: json['read_page'] != null
          ? ToolsetMemberConfig.fromJson(
              json['read_page'] as Map<String, dynamic>,
            )
          : null,
      rightClick: json['right_click'] != null
          ? ToolsetMemberConfig.fromJson(
              json['right_click'] as Map<String, dynamic>,
            )
          : null,
      screenshot: json['screenshot'] != null
          ? ToolsetMemberConfig.fromJson(
              json['screenshot'] as Map<String, dynamic>,
            )
          : null,
      scroll: json['scroll'] != null
          ? ToolsetMemberConfig.fromJson(json['scroll'] as Map<String, dynamic>)
          : null,
      scrollTo: json['scroll_to'] != null
          ? ToolsetMemberConfig.fromJson(
              json['scroll_to'] as Map<String, dynamic>,
            )
          : null,
      switchTab: json['switch_tab'] != null
          ? ToolsetMemberConfig.fromJson(
              json['switch_tab'] as Map<String, dynamic>,
            )
          : null,
      tripleClick: json['triple_click'] != null
          ? ToolsetMemberConfig.fromJson(
              json['triple_click'] as Map<String, dynamic>,
            )
          : null,
      typeAction: json['type'] != null
          ? ToolsetMemberConfig.fromJson(json['type'] as Map<String, dynamic>)
          : null,
      wait: json['wait'] != null
          ? ToolsetMemberConfig.fromJson(json['wait'] as Map<String, dynamic>)
          : null,
      zoom: json['zoom'] != null
          ? ToolsetMemberConfig.fromJson(json['zoom'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (closeTab != null) 'close_tab': closeTab!.toJson(),
    if (doubleClick != null) 'double_click': doubleClick!.toJson(),
    if (fileUpload != null) 'file_upload': fileUpload!.toJson(),
    if (find != null) 'find': find!.toJson(),
    if (formInput != null) 'form_input': formInput!.toJson(),
    if (getPageText != null) 'get_page_text': getPageText!.toJson(),
    if (holdKey != null) 'hold_key': holdKey!.toJson(),
    if (hover != null) 'hover': hover!.toJson(),
    if (javascriptExec != null) 'javascript_exec': javascriptExec!.toJson(),
    if (key != null) 'key': key!.toJson(),
    if (leftClick != null) 'left_click': leftClick!.toJson(),
    if (leftClickDrag != null) 'left_click_drag': leftClickDrag!.toJson(),
    if (leftMouseDown != null) 'left_mouse_down': leftMouseDown!.toJson(),
    if (leftMouseUp != null) 'left_mouse_up': leftMouseUp!.toJson(),
    if (listTabs != null) 'list_tabs': listTabs!.toJson(),
    if (middleClick != null) 'middle_click': middleClick!.toJson(),
    if (mouseMove != null) 'mouse_move': mouseMove!.toJson(),
    if (navigate != null) 'navigate': navigate!.toJson(),
    if (newTab != null) 'new_tab': newTab!.toJson(),
    if (readConsole != null) 'read_console': readConsole!.toJson(),
    if (readNetwork != null) 'read_network': readNetwork!.toJson(),
    if (readPage != null) 'read_page': readPage!.toJson(),
    if (rightClick != null) 'right_click': rightClick!.toJson(),
    if (screenshot != null) 'screenshot': screenshot!.toJson(),
    if (scroll != null) 'scroll': scroll!.toJson(),
    if (scrollTo != null) 'scroll_to': scrollTo!.toJson(),
    if (switchTab != null) 'switch_tab': switchTab!.toJson(),
    if (tripleClick != null) 'triple_click': tripleClick!.toJson(),
    if (typeAction != null) 'type': typeAction!.toJson(),
    if (wait != null) 'wait': wait!.toJson(),
    if (zoom != null) 'zoom': zoom!.toJson(),
  };

  /// Creates a copy with replaced values.
  BrowserToolsetConfigs copyWith({
    Object? closeTab = unsetCopyWithValue,
    Object? doubleClick = unsetCopyWithValue,
    Object? fileUpload = unsetCopyWithValue,
    Object? find = unsetCopyWithValue,
    Object? formInput = unsetCopyWithValue,
    Object? getPageText = unsetCopyWithValue,
    Object? holdKey = unsetCopyWithValue,
    Object? hover = unsetCopyWithValue,
    Object? javascriptExec = unsetCopyWithValue,
    Object? key = unsetCopyWithValue,
    Object? leftClick = unsetCopyWithValue,
    Object? leftClickDrag = unsetCopyWithValue,
    Object? leftMouseDown = unsetCopyWithValue,
    Object? leftMouseUp = unsetCopyWithValue,
    Object? listTabs = unsetCopyWithValue,
    Object? middleClick = unsetCopyWithValue,
    Object? mouseMove = unsetCopyWithValue,
    Object? navigate = unsetCopyWithValue,
    Object? newTab = unsetCopyWithValue,
    Object? readConsole = unsetCopyWithValue,
    Object? readNetwork = unsetCopyWithValue,
    Object? readPage = unsetCopyWithValue,
    Object? rightClick = unsetCopyWithValue,
    Object? screenshot = unsetCopyWithValue,
    Object? scroll = unsetCopyWithValue,
    Object? scrollTo = unsetCopyWithValue,
    Object? switchTab = unsetCopyWithValue,
    Object? tripleClick = unsetCopyWithValue,
    Object? typeAction = unsetCopyWithValue,
    Object? wait = unsetCopyWithValue,
    Object? zoom = unsetCopyWithValue,
  }) {
    return BrowserToolsetConfigs(
      closeTab: closeTab == unsetCopyWithValue
          ? this.closeTab
          : closeTab as ToolsetMemberConfig?,
      doubleClick: doubleClick == unsetCopyWithValue
          ? this.doubleClick
          : doubleClick as ToolsetMemberConfig?,
      fileUpload: fileUpload == unsetCopyWithValue
          ? this.fileUpload
          : fileUpload as ToolsetMemberConfig?,
      find: find == unsetCopyWithValue
          ? this.find
          : find as ToolsetMemberConfig?,
      formInput: formInput == unsetCopyWithValue
          ? this.formInput
          : formInput as ToolsetMemberConfig?,
      getPageText: getPageText == unsetCopyWithValue
          ? this.getPageText
          : getPageText as ToolsetMemberConfig?,
      holdKey: holdKey == unsetCopyWithValue
          ? this.holdKey
          : holdKey as ToolsetMemberConfig?,
      hover: hover == unsetCopyWithValue
          ? this.hover
          : hover as ToolsetMemberConfig?,
      javascriptExec: javascriptExec == unsetCopyWithValue
          ? this.javascriptExec
          : javascriptExec as ToolsetMemberConfig?,
      key: key == unsetCopyWithValue ? this.key : key as ToolsetMemberConfig?,
      leftClick: leftClick == unsetCopyWithValue
          ? this.leftClick
          : leftClick as ToolsetMemberConfig?,
      leftClickDrag: leftClickDrag == unsetCopyWithValue
          ? this.leftClickDrag
          : leftClickDrag as ToolsetMemberConfig?,
      leftMouseDown: leftMouseDown == unsetCopyWithValue
          ? this.leftMouseDown
          : leftMouseDown as ToolsetMemberConfig?,
      leftMouseUp: leftMouseUp == unsetCopyWithValue
          ? this.leftMouseUp
          : leftMouseUp as ToolsetMemberConfig?,
      listTabs: listTabs == unsetCopyWithValue
          ? this.listTabs
          : listTabs as ToolsetMemberConfig?,
      middleClick: middleClick == unsetCopyWithValue
          ? this.middleClick
          : middleClick as ToolsetMemberConfig?,
      mouseMove: mouseMove == unsetCopyWithValue
          ? this.mouseMove
          : mouseMove as ToolsetMemberConfig?,
      navigate: navigate == unsetCopyWithValue
          ? this.navigate
          : navigate as ToolsetMemberConfig?,
      newTab: newTab == unsetCopyWithValue
          ? this.newTab
          : newTab as ToolsetMemberConfig?,
      readConsole: readConsole == unsetCopyWithValue
          ? this.readConsole
          : readConsole as ToolsetMemberConfig?,
      readNetwork: readNetwork == unsetCopyWithValue
          ? this.readNetwork
          : readNetwork as ToolsetMemberConfig?,
      readPage: readPage == unsetCopyWithValue
          ? this.readPage
          : readPage as ToolsetMemberConfig?,
      rightClick: rightClick == unsetCopyWithValue
          ? this.rightClick
          : rightClick as ToolsetMemberConfig?,
      screenshot: screenshot == unsetCopyWithValue
          ? this.screenshot
          : screenshot as ToolsetMemberConfig?,
      scroll: scroll == unsetCopyWithValue
          ? this.scroll
          : scroll as ToolsetMemberConfig?,
      scrollTo: scrollTo == unsetCopyWithValue
          ? this.scrollTo
          : scrollTo as ToolsetMemberConfig?,
      switchTab: switchTab == unsetCopyWithValue
          ? this.switchTab
          : switchTab as ToolsetMemberConfig?,
      tripleClick: tripleClick == unsetCopyWithValue
          ? this.tripleClick
          : tripleClick as ToolsetMemberConfig?,
      typeAction: typeAction == unsetCopyWithValue
          ? this.typeAction
          : typeAction as ToolsetMemberConfig?,
      wait: wait == unsetCopyWithValue
          ? this.wait
          : wait as ToolsetMemberConfig?,
      zoom: zoom == unsetCopyWithValue
          ? this.zoom
          : zoom as ToolsetMemberConfig?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BrowserToolsetConfigs &&
          runtimeType == other.runtimeType &&
          closeTab == other.closeTab &&
          doubleClick == other.doubleClick &&
          fileUpload == other.fileUpload &&
          find == other.find &&
          formInput == other.formInput &&
          getPageText == other.getPageText &&
          holdKey == other.holdKey &&
          hover == other.hover &&
          javascriptExec == other.javascriptExec &&
          key == other.key &&
          leftClick == other.leftClick &&
          leftClickDrag == other.leftClickDrag &&
          leftMouseDown == other.leftMouseDown &&
          leftMouseUp == other.leftMouseUp &&
          listTabs == other.listTabs &&
          middleClick == other.middleClick &&
          mouseMove == other.mouseMove &&
          navigate == other.navigate &&
          newTab == other.newTab &&
          readConsole == other.readConsole &&
          readNetwork == other.readNetwork &&
          readPage == other.readPage &&
          rightClick == other.rightClick &&
          screenshot == other.screenshot &&
          scroll == other.scroll &&
          scrollTo == other.scrollTo &&
          switchTab == other.switchTab &&
          tripleClick == other.tripleClick &&
          typeAction == other.typeAction &&
          wait == other.wait &&
          zoom == other.zoom;

  @override
  int get hashCode => Object.hashAll([
    closeTab,
    doubleClick,
    fileUpload,
    find,
    formInput,
    getPageText,
    holdKey,
    hover,
    javascriptExec,
    key,
    leftClick,
    leftClickDrag,
    leftMouseDown,
    leftMouseUp,
    listTabs,
    middleClick,
    mouseMove,
    navigate,
    newTab,
    readConsole,
    readNetwork,
    readPage,
    rightClick,
    screenshot,
    scroll,
    scrollTo,
    switchTab,
    tripleClick,
    typeAction,
    wait,
    zoom,
  ]);

  @override
  String toString() =>
      'BrowserToolsetConfigs(closeTab: $closeTab, doubleClick: $doubleClick, fileUpload: $fileUpload, find: $find, formInput: $formInput, getPageText: $getPageText, holdKey: $holdKey, hover: $hover, javascriptExec: $javascriptExec, key: $key, leftClick: $leftClick, leftClickDrag: $leftClickDrag, leftMouseDown: $leftMouseDown, leftMouseUp: $leftMouseUp, listTabs: $listTabs, middleClick: $middleClick, mouseMove: $mouseMove, navigate: $navigate, newTab: $newTab, readConsole: $readConsole, readNetwork: $readNetwork, readPage: $readPage, rightClick: $rightClick, screenshot: $screenshot, scroll: $scroll, scrollTo: $scrollTo, switchTab: $switchTab, tripleClick: $tripleClick, typeAction: $typeAction, wait: $wait, zoom: $zoom)';
}
