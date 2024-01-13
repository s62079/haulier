import 'package:flutter/material.dart';
import 'package:haulier/util.dart';

import 'data.dart';

class TruckPage extends StatefulWidget {
  final Map<String, dynamic>? editTruck;

  const TruckPage({super.key, this.editTruck});

  @override
  State<StatefulWidget> createState() => _TruckPageState();
}

class _TruckPageState extends State<TruckPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _body = {
    'owner': Data.getCurrentUser()['id'],
    'plate': '',
  };
  Map<String, dynamic> _response = {};

  String? getErrorMessage(String key) {
    String? message;
    if (_response.containsKey('data')) {
      Map<String, dynamic> data = _response['data'];
      message = (data.containsKey(key)) ? data[key]!['message'] : null;
    }
    return message;
  }

  @override
  Widget build(BuildContext context) {
    bool register = widget.editTruck == null;

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: getNavOverlay(Theme.of(context).canvasColor),
        title: Text((register) ? 'Register Truck' : 'Truck Info'),
        actions: [
          if (!register)
            IconButton(
              onPressed: () async {
                await Data.deleteTruck(widget.editTruck!['id']);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.delete),
            ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Number Plate',
                  hintText: "Truck's number plate",
                ),
                initialValue: (register) ? '' : widget.editTruck!['plate'],
                validator: (value) {
                  String? error;
                  if (value == null || value.isEmpty) {
                    error = "Where is your truck's number plate?";
                  } else if (getErrorMessage('plate') != null) {
                    error = 'Truck with same number plate already registered.';
                  }
                  return error;
                },
                onSaved: (value) {
                  _body['plate'] = value;
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          _formKey.currentState!.save();
          _response = (register)
              ? await Data.addTruck(_body)
              : await Data.updateTruck(widget.editTruck!['id'], _body);
          if (_formKey.currentState!.validate()) {
            await Data.loadTrucks();
            if (context.mounted) {
              Navigator.pop(context);
            }
          }
        },
        label: Text((register) ? 'Register' : 'Update'),
        icon: const Icon(Icons.app_registration),
      ),
    );
  }
}
