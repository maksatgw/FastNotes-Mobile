import 'package:fastnotes_flutter/core/utils/dialog_utils.dart';
import 'package:fastnotes_flutter/data/models/note_model.dart';
import 'package:fastnotes_flutter/presentation/home/home_provider.dart';
import 'package:fastnotes_flutter/presentation/note/note_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class NoteDetailScreenView extends StatefulWidget {
  const NoteDetailScreenView({super.key, required this.note});
  final NoteModel note;

  @override
  State<NoteDetailScreenView> createState() => _NoteDetailScreenViewState();
}

class _NoteDetailScreenViewState extends State<NoteDetailScreenView> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.note.title ?? '';
    _contentController.text = widget.note.content ?? '';
  }

  Future<void> _deleteNote() async {
    DialogUtils.showLoadingDialog(context);
    await context.read<NoteProvider>().deleteNote(widget.note.id!);
    if (context.mounted) {
      Provider.of<HomeProvider>(context, listen: false).getNotesInit();
      DialogUtils.hideLoadingDialog(context);
      GoRouter.of(context).go('/home');
    }
  }

  Future<void> _updateNote() async {
    DialogUtils.showLoadingDialog(context);
    await context.read<NoteProvider>().updateNote(
      widget.note.id!,
      _titleController.text,
      _contentController.text,
    );
    if (context.mounted) {
      Provider.of<HomeProvider>(context, listen: false).getNotesInit();
      DialogUtils.hideLoadingDialog(context);
      GoRouter.of(context).go('/home');
    }
  }

  Future<void> _clearNote() async {
    _titleController.clear();
    _contentController.clear();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Not Detayı"),
        actions: [
          TextButton(
            onPressed: () {
              if (_titleController.text.isEmpty ||
                  _contentController.text.isEmpty) {
                return;
              }
              _updateNote();
            },
            child: Text(
              "Kaydet",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
      body: Consumer<NoteProvider>(
        builder: (context, provider, child) {
          if (provider.hasError) {
            return Center(child: Text(provider.errorMessage ?? ''));
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Not Başlığı',
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                  maxLines: 1,
                ),
                Expanded(
                  child: TextField(
                    controller: _contentController,
                    style: Theme.of(context).textTheme.bodyMedium,
                    decoration: const InputDecoration(
                      hintText: 'Not İçeriği',
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                    maxLines: 20,
                  ),
                ),
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: _deleteNote,
                      child: Text(
                        "Sil",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.red,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _clearNote,
                      child: Text(
                        "Temizle",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
