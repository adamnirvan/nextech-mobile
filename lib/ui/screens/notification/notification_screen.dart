import 'package:flutter/material.dart';
import 'package:nextech_mobile/ui/components/global_app_bar.dart'; 

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {

  // --- DUMMY DATA API ---
  // Format List of Maps ini sama persis dengan format JSON yang akan dikirim oleh Backend nanti.
  // Saat API sudah siap, kamu tinggal me-replace variabel ini dengan hasil fetch dari API.
  final List<Map<String, dynamic>> dummyNotifications = [
    {
      "icon": Icons.shopping_bag,
      "sender": "Nextech Promo",
      "time": "05-04-2026 17:10",
      "title": "Flash Sale Live: Up to 70% off on High-Density Storage Solutions!",
      "description": "The warehouse is clearing out previous generation rack modules. Limit 5 per industrial account.",
      "isUnread": true,
    },
    {
      "icon": Icons.local_shipping,
      "sender": "Order Logistics",
      "time": "05-04-2026 14:22",
      "title": "Parcel Delivered: INV-2026-X99",
      "description": "Your order for 'Precision Machined Gaskets' has been delivered to the loading dock B at your registered address.",
      "isUnread": false,
    },
    {
      "icon": Icons.security,
      "sender": "System Security",
      "time": "05-04-2026 09:05",
      "title": "New Login Detected",
      "description": "A new login was detected from a Windows device in Jakarta, Indonesia. If this wasn't you, secure your account now.",
      "isUnread": true,
    },
    {
      "icon": Icons.payments,
      "sender": "Financial Service",
      "time": "04-04-2026 21:45",
      "title": "Monthly Statement Available",
      "description": "Your industrial credit statement for the month of March is now ready for review and download.",
      "isUnread": false,
    },
    {
      "icon": Icons.verified,
      "sender": "Account Verification",
      "time": "04-04-2026 10:12",
      "title": "Vendor Verification Successful",
      "description": "Nextech has verified your vendor credentials. You now have access to high-volume procurement tools.",
      "isUnread": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const GlobalAppBar(
        title: "Notifications",
        backgroundColor: Colors.white,
        contentColor: Colors.black,       
      ),
      // --- MENGGUNAKAN LISTVIEW.BUILDER ---
      // Ini adalah kunci utama untuk integrasi API. Flutter akan melakukan looping 
      // dan mem-build widget secara dinamis berdasarkan panjang data (itemCount).
      body: ListView.builder(
        itemCount: dummyNotifications.length,
        itemBuilder: (context, index) {
          final data = dummyNotifications[index];
          
          return _buildNotificationItem(
            icon: data['icon'],
            sender: data['sender'],
            time: data['time'],
            title: data['title'],
            description: data['description'],
            isUnread: data['isUnread'],
          );
        },
      ),
    );
  }

  // --- REUSABLE COMPONENT ---
  Widget _buildNotificationItem({
    required IconData icon,
    required String sender,
    required String time,
    required String title,
    required String description,
    required bool isUnread,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAEDF1), 
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(icon, color: Colors.black87),
              ),
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          sender,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                        ),
                        if (isUnread) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                        const Spacer(), 
                        Text(
                          time,
                          style: const TextStyle(color: Colors.black54, fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                        height: 1.4, 
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
      ],
    );
  }
}