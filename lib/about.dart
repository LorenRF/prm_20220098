import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'DataBase/UserRepository.dart';
import 'Models/User.dart';
import 'DataBase/DataBase_helper.dart';

class AboutPage extends StatefulWidget {
  final int userID;

  AboutPage(userid, {required this.userID});

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  late Future<User?> _userFuture;
  late UserRepository _userRepository;
  late DataBaseHelper _dataBaseHelper;
  final List<String> reflections = [
    "La democracia es la forma de gobierno en la que el poder político es ejercido por el pueblo.",
    "Las elecciones son el instrumento fundamental de la democracia, permitiendo que el pueblo elija a sus representantes.",
    "El servicio cívico es la contribución individual al bienestar de la comunidad y al fortalecimiento de la democracia.",
    "La participación ciudadana es esencial para el funcionamiento efectivo de la democracia.",
    "La democracia es un proceso continuo de diálogo, debate y acción para promover el bien común."
  ];

  @override
  void initState() {
    super.initState();
    _initDatabase();
    _userFuture = _getUser(widget.userID);
  }

  Future<void> _initDatabase() async {
    _dataBaseHelper = DataBaseHelper.instance;
    await _dataBaseHelper.init();
    _userRepository = UserRepository();
    
  }

  Future<User?> _getUser(int id) async {
    print(id);
    _userRepository = UserRepository();
    return _userRepository.readUserbyid(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Acerca de'),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<User?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final User? user = snapshot.data;
            if (user == null) {
              return Center(child: Text('No se encontró el usuario'));
            } else {
              final userName = user.firstName ?? '';
              final userLastName = user.lastName ?? '';
              final userMatricula = user.matricula ?? '';
              final random = Random();
              final reflection = reflections[random.nextInt(reflections.length)];

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: FileImage(File(user?.photoUrl ?? "https://th.bing.com/th?id=OIP.Ii15573m21uyos5SZQTdrAHaHa&w=250&h=250&c=8&rs=1&qlt=90&o=6&dpr=1.3&pid=3.1&rm=2")), 
                    ),
                    SizedBox(height: 16),
                    Text(
                      '$userName $userLastName',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Matrícula: $userMatricula',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 32),
                    Text(
                      reflection,
                      style: TextStyle(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }
          }
        },
      ),
    );
  }
}
