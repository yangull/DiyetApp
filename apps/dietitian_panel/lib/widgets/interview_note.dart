import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// A question for the interview, kept out of the way: closed it is one quiet
/// line ("Görüşme notu"), open it is the paragraph. The demo is shown in live
/// interviews, so the text stays; it just no longer reads as leftover copy.
class InterviewNote extends StatefulWidget {
  const InterviewNote(this.text, {super.key});

  final String text;

  @override
  State<InterviewNote> createState() => _InterviewNoteState();
}

class _InterviewNoteState extends State<InterviewNote> {
  var _open = false;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          expanded: _open,
          child: EdgeButton(
            child: TextButton.icon(
              onPressed: () => setState(() => _open = !_open),
              icon: const Icon(AppIcons.info, size: 18),
              label: Text(_open ? 'Görüşme notunu gizle' : 'Görüşme notu'),
            ),
          ),
        ),
        if (_open)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                widget.text,
                style: text.bodySmall?.copyWith(
                  color: context.palette.textSecondary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
