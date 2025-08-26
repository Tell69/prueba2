import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/maintenance.dart';

class MaintenanceCard extends StatelessWidget {
  final Maintenance maintenance;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const MaintenanceCard({
    Key? key,
    required this.maintenance,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(maintenance.fecha);
    final formattedDate = DateFormat('dd/MM/yyyy').format(date);

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.build_circle,
                  color: Colors.blue[600],
                  size: 24,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    maintenance.tipoServicio,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Eliminar', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  formattedDate,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                SizedBox(width: 16),
                Icon(Icons.speed, size: 16, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  '${maintenance.kilometraje} km',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            if (maintenance.observaciones != null && 
                maintenance.observaciones!.isNotEmpty) ...[
              SizedBox(height: 8),
              Text(
                maintenance.observaciones!,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}