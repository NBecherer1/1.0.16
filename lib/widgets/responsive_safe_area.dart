import 'package:flutter/material.dart';


typedef ResponsiveBuilder = Widget Function(BuildContext context);

class ResponsiveSafeArea extends StatelessWidget {

  const ResponsiveSafeArea({
    required ResponsiveBuilder builder, Key? key,
  }) : responsiveBuilder = builder, super(key: key);

  final ResponsiveBuilder responsiveBuilder;

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: const Color(0xFF00A4DC),
      color: Theme.of(context).colorScheme.primary,
      child: SafeArea(
        // bottom: Platform.isAndroid,
          child: responsiveBuilder(context)
      ),
    );
  }
}