import 'dart:async';

import 'package:docs_clone/colors.dart';
import 'package:docs_clone/constants.dart';
import 'package:docs_clone/models/document.dart';
import 'package:docs_clone/models/error_model.dart';
import 'package:docs_clone/repository/auth_repository.dart';
import 'package:docs_clone/repository/document_repository.dart';
import 'package:docs_clone/repository/socket_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class DocumentScreen extends ConsumerStatefulWidget {
  final String id;
  const DocumentScreen({required this.id, super.key});

  @override
  ConsumerState<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends ConsumerState<DocumentScreen> {
  quill.QuillController? _controller;
  ErrorModel? errorModel;
  TextEditingController titleController =
      TextEditingController(text: 'Untitled Document');
  SocketRepository socketRepository = SocketRepository();

  @override
  void initState() {
    // TODO: implement initState3
    socketRepository.joinRoom(widget.id);
    super.initState();
    fetchDocumentData();
    socketRepository.changeListener((data) {
      _controller!.compose(
          Delta.fromJson(data['delta']),
          _controller!.selection ?? const TextSelection.collapsed(offset: 0),
          quill.ChangeSource.remote);
    });
    Timer.periodic(
        const Duration(
          seconds: 2,
        ), (timer) {
      socketRepository.autoSave(<String, dynamic>{
        'delta': _controller!.document.toDelta(),
        'room': widget.id,
      });
    });
  }

  void fetchDocumentData() async {
    errorModel = await ref
        .read(documentRepositoryProvider)
        .getDocumentById(ref.read(userProvider)!.token, widget.id);

    if (errorModel!.data != null) {
      titleController.text = (errorModel!.data as DocumentModel).title;
      _controller = quill.QuillController(
        document: errorModel!.data.content.isEmpty
            ? quill.Document()
            : quill.Document.fromDelta(
                Delta.fromJson(errorModel!.data.content)),
        selection: const TextSelection.collapsed(offset: 0),
      );
      setState(() {});
    }
    _controller!.document.changes.listen((event) {
      if (event.source == quill.ChangeSource.local) {
        Map<String, dynamic> map = {'delta': event.change, 'room': widget.id};
        socketRepository.typing(map);
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    titleController.dispose();
    super.dispose();
  }

  void updateTitle(WidgetRef ref, String title) {
    ref.read(documentRepositoryProvider).updateTitle(
          title: title,
          id: widget.id,
          token: ref.read(userProvider)!.token,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: kGreyColor, width: 0.1),
            ),
          ),
        ),
        backgroundColor: KwhiteColor,
        elevation: 0,
        actions: [
          GestureDetector(
            onTap: () => {
              Clipboard.setData(
                ClipboardData(text: '$host/#/document/${widget.id}'),
              ).then((value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Link copied"),
                  ),
                );
              }),
            },
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: kBlueColor),
                onPressed: () {},
                icon: Icon(
                  Icons.lock,
                  size: 16,
                ),
                label: Text('share'),
              ),
            ),
          ),
        ],
        title: Padding(
          padding: EdgeInsets.symmetric(vertical: 9.0),
          child: Row(children: [
            Image.asset(
              'assets/images/docs-logo.png',
              height: 40,
            ),
            const SizedBox(
              width: 10,
            ),
            SizedBox(
              width: 200,
              child: TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kBlueColor)),
                  contentPadding: EdgeInsets.only(left: 10),
                ),
                onSubmitted: (value) => updateTitle(ref, value),
              ),
            )
          ]),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            quill.QuillToolbar.simple(
              configurations: quill.QuillSimpleToolbarConfigurations(
                controller: _controller!,
                sharedConfigurations: const quill.QuillSharedConfigurations(
                  locale: Locale('de'),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: SizedBox(
                width: 750,
                child: Card(
                  color: KwhiteColor,
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: quill.QuillEditor.basic(
                      configurations: quill.QuillEditorConfigurations(
                        controller: _controller!,
                        readOnly: false,
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
