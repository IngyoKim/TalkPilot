import 'package:flutter/material.dart';
import 'package:talk_pilot/src/components/toast_message.dart';
import 'package:talk_pilot/src/services/text_extract/text_extract_service.dart';

class ScriptUploadButton extends StatelessWidget {
  final bool isLoading;
  final String projectId;
  final void Function(bool) setLoading;
  final BuildContext context;
  final bool mounted;

  const ScriptUploadButton({
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
      onPressed:
          isLoading
              ? null
              : () => _handleUpload(
                projectId: projectId,
                setLoading: setLoading,
                showMessage: _showMessage,
                confirmDialog: _showConfirmDialog,
              ),
    );
  }

  void _showMessage(String msg) {
    if (!mounted) return;
    ToastMessage.show(msg);
  }

  Future<bool> _showConfirmDialog(String title, String content) async {
    if (!mounted) return false;
    return await showDialog<bool>(
          context: context,
          builder:
              (dialogContext) => AlertDialog(
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
        ) ??
        false;
  }

  Future<void> _handleUpload({
    required String projectId,
    required void Function(bool) setLoading,
    required void Function(String) showMessage,
    required Future<bool> Function(String, String) confirmDialog,
  }) async {
    await pickAndExtractScriptText(
      projectId: projectId,
      setLoading: setLoading,
      showMessage: showMessage,
      confirmDialog: confirmDialog,
    );
  }
}
