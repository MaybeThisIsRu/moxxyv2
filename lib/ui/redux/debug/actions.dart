class DebugSetEnabledAction {
  final bool preStart; // If the action was triggered by the preStart routine
  final bool enabled;

  const DebugSetEnabledAction(this.enabled, this.preStart);
}

class DebugSetIpAction {
  final String ip;

  const DebugSetIpAction(this.ip);
}

class DebugSetPortAction {
  final int port;

  const DebugSetPortAction(this.port);
}

class DebugSetPassphraseAction {
  final String passphrase;

  const DebugSetPassphraseAction(this.passphrase);
}
