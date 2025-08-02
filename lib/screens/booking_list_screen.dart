import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../services/database_helper.dart';
import '../services/auth_service.dart';
import 'booking_detail_screen.dart';

class BookingListScreen extends StatefulWidget {
  const BookingListScreen({super.key});

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  late Future<List<Booking>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  void _loadBookings() {
    _bookingsFuture = DatabaseHelper.instance.getAllBookings();
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency) {
      case 'E1- Within 1 hour':
        return Colors.red;
      case 'E2- Within 6 hours':
        return Colors.orange;
      case 'E3- Within 24 hours':
        return Colors.black;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency OR Bookings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() => _loadBookings()),
          ),
        ],
      ),
      body: FutureBuilder<List<Booking>>(
        future: _bookingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final bookings = snapshot.data ?? [];
          if (bookings.isEmpty) {
            return const Center(child: Text('No bookings found'));
          }

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return Card(
                child: ListTile(
                  title: Text(
                    'MRN: ${booking.patientMrn}',
                    style: TextStyle(
                      color: _getUrgencyColor(booking.urgency),
                      fontWeight: booking.urgency == 'Life-saving-E1'
                          ? FontWeight.bold
                          : null,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Procedure: ${booking.procedure}'),
                      Text('Urgency: ${booking.urgency}'),
                      Text('Status: ${booking.bookingStatus}'),
                      Text(
                        'Booked: ${booking.bookingTime.toLocal().toString().split('.')[0]}',
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (AuthService().userType == 'Anesthesia') ...[
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Confirm Deletion'),
                                content: const Text(
                                  'Are you sure you want to delete this booking?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true && booking.id != null) {
                              await DatabaseHelper.instance.deleteBooking(
                                booking.id!,
                              );
                              setState(() => _loadBookings());
                            }
                          },
                        ),
                      ],
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  BookingDetailScreen(bookingId: booking.id!),
                            ),
                          ).then((_) => setState(() => _loadBookings()));
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
