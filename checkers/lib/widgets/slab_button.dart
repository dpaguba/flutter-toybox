import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/sheet.dart';

/// A button as a typeset slab: a bold word across the full width of the
/// page.
///
/// [filled] prints the slab in ink and knocks the word out in paper,
/// otherwise it leaves the word in ink inside a frame. The height is never
/// less than a finger's width, whatever the text size.
class SlabButton extends StatelessWidget {
  const SlabButton({
    super.key,
    required this.label,
    required this.onTap,
    this.filled = true,
    this.footer = false,
  });

  /// The word on the slab.
  final String label;

  /// What to do on a tap.
  final VoidCallback onTap;

  /// Whether the slab is filled with ink.
  final bool filled;

  /// Whether the slab sits as the page's footer, flush with the bottom
  /// edge of the screen.
  final bool footer;

  @override
  Widget build(BuildContext context) {
    final Sheet sheet = Sheet.of(context);
    final TextTheme type = Theme.of(context).textTheme;
    return CupertinoButton(
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.zero,
      minSize: touchFloor,
      onPressed: onTap,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: touchFloor + 12),
        alignment: Alignment.center,
        padding: EdgeInsets.fromLTRB(
          16,
          14,
          16,
          14 + (footer ? MediaQuery.of(context).viewPadding.bottom : 0),
        ),
        decoration: BoxDecoration(
          color: filled ? sheet.mark : sheet.ground,
          border: Border.all(color: sheet.mark, width: heavyRule / 2),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: type.titleLarge?.copyWith(
            color: filled ? sheet.ground : sheet.mark,
          ),
        ),
      ),
    );
  }
}
