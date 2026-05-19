import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:t5/views/widgets/notification_dropdown.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/constants/event_locations.dart';
import '../../data/models/event.dart';

import '../../viewModels/authViewModel/auth_viewModel.dart';
import '../../viewModels/event_viewModel.dart';
import '../../viewModels/notification_viewModel.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _maxUsersController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  DateTime? startDate;
  DateTime? endDate;

  List<int> selectedObjectives = [];
  List<XFile> selectedImages = [];

  String? selectedCountry;
  String? selectedDistrict;
  String? selectedCity;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _maxUsersController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final images = await _picker.pickMultiImage();

    if (images.isNotEmpty) {
      setState(() {
        selectedImages = images;
      });
    }
  }

  Future<DateTime?> _pickDateTime() async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(2100),
    );

    if (date == null) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  void _createEvent() async {
    final now = DateTime.now();

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
        const SnackBar(content: Text('Please fill in all fields correctly')),
      );
      return;
    }

    if (startDate!.isBefore(now)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Start date must be in the future')),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('You must be logged in')));
      return;
    }

    final eventId = DateTime.now().millisecondsSinceEpoch.toString();

    final imageUrls = await context.read<EventViewModel>().uploadEventImages(
      eventId: eventId,
      images: selectedImages,
    );

    final event = Event(
      id: eventId,
      title: name,
      description: description,
      createdAt: DateTime.now(),
      startDate: startDate!,
      endDate: endDate!,
      maxUsers: maxUsers,
      currentUsers: 1,
      idCreator: currentUser.uid,
      objectives: selectedObjectives,
      country: selectedCountry!,
      district: selectedDistrict!,
      city: selectedCity!,
      imageUrls: imageUrls,
      coverImageUrl: imageUrls.isNotEmpty ? imageUrls.first : null,
    );

    await context.read<EventViewModel>().createEvent(event);
    await context.read<AppNotificationViewModel>().createNewEventNotification(
      event,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event created successfully!')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event')
      ),

      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 6),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: _createEvent,
                  child: const Text('Create'),
                ),
              ),
            ],
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
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

            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerLeft,
              child: Text('Event Photos', style: theme.textTheme.titleMedium),
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: selectedImages.length + 1,
                itemBuilder: (context, index) {
                  if (index == selectedImages.length) {
                    return GestureDetector(
                      onTap: _pickImages,
                      child: Container(
                        width: 110,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: const Icon(Icons.add_a_photo, size: 30),
                      ),
                    );
                  }

                  return Container(
                    width: 110,
                    margin: const EdgeInsets.only(right: 10),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: kIsWeb
                        ? Image.network(
                            selectedImages[index].path,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(selectedImages[index].path),
                            fit: BoxFit.cover,
                          ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerLeft,
              child: Text('Event Capacity', style: theme.textTheme.titleMedium),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Text(
                  '${_maxUsersController.text.isEmpty ? 0 : _maxUsersController.text}',
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Slider(
                    value:
                        (_maxUsersController.text.isEmpty
                                ? 0
                                : int.parse(_maxUsersController.text))
                            .toDouble(),
                    min: 0,
                    max: 50,
                    divisions: 50,
                    onChanged: (value) {
                      setState(() {
                        _maxUsersController.text = value.round().toString();
                      });
                    },
                  ),
                ),
              ],
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
                if (picked == null) return;

                if (picked.isBefore(DateTime.now())) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Start date must be in the future'),
                    ),
                  );
                  return;
                }

                setState(() {
                  startDate = picked;
                  _startDateController.text = DateFormat(
                    'dd/MM/yyyy HH:mm',
                  ).format(picked);
                });
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
                if (picked == null) return;

                if (startDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Select start date first')),
                  );
                  return;
                }

                if (picked.isBefore(startDate!)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('End date must be after start date'),
                    ),
                  );
                  return;
                }

                setState(() {
                  endDate = picked;
                  _endDateController.text = DateFormat(
                    'dd/MM/yyyy HH:mm',
                  ).format(picked);
                });
              },
            ),

            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Environmental Goals',
                style: theme.textTheme.titleMedium,
              ),
            ),

            const SizedBox(height: 10),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: 18,
              itemBuilder: (context, index) {
                final goal = index + 1;

                final isSelected = selectedObjectives.contains(goal);

                return GestureDetector(
                  onTap: goal == 18
                      ? null
                      : () {
                          setState(() {
                            if (isSelected) {
                              selectedObjectives.remove(goal);
                            } else {
                              selectedObjectives.add(goal);
                            }
                          });
                        },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: (isSelected && goal != 18)
                          ? Border.all(color: Colors.green, width: 3)
                          : null,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      'assets/objectives/goal$goal.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerLeft,
              child: Text('Location', style: theme.textTheme.titleMedium),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Country'),
              value: selectedCountry,
              menuMaxHeight: 300,
              isExpanded: true,
              items: eventCountries
                  .map(
                    (country) =>
                        DropdownMenuItem(value: country, child: Text(country)),
                  )
                  .toList(),
              onChanged: (value) => setState(() {
                selectedCountry = value;
                selectedDistrict = null;
                selectedCity = null;
              }),
            ),

            if (selectedCountry != null) ...[
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'District'),
                value: selectedDistrict,
                menuMaxHeight: 300,
                isExpanded: true,
                items: eventDistrictsByCountry[selectedCountry]!
                    .map(
                      (district) => DropdownMenuItem(
                        value: district,
                        child: Text(district),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() {
                  selectedDistrict = value;
                  selectedCity = null;
                }),
              ),
            ],

            if (selectedDistrict != null) ...[
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'City'),
                value: selectedCity,
                menuMaxHeight: 300,
                isExpanded: true,
                items: eventCitiesByDistrict[selectedDistrict]!
                    .map(
                      (city) =>
                          DropdownMenuItem(value: city, child: Text(city)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => selectedCity = value),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
