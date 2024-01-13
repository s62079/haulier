import 'package:flutter/material.dart';
import 'package:haulier/data.dart';
import 'package:haulier/util.dart';
import 'package:haulier/view_schedule.dart';

class ScheduleListView extends StatefulWidget {
  const ScheduleListView({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ScheduleListViewState();
  }
}

class _ScheduleListViewState extends State<ScheduleListView> {
  Icon getIcon(String status) {
    IconData iconData;
    Color iconColor;
    switch (status) {
      case 'scheduled':
        iconData = Icons.event_available;
        iconColor = Colors.yellow;
      case 'started':
        iconData = Icons.local_shipping;
        iconColor = Colors.blue;
      case 'finished':
        iconData = Icons.done;
        iconColor = Colors.green;
      case 'cancelled':
        iconData = Icons.block;
        iconColor = Colors.red;
      default:
        iconData = Icons.question_mark;
        iconColor = Colors.grey;
    }
    return Icon(iconData, color: iconColor);
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Data.loadSchedules();
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final schedules = Data.schedules;
    var trucks = {};
    for (final truck in Data.trucks) {
      if (!trucks.containsKey(truck['id'])) {
        trucks[truck['id']] = truck['plate'];
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      itemCount: schedules.length,
      itemBuilder: (BuildContext context, int index) {
        final schedule = schedules[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: rounded30,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            shape: rounded30,
            leading: getIcon(schedule['status']),
            title: Text(
              '${trucks[schedule['truck']]} - ${yMdHm.format(DateTime.parse(schedule['dateStart']))}',
            ),
            subtitle: Text(
              'Details: ${(schedule['details'] != '') ? schedule['details'] : '-'}',
            ),
            // subtitle: Text(schedule.toString()),
            trailing: const Icon(Icons.arrow_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SchedulePage(editSchedule: schedule),
              ),
            ).then((value) async {
              await Data.loadSchedules();
              setState(() {});
            }),
          ),
        );
      },
    );
  }
}
