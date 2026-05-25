import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../data/models/events/event.dart';
import '../../../viewModels/events/event_viewModel.dart';
import '../../../viewModels/search/search_viewModel.dart';
import '../../dialogs/event_details_dialog.dart';
import '../../widgets/event_card.dart';

class SearchEventsPage extends StatelessWidget {
  const SearchEventsPage({super.key});

  void _openEventDetails(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder: (_) => EventDetailsDialog(event: event),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchViewModel = context.watch<SearchViewModel>();
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Column(
        children: [
          // ── Top Bar ────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: topPadding + 12, bottom: 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(34),
                bottomRight: Radius.circular(34),
              ),
            ),
            child: Stack(
              children: [
                // Ícones decorativos
                Positioned(
                  top: -7,
                  left: 65,
                  child: Opacity(
                    opacity: 0.05,
                    child: Icon(
                      Icons.eco_rounded,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  top: -7,
                  right: 65,
                  child: Opacity(
                    opacity: 0.05,
                    child: Icon(
                      Icons.eco_rounded,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                ),

                // Conteúdo
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Botão voltar + título
                      Row(
                        children: [
                          _CircleButton(
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Search',
                            style: GoogleFonts.dmSerifDisplay(
                              fontSize: 32,
                              color: Colors.white,
                              height: 1,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Caixa de pesquisa
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F7EF),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.10),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 14),
                            Icon(
                              Icons.search_rounded,
                              color: Colors.green.shade600,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: searchViewModel.searchController,
                                autofocus: true,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF2E7D32),
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Search events...',
                                  hintStyle: TextStyle(
                                    color: Colors.green.shade300,
                                    fontSize: 15,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: searchViewModel.updateSearch,
                              ),
                            ),
                            // Botão limpar
                            ValueListenableBuilder<TextEditingValue>(
                              valueListenable: searchViewModel.searchController,
                              builder: (context, value, _) {
                                if (value.text.isEmpty)
                                  return const SizedBox(width: 14);
                                return IconButton(
                                  icon: Icon(
                                    Icons.close_rounded,
                                    color: Colors.green.shade400,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    searchViewModel.searchController.clear();
                                    searchViewModel.updateSearch('');
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Lista de resultados ────────────────────────────
          Expanded(
            child: StreamBuilder<List<Event>>(
              stream: context.watch<EventViewModel>().eventsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final allEvents = snapshot.data ?? [];
                final events = searchViewModel.filterEvents(allEvents);

                if (events.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 56,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No matching events found.',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return EventCard(
                      event: event,
                      onTap: () => _openEventDetails(context, event),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final Widget child;
  const _CircleButton({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
