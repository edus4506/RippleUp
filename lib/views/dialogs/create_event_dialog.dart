import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/models/event.dart';
import '../../viewModels/event_viewModel.dart';
import '../../viewModels/authViewModel/auth_viewModel.dart';

class CreateEventDialog extends StatefulWidget {
  final void Function(Event event) onCreate;
  final int nextId;

  const CreateEventDialog({
    super.key,
    required this.onCreate,
    required this.nextId,
  });

  @override
  State<CreateEventDialog> createState() => _CreateEventDialogState();
}

class _CreateEventDialogState extends State<CreateEventDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _maxUsersController = TextEditingController();

  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;

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
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<DateTime?> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date == null) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return null;

    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
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
        selectedCity == null ||
        startDate == null ||
        endDate == null) {
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

    if (endDate!.isBefore(startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date must be after start date')),
      );
      return;
    }

    final currentUser = context.read<AuthViewModel>().currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in')),
      );
      return;
    }

    final event = Event(
      id: '',
      title: name,
      description: description,

      createdAt: DateTime.now(),
      startDate: startDate!,
      endDate: endDate!,

      maxUsers: maxUsers,
      currentUsers: 1,
      eventStatus: 'PLANNING',
      idCreator: currentUser.uid,
      objectives: selectedObjectives,
      country: selectedCountry!,
      district: selectedDistrict!,
      city: selectedCity!,
    );

    await context.read<EventViewModel>().createEvent(event);

    if (!mounted) return;

    widget.onCreate(event);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text('Create Event', style: theme.textTheme.titleMedium),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Event name'),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: _maxUsersController,
                decoration: const InputDecoration(labelText: 'Max users'),
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 10),

              TextField(
                controller: _startDateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Start Date',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  final picked = await _pickDateTime();
                  if (picked != null) {
                    setState(() {
                      startDate = picked;
                      _startDateController.text =
                          DateFormat('dd/MM/yyyy HH:mm').format(picked);
                    });
                  }
                },
              ),

              const SizedBox(height: 10),

              TextField(
                controller: _endDateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'End Date',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  final picked = await _pickDateTime();
                  if (picked != null) {
                    setState(() {
                      endDate = picked;
                      _endDateController.text =
                          DateFormat('dd/MM/yyyy HH:mm').format(picked);
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              Align(
                alignment: Alignment.centerLeft,
                child: Text('Objectives', style: theme.textTheme.titleMedium),
              ),

              SizedBox(
                height: 150,
                child: ListView.builder(
                  itemCount: 17,
                  itemBuilder: (context, index) {
                    final objective = index + 1;

                    return CheckboxListTile(
                      dense: true,
                      title: Text('Objective $objective'),
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

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Country"),
                value: selectedCountry,
                items: countries.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() {
                  selectedCountry = v;
                  selectedDistrict = null;
                  selectedCity = null;
                }),
              ),

              if (selectedCountry != null)
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: "District"),
                  value: selectedDistrict,
                  items: districts[selectedCountry]!
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
                  onChanged: (v) => setState(() {
                    selectedDistrict = v;
                    selectedCity = null;
                  }),
                ),

              if (selectedDistrict != null)
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: "City"),
                  value: selectedCity,
                  items: cities[selectedDistrict]!
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => selectedCity = v),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: _createEvent, child: const Text('Create')),
      ],
    );
  }
}