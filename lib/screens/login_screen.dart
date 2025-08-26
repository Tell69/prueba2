import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'maintenance_list_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _isLoginMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[400]!, Colors.blue[600]!],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(32),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.car_repair,
                          size: 64,
                          color: Colors.blue[600],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Mantenimiento Vehicular',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 32),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Ingresa tu email';
                            }
                            if (!value!.contains('@')) {
                              return 'Email inválido';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Ingresa tu contraseña';
                            }
                            if (value!.length < 6) {
                              return 'Mínimo 6 caracteres';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 24),
                        _isLoading
                            ? Column(
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 16),
                                  Text('Conectando...'),
                                ],
                              )
                            : SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: _handleAuth,
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    _isLoginMode ? 'Iniciar Sesión' : 'Registrarse',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                        SizedBox(height: 16),
                        TextButton(
                          onPressed: _isLoading ? null : () {
                            setState(() {
                              _isLoginMode = !_isLoginMode;
                            });
                          },
                          child: Text(
                            _isLoginMode 
                                ? '¿No tienes cuenta? Regístrate'
                                : '¿Ya tienes cuenta? Inicia sesión',
                          ),
                        ),
                        // Botón de reintentar para problemas de conectividad
                        if (!_isLoading)
                          TextButton(
                            onPressed: _testConnection,
                            child: Text('Probar conectividad'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    AuthResult result;
    if (_isLoginMode) {
      result = await _authService.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } else {
      result = await _authService.register(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }

    setState(() {
      _isLoading = false;
    });

    if (result.success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MaintenanceListScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.message.contains('conexión') ? Colors.orange : Colors.red,
          duration: Duration(seconds: 4),
          action: result.message.contains('conexión') ? SnackBarAction(
            label: 'Reintentar',
            onPressed: _handleAuth,
            textColor: Colors.white,
          ) : null,
        ),
      );
    }
  }

  Future<void> _testConnection() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Verificando conectividad...'),
        duration: Duration(seconds: 2),
      ),
    );
    
    // Intento básico de conexión
    try {
      await _authService.signIn('test@test.com', '123456');
    } catch (e) {
      // Esto solo es para probar la conectividad
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}