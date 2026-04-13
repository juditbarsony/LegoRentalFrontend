import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:lego_rental_frontend/core/models/rental_model.dart';
import 'package:lego_rental_frontend/features/rentals/rental_providers.dart';

class MyRentalsScreen extends ConsumerStatefulWidget {
  const MyRentalsScreen({super.key});

  @override
  ConsumerState<MyRentalsScreen> createState() => _MyRentalsScreenState();
}

class _MyRentalsScreenState extends ConsumerState<MyRentalsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(myRentalsProvider.notifier).load();
    });
  }

  String _formatRentalPeriod(DateTime startDate, DateTime endDate) {
    final formatter = DateFormat('yyyy.MM.dd');
    return '${formatter.format(startDate)} - ${formatter.format(endDate)}';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myRentalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Rentals'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null
              ? Center(child: Text(state.errorMessage!))
              : ListView.builder(
                  itemCount: state.rentals.length,
                  itemBuilder: (context, index) {
                    final rental = state.rentals[index];

                    return ListTile(
                      title: Text(rental.setTitle ?? 'Unknown set'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Owner: ${rental.ownerName ?? 'Unknown owner'}'),
                          Text(
                            'Rental period: ${_formatRentalPeriod(rental.startDate, rental.endDate)}',
                          ),
                          Text('Status: ${rental.status}'),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}