import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'DataBase/UserRepository.dart';
import 'Models/User.dart';
import 'DataBase/DataBase_helper.dart';
import 'package:path_provider/path_provider.dart';

class UserRegistration extends StatefulWidget {
  const UserRegistration({Key? key}) : super(key: key);

  @override
  _UserRegistrationState createState() => _UserRegistrationState();
}

class _UserRegistrationState extends State<UserRegistration> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _matriculaController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _photoUrl;
  late bool _showImage = false;
  late DataBaseHelper _dataBaseHelper;
  late UserRepository _userRepository;

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

Future<void> _getImage() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  if (pickedFile != null) {
    final directory = await getApplicationDocumentsDirectory();
    final mediaDirectory = Directory('${directory.path}/media');
    if (!await mediaDirectory.exists()) {
      await mediaDirectory.create(recursive: true);
    }
    final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final File newImage = await File(pickedFile.path).copy('${mediaDirectory.path}/$fileName');
    
    setState(() {
      _photoUrl = newImage.path;
      _showImage = true;
    });
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro de Usuario'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(labelText: 'Nombre'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese su nombre';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(labelText: 'Apellido'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese su apellido';
                    }
                    return null;
                  },
                ),
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
                  decoration: InputDecoration(labelText: 'Password'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese una contraseña';
                    }
                    return null;
                  },
                ),
                ElevatedButton(
                  onPressed: _getImage,
                  child: Text('Seleccionar imagen'),
                ),
                if (_showImage && _photoUrl != null)
                  Image.file(
                    File(_photoUrl!),
                    width: 100,
                    height: 100,
                  ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Registrar Usuario'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                  )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newUser = User(
        photoUrl: _photoUrl ?? '',
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        matricula: _matriculaController.text,
        password: _passwordController.text,
      );

      _saveUser(newUser);

      _firstNameController.clear();
      _lastNameController.clear();
      _matriculaController.clear();
      _passwordController.clear();

      setState(() {
        _showImage = false;
      });
    }
  }

  void _saveUser(User user) async {

final existinguser = await _userRepository.readUser(user.matricula);
print(existinguser);
if(existinguser == null){
    try {
      
      await _userRepository.insert(user);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Usuario registrado correctamente'),
        duration: Duration(seconds: 2),
      ));
      
    } catch (e) {
      print('Error al registrar el usuario: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error al registrar el usuario'),
        duration: Duration(seconds: 2),
      ));
    }
} else {ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Este Usuario ya existe'),
        duration: Duration(seconds: 2),
        ));
}
  }
}
