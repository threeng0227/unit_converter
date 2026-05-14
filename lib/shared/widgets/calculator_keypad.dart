import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unit_converter_pro/core/theme/app_theme.dart';

class CalculatorKeypad extends StatelessWidget {
  final VoidCallback onClear;
  final VoidCallback onDelete;
  final VoidCallback onDot;
  final ValueChanged<String> onDigit;

  const CalculatorKeypad({
    super.key,
    required this.onClear,
    required this.onDelete,
    required this.onDot,
    required this.onDigit,
  });

  static const _rows = [
    [('7', _KeyType.number), ('8', _KeyType.number), ('9', _KeyType.number), ('C', _KeyType.action)],
    [('4', _KeyType.number), ('5', _KeyType.number), ('6', _KeyType.number), ('⌫', _KeyType.action)],
    [('1', _KeyType.number), ('2', _KeyType.number), ('3', _KeyType.number), ('.', _KeyType.secondary)],
    [('00', _KeyType.secondary), ('0', _KeyType.number), ('', _KeyType.empty), ('', _KeyType.empty)],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _rows.map((row) {
        return Expanded(
          child: Row(
            children: row.map((key) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: _KeyButton(
                    label: key.$1,
                    type: key.$2,
                    onTap: _handle,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  void _handle(String key) {
    switch (key) {
      case 'C':
        onClear();
      case '⌫':
        onDelete();
      case '.':
        onDot();
      case '':
        break;
      default:
        onDigit(key);
    }
  }
}

enum _KeyType { number, action, secondary, empty }

class _KeyButton extends StatefulWidget {
  final String label;
  final _KeyType type;
  final void Function(String) onTap;
  const _KeyButton(
      {required this.label, required this.type, required this.onTap});

  @override
  State<_KeyButton> createState() => _KeyButtonState();
}

class _KeyButtonState extends State<_KeyButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 80),
    reverseDuration: const Duration(milliseconds: 200),
    lowerBound: 0.92,
    upperBound: 1.0,
    value: 1.0,
  );

  bool get _isEmpty => widget.type == _KeyType.empty;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isEmpty) return const SizedBox.expand();

    return ScaleTransition(
      scale: _ctrl,
      child: GestureDetector(
        onTapDown: (_) {
          HapticFeedback.lightImpact();
          _ctrl.reverse();
        },
        onTapUp: (_) {
          _ctrl.forward();
          widget.onTap(widget.label);
        },
        onTapCancel: () => _ctrl.forward(),
        child: _KeyFace(label: widget.label, type: widget.type),
      ),
    );
  }
}

class _KeyFace extends StatelessWidget {
  final String label;
  final _KeyType type;
  const _KeyFace({required this.label, required this.type});

  Color get _bg => switch (type) {
        _KeyType.action => AppColors.primary.withValues(alpha: 0.15),
        _KeyType.secondary => AppColors.surface,
        _ => AppColors.card,
      };

  Color get _border => switch (type) {
        _KeyType.action => AppColors.primary.withValues(alpha: 0.30),
        _ => AppColors.cardBorder,
      };

  Color get _fg => switch (type) {
        _KeyType.action => AppColors.primary,
        _ => AppColors.textPrimary,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Center(
        child: label == '⌫'
            ? Icon(Icons.backspace_outlined, color: _fg, size: 20)
            : Text(
                label,
                style: TextStyle(
                  color: _fg,
                  fontSize: label.length > 1 ? 20 : 24,
                  fontWeight: type == _KeyType.action
                      ? FontWeight.w700
                      : FontWeight.w400,
                  letterSpacing: -0.5,
                ),
              ),
      ),
    );
  }
}
