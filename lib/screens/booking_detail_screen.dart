import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../models/booking.dart';
import '../models/comment.dart';
import '../services/database_helper.dart';
import '../services/auth_service.dart';

class BookingDetailScreen extends StatefulWidget {
  final int bookingId;

  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  late Future<Booking?> _bookingFuture;
  late Future<List<Comment>> _commentsFuture;
  final _commentFormKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _bookingFuture = DatabaseHelper.instance.getBookingById(widget.bookingId);
    _commentsFuture = DatabaseHelper.instance.getCommentsForBooking(
      widget.bookingId,
    );
  }

  Widget _buildStatusUpdateSection(Booking booking) {
    if (AuthService().userType != 'Anesthesia') return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(),
        const Text(
          'Update Status:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        FormBuilder(
          key: _formKey,
          child: FormBuilderDropdown<String>(
            name: 'status',
            decoration: const InputDecoration(border: OutlineInputBorder()),
            initialValue: booking.bookingStatus,
            items:
                [
                      'Pending',
                      'Patient seen and accepted',
                      'Patient seen by anesthesia and pending requests to be fulfilled',
                      'OP done',
                      'Postponed',
                      'Cancelled',
                    ]
                    .map(
                      (status) =>
                          DropdownMenuItem(value: status, child: Text(status)),
                    )
                    .toList(),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState?.saveAndValidate() ?? false) {
              final newStatus = _formKey.currentState!.value['status'];
              final updatedBooking = Booking(
                id: booking.id,
                patientMrn: booking.patientMrn,
                procedure: booking.procedure,
                urgency: booking.urgency,
                consultantName: booking.consultantName,
                consultantPhone: booking.consultantPhone,
                physicianName: booking.physicianName,
                physicianPhone: booking.physicianPhone,
                anesthesiaManagerName: booking.anesthesiaManagerName,
                anesthesiaManagerPhone: booking.anesthesiaManagerPhone,
                anesthesiaConsultantName: booking.anesthesiaConsultantName,
                anesthesiaConsultantPhone: booking.anesthesiaConsultantPhone,
                bookingTime: booking.bookingTime,
                bookingStatus: newStatus,
              );
              await DatabaseHelper.instance.updateBooking(updatedBooking);
              setState(() {
                _loadData();
              });
            }
          },
          child: const Text('Update Status'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Details')),
      body: FutureBuilder<Booking?>(
        future: _bookingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final booking = snapshot.data;
          if (booking == null) {
            return const Center(child: Text('Booking not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Patient MRN: ${booking.patientMrn}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Procedure: ${booking.procedure}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Urgency: ${booking.urgency}',
                  style: TextStyle(
                    fontSize: 16,
                    color: booking.urgency == 'E1- Within 1 hour'
                        ? Colors.red
                        : booking.urgency == 'E2- Within 6 hours'
                        ? Colors.orange
                        : Colors.black,
                    fontWeight: booking.urgency == 'E1- Within 1 hour'
                        ? FontWeight.bold
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Status: ${booking.bookingStatus}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Contact Information:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Consultant: ${booking.consultantName}'),
                        Text('Consultant Phone: ${booking.consultantPhone}'),
                        const SizedBox(height: 8),
                        Text('Physician: ${booking.physicianName}'),
                        Text('Physician Phone: ${booking.physicianPhone}'),
                        const SizedBox(height: 8),
                        Text(
                          'Anesthesia Manager: ${booking.anesthesiaManagerName}',
                        ),
                        Text(
                          'Manager Phone: ${booking.anesthesiaManagerPhone}',
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Anesthesia Consultant: ${booking.anesthesiaConsultantName}',
                        ),
                        Text(
                          'Consultant Phone: ${booking.anesthesiaConsultantPhone}',
                        ),
                      ],
                    ),
                  ),
                ),
                _buildStatusUpdateSection(booking),
                const SizedBox(height: 16),
                const Text(
                  'Comments:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                FutureBuilder<List<Comment>>(
                  future: _commentsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Text('Error loading comments: ${snapshot.error}');
                    }

                    final comments = snapshot.data ?? [];

                    return Column(
                      children: [
                        ...comments.map(
                          (comment) => Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        comment.commenterName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        comment.timestamp
                                            .toLocal()
                                            .toString()
                                            .split('.')[0],
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(comment.commentText),
                                ],
                              ),
                            ),
                          ),
                        ),
                        FormBuilder(
                          key: _commentFormKey,
                          child: Column(
                            children: [
                              FormBuilderTextField(
                                name: 'comment',
                                decoration: const InputDecoration(
                                  labelText: 'Add a comment',
                                  border: OutlineInputBorder(),
                                ),
                                validator: FormBuilderValidators.required(),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () async {
                                  if (_commentFormKey.currentState
                                          ?.saveAndValidate() ??
                                      false) {
                                    final commentText = _commentFormKey
                                        .currentState!
                                        .value['comment'];
                                    final comment = Comment(
                                      bookingId: widget.bookingId,
                                      commenterName:
                                          AuthService().userName ?? 'Unknown',
                                      commentText: commentText ?? '',
                                      timestamp: DateTime.now(),
                                    );
                                    await DatabaseHelper.instance.createComment(
                                      comment,
                                    );
                                    setState(() {
                                      _loadData();
                                    });
                                    _commentFormKey.currentState?.reset();
                                  }
                                },
                                child: const Text('Add Comment'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
