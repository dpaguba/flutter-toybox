import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/sheet.dart';

/// A return to the previous page, in the navigation bar.
///
/// The arrow and the name of the page we came from are set in the page's
/// own ink, so the navigation bar does not stay the one place with
/// system colors.
class BackSlab extends StatelessWidget {
  const BackSlab({super.key, required this.previous});

  /// The name of the page a tap returns to.
  final String previous;

  @override
  Widget build(BuildContext context) {
    final Sheet sheet = Sheet.of(context);
    return CupertinoButton(
      key: const ValueKey('back'),
      padding: EdgeInsets.zero,
      minSize: touchFloor,
      onPressed: () => Navigator.of(context).maybePop(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.arrow_back_ios_new, size: 15, color: sheet.accent),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              previous,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: sheet.accent),
            ),
          ),
        ],
      ),
    );
  }
}
