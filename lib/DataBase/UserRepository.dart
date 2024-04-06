import '../Models/User.dart';
import 'DataBase_helper.dart';

class UserRepository {
  final database = DataBaseHelper.instance.db;

  Future<User?> readUser(String id) async {
    final data = await database.query('Usuarios', where: 'matricula = ?', whereArgs: [id]);
    if (data.isNotEmpty) {
      return User.fromMap(data.first);
    } else {
      return null;
    }
  }

  Future<User?> readUserbyid(int id) async {
    final data = await database.query('Usuarios', where: 'id = ?', whereArgs: [id]);
    if (data.isNotEmpty) {
      return User.fromMap(data.first);
    } else {
      return null;
    }
  }

  Future<void> insert(User user) async {
    await database.insert('Usuarios', user.toMap());
  }

}
