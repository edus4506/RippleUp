import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/constants/event_locations.dart';
import '../../../data/models/events/event.dart';
import '../../../viewModels/authentication/auth_viewModel.dart';
import '../../../viewModels/events/event_viewModel.dart';

class EditEventPage extends StatefulWidget {
  final Event event;

  const EditEventPage({super.key, required this.event});

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _maxUsersController;
  late final TextEditingController _startDateController;
  late final TextEditingController _endDateController;

  final ImagePicker _picker = ImagePicker();

  late DateTime? startDate;
  late DateTime? endDate;

  late List<int> selectedObjectives;

  /// New images picked from device (not yet uploaded)
  List<XFile> newImages = [];

  /// Existing image URLs from the event (kept unless removed)
  late List<String> existingImageUrls;

  late String? selectedCountry;
  late String? selectedDistrict;
  late String? selectedCity;

  @override
  void initState() {
    super.initState();

    final e = widget.event;

    _nameController = TextEditingController(text: e.title);
    _descriptionController = TextEditingController(text: e.description);
    _maxUsersController = TextEditingController(text: e.maxUsers.toString());

    startDate = e.startDate;
    endDate = e.endDate;

    _startDateController = TextEditingController(
      text: DateFormat('dd/MM/yyyy HH:mm').format(e.startDate),
    );
    _endDateController = TextEditingController(
      text: DateFormat('dd/MM/yyyy HH:mm').format(e.endDate),
    );

    selectedObjectives = List<int>.from(e.objectives);
    existingImageUrls = List<String>.from(e.imageUrls);

    selectedCountry = e.country;
    selectedDistrict = e.district;
    selectedCity = e.city;
  }

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
        newImages = images;
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

  void _saveEvent() async {
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

    if (maxUsers < widget.event.currentUsers) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Capacity cannot be less than current participants (${widget.event.currentUsers})',
          ),
        ),
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

    // Guard: only the owner can save
    if (currentUser.uid != widget.event.idCreator) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only the event owner can edit this event'),
        ),
      );
      return;
    }

    final vm = context.read<EventViewModel>();

    // Upload any newly picked images and merge with kept existing ones
    List<String> uploadedUrls = [];
    if (newImages.isNotEmpty) {
      uploadedUrls = await vm.uploadEventImages(
        eventId: widget.event.id,
        images: newImages,
      );
    }

    final allImageUrls = [...existingImageUrls, ...uploadedUrls];

    final updatedEvent = Event(
      id: widget.event.id,
      title: name,
      description: description,
      createdAt: widget.event.createdAt,
      startDate: startDate!,
      endDate: endDate!,
      maxUsers: maxUsers,
      currentUsers: widget.event.currentUsers,
      idCreator: widget.event.idCreator,
      objectives: selectedObjectives,
      country: selectedCountry!,
      district: selectedDistrict!,
      city: selectedCity!,
      imageUrls: allImageUrls,
      coverImageUrl: allImageUrls.isNotEmpty ? allImageUrls.first : null,
    );

    final success = await vm.updateEvent(updatedEvent);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event updated successfully!')),
      );
      // Add a small delay to allow the snackbar to be rendered before navigation
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        Navigator.pop(context, true);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.errorMessage ?? 'Failed to update event')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Total image count = existing kept + newly picked
    final totalImageCount = existingImageUrls.length + newImages.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Event')),

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
                  onPressed: _saveEvent,
                  child: const Text('Save'),
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
              maxLines: 3,
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
                itemCount: totalImageCount + 1,
                itemBuilder: (context, index) {
                  // "Add photo" button at the end
                  if (index == totalImageCount) {
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

                  // Existing network images
                  if (index < existingImageUrls.length) {
                    return Stack(
                      children: [
                        Container(
                          width: 110,
                          margin: const EdgeInsets.only(right: 10),
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Image.network(
                            existingImageUrls[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 14,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                existingImageUrls.removeAt(index);
                              });
                            },
                            child: const CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.red,
                              child: Icon(
                                Icons.close,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  // Newly picked local images
                  final newIndex = index - existingImageUrls.length;
                  return Container(
                    width: 110,
                    margin: const EdgeInsets.only(right: 10),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: kIsWeb
                        ? Image.network(
                            newImages[newIndex].path,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(newImages[newIndex].path),
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
                  _maxUsersController.text.isEmpty
                      ? '0'
                      : _maxUsersController.text,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Slider(
                    value:
                        (_maxUsersController.text.isEmpty
                                ? widget.event.currentUsers
                                : int.parse(_maxUsersController.text))
                            .toDouble(),
                    min: widget.event.currentUsers.toDouble(),
                    max: 50,
                    divisions: (50 - widget.event.currentUsers).clamp(1, 50),
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
              initialValue: selectedCountry,
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
                initialValue: selectedDistrict,
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
                initialValue: selectedCity,
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
