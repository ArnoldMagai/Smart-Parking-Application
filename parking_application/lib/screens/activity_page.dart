import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ActivityPage extends StatelessWidget {

  final List activities;

  const ActivityPage({
    Key? key,
    required this.activities,
  }) : super(key: key);

  String formatTime(DateTime time) {
    return DateFormat(
      'dd MMM yyyy • hh:mm a',
    ).format(time);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Activity"),
      ),

      body: activities.isEmpty

          ? const Center(
              child: Text(
                "No recent activity",
              ),
            )

          : ListView.builder(

              itemCount: activities.length,

              itemBuilder: (context, index) {

                final activity = activities[index];

                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
 
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surface,

                   borderRadius:
                      BorderRadius.circular(16),
                  ),

                  child: ListTile(

                    leading: Container(

                      width: 48,
                      height: 48,

                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.15),
                        borderRadius:
                        BorderRadius.circular(12),
                      ),

                      child: const Icon(
                        Icons.local_parking,
                        color: Colors.red,
                      ),
                    ),

                    title: Text(
                      activity['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    subtitle: Padding(
                      padding: const EdgeInsets.only(
                        top: 4,
                      ),
                      child: Text(
                        formatTime(activity['time'],)
                      ),
                    ),

                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
                  ),
                );
              },
            ),
    );
  }
}