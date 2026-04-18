import 'package:flutter/material.dart';
import '../../data/models/event.dart';
import '../../data/repositories/event_repository.dart';

class CreateEventPage extends StatefulWidget {
  final void Function(Event event) onCreate;
  final int nextId;

  const CreateEventPage({
    super.key,
    required this.onCreate,
    required this.nextId,
  });

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _maxUsersController = TextEditingController();

  List<int> selectedObjectives = [];

  String? selectedCountry;
  String? selectedDistrict;
  String? selectedCity;

  final List<String> countries = ["Portugal", "Spain"];

  final Map<String, List<String>> districts = {
    "Portugal": ["Porto", "Lisboa"],
    "Spain": ["Galicia"],
  };

  final Map<String, List<String>> cities = {
    "Porto": ["Porto", "Matosinhos"],
    "Lisboa": ["Lisboa"],
    "Galicia": ["Vigo"],
  };

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _maxUsersController.dispose();
    super.dispose();
  }

  void _createEvent() async {
    final theme = Theme.of(context);

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final maxUsers = int.tryParse(_maxUsersController.text.trim());

    if (name.isEmpty ||
        description.isEmpty ||
        maxUsers == null ||
        maxUsers <= 0 ||
        selectedObjectives.isEmpty ||
        selectedCountry == null ||
        selectedDistrict == null ||
        selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill in all fields correctly',
            style: theme.textTheme.bodyMedium,
          ),
        ),
      );
      return;
    }

    final event = Event(
      id: '',
      title: name,
      description: description,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(hours: 2)),
      maxUsers: maxUsers,
      currentUsers: 0,
      eventStatus: 'PLANNING',
      idCreator: 'CURRENT_USER_ID',
      objectives: selectedObjectives,
      country: selectedCountry!,
      district: selectedDistrict!,
      city: selectedCity!,
    );

    await EventRepository().createEvent(event);
    widget.onCreate(event);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(
        'Create Event',
        style: theme.textTheme.titleMedium,
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                key: const Key('create_name_field'),
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Event name'),
              ),

              const SizedBox(height: 10),

              TextField(
                key: const Key('create_description_field'),
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),

              const SizedBox(height: 10),

              TextField(
                key: const Key('create_max_users_field'),
                controller: _maxUsersController,
                decoration: const InputDecoration(labelText: 'Max users'),
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 16),

              /// Section title
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Objectives',
                  style: theme.textTheme.titleMedium,
                ),
              ),

              const SizedBox(height: 8),

              SizedBox(
                height: 180,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: 17,
                  itemBuilder: (context, index) {
                    final objective = index + 1;

                    return CheckboxListTile(
                      dense: true,
                      title: Text(
                        'Objective $objective',
                        style: theme.textTheme.bodyMedium,
                      ),
                      value: selectedObjectives.contains(objective),
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            selectedObjectives.add(objective);
                          } else {
                            selectedObjectives.remove(objective);
                          }
                        });
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Country"),
                initialValue: selectedCountry,
                items: countries.map((country) {
                  return DropdownMenuItem(
                    value: country,
                    child: Text(country, style: theme.textTheme.bodyMedium),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCountry = value;
                    selectedDistrict = null;
                    selectedCity = null;
                  });
                },
              ),

              const SizedBox(height: 10),

              if (selectedCountry != null)
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: "District"),
                  initialValue: selectedDistrict,
                  items: districts[selectedCountry]!.map((district) {
                    return DropdownMenuItem(
                      value: district,
                      child: Text(district, style: theme.textTheme.bodyMedium),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedDistrict = value;
                      selectedCity = null;
                    });
                  },
                ),

              const SizedBox(height: 10),

              if (selectedDistrict != null)
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: "City"),
                  initialValue: selectedCity,
                  items: cities[selectedDistrict]!.map((city) {
                    return DropdownMenuItem(
                      value: city,
                      child: Text(city, style: theme.textTheme.bodyMedium),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCity = value;
                    });
                  },
                ),
            ],
          ),
        ),
      ),

      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: theme.textTheme.labelLarge,
          ),
        ),

        ElevatedButton(
          key: const Key('confirm_create_event_button'),
          onPressed: _createEvent,
          child: const Text('Create'),
        ),
      ],
    );
  }
}