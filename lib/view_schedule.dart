import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:haulier/data.dart';
import 'package:haulier/util.dart';
import 'package:haulier/view_location.dart';

class SchedulePage extends StatefulWidget {
  final Map<String, dynamic>? editSchedule;

  const SchedulePage({super.key, this.editSchedule});

  @override
  State<StatefulWidget> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map<String, dynamic> _body = {
    'user': Data.getCurrentUser()['id'],
    'truck': Data.trucks[0]['id'],
    'status': 'scheduled',
    'details': '',
    'dateStart': '',
    'dateEnd': '',
    'posStart': null,
    'posEnd': null,
    'posNow': null,
  };
  Map<String, dynamic> _response = {};
  String details = '',
      dateStart = 'Start Date',
      dateEnd = 'End Date',
      posStart = 'Start',
      posEnd = 'Destination',
      posNow = '';
  Future<String>? status;
  Timer? locationSpammer;

  String? getErrorMessage(String key) {
    String? message;
    if (_response.containsKey('data')) {
      Map<String, dynamic> data = _response['data'];
      message = (data.containsKey(key)) ? data[key]!['message'] : null;
    }
    return message;
  }

  Future<String> getPosName(String key) async {
    String location = '-';
    if (_body[key] != null) {
      List<dynamic> pos = _body[key]['coordinates'];
      List<Placemark> places = await placemarkFromCoordinates(
        pos[1] as double,
        pos[0] as double,
      );
      Map<String, dynamic> place = places[0].toJson();
      location = getFancyLocationName(place);
    }
    return location;
  }

  String getDate(String key, String alternative) {
    return ((_body[key] as String).isEmpty)
        ? alternative
        : getFancyDate(_body[key]);
  }

  Future<void> setPosNow() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if ([LocationPermission.always, LocationPermission.whileInUse]
        .contains(permission)) {
      Position current = await Geolocator.getCurrentPosition();
      _body['posNow'] = {
        'coordinates': [current.longitude, current.latitude]
      };
    } else {
      _body['posNow'] = _body['posStart'];
    }
    posNow = await getPosName('posNow');

    _response = await Data.updateSchedule(widget.editSchedule!['id'], _body);

    if (context.mounted) {
      setState(() {});
    }

    if (kDebugMode) {
      print('DEBUG: set position to ${_body['posNow']}');
    }
  }

  String getFancyDate(String date) {
    return yMdHm.format(DateTime.parse(date));
  }

  String getFancyLocationName(Map<String, dynamic> location) {
    String name = '';
    if (location['street'].contains(location['name'])) {
      name = location['street'];
    } else {
      name = location['name'] + ', ' + location['street'];
    }
    if (location['postalCode'] != null || location['postalCode'] != '') {
      name += ', ${location['postalCode']}';
    }
    if (location['administrativeArea'] != null ||
        location['administrativeArea'] != '') {
      name += ', ${location['administrativeArea']}';
    }
    if (location['country'] != null || location['country'] != '') {
      name += ', ${location['country']}';
    }
    return name;
  }

  Future<void> checkBody() async {
    if (widget.editSchedule == null) return;
    _body = Map.from(widget.editSchedule!);
    details = _body['details'];
    dateStart = getDate('dateStart', 'Start Date');
    dateEnd = getDate('dateEnd', 'End Date');
    posStart = await getPosName('posStart');
    posEnd = await getPosName('posEnd');
    posNow = await getPosName('posNow');
    setState(() {});
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      bool locationOn = await Geolocator.isLocationServiceEnabled();
      LocationPermission permission = await Geolocator.checkPermission();
      if (locationOn && permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      } else if (!locationOn ||
          permission == LocationPermission.deniedForever) {
        if (kDebugMode) {
          print('DEBUG: No location permission');
        }
      } else {
        checkBody();
        if (_body['status'] == 'started') {
          locationSpammer = Timer.periodic(
            const Duration(seconds: 10),
            (timer) => setPosNow(),
          );
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    locationSpammer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool add = widget.editSchedule == null;

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: getNavOverlay(Theme.of(context).canvasColor),
        title: Text((add) ? 'Add Schedule' : 'Schedule Info'),
        actions: [
          if (!add)
            IconButton(
              onPressed: () async {
                await Data.deleteSchedule(widget.editSchedule!['id']);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.delete),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                children: [
                  if (!add)
                    Flexible(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Status'),
                        value: _body['status'],
                        items: ['scheduled', 'started', 'finished', 'cancelled']
                            .map<DropdownMenuItem<String>>((e) =>
                                DropdownMenuItem<String>(
                                    value: e, child: Text(e)))
                            .toList(),
                        onChanged: (String? value) async {
                          _body['status'] = value!;
                          if (_body['status'] == 'started') {
                            _body['posNow'] = _body['posStart'];
                            locationSpammer = Timer.periodic(
                              const Duration(seconds: 10),
                              (timer) => setPosNow(),
                            );
                          } else {
                            locationSpammer?.cancel();
                            if (_body['status'] == 'finished') {
                              _body['posNow'] = _body['posEnd'];
                            } else {
                              _body['posNow'] = null;
                            }
                          }
                          posNow = await getPosName('posNow');
                          setState(() {});
                        },
                      ),
                    ),
                  Flexible(
                    child: DropdownButtonFormField<String>(
                      decoration:
                          const InputDecoration(labelText: 'Truck Plate No.'),
                      value: _body['truck'],
                      items: Data.trucks
                          .map<DropdownMenuItem<String>>((e) =>
                              DropdownMenuItem<String>(
                                  value: e['id'], child: Text(e['plate'])))
                          .toList(),
                      onChanged: (_body['status'] == 'scheduled')
                          ? (String? value) {
                              setState(() => _body['truck'] = value!);
                            }
                          : null,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Flexible(
                    child: TextFormField(
                      key: Key('start@$dateStart'),
                      decoration:
                          const InputDecoration(labelText: 'Start Date'),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      initialValue: dateStart,
                      readOnly: true,
                      onTap: (_body['status'] == 'scheduled')
                          ? () async {
                              DateTime? picked =
                                  DateTime.tryParse(_body['dateStart']);
                              final DateTime dateNow = DateTime.now();
                              DateTime? dateTime = await showDatePicker(
                                context: context,
                                initialDate: picked ?? dateNow,
                                firstDate: picked ?? dateNow,
                                lastDate:
                                    dateNow.copyWith(year: dateNow.year + 1),
                              );
                              if (dateTime != null && context.mounted) {
                                TimeOfDay timeNow = (picked != null)
                                    ? TimeOfDay.fromDateTime(picked)
                                    : TimeOfDay.now();
                                TimeOfDay? time = await showTimePicker(
                                  context: context,
                                  initialTime: timeNow,
                                );
                                if (time == null) return;
                                dateTime = dateTime.add(
                                  Duration(
                                    hours: time.hour,
                                    minutes: time.minute,
                                  ),
                                );
                              }
                              setState(() {
                                bool hasPicked = dateTime != null;
                                _body['dateStart'] =
                                    (hasPicked) ? dateTime.toString() : '';
                                dateStart = (hasPicked)
                                    ? yMdHm.format(dateTime)
                                    : 'Start Date';
                              });
                            }
                          : null,
                      validator: (value) {
                        String? error;
                        if (value == 'Start Date') {
                          error = 'No Date?';
                        } else {
                          error = getErrorMessage('dateStart');
                        }
                        return error;
                      },
                    ),
                  ),
                  Flexible(
                    child: TextFormField(
                      key: Key('end@$dateEnd'),
                      decoration: const InputDecoration(labelText: 'End Date'),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      initialValue: dateEnd,
                      readOnly: true,
                      onTap: (_body['status'] == 'scheduled')
                          ? () async {
                              DateTime? picked =
                                  DateTime.tryParse(_body['dateStart']);
                              final DateTime dateNow = DateTime.now();
                              DateTime? dateTime = await showDatePicker(
                                context: context,
                                initialDate: picked ?? dateNow,
                                firstDate: picked ?? dateNow,
                                lastDate:
                                    dateNow.copyWith(year: dateNow.year + 1),
                              );
                              if (dateTime != null && context.mounted) {
                                TimeOfDay timeNow = (picked != null)
                                    ? TimeOfDay.fromDateTime(picked)
                                    : TimeOfDay.now();
                                TimeOfDay? time = await showTimePicker(
                                  context: context,
                                  initialTime: timeNow,
                                );
                                if (time == null) return;
                                dateTime = dateTime.add(
                                  Duration(
                                    hours: time.hour,
                                    minutes: time.minute,
                                  ),
                                );
                              }
                              setState(() {
                                bool hasPicked = dateTime != null;
                                _body['dateEnd'] =
                                    (hasPicked) ? dateTime.toString() : '';
                                dateEnd = (hasPicked)
                                    ? yMdHm.format(dateTime)
                                    : 'End Date';
                              });
                            }
                          : null,
                      validator: (value) {
                        String? error;
                        if (value == 'End Date') {
                          error = 'No Date?';
                        } else {
                          error = getErrorMessage('dateEnd');
                        }
                        return error;
                      },
                    ),
                  )
                ],
              ),
              // https://stackoverflow.com/questions/45900387
              TextFormField(
                key: Key('posStart@$posStart'),
                decoration:
                    const InputDecoration(labelText: 'Starting Location'),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                initialValue: posStart,
                readOnly: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LocationPickerPage(
                      coordinates: _body['posStart'],
                      viewOnly: _body['status'] != 'scheduled',
                    ),
                  ),
                ).then((value) async {
                  if (value != null) {
                    _body['posStart'] = value;
                    posStart = await getPosName('posStart');
                    setState(() {});
                  }
                }),
                validator: (value) {
                  String? error;
                  if (value == 'Start') {
                    error = 'No location?';
                  } else {
                    error = getErrorMessage('posStart');
                  }
                  return error;
                },
              ),
              TextFormField(
                key: Key('posEnd@$posEnd'),
                decoration: const InputDecoration(labelText: 'Destination'),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                initialValue: posEnd,
                readOnly: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LocationPickerPage(
                      coordinates: _body['posEnd'],
                      viewOnly: _body['status'] != 'scheduled',
                    ),
                  ),
                ).then((value) async {
                  if (value != null) {
                    _body['posEnd'] = value;
                    posEnd = await getPosName('posEnd');
                    setState(() {});
                  }
                }),
                validator: (value) {
                  String? error;
                  if (value == 'Destination') {
                    error = 'No location?';
                  } else {
                    error = getErrorMessage('posEnd');
                  }
                  return error;
                },
              ),
              if (_body['status'] == 'started')
                TextFormField(
                  key: Key('posNow@$posNow'),
                  decoration:
                      const InputDecoration(labelText: 'Current Location'),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  initialValue: posNow,
                  readOnly: true,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LocationPickerPage(
                        coordinates: _body['posNow'],
                        viewOnly: true,
                      ),
                    ),
                  ).then((value) async {
                    if (value != null) {
                      _body['posNow'] = value;
                      setState(() {});
                    }
                  }),
                ),
              TextFormField(
                key: Key('start@$details'),
                decoration: const InputDecoration(labelText: 'Details'),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                initialValue: details,
                onSaved: (value) => _body['details'] = value!,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          _formKey.currentState!.save();
          _response = (add)
              ? await Data.addSchedule(_body)
              : await Data.updateSchedule(widget.editSchedule!['id'], _body);
          if (_formKey.currentState!.validate()) {
            await Data.loadSchedules();
            if (context.mounted) {
              Navigator.pop(context);
            }
          }
        },
        label: Text((add) ? 'Add' : 'Update'),
        icon: const Icon(Icons.check),
      ),
    );
  }
}
