import 'package:flutter/material.dart';
import 'package:haulier/data.dart';
import 'package:haulier/util.dart';
import 'package:pie_chart/pie_chart.dart';

class TruckUtilView extends StatefulWidget {
  const TruckUtilView({super.key});

  @override
  State<StatefulWidget> createState() {
    return _TruckUtilViewState();
  }
}

class _TruckUtilViewState extends State<TruckUtilView> {
  late final theme = Theme.of(context);

  Map<String, dynamic> data = {
    'sumMiles': 1.0,
    'usrMiles': 0.0,
    'users': 0,
    'trucks': 0,
    'avgMilesPerDriver': 0,
    'sumMileageCapacity': 0,
  };

  ListTile createTile(String title, String value) {
    return ListTile(
      title: Column(
        children: [
          Text(title, style: theme.textTheme.headlineSmall),
          Text(value, style: theme.textTheme.displaySmall),
        ],
      ),
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      data = await Data.getTruckAvgUtils();
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: rounded30,
      margin: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Wrap(
            runSpacing: 16,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 64),
                child: PieChart(
                  totalValue: data['sumMiles'],
                  dataMap: {'User': data['usrMiles']},
                  baseChartColor: Colors.grey.withOpacity(0.1),
                  legendOptions: const LegendOptions(showLegends: false),
                ),
              ),
              createTile('Total Distance', '${data['sumMiles']} km'),
              createTile('Your Total Distance', '${data['usrMiles']} km'),
              createTile('Total No. of Drivers', data['users'].toString()),
              createTile(
                'Avg. Distance per Driver',
                '${data['avgMilesPerDriver']} km',
              ),
              createTile('Total No. of Trucks', data['trucks'].toString()),
              createTile(
                  'Mileage Capacity', '${data['sumMileageCapacity']} km'),
              // Text(data.toString()),
            ],
          ),
        ),
      ),
    );
  }
}
