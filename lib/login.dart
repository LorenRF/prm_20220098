import 'package:flutter/material.dart';
import 'DataBase/UserRepository.dart';
import 'Models/User.dart';
import 'DataBase/DataBase_helper.dart';
import 'eventsview.dart';
import 'singin.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _matriculaController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late UserRepository _userRepository;
  late DataBaseHelper _dataBaseHelper;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    _dataBaseHelper = DataBaseHelper.instance;
    await _dataBaseHelper.init();
    _userRepository = UserRepository();
  }
 void _navigateToRegistration() {
    // Navega a la vista de registro
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserRegistration()),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio de Sesión'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _matriculaController,
                decoration: InputDecoration(labelText: 'Matrícula'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese su matrícula';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese su contraseña';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Iniciar Sesión'),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _navigateToRegistration,
              
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              child: Text('Registrarte'),
            ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
  if (_formKey.currentState!.validate()) {
    final matricula = _matriculaController.text;
    final password = _passwordController.text;

    try {
      final user = await _userRepository.readUser(matricula);
      print(user?.password);
      if (user?.password == password) {

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EventViewPage(user?.id, userID: user?.id,)),
    );
        print('Autenticación exitosa');
      } else {
        print('Contraseña incorrecta');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Contraseña incorrecta'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Error al obtener el usuario
      print('Error al autenticar: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al autenticar'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

}
