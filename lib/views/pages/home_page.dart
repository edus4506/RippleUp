import 'package:flutter/material.dart';
import 'package:t5/views/widgets/bottom_nav.dart';
import 'profile_page.dart';

import '/data/models/event.dart';
import '../../viewmodels/event_filter.dart';
import '../../data/repositories/event_repositorie.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final EventFilter _eventFilter = EventFilter(EventRepository());
  List<Event> _filteredEvents = [];

  @override
  void initState() {
    super.initState();
    _filteredEvents = _eventFilter.applyFilters();
  }

  Widget _buildEventsPage() {
    return ListView.builder(
      itemCount: _filteredEvents.length,
      itemBuilder: (context, index) {
        final event = _filteredEvents[index];

        return ListTile(
          key: Key('event_${event.id}'),
          title: Text(event.name),
          subtitle: Text(
            "${event.country} - Objective ${event.objectives.join(", ")}",
          ),
          trailing: event.isFull
              ? const Chip(
            label: Text('FULL'),
          )
              : null,
          onTap: () {
            _showEventDetails(event);
          },
        );
      },
    );
  }

  void _showEventDetails(Event event) {
    final bool isFull = event.isFull;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(event.name),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.description, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                Text("Objectives: ${event.objectives.join(', ')}"),
                Text("Country: ${event.country}"),
                Text("District: ${event.district}"),
                Text("City: ${event.city}"),
                Text("Max Users: ${event.maxUsers}"),
                Text(
                  "Participants: ${event.currentUsers}/${event.maxUsers}",
                  key: const Key('participants_text'),
                ),
                const SizedBox(height: 12),
                if (isFull)
                  Container(
                    key: const Key('full_badge'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'FULL',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (isFull) const SizedBox(height: 12),
                if (isFull)
                  const Text(
                    'This activity is full',
                    key: Key('full_message'),
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  key: const Key('join_button'),
                  onPressed: isFull
                      ? null
                      : () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('You joined ${event.name}'),
                      ),
                    );
                  },
                  child: const Text('Join'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _openFilterDialog() {
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

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
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
                              setStateDialog(() {
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
                          child: Text(country),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setStateDialog(() {
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
                            child: Text(district),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setStateDialog(() {
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
                            child: Text(city),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setStateDialog(() {
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
                    setState(() {
                      _filteredEvents = _eventFilter.applyFilters(
                        objectives: selectedObjectives,
                        country: selectedCountry,
                        district: selectedDistrict,
                        city: selectedCity,
                      );
                    });

                    Navigator.pop(context);
                  },
                  child: const Text("Apply"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
        actions: [
          IconButton(
            key: const Key('filter_button'),
            icon: const Icon(Icons.filter_list),
            onPressed: _openFilterDialog,
          ),
        ],
      ),
      body: _currentIndex == 0
          ? _buildEventsPage()
          : _currentIndex == 1
          ? const Center(
        child: Text('Tarefas', style: TextStyle(fontSize: 24)),
      )
          : _currentIndex == 2
          ? const Center(
        child: Text('Favoritos', style: TextStyle(fontSize: 24)),
      )
          : const ProfilePage(),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}