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

  /// Favorite events list
  List<Event> get _favoriteEvents {
    return _allEvents.where((e) => e.isFavorite).toList();
  }

  /// Active filters
  List<int> _selectedObjectives = [];
  String? _selectedCountry;
  String? _selectedDistrict;
  String? _selectedCity;
  int? _minCurrentUsers;
  int? _maxCurrentUsers;
  int? _minMaxUsers;
  int? _maxMaxUsers;
  bool _showFullEvents = true;

  @override
  void initState() {
    super.initState();

    /// Load initial events
    _allEvents = EventRepository().getAllEvents();

    /// Apply default filters
    _filteredEvents = _eventFilter.applyFilters(events: _allEvents);
  }

  /// Main events list
  Widget _buildEventsPage() {
    return ListView.builder(
      itemCount: _filteredEvents.length,
      itemBuilder: (context, index) {
        final event = _filteredEvents[index];

        return EventCard(
          key: Key('event_${event.id}'),
          event: event,
          onTap: () => _showEventDetails(event),
          onFavoriteToggle: () => _toggleFavorite(event),
        );
      },
    );
  }

  /// Favorites list
  Widget _buildFavoritesPage() {
    final favorites = _favoriteEvents;

    if (favorites.isEmpty) {
      return Center(
        child: Text(
          'No favorite events yet',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return ListView.builder(
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final event = favorites[index];

        return EventCard(
          event: event,
          onTap: () => _showEventDetails(event),
          onFavoriteToggle: () => _toggleFavorite(event),
        );
      },
    );
  }

  /// Apply current filters to events
  void _applyCurrentFilters() {
    _filteredEvents = _eventFilter.applyFilters(
      events: _allEvents,
      objectives: _selectedObjectives,
      country: _selectedCountry,
      district: _selectedDistrict,
      city: _selectedCity,
      minCurrentUsers: _minCurrentUsers,
      maxCurrentUsers: _maxCurrentUsers,
      minMaxUsers: _minMaxUsers,
      maxMaxUsers: _maxMaxUsers,
      showFullEvents: _showFullEvents,
    );
  }

  /// Generate next event ID
  int _nextEventId() {
    final maxId = _allEvents.fold<int>(
      0,
      (maxValue, event) => event.id > maxValue ? event.id : maxValue,
    );

    return maxId + 1;
  }

  /// Open create event dialog
  void _openCreateDialog() {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) {
        return CreateEventPage(
          nextId: _nextEventId(),
          onCreate: (event) {
            setState(() {
              _allEvents.insert(0, event);
              _applyCurrentFilters();
            });

            ScaffoldMessenger.of(this.context).showSnackBar(
              SnackBar(
                content: Text(
                  '${event.name} created successfully',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Show event details dialog
  void _showEventDetails(Event event) {
    final theme = Theme.of(context);
    final bool isFull = event.isFull;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            event.name,
            style: theme.textTheme.titleMedium,
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.description, style: theme.textTheme.bodyMedium),

                const SizedBox(height: 10),

                Text("Objectives: ${event.objectives.join(', ')}",
                    style: theme.textTheme.bodyMedium),
                Text("Country: ${event.country}",
                    style: theme.textTheme.bodyMedium),
                Text("District: ${event.district}",
                    style: theme.textTheme.bodyMedium),
                Text("City: ${event.city}",
                    style: theme.textTheme.bodyMedium),
                Text("Max Users: ${event.maxUsers}",
                    style: theme.textTheme.bodyMedium),

                Text(
                  "Participants: ${event.currentUsers}/${event.maxUsers}",
                  key: const Key('participants_text'),
                  style: theme.textTheme.bodyLarge,
                ),

                const SizedBox(height: 12),

                /// Full badge
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
                    child: Text(
                      'FULL',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.red,
                      ),
                    ),
                  ),

                if (isFull) const SizedBox(height: 12),

                /// Full message
                if (isFull)
                  Text(
                    'This activity is full',
                    key: const Key('full_message'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                const SizedBox(height: 16),

                /// Join button
                ElevatedButton(
                  key: const Key('join_button'),
                  onPressed: isFull
                      ? null
                      : () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'You joined ${event.name}',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          );
                        },
                  child: const Text('Join'),
                ),
              ],
            ),
          ),

          /// Close dialog action
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Close",
                style: theme.textTheme.labelLarge,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Toggle favorite state
  void _toggleFavorite(Event event) {
    setState(() {
      event.isFavorite = !event.isFavorite;
    });
  }

  /// Open filter dialog
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
            int? minCurrentUsers,
            int? maxCurrentUsers,
            int? minMaxUsers,
            int? maxMaxUsers,
            bool showFullEvents = true,
          }) {
            setState(() {
              _selectedObjectives = objectives;
              _selectedCountry = country;
              _selectedDistrict = district;
              _selectedCity = city;
              _minCurrentUsers = minCurrentUsers;
              _maxCurrentUsers = maxCurrentUsers;
              _minMaxUsers = minMaxUsers;
              _maxMaxUsers = maxMaxUsers;
              _showFullEvents = showFullEvents;
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

        /// Open filter dialog
        leading: IconButton(
          key: const Key('filter_button'),
          icon: const Icon(Icons.filter_list),
          onPressed: _openFilterDialog,
        ),

        /// Open create event dialog
        actions: [
          IconButton(
            key: const Key('create_event_button'),
            icon: const Icon(Icons.add),
            onPressed: _openCreateDialog,
          ),
        ],
      ),

      /// Main content based on selected tab
      body: _currentIndex == 0
          ? _buildEventsPage()
          : _currentIndex == 1
              ? const Center(child: Text('Tarefas'))
              : _currentIndex == 2
                  ? _buildFavoritesPage()
                  : const ProfilePage(),

      /// Bottom navigation
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