import 'package:flutter/material.dart';

class EventFilterPage extends StatefulWidget {
  final Function({
    required List<int> objectives,
    String? country,
    String? district,
    String? city,
    int? minCurrentUsers,
    int? maxCurrentUsers,
    int? minMaxUsers,
    int? maxMaxUsers,
    bool showFullEvents,
  }) onApply;

  const EventFilterPage({super.key, required this.onApply});

  @override
  State<EventFilterPage> createState() => _EventFilterPageState();
}

class _EventFilterPageState extends State<EventFilterPage> {
  List<int> selectedObjectives = [];

  String? selectedCountry;
  String? selectedDistrict;
  String? selectedCity;

  RangeValues currentUsersRange = const RangeValues(0, 100);
  RangeValues maxUsersRange = const RangeValues(0, 100);

  bool showFullEvents = true;

  /// 🔥 FALTAVA ISTO (localização)
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
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Filter Events"),
      content: SizedBox(
        width: double.maxFinite,
        height: 550,
        child: SingleChildScrollView(
          child: Column(
            children: [

              /// 🔹 OBJECTIVES
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Objectives",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),

              const SizedBox(height: 10),

              Card(
                child: SizedBox(
                  height: 150,
                  child: ListView.builder(
                    itemCount: 17,
                    itemBuilder: (context, index) {
                      final objective = index + 1;

                      return CheckboxListTile(
                        title: Text("Objective $objective"),
                        value: selectedObjectives.contains(objective),
                        onChanged: (value) {
                          setState(() {
                            value == true
                                ? selectedObjectives.add(objective)
                                : selectedObjectives.remove(objective);
                          });
                        },
                      );
                    },
                  ),
                ),
              ),

              /// 🔥 FULL CHECKBOX
              CheckboxListTile(
                title: Text(
                  "Show Full Events",
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                value: showFullEvents,
                onChanged: (value) {
                  setState(() {
                    showFullEvents = value ?? true;
                  });
                },
              ),

              /// 🔥 CURRENT USERS
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Current Participants",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),

              RangeSlider(
                values: currentUsersRange,
                min: 0,
                max: 100,
                divisions: 20,
                labels: RangeLabels(
                  currentUsersRange.start.round().toString(),
                  currentUsersRange.end.round().toString(),
                ),
                onChanged: (values) {
                  setState(() {
                    currentUsersRange = values;
                  });
                },
              ),

              /// 🔥 MAX USERS
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Max Participants",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),

              RangeSlider(
                values: maxUsersRange,
                min: 0,
                max: 100,
                divisions: 20,
                labels: RangeLabels(
                  maxUsersRange.start.round().toString(),
                  maxUsersRange.end.round().toString(),
                ),
                onChanged: (values) {
                  setState(() {
                    maxUsersRange = values;
                  });
                },
              ),

              const SizedBox(height: 16),

              /// 🔹 COUNTRY
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Country"),
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

              /// 🔹 DISTRICT
              if (selectedCountry != null)
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: "District"),
                  value: selectedDistrict,
                  items: districts[selectedCountry]!.map((district) {
                    return DropdownMenuItem(
                      value: district,
                      child: Text(district),
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

              /// 🔹 CITY
              if (selectedDistrict != null)
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: "City"),
                  value: selectedCity,
                  items: cities[selectedDistrict]!.map((city) {
                    return DropdownMenuItem(
                      value: city,
                      child: Text(city),
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
          onPressed: () {
            widget.onApply(
              objectives: selectedObjectives,
              country: selectedCountry,
              district: selectedDistrict,
              city: selectedCity,
              minCurrentUsers: currentUsersRange.start.round(),
              maxCurrentUsers: currentUsersRange.end.round(),
              minMaxUsers: maxUsersRange.start.round(),
              maxMaxUsers: maxUsersRange.end.round(),
              showFullEvents: showFullEvents,
            );

            Navigator.pop(context);
          },
          child: const Text("Apply"),
        ),
      ],
    );
  }
}