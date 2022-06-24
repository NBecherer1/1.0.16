import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../models/FinampModels.dart';
import '../../services/FinampSettingsHelper.dart';

class HideTabToggle extends StatelessWidget {
  const HideTabToggle({
    Key? key,
    required this.tabContentType,
  }) : super(key: key);

  final TabContentType tabContentType;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<FinampSettings>>(
      valueListenable: FinampSettingsHelper.finampSettingsListener,
      builder: (_, box, __) {
        return SwitchListTile(
          title: Text('Show ${tabContentType.humanReadableName}'),
          // This should never be null, but it gets set to true if it is.
          value: FinampSettingsHelper.finampSettings.showTabs[tabContentType] ??
              true,
          onChanged: (value) =>
              FinampSettingsHelper.setShowTab(tabContentType, value),
        );
      },
    );
  }
}
