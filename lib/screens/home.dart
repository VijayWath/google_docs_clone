import 'package:docs_clone/colors.dart';
import 'package:docs_clone/common/widgets/loder.dart';
import 'package:docs_clone/models/document.dart';
import 'package:docs_clone/models/error_model.dart';
import 'package:docs_clone/repository/auth_repository.dart';
import 'package:docs_clone/repository/document_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void signOut(WidgetRef ref) {
    ref.read(authRepositoryProvider).signOut();
    ref.read(userProvider.notifier).update((state) => null);
  }

  void createDocument(BuildContext context, WidgetRef ref) async {
    String token = ref.read(userProvider)!.token;
    final navigator = Routemaster.of(context);
    final snackBar = ScaffoldMessenger.of(context);
    final errorModel =
        await ref.read(documentRepositoryProvider).createDocument(token);

    if (errorModel.data != null) {
      navigator.push('/document/${errorModel.data.id}');
    } else {
      snackBar.showSnackBar(
        SnackBar(
          content: Text(errorModel.error!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => createDocument(context, ref),
            icon: const Icon(Icons.add),
          ),
          IconButton(
              onPressed: () => signOut(ref),
              icon: const Icon(
                Icons.logout,
                color: kredColor,
              )),
        ],
      ),
      body: Center(
        child: FutureBuilder(
          future: ref
              .watch(documentRepositoryProvider)
              .getDocument(ref.watch(userProvider)!.token),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Loader();
            } else if (snapshot.data == null) {
              print("NO DATA IN DB or NULL SNAPSHOT");
              return const Text('No data available');
            } else if (snapshot.data!.data == null) {
              return Text('DATA is Empty');
            }
            return ListView.builder(
              itemCount: snapshot.data!.data.length,
              itemBuilder: (context, index) {
                DocumentModel document = snapshot.data!.data[index];
                return Card(
                  child: Center(
                    child: Text(
                      document.title,
                      style: const TextStyle(fontSize: 17),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
