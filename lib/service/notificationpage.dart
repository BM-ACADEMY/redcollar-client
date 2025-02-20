import 'package:flutter/material.dart';
import 'package:flutter_application_1/service/notifi_service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key, required this.title});

  final String title;

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final NotifiService _notifiService = NotifiService();

  @override
  void initState() {
    super.initState();
    _notifiService.iniNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Show notifications'),
          onPressed: () {
            _notifiService.showNotification(
              title: 'Sample Notification',
              body: 'It works!',
            );
          },
        ),
      ),
    );
  }
}
