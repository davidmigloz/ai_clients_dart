/// Shared opt-in WebSocket recovery configuration and delivery reports.
///
/// Existing Responses names remain compatible aliases. Voice connections retain
/// pending frames for explicit reconciliation; socket reopening never restores
/// application state or proves delivery of an attempted write.
library;

import 'responses/responses_recovering_websocket.dart';
import 'responses/responses_recovery.dart';

/// Shared ReconnectOptions contract for explicitly enabled socket recovery.
typedef WebSocketReconnectOptions = ResponsesReconnectOptions;

/// Shared ReconnectPreparation contract for explicitly enabled socket recovery.
typedef WebSocketReconnectPreparation = ResponsesReconnectPreparation;

/// Shared ReconnectContext contract for explicitly enabled socket recovery.
typedef WebSocketReconnectContext = ResponsesReconnectContext;

/// Shared ReconnectDecision contract for explicitly enabled socket recovery.
typedef WebSocketReconnectDecision = ResponsesReconnectDecision;

/// Shared UnsentMessage contract for explicitly enabled socket recovery.
typedef WebSocketUnsentMessage = ResponsesUnsentMessage;

/// Shared RecoveryEvent contract for explicitly enabled socket recovery.
typedef WebSocketRecoveryEvent = ResponsesRecoveryEvent;

/// Shared RecoveryReconnecting contract for explicitly enabled socket recovery.
typedef WebSocketRecoveryReconnecting = ResponsesRecoveryReconnecting;

/// Shared RecoveryReconnected contract for explicitly enabled socket recovery.
typedef WebSocketRecoveryReconnected = ResponsesRecoveryReconnected;

/// Shared RecoveryClosed contract for explicitly enabled socket recovery.
typedef WebSocketRecoveryClosed = ResponsesRecoveryClosed;

/// Shared RecoveryQueueOverflow contract for explicitly enabled socket recovery.
typedef WebSocketRecoveryQueueOverflow = ResponsesRecoveryQueueOverflow;

/// Shared RecoveryDeliveryUnknown contract for explicitly enabled socket recovery.
typedef WebSocketRecoveryDeliveryUnknown = ResponsesRecoveryDeliveryUnknown;

/// Shared RecoveryTransportError contract for explicitly enabled socket recovery.
typedef WebSocketRecoveryTransportError = ResponsesRecoveryTransportError;

/// Shared SendQueueOverflowException contract for explicitly enabled socket recovery.
typedef WebSocketSendQueueOverflowException =
    ResponsesSendQueueOverflowException;

/// Shared DeliveryUnknownException contract for explicitly enabled socket recovery.
typedef WebSocketDeliveryUnknownException = ResponsesDeliveryUnknownException;

/// Observable recovery state and explicit pending-frame operations.
typedef WebSocketRecovery = ResponsesRecovery;
