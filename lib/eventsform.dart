import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'DataBase/EventRepository.dart';
import 'Models/Event.dart';
import 'DataBase/DataBase_helper.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:file_picker/file_picker.dart';



class AddEventPage extends StatefulWidget {
   final int userID;

   AddEventPage(userid, {required this.userID});

  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  late EventRepository _eventsRepository;
  late DataBaseHelper _dataBaseHelper;
  DateTime selectedDate = DateTime.now();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  late bool _showImage = false;
  String? imagePath;
  String? audioFilePath;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    _dataBaseHelper = DataBaseHelper.instance;
    await _dataBaseHelper.init();
    _eventsRepository = EventRepository();
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
        imagePath = newImage.path;
        _showImage = true;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final newEvent = Event(
        userid: widget.userID,
        title: _titleController.text,
        description: _descriptionController.text,
        date: _dateController.text,
        imagePath: imagePath,
        audioPath: audioFilePath,
      );

      await _eventsRepository.insert(newEvent);

      // Limpiar los controladores después de enviar el formulario
      _titleController.clear();
      _descriptionController.clear();
      _dateController.clear(); 

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Evento agregado correctamente'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
  
  Future<void> _getAudio() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);
  if (result != null) {
    PlatformFile file = result.files.first;
    audioFilePath = file.path;
    print('Archivo seleccionado: $audioFilePath');
  } else {
    print('Selección de archivo cancelada');
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar evento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Título'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el título del evento';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Descripción'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese la descripción del evento';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: () {
                 DatePicker.showDateTimePicker(
  context,
  showTitleActions: true,
  onChanged: (date) {
    setState(() {
      selectedDate = date;
      // Actualiza el valor del controlador con la fecha seleccionada
      _dateController.text = date.toString();
    });
  },
  onConfirm: (date) {
    setState(() {
      selectedDate = date;
      // Actualiza el valor del controlador con la fecha seleccionada
      _dateController.text = date.toString();
    });
  },
  currentTime: DateTime.now(),
  locale: LocaleType.es,
);
                },
                child: Text('Seleccionar fecha'),
              ),
              Text('Fecha seleccionada: ${selectedDate.toString()}'),
              ElevatedButton(
                onPressed: _getImage,
                child: Text('Seleccionar imagen'),
              ),
              if (_showImage && imagePath != null)
                Image.file(
                  File(imagePath!),
                  width: 100,
                  height: 100,
                ),
              SizedBox(height: 16.0),
              
              ElevatedButton(
  onPressed: _getAudio,
  child: Text('Seleccionar audio'),
),
ElevatedButton(
  onPressed: _submitForm,
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blueAccent,
  ),
  child: Text('Registrar Evento'),
),

            ],
          ),
        ),
      ),
    );
  }
}
