import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:note_all/models/note.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:note_all/models/process_response.dart';
import 'package:note_all/preferences/shared_pref_controller.dart';
import 'package:note_all/provider/note_provider.dart';
import 'package:note_all/utils/helpers.dart';
import 'package:note_all/widgets/app_text_field.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({Key? key, this.note});

  final Note? note;

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> with Helpers {
  late TextEditingController _titleTextController;
  late TextEditingController _infoTextController;

  @override
  void initState() {
    super.initState();
    _titleTextController = TextEditingController(text: widget.note?.title);
    _infoTextController = TextEditingController(text: widget.note?.info);
  }

  @override
  void dispose() {
    _titleTextController.dispose();
    _infoTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.nunito(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              AppLocalizations.of(context)!.note_hint,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w300,
                color: Colors.black45,
              ),
            ),
            SizedBox(height: 20),
            AppTextField(
              textController: _titleTextController,
              hint: AppLocalizations.of(context)!.title,
              prefixIcon: Icons.title,
            ),
            SizedBox(height: 10),
            AppTextField(
              textController: _infoTextController,
              hint: AppLocalizations.of(context)!.info,
              prefixIcon: Icons.info,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async => await _performSave(),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        ),
      ),
    );
  }

  String get title {
    return isNewNote
        ? AppLocalizations.of(context)!.new_note
        : AppLocalizations.of(context)!.update_note;
  }

  bool get isNewNote => widget.note == null;

  Future<void> _performSave() async {
    if (_checkData()) {
      await _save();
    }
  }

  bool _checkData() {
    if (_titleTextController.text.isNotEmpty &&
        _infoTextController.text.isNotEmpty) {
      return true;
    }
    showSnackBar(context, message: 'Enter required data!', error: true);
    return false;
  }

  Future<void> _save() async {
    ProcessResponse processResponse = isNewNote
        ? await Provider.of<NoteProvider>(context, listen: false)
            .create(note: note)
        : await Provider.of<NoteProvider>(context, listen: false)
            .update(updatedNote: note);

    showSnackBar(context,
        message: processResponse.message, error: !processResponse.success);
    if (processResponse.success) {
      isNewNote ? clear() : Navigator.pop(context);
    }
  }

  Note get note {
    Note note = isNewNote ? Note() : widget.note!;
    note.title = _titleTextController.text;
    note.info = _infoTextController.text;
    note.userId =
        SharedPrefController().getValueFor<int>(key: PrefKeys.id.name)!;
    return note;
  }

  void clear() {
    _titleTextController.clear();
    _infoTextController.clear();
  }
}
