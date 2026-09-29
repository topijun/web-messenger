import 'package:flutter/material.dart';
import 'package:mobile_messenger/features/chats/application/chat_controller.dart';

/// Form to create a group chat with the current user as admin.
class NewGroupScreen extends StatefulWidget {
  /// Creates a [NewGroupScreen].
  const NewGroupScreen({super.key, required this.controller});

  final ChatController controller;

  @override
  State<NewGroupScreen> createState() => _NewGroupScreenState();
}

class _NewGroupScreenState extends State<NewGroupScreen> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final created = await widget.controller.createGroup(_nameController.text);
    if (!mounted) {
      return;
    }
    if (created) {
      Navigator.of(context).pop(true);
      return;
    }
    final message = widget.controller.errorMessage;
    if (message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New group')),
      body: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  key: const Key('groupName'),
                  controller: _nameController,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Group name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  key: const Key('createGroup'),
                  onPressed: widget.controller.actionBusy ? null : _create,
                  child: const Text('Create group'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
