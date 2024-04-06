import '../Models/Event.dart';
import 'DataBase_helper.dart';

class EventRepository {
  final database = DataBaseHelper.instance.db;

  Future<List<Event>> readAll() async {
    final data = await database.query('Eventos');
    return data.map((e) => Event.fromMap(e)).toList();
  }

  Future<int> insert(Event event) async {
    return await database.insert('Eventos', event.toMap());
  }

  Future<void> update(Event event) async {
    await database.update('Eventos', event.toMap(), where: 'id = ?', whereArgs: [event.id]);
  }

  Future<void> delete(Event event) async {
    await database.delete('Eventos', where: 'id = ?', whereArgs: [event.id]);
  }

  Future<void> deleteEventsByUserId(int userId) async {
    await database.delete('Eventos', where: 'userid = ?', whereArgs: [userId]);
  }

}
