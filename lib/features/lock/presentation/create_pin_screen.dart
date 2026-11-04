import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart' hide LockState;
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/lock/blocs/lock_bloc/lock_bloc.dart';
import 'package:tabibu/features/lock/blocs/lock_bloc/lock_event.dart';
import 'package:tabibu/features/lock/blocs/lock_bloc/lock_state.dart';
import 'package:tabibu/features/lock/presentation/widgets/pin_pad.dart';
import 'package:tabibu/l10n/l10n.dart';

/// Create / confirm a four-digit PIN. Two steps on one screen.
class CreatePinScreen extends StatefulWidget {
  const CreatePinScreen({required this.role, super.key});

  final Role role;

  @override
  State<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<CreatePinScreen> {
  String? _first;
  var _mismatch = false;

  String _body(AppLocalizations l10n) => switch (widget.role) {
    .patient => l10n.appLockCreatePatient,
    .doctor => l10n.appLockCreateDoctor,
    .pathologist => l10n.appLockCreatePathologist,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final confirming = _first != null;
    return BlocListener<LockBloc, LockState>(
      listenWhen: (_, current) =>
          current is LockPinCreateSuccess ||
          current is LockPinMismatch ||
          current is LockWriteFailure,
      listener: (context, state) {
        if (state is LockPinCreateSuccess) {
          context.pop();
          return;
        }
        if (state is LockPinMismatch) {
          setState(() {
            _first = null;
            _mismatch = true;
          });
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenMargin,
                  AppSpacing.md,
                  AppSpacing.screenMargin,
                  0,
                ),
                child: TopBar(
                  title: confirming ? l10n.appLockConfirm : l10n.appLockCreate,
                  backLabel: l10n.commonBack,
                  onBack: context.pop,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.screenMargin),
                  child: Column(
                    children: [
                      Text(
                        confirming ? l10n.appLockConfirmBody : _body(l10n),
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: .center,
                      ),
                      if (!confirming) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          l10n.appLockAvoid,
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: .center,
                        ),
                      ],
                      const Spacer(),
                      PinEntry(
                        hasError: _mismatch,
                        errorLabel: _mismatch ? l10n.appLockMismatch : null,
                        onComplete: (pin) {
                          if (_first == null) {
                            setState(() {
                              _first = pin;
                              _mismatch = false;
                            });
                            return;
                          }
                          context.read<LockBloc>().add(
                            LockPinCreateRequested(
                              pin: _first!,
                              confirmPin: pin,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        l10n.appLockStaysOnPhone,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: .center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
