import '../../services/JellyfinApiData.dart';
import '../../models/JellyfinModels.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../ViewIcon.dart';



class ViewListTile extends StatelessWidget {
  final BaseItemDto view;
  const ViewListTile({Key? key, required this.view}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final jellyfinApiData = GetIt.instance<JellyfinApiData>();
    if (view.name != null && view.name!.contains('Music')) {
      return const SizedBox.shrink();
    } else {
      return ListTile(
      leading: ViewIcon(
        collectionType: view.collectionType,
        color: jellyfinApiData.currentUser!.currentViewId == view.id
          ? Theme.of(context).colorScheme.secondary : null,
      ),
      title: Text(
        view.name ?? "Unknown Name",
        style: TextStyle(
          color: jellyfinApiData.currentUser!.currentViewId == view.id
            ? Theme.of(context).colorScheme.secondary : null,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        jellyfinApiData.setCurrentUserCurrentViewId(view.id);
      });
    }
  }
}
