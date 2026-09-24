import 'package:flutter/material.dart';

import '../../domain/entities/biller.dart';

class BillerListTile
    extends StatelessWidget {
  final Biller biller;
  final VoidCallback onTap;

  const BillerListTile({
    super.key,
    required this.biller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        child: Icon(
          Icons.receipt_long,
        ),
      ),
      title: Text(biller.name),
      subtitle: Text(
        '${biller.category} • ${biller.state}',
      ),
      trailing: const Icon(
        Icons.chevron_right,
      ),
      onTap: onTap,
    );
  }
}