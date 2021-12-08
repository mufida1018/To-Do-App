
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'checkbox_state.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  TextEditingController taskNameController = TextEditingController();
  TextEditingController infoController = TextEditingController();
  List task= [];
  bool value = false;

  @override
  void initState() {
    // TODO: implement initState
    getDataFromFirebase();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     floatingActionButton: FloatingActionButton(
       child: Icon(Icons.add),
       backgroundColor: Colors.blue,
       onPressed: (){
         showAdTask();
       },
     ),
      body: Column(

        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          task != null ?
              Expanded(
                child: ListView.builder(
                  itemCount: task.length,
                    itemBuilder: (context,index){
                      return Card(
                        child: Row(
                          children: [
                            Checkbox(
                                value: value ,
                                onChanged: (value){
                                  setState(() {
                                    this.value = value! ;
                                  });
                                },
                            ),
                               Padding(
                                 padding: const EdgeInsets.only(left: 8.0,right: 150,top: 8,),
                                 child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(task[index]['name'],style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20)),
                                    Text(task[index]['info'],style: TextStyle(fontSize: 10)),
                                  ],
                              ),
                               ),

                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: IconButton(
                                icon: Icon(Icons.delete,color: Colors.redAccent,size: 20,),
                                 onPressed: (){
                                   FirebaseFirestore.instance.collection('task').doc(task[index]['timestamp']).delete();
                                 },
                              ),
                            )
                          ],
                        ),
                      );
                    },
                ),
              ) :  Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Task"),
            ),
          )
        ],
      ),
    );
  }
  void showAdTask(){
    Alert(
        context: context,
        title: "ADD Task",
        content: Column(
          children: <Widget>[
            TextField(
              controller: taskNameController,
              decoration: InputDecoration(
                icon: Icon(Icons.account_circle),
                labelText: 'Task Name',
              ),
            ),
            TextField(
              controller: infoController,
              obscureText: false,
              decoration: InputDecoration(
                icon: Icon(Icons.lock),
                labelText: 'Information',
              ),
            ),
          ],
        ),
        buttons: [
          DialogButton(
            onPressed: () {
              addDataToFirebase();
              Navigator.pop(context);
            },
            child: Text(
              "ADD",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }
  void addDataToFirebase()async{
    var timestamp =  DateTime.now().millisecondsSinceEpoch.toString();
    var uid = await FirebaseAuth.instance.currentUser!.uid;
    var taskData = {
      'userUid': uid,
      'name':taskNameController.text,
      'info':infoController.text,
      'timestamp':timestamp,
      'isDone':false,
    };
    FirebaseFirestore.instance.collection('task').doc(timestamp).set(taskData).then((value){
      taskNameController.text = "";
      infoController.text="";
    });
  }
  void getDataFromFirebase(){
    var uid =  FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance.collection('task').where('userUid', isEqualTo: uid).orderBy('timestamp',descending: false).snapshots().listen((snapshot) {
      if(snapshot != null){
        task = snapshot.docs;
        print(task);
        setState(() {

        });
      }
    });
  }
}
class CheckBoxState{
  final String title ;
  bool value;

  CheckBoxState({
    required this.title,
    this.value= false,
  });
}
