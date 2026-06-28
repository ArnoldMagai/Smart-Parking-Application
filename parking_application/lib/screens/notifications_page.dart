import 'package:flutter/material.dart';

class NotificationsPage
    extends StatefulWidget {

  const NotificationsPage({
    super.key,
  });

  @override
  State<NotificationsPage>
      createState() =>
          _NotificationsPageState();
}

class _NotificationsPageState
    extends State<
        NotificationsPage> {

  bool bookingAlerts = true;
  bool promotions = true;

  @override
  Widget build(
      BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title:
            const Text("Notifications"),
      ),

      body: ListView(
        children: [

          SwitchListTile(
            title: const Text(
                "Booking Alerts"),
            value: bookingAlerts,
            onChanged: (value) {
              setState(() {
                bookingAlerts =
                    value;
              });
            },
          ),

          SwitchListTile(
            title: const Text(
                "Promotions"),
            value: promotions,
            onChanged: (value) {
              setState(() {
                promotions =
                    value;
              });
            },
          ),
        ],
      ),
    );
  }
}