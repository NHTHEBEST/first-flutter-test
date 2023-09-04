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
  @override
  State<TimerScreen> createState() => _TimerScreenState();

}

class _TimerScreenState extends State<TimerScreen> {
  final Stopwatch _stopwatch = Stopwatch();

  late Timer _timer;

  String _result = '00:00:00';

  void _start(){
    _timer = Timer.periodic(const Duration(milliseconds: 30), (Timer t) {
      // Update the UI
      setState(() {
        // result in hh:mm:ss format
        _result =
            '${_stopwatch.elapsed.inMinutes.toString().padLeft(2, '0')}:${(_stopwatch.elapsed.inSeconds % 60).toString().padLeft(2, '0')}:${(_stopwatch.elapsed.inMilliseconds % 100).toString().padLeft(2, '0')}';
      });
    });
    // Start the stopwatch
    _stopwatch.start();
  }
void _stop() {
    _timer.cancel();
    _stopwatch.stop();
  }
 void _reset() {
    _stop();
    _stopwatch.reset();
_result='00:00:00';
    // Update the UI
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timer'),
      ),
      body: Center(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_result, style: const TextStyle(fontSize: 60)),
          const SizedBox(height: 20.0,),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(onPressed: _start, style: ElevatedButton.styleFrom(backgroundColor: Colors.blue), child: const Text('Start'),),
              ElevatedButton(onPressed: _stop, style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Stop'),), // red
              ElevatedButton(onPressed: _reset, style: ElevatedButton.styleFrom(backgroundColor: Colors.green),  child: const Text('Reset')), // green
            ],),
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

  final List<TimerSave> timers = [];
  void addTimer(TimerSave timer) {
    setState(() {
      timers.add(timer);
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
                title: Text(timers[index].toString()),
                subtitle: Text(timers[index].time.toString()),
                // on tap onpen timer screen
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TimerScreen(),
                    ),
                  );
                },
                // on long press delete timer
                onLongPress: () async {
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
        
      ],),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //add item to list
          // get last timer
          try{
            addTimer(TimerSave(id: timers.last.id+1  , name: 'timer', time: 0, runing: false));
          }catch(e){
            addTimer(const TimerSave(id: 0  , name: 'timer', time: 0, runing: false));
          } 
        },
        child: const Icon(Icons.add),
      )
    );
  }
}

class TimerSave {
  final int id;
  final String name;
  final int time; // can be last time if runing or current not time if runing
  final bool runing;

  const TimerSave({
    required this.id,
    required this.name,
    required this.time,
    required this.runing,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'time': time,
      'runing': runing,
    };
  }
  @override
  String toString() {
    return 'TimerSave{id: $id, name: $name, time: $time, runing: $runing}';
  }
}