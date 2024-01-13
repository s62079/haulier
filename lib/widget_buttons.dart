import 'package:flutter/material.dart';
import 'package:haulier/view_schedule.dart';
import 'package:haulier/view_truck.dart';

class AddTruckButton extends StatelessWidget {
  final Function refresh;

  const AddTruckButton({super.key, required this.refresh});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const TruckPage()),
      ).then((_) => refresh()),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add),
          SizedBox(width: 4),
          Text('Register Truck'),
        ],
      ),
    );
  }
}

class AddScheduleButton extends StatelessWidget {
  final Function refresh;

  const AddScheduleButton({super.key, required this.refresh});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SchedulePage()),
      ).then((_) => refresh()),
      label: const Text('Schedule'),
      icon: const Icon(Icons.add),
    );
  }
}
