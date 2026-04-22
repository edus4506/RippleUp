import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:t5/viewModels/event_viewModel.dart';

class EventFilterDialog extends StatefulWidget {
  const EventFilterDialog({super.key});

  @override
  State<EventFilterDialog> createState() => _EventFilterDialogState();
}

class _EventFilterDialogState extends State<EventFilterDialog> {
  bool hideFull = false;
  bool showDone = false;
  Set<int> selectedGoals = {};

  RangeValues capacityRange = const RangeValues(0, 50);
  bool capacityChanged = false;

  RangeValues currentUsersRange = const RangeValues(0, 50);
  bool currentUsersChanged = false;

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
  void initState() {
    super.initState();

    final filter = context.read<EventViewModel>().currentFilter;

    hideFull = filter.hideFull;
    showDone = filter.showDone;
    selectedGoals = Set.from(filter.goals);

    capacityRange = RangeValues(
      filter.minCapacity?.toDouble() ?? 0,
      filter.maxCapacity?.toDouble() ?? 50,
    );

    capacityChanged =
        filter.minCapacity != null || filter.maxCapacity != null;

    currentUsersRange = RangeValues(
      filter.minCurrentUsers?.toDouble() ?? 0,
      filter.maxCurrentUsers?.toDouble() ?? 50,
    );

    currentUsersChanged =
        filter.minCurrentUsers != null ||
        filter.maxCurrentUsers != null;

    selectedCountry = filter.country;
    selectedDistrict = filter.district;
    selectedCity = filter.city;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        width: double.maxFinite,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
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

                      const SizedBox(height: 10),

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

                          if (goal == 18) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                            );
                          }

                          final isSelected = selectedGoals.contains(goal);

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  selectedGoals.remove(goal);
                                } else {
                                  selectedGoals.add(goal);
                                }
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.green
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  goal.toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
                        decoration:
                            const InputDecoration(labelText: "Country"),
                        value: selectedCountry,
                        items: countries.map((country) {
                          return DropdownMenuItem(
                            value: country,
                            child: Text(country),
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
                          decoration:
                              const InputDecoration(labelText: "District"),
                          value: selectedDistrict,
                          items: districts[selectedCountry]!
                              .map((district) => DropdownMenuItem(
                                    value: district,
                                    child: Text(district),
                                  ))
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
                          decoration:
                              const InputDecoration(labelText: "City"),
                          value: selectedCity,
                          items: cities[selectedDistrict]!
                              .map((city) => DropdownMenuItem(
                                    value: city,
                                    child: Text(city),
                                  ))
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
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 6,
                    ),
                  ],
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey.shade300,
                      width: 0.5,
                    ),
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
                            showDone = true;
                            selectedGoals.clear();
                            capacityChanged = false;
                            capacityRange = const RangeValues(0, 50);
                            currentUsersChanged = false;
                            currentUsersRange = const RangeValues(0, 50);
                            selectedCountry = null;
                            selectedDistrict = null;
                            selectedCity = null;
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
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
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
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                              context.read<EventViewModel>().applyFilters(
                                    hideFull: hideFull,
                                    showDone: showDone,
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
}