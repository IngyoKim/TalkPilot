import 'package:flutter/material.dart';
import 'package:talk_pilot/src/services/text_extract/text_extract_service.dart';

class ScriptUpload extends StatelessWidget {
  final bool isLoading;
  final String projectId;
  final void Function(bool) setLoading;
  final BuildContext context;
  final bool mounted;

  const ScriptUpload({
    super.key,
    required this.context,
    required this.isLoading,
    required this.projectId,
    required this.setLoading,
    required this.mounted,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.upload_file),
      tooltip: 'DOCX 또는 TXT 업로드',
      onPressed: isLoading
          ? null
          : () => pickAndExtractScriptText(
                projectId: projectId,
                setLoading: setLoading,
                showMessage: (msg) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(content: Text(msg)),
                  );
                },
                confirmDialog: (title, content) async {
                  if (!mounted) return false;
                  return await showDialog<bool>(
                    context: this.context,
                    builder: (dialogContext) => AlertDialog(
                      title: Text(title),
                      content: Text(content),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(false),
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(true),
                          child: const Text('확인'),
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}
