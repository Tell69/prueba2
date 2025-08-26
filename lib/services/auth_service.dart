import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Usuario actual
  User? get currentUser => _auth.currentUser;

  // Stream de estado de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Registrar usuario
  Future<AuthResult> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return AuthResult(success: true, message: 'Usuario registrado correctamente');
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthException(e);
    } catch (e) {
      print('Error al registrar: $e');
      return AuthResult(success: false, message: 'Error inesperado al registrar');
    }
  }

  // Iniciar sesión
  Future<AuthResult> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return AuthResult(success: true, message: 'Sesión iniciada correctamente');
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthException(e);
    } catch (e) {
      print('Error al iniciar sesión: $e');
      return AuthResult(success: false, message: 'Error inesperado al iniciar sesión');
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error al cerrar sesión: $e');
    }
  }

  // Manejar excepciones específicas de Firebase Auth
  AuthResult _handleFirebaseAuthException(FirebaseAuthException e) {
    String message;
    
    switch (e.code) {
      case 'network-request-failed':
        message = 'Error de conexión. Verifica tu conexión a internet e intenta nuevamente.';
        break;
      case 'user-not-found':
        message = 'No existe una cuenta con este email.';
        break;
      case 'wrong-password':
        message = 'Contraseña incorrecta.';
        break;
      case 'email-already-in-use':
        message = 'Ya existe una cuenta con este email.';
        break;
      case 'weak-password':
        message = 'La contraseña es muy débil.';
        break;
      case 'invalid-email':
        message = 'Email inválido.';
        break;
      case 'too-many-requests':
        message = 'Demasiados intentos. Espera un momento e intenta nuevamente.';
        break;
      case 'operation-not-allowed':
        message = 'Operación no permitida. Contacta al administrador.';
        break;
      default:
        message = 'Error de autenticación: ${e.message}';
    }
    
    return AuthResult(success: false, message: message);
  }
}

// Clase para manejar resultados de autenticación
class AuthResult {
  final bool success;
  final String message;
  
  AuthResult({required this.success, required this.message});
}