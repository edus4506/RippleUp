import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:t5/data/constants/event_locations.dart';
import 'package:t5/viewModels/events/event_viewModel.dart';

class EventFilterDialog extends StatefulWidget {
  final String currentUserId;
  const EventFilterDialog({super.key, required this.currentUserId});

  @override
  State<EventFilterDialog> createState() => _EventFilterDialogState();
}

class _EventFilterDialogState extends State<EventFilterDialog> {
  bool hideFull = false;
  bool showDone = false;
  bool canJoin = false;
  Set<int> selectedGoals = {};

  RangeValues capacityRange = const RangeValues(0, 50);
  bool capacityChanged = false;

  RangeValues currentUsersRange = const RangeValues(0, 50);
  bool currentUsersChanged = false;

  String? selectedCountry;
  String? selectedDistrict;
  String? selectedCity;

  int selectedQuickDate = -1;
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final filter = context.read<EventViewModel>().currentFilter;

    hideFull = filter.hideFull;
    showDone = filter.showDone;
    canJoin = filter.canJoin;
    selectedGoals = Set.from(filter.goals);

    capacityRange = RangeValues(
      filter.minCapacity?.toDouble() ?? 0,
      filter.maxCapacity?.toDouble() ?? 50,
    );

    capacityChanged = filter.minCapacity != null || filter.maxCapacity != null;

    currentUsersRange = RangeValues(
      filter.minCurrentUsers?.toDouble() ?? 0,
      filter.maxCurrentUsers?.toDouble() ?? 50,
    );

    currentUsersChanged =
        filter.minCurrentUsers != null || filter.maxCurrentUsers != null;

    selectedCountry = filter.country;
    selectedDistrict = filter.district;
    selectedCity = filter.city;

    if (filter.startDate != null) {
      startDateController.text =
      '${filter.startDate!.day.toString().padLeft(2, '0')}/${filter.startDate!.month.toString().padLeft(2, '0')}/${filter.startDate!.year}';
    }

    if (filter.endDate != null) {
      endDateController.text =
      '${filter.endDate!.day.toString().padLeft(2, '0')}/${filter.endDate!.month.toString().padLeft(2, '0')}/${filter.endDate!.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        width: double.maxFinite,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text('Filters', style: theme.textTheme.titleMedium),

                      const SizedBox(height: 10),

                      CheckboxListTile(
                        title: const Text('Hide full events'),
                        value: hideFull,
                        onChanged: (value) {
                          setState(() {
                            hideFull = value ?? false;
                          });
                        },
                      ),

                      CheckboxListTile(
                        title: const Text('Show finished events'),
                        value: showDone,
                        onChanged: (value) {
                          setState(() {
                            showDone = value ?? true;
                          });
                        },
                      ),

                      CheckboxListTile(
                        title: const Text('Show only events you can join'),
                        value: canJoin,
                        onChanged: (value) {
                          setState(() {
                            canJoin = value ?? false;
                          });
                        },
                      ),

                      const SizedBox(height: 10),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Event Date',
                          style: theme.textTheme.titleMedium,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _dateChip('Today', 0),
                          _dateChip('Tomorrow', 1),
                          _dateChip('This Week', 2),
                          _dateChip('This Month', 3),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: startDateController,
                              decoration: const InputDecoration(
                                hintText: 'dd/mm/yyyy',
                                labelText: 'Start Date',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: endDateController,
                              decoration: const InputDecoration(
                                hintText: 'dd/mm/yyyy',
                                labelText: 'End Date',
                              ),
                            ),
                          ),
                        ],
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
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: 18,
                        itemBuilder: (context, index) {
                          final goal = index + 1;
                          final isSelected = selectedGoals.contains(goal);

                          return GestureDetector(
                            onTap: goal == 18
                                ? null
                                : () {
                              setState(() {
                                if (isSelected) {
                                  selectedGoals.remove(goal);
                                } else {
                                  selectedGoals.add(goal);
                                }
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected
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
                        child: Text(
                          'Location',
                          style: theme.textTheme.titleMedium,
                        ),
                      ),

                      const SizedBox(height: 10),

                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Country'),
                        value: selectedCountry,
                        menuMaxHeight: 300,
                        isExpanded: true,
                        items: eventCountries
                            .map(
                              (country) => DropdownMenuItem(
                            value: country,
                            child: Text(country),
                          ),
                        )
                            .toList(),
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
                          decoration: const InputDecoration(
                            labelText: 'District',
                          ),
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
                          decoration: const InputDecoration(labelText: 'City'),
                          value: selectedCity,
                          menuMaxHeight: 300,
                          isExpanded: true,
                          items: eventCitiesByDistrict[selectedDistrict]!
                              .map(
                                (city) => DropdownMenuItem(
                              value: city,
                              child: Text(city),
                            ),
                          )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCity = value;
                            });
                          },
                        ),

                      const SizedBox(height: 10),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Event Capacity',
                          style: theme.textTheme.titleMedium,
                        ),
                      ),

                      Row(
                        children: [
                          Text(
                            '${capacityRange.start.round()} - ${capacityRange.end.round()}',
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: RangeSlider(
                              values: capacityRange,
                              min: 0,
                              max: 50,
                              divisions: 50,
                              onChanged: (values) {
                                setState(() {
                                  capacityRange = values;
                                  capacityChanged = true;
                                });
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Current Participants',
                          style: theme.textTheme.titleMedium,
                        ),
                      ),

                      Row(
                        children: [
                          Text(
                            '${currentUsersRange.start.round()} - ${currentUsersRange.end.round()}',
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: RangeSlider(
                              values: currentUsersRange,
                              min: 0,
                              max: 50,
                              divisions: 50,
                              onChanged: (values) {
                                setState(() {
                                  currentUsersRange = values;
                                  currentUsersChanged = true;
                                });
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 6),
                  ],
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade300, width: 0.5),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            hideFull = false;
                            showDone = false;
                            canJoin = false;
                            selectedGoals.clear();
                            capacityChanged = false;
                            capacityRange = const RangeValues(0, 50);
                            currentUsersChanged = false;
                            currentUsersRange = const RangeValues(0, 50);
                            selectedCountry = null;
                            selectedDistrict = null;
                            selectedCity = null;
                            selectedQuickDate = -1;
                            startDateController.clear();
                            endDateController.clear();
                          });
                        },
                        child: const Text('Clear filters'),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              side: BorderSide(color: Colors.grey.shade400),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3E5F36),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                              DateTime? startDate;
                              DateTime? endDate;

                              try {
                                if (startDateController.text.isNotEmpty) {
                                  final parts =
                                  startDateController.text.split('/');
                                  startDate = DateTime(
                                    int.parse(parts[2]),
                                    int.parse(parts[1]),
                                    int.parse(parts[0]),
                                  );
                                }

                                if (endDateController.text.isNotEmpty) {
                                  final parts =
                                  endDateController.text.split('/');
                                  endDate = DateTime(
                                    int.parse(parts[2]),
                                    int.parse(parts[1]),
                                    int.parse(parts[0]),
                                  );
                                }
                              } catch (_) {}

                              context.read<EventViewModel>().applyFilters(
                                hideFull: hideFull,
                                showDone: showDone,
                                canJoin: canJoin,
                                excludeCreatedBy: canJoin
                                    ? widget.currentUserId
                                    : null,
                                goals: selectedGoals,
                                minCapacity: capacityChanged
                                    ? capacityRange.start.round()
                                    : null,
                                maxCapacity: capacityChanged
                                    ? capacityRange.end.round()
                                    : null,
                                minCurrentUsers: currentUsersChanged
                                    ? currentUsersRange.start.round()
                                    : null,
                                maxCurrentUsers: currentUsersChanged
                                    ? currentUsersRange.end.round()
                                    : null,
                                country: selectedCountry,
                                district: selectedDistrict,
                                city: selectedCity,
                                startDate: startDate,
                                endDate: endDate,
                              );

                              Navigator.pop(context);
                            },
                            child: const Text('Apply'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applyQuickDate(int index) {
    final now = DateTime.now();
    DateTime start;
    DateTime end;

    switch (index) {
      case 0:
        start = DateTime(now.year, now.month, now.day);
        end = DateTime(now.year, now.month, now.day);
        break;
      case 1:
        final tomorrow = now.add(const Duration(days: 1));
        start = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
        end = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
        break;
      case 2:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
        end = DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day);
        break;
      case 3:
        start = DateTime(now.year, now.month, 1);
        end = DateTime(now.year, now.month + 1, 0);
        break;
      default:
        return;
    }

    String fmt(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

    startDateController.text = fmt(start);
    endDateController.text = fmt(end);
  }

  Widget _dateChip(String text, int index) {
    final isSelected = selectedQuickDate == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedQuickDate = index;
          _applyQuickDate(index);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3E5F36) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF3E5F36) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}