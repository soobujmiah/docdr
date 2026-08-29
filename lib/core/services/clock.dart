/// Injectable time source so document generation is reproducible.
///
/// ## Why this exists
///
/// Audit finding **DOC-08**: `DocDrElement.resolveValue` injected
/// `DateTime.now()` directly when a date element had no supplied value. That
/// makes generation non-deterministic, so golden-file and regression tests
/// are impossible and two runs over the same data produce different output.
///
/// ## Contract
///
/// * Element resolution accepts an explicit [DateTime] via its `now`
///   argument.
/// * **Generation entry points must supply it.** Batch and single-record
///   generation are the layers that own the clock.
/// * When a caller omits it, the value falls back to [docDrClock], which
///   defaults to [SystemDocumentClock]. Tests override [docDrClock] with a
///   [FixedDocumentClock] to pin time.
library;

/// A source of the current time.
abstract class DocumentClock {
  /// Returns the current time.
  DateTime now();
}

/// Clock backed by the device clock. Production default.
class SystemDocumentClock implements DocumentClock {
  /// Creates a system clock.
  const SystemDocumentClock();

  @override
  DateTime now() => DateTime.now();
}

/// Clock that always returns a fixed instant. Used by tests and by any
/// replay/audit workflow that must reproduce a document exactly.
class FixedDocumentClock implements DocumentClock {
  /// Creates a clock pinned to [fixedNow].
  const FixedDocumentClock(this.fixedNow);

  /// The instant returned by every [now] call.
  final DateTime fixedNow;

  @override
  DateTime now() => fixedNow;
}

/// Process-wide default clock.
///
/// Defaults to [SystemDocumentClock]. Test code may replace it with a
/// [FixedDocumentClock] and must restore it afterwards.
///
/// This exists as a convenience for call sites that cannot thread a clock
/// through (for example ad-hoc element inspection). It is **not** a licence
/// for generation code to be non-deterministic: generation entry points must
/// pass an explicit [DateTime].
DocumentClock docDrClock = const SystemDocumentClock();

/// Reads the current time from [docDrClock].
DateTime docDrNow() => docDrClock.now();
