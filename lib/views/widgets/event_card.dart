import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:t5/data/models/events/event.dart';
import 'package:t5/theme/event_status_colors.dart';
import 'package:t5/theme/palette.dart';

class EventCard extends StatelessWidget {
  final Event event;

  final VoidCallback onTap;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor =
        getEventStatusColor(
          event.status,
        );

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),

      child: Material(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(22),

        elevation: 2,

        child: InkWell(
          onTap: onTap,

          borderRadius:
              BorderRadius.circular(22),

          child: Padding(
            padding: const EdgeInsets.all(12),

            child: Row(
              children: [
                // IMAGE
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(
                        16,
                      ),

                  child: event
                              .coverImageUrl !=
                          null &&
                      event.coverImageUrl!
                          .isNotEmpty
                      ? Image.network(
                          event.coverImageUrl!,

                          width: 105,
                          height: 105,

                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 105,
                          height: 105,

                          color: const Color(
                            0xFFE8F5E9,
                          ),

                          child: const Icon(
                            Icons.image,
                            color:
                                Palette
                                    .primary,

                            size: 40,
                          ),
                        ),
                ),

                const SizedBox(width: 16),

                // INFO
                Expanded(
                  child: SizedBox(
                    height: 105,

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,

                      children: [
                        // TITLE
                        Text(
                          event.title,

                          maxLines: 1,

                          overflow:
                              TextOverflow
                                  .ellipsis,

                          style:
                              const TextStyle(
                                fontSize: 20,

                                fontWeight:
                                    FontWeight
                                        .bold,

                                color:
                                    Palette
                                        .textPrimary,
                              ),
                        ),

                        // STATUS
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                                horizontal:
                                    10,

                                vertical: 5,
                              ),

                          decoration:
                              BoxDecoration(
                                color:
                                    statusColor
                                        .withOpacity(
                                          0.15,
                                        ),

                                borderRadius:
                                    BorderRadius.circular(
                                      10,
                                    ),
                              ),

                          child: Text(
                            event.status.name
                                .toUpperCase(),

                            style:
                                TextStyle(
                                  color:
                                      statusColor,

                                  fontSize:
                                      11,

                                  fontWeight:
                                      FontWeight
                                          .w700,

                                  letterSpacing:
                                      0.4,
                                ),
                          ),
                        ),

                        // DATE + TIME
                        Row(
                          children: [
                            const Icon(
                              Icons
                                  .calendar_today_rounded,

                              size: 15,

                              color:
                                  Colors
                                      .black54,
                            ),

                            const SizedBox(
                              width: 6,
                            ),

                            Text(
                              DateFormat(
                                'MMM dd, yyyy',
                              ).format(
                                event
                                    .startDate,
                              ),

                              style:
                                  const TextStyle(
                                    fontSize:
                                        13,

                                    color:
                                        Colors
                                            .black54,

                                    fontWeight:
                                        FontWeight
                                            .w500,
                                  ),
                            ),

                            const SizedBox(
                              width: 12,
                            ),

                            const Icon(
                              Icons.access_time,

                              size: 15,

                              color:
                                  Colors
                                      .black54,
                            ),

                            const SizedBox(
                              width: 6,
                            ),

                            Text(
                              DateFormat(
                                'hh:mm a',
                              ).format(
                                event
                                    .startDate,
                              ),

                              style:
                                  const TextStyle(
                                    fontSize:
                                        13,

                                    color:
                                        Colors
                                            .black54,

                                    fontWeight:
                                        FontWeight
                                            .w500,
                                  ),
                            ),
                          ],
                        ),

                        // LOCATION
                        Row(
                          children: [
                            const Icon(
                              Icons
                                  .location_on_outlined,

                              size: 16,

                              color:
                                  Colors
                                      .black54,
                            ),

                            const SizedBox(
                              width: 6,
                            ),

                            Expanded(
                              child: Text(
                                '${event.city}, ${event.district}',

                                maxLines: 1,

                                overflow:
                                    TextOverflow
                                        .ellipsis,

                                style:
                                    const TextStyle(
                                      fontSize:
                                          14,

                                      color:
                                          Colors
                                              .black87,

                                      fontWeight:
                                          FontWeight
                                              .w500,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 4),

                const Icon(
                  Icons.chevron_right_rounded,

                  color: Colors.black38,

                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}