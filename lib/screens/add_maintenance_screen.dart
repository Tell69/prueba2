import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import '../models/maintenance.dart';

class AddMaintenanceScreen extends StatefulWidget {
  final Maintenance? maintenance;

  AddMaintenanceScreen({this.maintenance});

  @override
  _AddMaintenanceScreenState createState() => _AddMaintenanceScreenState();
}

class _AddMaintenanceScreenState extends State<AddMaintenanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tipoServicioController = TextEditingController();
  final _kilometrajeController = TextEditingController();
  final _observacionesController = TextEditingController();
  final _databaseService = DatabaseService();
  
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.maintenance != null) {
      _tipoServicioController.text = widget.maintenance!.tipoServicio;
      _kilometrajeController.text = widget.maintenance!.kilometraje.toString();
      _observacionesController.text = widget.maintenance!.observaciones ?? '';
      _selectedDate = DateTime.parse(widget.maintenance!.fecha);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.maintenance != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Mantenimiento' : 'Nuevo Mantenimiento'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información del Servicio',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _tipoServicioController,
                      decoration: InputDecoration(
                        labelText: 'Tipo de Servicio',
                        hintText: 'ej: Cambio de aceite, Revisión técnica',
                        prefixIcon: Icon(Icons.build),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Ingresa el tipo de servicio';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.grey),
                        SizedBox(width: 16),
                        Text('Fecha: '),
                        TextButton(
                          onPressed: _selectDate,
                          child: Text(
                            DateFormat('dd/MM/yyyy').format(_selectedDate),
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _kilometrajeController,
                      decoration: InputDecoration(
                        labelText: 'Kilometraje',
                        prefixIcon: Icon(Icons.speed),
                        border: OutlineInputBorder(),
                        suffixText: 'km',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Ingresa el kilometraje';
                        }
                        if (int.tryParse(value!) == null) {
                          return 'Ingresa un número válido';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _observacionesController,
                      decoration: InputDecoration(
                        labelText: 'Observaciones (Opcional)',
                        hintText: 'Notas adicionales sobre el servicio',
                        prefixIcon: Icon(Icons.notes),
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _saveMaintenance,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        isEditing ? 'Actualizar Mantenimiento' : 'Guardar Mantenimiento',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveMaintenance() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final maintenance = Maintenance(
        id: widget.maintenance?.id,
        tipoServicio: _tipoServicioController.text,
        fecha: DateFormat('yyyy-MM-dd').format(_selectedDate),
        kilometraje: int.parse(_kilometrajeController.text),
        observaciones: _observacionesController.text.isEmpty 
            ? null 
            : _observacionesController.text,
      );

      if (widget.maintenance != null) {
        await _databaseService.updateMaintenance(maintenance);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mantenimiento actualizado')),
        );
      } else {
        await _databaseService.createMaintenance(maintenance);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mantenimiento guardado')),
        );
      }

      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}