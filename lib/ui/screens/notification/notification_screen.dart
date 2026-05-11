import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // FUNGSI MARK ALL AS READ (Ke Database)
  Future<void> _markAllAsRead(List<QueryDocumentSnapshot> unreadDocs) async {
    if (unreadDocs.isEmpty) return;

    WriteBatch batch = FirebaseFirestore.instance.batch();
    for (var doc in unreadDocs) {
      batch.update(doc.reference, {'isRead': true});
    }

    try {
      await batch.commit();
    } catch (e) {
      debugPrint("Gagal update notifikasi: $e");
    }
  }

  // FUNGSI MARK SINGLE AS READ
  Future<void> _markAsRead(
      DocumentReference docRef, bool currentStatus) async {
    if (!currentStatus) {
      await docRef.update({'isRead': true});
    }
  }

  // FUNGSI HAPUS NOTIF
  Future<void> _deleteNotification(DocumentReference docRef) async {
    await docRef.delete();
  }

  IconData _getIconForType(String type) {
    if (type == 'order') return Icons.receipt_long;
    if (type == 'delivery') return Icons.local_shipping;
    return Icons.notifications; // Default
  }

  Color _getColorForType(String type, ColorScheme colorScheme) {
    if (type == 'order') return const Color(0xFF43A047);   // hijau
    if (type == 'delivery') return const Color(0xFF1E88E5); // biru
    return colorScheme.onSurface; // Default
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (currentUser == null) {
      return Scaffold(
        body: Center(
          child: Text(
            "Silakan login terlebih dahulu",
            style: TextStyle(color: colorScheme.onSurface),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        title: Text(
          "Notifications",
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),

      // MENDENGARKAN FIRESTORE SECARA REAL-TIME
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: currentUser!.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.onSurface),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Terjadi kesalahan: ${snapshot.error}",
                style: TextStyle(color: colorScheme.onSurface),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState(colorScheme);
          }

          final notifications = snapshot.data!.docs;

          // Cari dokumen yang belum dibaca untuk tombol "Mark all read"
          final unreadDocs =
              notifications.where((doc) => doc['isRead'] == false).toList();

          return Column(
            children: [
              // HEADER ACTIONS (Tombol Mark All As Read)
              if (unreadDocs.isNotEmpty)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _markAllAsRead(unreadDocs),
                    child: Text(
                      "Mark all read",
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.55),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

              // DAFTAR NOTIFIKASI
              Expanded(
                child: ListView.separated(
                  itemCount: notifications.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    thickness: 1,
                    color: colorScheme.onSurface.withOpacity(0.07),
                  ),
                  itemBuilder: (context, index) {
                    final doc = notifications[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final bool isRead = data['isRead'] ?? false;

                    // Format Waktu dari Firestore
                    String timeString = "Baru saja";
                    if (data['createdAt'] != null) {
                      DateTime date =
                          (data['createdAt'] as Timestamp).toDate();
                      timeString = DateFormat('dd MMM, HH:mm').format(date);
                    }

                    return Dismissible(
                      key: Key(doc.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: colorScheme.error,
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        _deleteNotification(doc.reference); // Hapus permanen di Firestore
                      },
                      child: Material(
                        color: isRead
                            ? colorScheme.surface
                            : colorScheme.error.withOpacity(0.03),
                        child: InkWell(
                          onTap: () {
                            _markAsRead(doc.reference, isRead); // Ubah ke sudah dibaca
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _getColorForType(
                                            data['type'] ?? 'order',
                                            colorScheme)
                                        .withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _getIconForType(data['type'] ?? 'order'),
                                    size: 24,
                                    color: _getColorForType(
                                        data['type'] ?? 'order', colorScheme),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              data['title'] ?? 'Notifikasi',
                                              style: TextStyle(
                                                fontWeight: isRead
                                                    ? FontWeight.w600
                                                    : FontWeight.bold,
                                                fontSize: 15,
                                                color: colorScheme.onSurface,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(
                                            timeString,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: colorScheme.onSurface
                                                  .withOpacity(0.4),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        data['message'] ?? '',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isRead
                                              ? colorScheme.onSurface
                                                  .withOpacity(0.5)
                                              : colorScheme.onSurface
                                                  .withOpacity(0.8),
                                          height: 1.4,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                if (!isRead)
                                  Container(
                                    margin: const EdgeInsets.only(
                                        left: 12, top: 6),
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: colorScheme.error,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: colorScheme.onSurface.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            "No notification yet",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface.withOpacity(0.75),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Your transactions and order\nupdates will appear here.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withOpacity(0.45),
            ),
          ),
        ],
      ),
    );
  }
}