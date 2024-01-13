import 'package:flutter/material.dart';
import 'package:haulier/view_truck.dart';
import 'package:haulier/widget_buttons.dart';

import 'data.dart';

class TruckListView extends StatefulWidget {
  final Function refresh;

  const TruckListView({super.key, required this.refresh});

  @override
  State<StatefulWidget> createState() => _TruckListViewState();
}

class _TruckListViewState extends State<TruckListView> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Data.loadTrucks();
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      margin: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ListView.builder(
              shrinkWrap: true,
              itemCount: Data.trucks.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    leading: const Icon(Icons.local_shipping),
                    title: Text(Data.trucks[index]['plate']),
                    trailing: const Icon(Icons.arrow_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            TruckPage(editTruck: Data.trucks[index]),
                      ),
                    ).then((value) async {
                      await Data.loadTrucks();
                      setState(() {});
                    }),
                  ),
                );
              },
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Divider(),
            ),
            AddTruckButton(refresh: widget.refresh),
          ],
        ),
      ),
    );
  }
}
