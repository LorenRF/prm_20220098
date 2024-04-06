import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'DataBase/EventRepository.dart';
import 'Models/Event.dart';
import 'DataBase/DataBase_helper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:just_audio/just_audio.dart';
import 'about.dart';
import 'eventsform.dart';

class EventViewPage extends StatefulWidget {
  final int? userID;

  const EventViewPage(int? id, {Key? key, required this.userID}) : super(key: key);

  @override
  _EventViewPageState createState() => _EventViewPageState();
}

class _EventViewPageState extends State<EventViewPage> {
  late EventRepository _eventsRepository;
  late DataBaseHelper _dataBaseHelper;
  late List<Event> _events = [];
  late int _userID;
  var colorwhite = false;

  @override
  void initState() {
    super.initState();
    checkPermissions();
    _userID = widget.userID!;
    _initDatabase();
    _loadEvents();
  }

  void checkPermissions() async {
    if (await Permission.microphone.request().isGranted &&
        await Permission.storage.request().isGranted) {
      print('YA: Permission');
    } else {
      print('no');
    }
  }

  Future<void> _initDatabase() async {
    _dataBaseHelper = DataBaseHelper.instance;
    await _dataBaseHelper.init();
    _eventsRepository = EventRepository();
    _loadEvents();
    
  }

  void colors (int num){
    if (num % 2 == 0){
        colorwhite = false;
    }else{
      colorwhite = true;
    }
  }

  Future<void> _loadEvents() async {
    final List<Event> events = await _eventsRepository.readAll();
    setState(() {
      _events = events.where((event) => event.userid == _userID).toList();
    });
  }

  Future<void> _deleteAllEvents() async {
  await _eventsRepository.deleteEventsByUserId(_userID);

  _loadEvents();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Todos los eventos han sido eliminados'),
      duration: Duration(seconds: 2),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    _loadEvents();
    
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              backgroundColor: Colors.blueAccent,
              expandedHeight: 300.0,
              floating: false,
              pinned: true,
              stretch: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                collapseMode: CollapseMode.parallax,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AddEventPage(_userID, userID: _userID,)),
                        ).then((value) {
                          _loadEvents();
                        });
                      },
                      child: Icon(
                        Icons.add,
                        color: Colors.amber,
                        size: 20, // Icono blanco
                      ),
                    ),
                    ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Cambia el color de fondo del botón
                  ),
                  onPressed: () {
                    _deleteAllEvents();
                  },
                  child: Icon(
                    Icons.delete_forever,
                    color: Colors.white,
                    size: 10, // Icono blanco
                  ),
                ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // Cambia el color de fondo del botón
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AboutPage(_userID, userID: _userID,)),
                        ).then((value) {
                          _loadEvents();
                        });
                      },
                      child: Icon(
                        Icons.person,
                        color: Colors.blueAccent,
                        size: 10, // Icono blanco
                      ),
                    ),
                  ],
                ),
                background: Image.network(
                  "https://i0.wp.com/lavozdelprm.org/wp-content/uploads/2018/09/BanderaPRM.jpg",
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ];
        },
        body: _events.isEmpty
            ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('No tienes eventos agregados'),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent, 
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddEventPage(_userID, userID: _userID,)),
                      ).then((value) {
                        _loadEvents();
                      });
                    },
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 20, // Icono blanco
                    ),
                  ),
                ],
              ),
            )
            : ListView.builder(
              
              itemCount: _events.length,
              itemBuilder: (context, index) {
                final event = _events[index];
                colors(index);
                return Container(
              color: colorwhite ? Colors.white : Colors.blueAccent,
              child:
              ListTile(
                
                  title: Text(event.title),
                  leading: Hero(
                    tag: event.id ?? UniqueKey(),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Image.file(
                        File(event.imagePath ?? "https://th.bing.com/th?id=OIP.Ii15573m21uyos5SZQTdrAHaHa&w=250&h=250&c=8&rs=1&qlt=90&o=6&dpr=1.3&pid=3.1&rm=2"), 
                        width: 100,
                        fit: BoxFit.cover,
                        
                      ),
                    
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => EventDetailsPage(event: event)));
                  },
      ),
                );
              },
            ),
      ),
    );
  }
}
class EventDetailsPage extends StatefulWidget {
  final Event event;

  const EventDetailsPage({Key? key, required this.event}) : super(key: key);

  @override
  _EventDetailsPageState createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  late AudioPlayer player = AudioPlayer();
  late IconData playPauseIcon;
  late bool isPlaying;

  @override
  void initState() {
    super.initState();
    playPauseIcon = Icons.play_arrow;
    isPlaying = false;
    initPlayer();
  }

  void initPlayer() async {
    await player.setUrl(widget.event.audioPath!);
    player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          playPauseIcon = Icons.play_arrow;
          isPlaying = false;
        });
      }
    });
  }

  Future<void> playPause() async {
    if (!isPlaying) {
      await player.play();
      setState(() {
        playPauseIcon = Icons.pause;
        isPlaying = true;
      });
    } else {
      await player.pause();
      setState(() {
        playPauseIcon = Icons.play_arrow;
        isPlaying = false;
      });
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.event.title)),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Hero(
                tag: widget.event.id ?? UniqueKey(),
                child: Image.file(
                  File(widget.event.imagePath ?? ""),
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.event.title,
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.event.description,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Fecha: ${widget.event.date}",
                    style: Theme.of(context).textTheme.bodyText2,
                    selectionColor: Colors.black,
                  ),
                  SizedBox(height: 8),
                  IconButton(
                    icon: Icon(playPauseIcon),
                    onPressed: playPause,
                    iconSize: 48.0,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
