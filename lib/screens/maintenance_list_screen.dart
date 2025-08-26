import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/maintenance.dart';
import '../widgets/maintenance_card.dart';
import 'add_maintenance_screen.dart';
import 'login_screen.dart';

class MaintenanceListScreen extends StatefulWidget {
  @override
  _MaintenanceListScreenState createState() => _MaintenanceListScreenState();
}

class _MaintenanceListScreenState extends State<MaintenanceListScreen> {
  final _authService = AuthService();
  final _databaseService = DatabaseService();
  List<Maintenance> _maintenances = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMaintenances();
  }

  Future<void> _loadMaintenances() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final maintenances = await _databaseService.getMaintenances();
      setState(() {
        _maintenances = maintenances;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar mantenimientos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Mantenimientos'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _maintenances.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.car_repair,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No hay mantenimientos registrados',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Toca el botón + para agregar uno',
                        style: TextStyle(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _maintenances.length,
                  itemBuilder: (context, index) {
                    return MaintenanceCard(
                      maintenance: _maintenances[index],
                      onDelete: () => _deleteMaintenance(_maintenances[index].id!),
                      onEdit: () => _editMaintenance(_maintenances[index]),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddMaintenanceScreen(),
            ),
          );
          if (result == true) {
            _loadMaintenances();
          }
        },
        child: Icon(Icons.add),
        tooltip: 'Agregar Mantenimiento',
      ),
    );
  }

  Future<void> _deleteMaintenance(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de eliminar este mantenimiento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Eliminar'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _databaseService.deleteMaintenance(id);
        _loadMaintenances();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mantenimiento eliminado')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar')),
        );
      }
    }
  }

  Future<void> _editMaintenance(Maintenance maintenance) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddMaintenanceScreen(maintenance: maintenance),
      ),
    );
    if (result == true) {
      _loadMaintenances();
    }
  }
}