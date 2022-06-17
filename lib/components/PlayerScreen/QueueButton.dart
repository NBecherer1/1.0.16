import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:na0826/services/MusicPlayerBackgroundTask.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'QueueList.dart';



class QueueButton extends StatelessWidget {
  QueueButton({Key? key}) : super(key: key);

  final _audioHandler = GetIt.instance<MusicPlayerBackgroundTask>();
  void _selectedItem(BuildContext context, int item) {
    switch (item) {
      case 0: {
        _audioHandler.setSpeed(0.5);
        break;
      }
      case 1: {
        _audioHandler.setSpeed(0.6);
        break;
      }
      case 2: {
        _audioHandler.setSpeed(0.7);
        break;
      }
      case 3: {
        _audioHandler.setSpeed(0.8);
        break;
      }
      case 4: {
        _audioHandler.setSpeed(0.9);
        break;
      }
      case 5: {
        _audioHandler.setSpeed(1);
        break;
      }
      case 6: {
        _audioHandler.setSpeed(1.10);
        break;
      }
      case 7: {
        _audioHandler.setSpeed(1.20);
        break;
      }
      case 8: {
        _audioHandler.setSpeed(1.30);
        break;
      }
      case 9: {
        _audioHandler.setSpeed(1.40);
        break;
      }
      case 10: {
        _audioHandler.setSpeed(1.50);
        break;
      }
      case 11: {
        _audioHandler.setSpeed(2.00);
        break;
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        PopupMenuButton(
          icon: const Icon(MdiIcons.playSpeed),
          color: Colors.black,
          onSelected: (int item) => _selectedItem(context, item),
          itemBuilder: (context) => const [

            PopupMenuItem<int>(
              value: 0,
              child: Text("0.50x",
                style: TextStyle(color: Colors.white),
              ),
            ),

            PopupMenuItem<int>(
              value: 1,
              child: Text("0.60x",
                style: TextStyle(color: Colors.white),
              ),
            ),

            PopupMenuItem<int>(
              value: 2,
              child: Text("0.70x",
                style: TextStyle(color: Colors.white),
              ),
            ),

            PopupMenuItem<int>(
              value: 3,
              child: Text("0.80x",
                style: TextStyle(color: Colors.white),
              ),
            ),

            PopupMenuItem<int>(
              value: 4,
              child: Text("0.90x ",
                style: TextStyle(color: Colors.white),
              ),
            ),
            PopupMenuItem<int>(
              value: 5,
              child: Text("1x",
                style: TextStyle(color: Colors.white),
              ),
            ),
            PopupMenuItem<int>(
              value: 6,
              child: Text("1.10x",
                style: TextStyle(color: Colors.white),
              ),
            ),
            PopupMenuItem<int>(
              value: 7,
              child: Text("1.20x",
                style: TextStyle(color: Colors.white),
              ),
            ),
            PopupMenuItem<int>(
              value: 8,
              child: Text("1.30x",
                style: TextStyle(color: Colors.white),
              ),
            ),
            PopupMenuItem<int>(
              value: 9,
              child: Text("1.40x",
                style: TextStyle(color: Colors.white),
              ),
            ),
            PopupMenuItem<int>(
              value: 10,
              child: Text("1.50x",
                style: TextStyle(color: Colors.white),
              ),
            ),
            PopupMenuItem<int>(
              value: 11,
              child: Text("2.00x",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),

        IconButton(
          icon: const Icon(Icons.queue_music),
          onPressed: () {
            showModalBottomSheet(
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
              ),
              context: context,
              builder: (context) {
                return DraggableScrollableSheet(
                  expand: false,
                  builder: (context, scrollController) {
                    return QueueList(
                      scrollController: scrollController,
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}
