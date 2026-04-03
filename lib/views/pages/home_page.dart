import 'package:flutter/material.dart';
import 'package:t5/views/widgets/bottom_nav.dart';
import 'package:t5/views/widgets/event_card.dart';

import '../../data/models/event.dart';
import '../../data/repositories/event_repositorie.dart';
import '../../viewmodels/event_filter.dart';
import 'create_event_page.dart';
import 'event_filter_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final EventFilter _eventFilter = EventFilter(EventRepository());

  late List<Event> _allEvents;
  List<Event> _filteredEvents = [];

  List<int> _selectedObjectives = [];
  String? _selectedCountry;
  String? _selectedDistrict;
  String? _selectedCity;

  @override
  void initState() {
    super.initState();
    _allEvents = EventRepository().getAllEvents();
    _filteredEvents = _eventFilter.applyFilters(events: _allEvents);
  }

  Widget _buildEventsPage() {
    return ListView.builder(
      itemCount: _filteredEvents.length,
      itemBuilder: (context, index) {
        final event = _filteredEvents[index];

        return EventCard(
          key: Key('event_${event.id}'),
          event: event,
          onTap: () => _showEventDetails(event),
        );
      },
    );
  }

  void _applyCurrentFilters() {
    _filteredEvents = _eventFilter.applyFilters(
      events: _allEvents,
      objectives: _selectedObjectives,
      country: _selectedCountry,
      district: _selectedDistrict,
      city: _selectedCity,
    );
  }

  int _nextEventId() {
    final maxId = _allEvents.fold<int>(
      0,
      (maxValue, event) => event.id > maxValue ? event.id : maxValue,
    );

    return maxId + 1;
  }

  void _openCreateDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return CreateEventPage(
          nextId: _nextEventId(),
          onCreate: (event) {
            setState(() {
              _allEvents.add(event);
              _applyCurrentFilters();
            });

            ScaffoldMessenger.of(this.context).showSnackBar(
              SnackBar(content: Text('${event.name} created successfully')),
            );
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
                Text(event.description),
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
    showDialog(
      context: context,
      builder: (context) {
        return EventFilterPage(
          onApply: ({
            required List<int> objectives,
            String? country,
            String? district,
            String? city,
          }) {
            setState(() {
              _selectedObjectives = objectives;
              _selectedCountry = country;
              _selectedDistrict = district;
              _selectedCity = city;
              _applyCurrentFilters();
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),

        leading: IconButton(
          key: const Key('filter_button'),
          icon: const Icon(Icons.filter_list),
          onPressed: _openFilterDialog,
        ),

        actions: [
          IconButton(
            key: const Key('create_event_button'),
            icon: const Icon(Icons.add),
            onPressed: _openCreateDialog,
          ),
        ],
      ),
      body: _currentIndex == 0
          ? _buildEventsPage()
          : _currentIndex == 1
              ? const Center(child: Text('Tarefas'))
              : _currentIndex == 2
                  ? const Center(child: Text('Favoritos'))
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