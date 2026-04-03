import 'package:flutter/material.dart';

class EventFilterPage extends StatefulWidget {
  final Function({
    required List<int> objectives,
    String? country,
    String? district,
    String? city,
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
        height: 450,
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Objectives",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),

            /// OBJECTIVES
            SizedBox(
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

            /// COUNTRY
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

            /// DISTRICT
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

            /// CITY
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
      actions: [
        TextButton(
          onPressed: () {
            widget.onApply(
              objectives: selectedObjectives,
              country: selectedCountry,
              district: selectedDistrict,
              city: selectedCity,
            );

            Navigator.pop(context);
          },
          child: const Text("Apply"),
        ),
      ],
    );
  }
}