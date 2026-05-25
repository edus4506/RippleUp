import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/constants/event_locations.dart';
import '../../../data/models/events/event.dart';

import '../../../viewModels/authentication/auth_viewModel.dart';
import '../../../viewModels/events/event_viewModel.dart';
import '../../../viewModels/social/notification_viewModel.dart';
import '../../widgets/top_bar_tabs/top_bar.dart';

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
      setState(() => selectedImages.addAll(images));
    }
  }

  Future<DateTime?> _pickDateTime() async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF3E5F36),
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );

    if (date == null) return null;

    TimeOfDay? time = await showDialog<TimeOfDay>(
      context: context,
      builder: (context) => _WheelTimePicker(initial: TimeOfDay.now()),
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

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF3E5F36),
      ),
    ),
  );

  Widget _card(Widget child) => Card(
    color: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: child,
  );

  InputDecoration _inputDec(String label, {Widget? prefix}) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Colors.black54),
    filled: true,
    fillColor: Colors.white,
    prefixIcon: prefix,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF3E5F36), width: 1.5),
    ),
  );

  InputDecoration _dropDec(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF3E5F36), width: 1.5),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F2),
      appBar: TopBar(
        title: 'Create',
        leftWidget: _CircleButton(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 8),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF43A047),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side: const BorderSide(color: Color(0xFF43A047)),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF43A047),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: _createEvent,
                  child: const Text(
                    'Create Event',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel('Event Info'),
            _card(
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: _inputDec('Event name'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: _inputDec('Description'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            _sectionLabel('Event Photos'),
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo_outlined,
                              size: 28,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Add',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return Stack(
                    children: [
                      Container(
                        width: 110,
                        margin: const EdgeInsets.only(right: 10),
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
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
                      ),
                      Positioned(
                        top: 4,
                        right: 14,
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => selectedImages.removeAt(index)),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(3),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            _sectionLabel('Event Capacity'),
            Row(
              children: [
                Text(
                  '${_maxUsersController.text.isEmpty ? 0 : _maxUsersController.text}',
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFF3E5F36),
                      thumbColor: const Color(0xFF3E5F36),
                    ),
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
                        setState(
                          () => _maxUsersController.text = value
                              .round()
                              .toString(),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            _sectionLabel('Event Dates'),
            _card(
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    TextField(
                      controller: _startDateController,
                      readOnly: true,
                      decoration: _inputDec(
                        'Start Date & Time',
                        prefix: const Icon(
                          Icons.calendar_today_outlined,
                          color: Color(0xFF3E5F36),
                        ),
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
                      decoration: _inputDec(
                        'End Date & Time',
                        prefix: const Icon(
                          Icons.event_available_outlined,
                          color: Color(0xFF3E5F36),
                        ),
                      ),
                      onTap: () async {
                        if (startDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Select start date first'),
                            ),
                          );
                          return;
                        }
                        final picked = await _pickDateTime();
                        if (picked == null) return;
                        if (picked.isBefore(startDate!)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'End date must be after start date',
                              ),
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
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            _sectionLabel('Environmental Goals'),
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

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
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
                    child: Ink(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF3E5F36)
                              : Colors.grey.shade300,
                          width: isSelected ? 3 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(
                                    0xFF3E5F36,
                                  ).withValues(alpha: 0.25),
                                  blurRadius: 8,
                                ),
                              ]
                            : [],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              'assets/objectives/goal$goal.jpg',
                              fit: BoxFit.cover,
                            ),
                            if (isSelected)
                              Container(
                                color: Colors.black.withValues(alpha: 0.35),
                                child: const Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            _sectionLabel('Location'),
            DropdownButtonFormField<String>(
              decoration: _dropDec('Country'),
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
                decoration: _dropDec('District'),
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
                decoration: _dropDec('City'),
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

class _WheelTimePicker extends StatefulWidget {
  final TimeOfDay initial;
  const _WheelTimePicker({required this.initial});

  @override
  State<_WheelTimePicker> createState() => _WheelTimePickerState();
}

class _WheelTimePickerState extends State<_WheelTimePicker> {
  late int _hour;
  late int _minute;

  late FixedExtentScrollController _hourCtrl;
  late FixedExtentScrollController _minuteCtrl;

  @override
  void initState() {
    super.initState();
    _hour = widget.initial.hour;
    _minute = widget.initial.minute;
    _hourCtrl = FixedExtentScrollController(initialItem: _hour);
    _minuteCtrl = FixedExtentScrollController(initialItem: _minute);
  }

  @override
  void dispose() {
    _hourCtrl.dispose();
    _minuteCtrl.dispose();
    super.dispose();
  }

  Widget _wheel({
    required FixedExtentScrollController controller,
    required int itemCount,
    required String Function(int) label,
    required ValueChanged<int> onChanged,
  }) {
    return SizedBox(
      width: 72,
      height: 180,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 48,
        diameterRatio: 1.6,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: onChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: itemCount,
          builder: (context, index) {
            final isSelected =
                (controller.hasClients && controller.selectedItem == index) ||
                (!controller.hasClients &&
                    (label == ((i) => i.toString().padLeft(2, '0'))
                        ? index == _hour
                        : index == _minute));
            return Center(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: isSelected ? 34 : 24,
                  color: isSelected
                      ? const Color(0xFF3E5F36)
                      : Colors.grey.shade400,
                  fontWeight: FontWeight.w400,
                ),
                child: Text(label(index)),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF4F7F2),
          borderRadius: BorderRadius.circular(28),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              color: const Color(0xFF43A047),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircleButton(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.translate(
                        offset: const Offset(0, 2),
                        child: Transform.rotate(
                          angle: -1.57,
                          child: const Icon(
                            Icons.grass_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Pick Time',
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 38,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Transform.translate(
                        offset: const Offset(0, 2),
                        child: Transform.rotate(
                          angle: 1.57,
                          child: const Icon(
                            Icons.grass_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 52),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 48,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3E5F36).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF3E5F36).withValues(alpha: 0.18),
                      width: 1.5,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _wheel(
                      controller: _hourCtrl,
                      itemCount: 24,
                      label: (i) => i.toString().padLeft(2, '0'),
                      onChanged: (i) => setState(() => _hour = i),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        ':',
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 36,
                          color: const Color(0xFF3E5F36),
                        ),
                      ),
                    ),
                    _wheel(
                      controller: _minuteCtrl,
                      itemCount: 60,
                      label: (i) => i.toString().padLeft(2, '0'),
                      onChanged: (i) => setState(() => _minute = i),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF43A047),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: () => Navigator.pop(
                    context,
                    TimeOfDay(hour: _hour, minute: _minute),
                  ),
                  child: Text(
                    'Confirm  ${_hour.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _CircleButton({required this.child, this.onTap});

  @override
  State<_CircleButton> createState() => _CircleButtonState();
}

class _CircleButtonState extends State<_CircleButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: _hovered
                ? Colors.white.withValues(alpha: 0.25)
                : Colors.white.withValues(alpha: 0.14),
            shape: BoxShape.circle,
            border: Border.all(
              color: _hovered
                  ? Colors.white.withValues(alpha: 0.25)
                  : Colors.white.withValues(alpha: 0.10),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}
