// basic flutter app
import 'dart:async';
import 'package:flutter/material.dart';

import 'package:confirm_dialog/confirm_dialog.dart';


void main() 
{
  
  runApp(MyApp());

}

//my app
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //home: FirstScreen(),
      debugShowCheckedModeBanner: false,
      //home: TimerScreen(),
      home:TimerListScreen()
    );
  }
}




class TimerScreen extends StatefulWidget {
  // get timer on create
  const TimerScreen({Key? key, required this.timer}) : super(key: key);
  final TimerSave timer;
  @override
  State<TimerScreen> createState() => _TimerScreenState(timer: timer);

}

class _TimerScreenState extends State<TimerScreen> {

    TimerSave timer;
  _TimerScreenState({required this.timer});

  late Timer _timer;
  final fieldText = TextEditingController();

  String _result = '00:00:00';
  String lastlog = "";

  void _start(){
    _timer = Timer.periodic(const Duration(milliseconds: 30), (Timer t) {
      // Update the UI
      try{
      setState(() {
        // get time now
        int now = DateTime.now().millisecondsSinceEpoch;
        // get time since last update
        int time = now - timer.lasttime;
        // add time to running time
        if(timer.runing){
        timer.runningtime += time;
        // set last time to now
        timer.lasttime = now;
        // convert time to string
        _result = Duration(milliseconds: timer.runningtime).toString().split('.').first.padLeft(8, "0");}
        
    });}catch(e){
      // do nothing}
    }
    });
    // Start the stopwatch
   timer.runing = true;
   // set timer.lasttime to now
    timer.lasttime = DateTime.now().millisecondsSinceEpoch;
    // Update the UI
    
  }


@override
void initState() {
  _start();
  super.initState();
}

  @override
  Widget build(BuildContext context) {
   // _start();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timer'),
      ),
      body: Center(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // timer name
          Text(timer.name, style: const TextStyle(fontSize: 60)),
          // spacer
          const SizedBox(height: 100.0,),
          Text(_result, style: const TextStyle(fontSize: 60)),
          const SizedBox(height: 20.0,),
          
            // some spaceing 
            const SizedBox(height: 60.0,),
            Text(lastlog),
            const SizedBox(height: 20.0,),
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                //on submit set lastlog to text

              ),
              // on submit set lastlog to text
              onSubmitted: (String value) async {
                setState(() {
                  lastlog = value;
                  // clear text
                  fieldText.clear();
                });
              },
              controller: fieldText,
            ),
            // submit button for text field
            ElevatedButton(onPressed: () async {
              setState(() {
                lastlog = fieldText.text;
                // clear text
                fieldText.clear();
              });
            }, child: const Text('Submit'),),
            //spacer
            const SizedBox(height: 200.0,),
            // send log button
            ElevatedButton(onPressed: () async {
              // send log to server
              // clear lastlog
              setState(() {
                lastlog = "";
              });
            }, child: const Text('Send Log'),),
            ],
            ),)
    );

  }
}



// screen with a list of timers and a button to add a new timer and a button to delete a timer
class TimerListScreen extends StatefulWidget{
  @override
  State<TimerListScreen> createState() => _TimerListScreen();
}

class _TimerListScreen extends State<TimerListScreen>{
late Timer _timer;
  final List<TimerSave> timers = [];
  int running = 0;
  bool editing = false;
  void addTimer(TimerSave timer) {
    setState(() {
      timers.add(timer);
    });
  }
  void stoppall()
  {
    // stop all timers
    for (var i = 0; i < timers.length; i++) {
      timers[i].runing = false;
    }
  }

@override
void initState() {
  super.initState();
  _timer = Timer.periodic(const Duration(milliseconds: 30), (Timer t) {
    setState(() {
      for (var i = 0; i < timers.length; i++) {
        if(timers[i].runing){
          timers[i].runningtime += DateTime.now().millisecondsSinceEpoch - timers[i].lasttime;
          timers[i].lasttime = DateTime.now().millisecondsSinceEpoch;
        }
      }
    });
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Timers"),
      ),
      body: Column(children: [
        Expanded(
          child: ListView.builder(
            itemCount: timers.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(style: (){if (editing ){ return const TextStyle(fontStyle: FontStyle.italic); }}(),timers[index].name),
                subtitle: Text(Duration(milliseconds: timers[index].runningtime).toString().split('.').first.padLeft(8, "0")),
                selected: timers[index].runing,
                // if editing make italic
                
                // on tap onpen timer screen
                onTap: () {
                  if (editing)
                  {
                    // name change popup
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('Change Name'),
                        content: TextField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          // on submit set lastlog to text
                          onSubmitted: (String value) async {
                            setState(() {
                              timers[index].name = value;
                            });
                          },
                          controller: TextEditingController(text: timers[index].name),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(context, 'OK'),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                    
                    return;
                  }
                  // stop all timers
                  for (var i = 0; i < timers.length; i++) {
                    timers[i].runing = false;
                  }
                  // start selected timer
                  timers[index].runing = true;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TimerScreen(timer: timers[index]),
                    ),
                  );
                },
                // on long press delete timer
                onLongPress: () async {
                  // check if timer running 
                  if(timers[index].runing){
                    // popup
                    await showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('Timer Running'),
                        content: const Text('Please stop timer before deleting'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(context, 'OK'),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                    return;
                  }
                  if (await confirm(
                    context, 
                    title: const Text('Delete Timer?'),
                    content: const Text('This will delete the timer'),
                    textOK: const Text('Yes'),
                    textCancel: const Text('No'),
                    )) {  
                      setState(() {
                       timers.removeAt(index);
                    });
                  }
                },
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(onPressed: stoppall, 
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Stop timers"),
            ),
          // edit button
            ElevatedButton(onPressed: (){editing= !editing;}, child: (){if (editing) {return const Text("Done");} else {return const Text("Edit");}}()),
          
          ],
        )
      ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //add item to list
          // get last timer
          try{
            addTimer(TimerSave(id: timers.last.id + 1  , name: 'timer '+(timers.last.id+2).toString(), runningtime: 0, runing: false, lasttime: 0));
          }catch(e){
            addTimer(TimerSave(id: 0  , name: 'timer 1', runningtime: 0, runing: false, lasttime: 0));
          } 
        },
        child: const Icon(Icons.add),
      )
    );
  }
}

class TimerSave {
 
   int id;
   String name;
   int runningtime;
   int lasttime;
   bool runing;

   TimerSave({
    required this.id,
    required this.name,
    required this.runningtime,
    required this.lasttime,
    required this.runing,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'runningtime': runningtime,
      'lasttime': lasttime,
      'runing': runing,
    };
  }

  @override
  String toString() {
    return 'TimerType{id: $id, name: $name, runningtime: $runningtime, lasttime: $lasttime, runing: $runing}';
  }
  
}