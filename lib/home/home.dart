import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neighborhood/creation/create_post.dart';
import 'package:neighborhood/home/view_all_alerts.dart';
import 'package:neighborhood/home/view_all_polls.dart';
import 'package:neighborhood/home/view_all_events.dart';
import 'package:neighborhood/home/profile.dart';
import 'package:neighborhood/services/auth.dart';
import 'package:provider/provider.dart';
import 'contact.dart';
import 'feed.dart';

//Parent widget of the tabbed homepage

class Home extends StatefulWidget {
  const Home({ Key key }) : super(key: key);
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> with SingleTickerProviderStateMixin {

  final currentHood = "Demo";

  String getHood(){
    return this.currentHood;
  }


  final List<Tab> myTabs = <Tab>[
    Tab(text: 'Home'),
    Tab(text: 'Events'),
    Tab(text: 'Polls'),
    Tab(text: 'Alerts'),
  ];


  TabController _tabController;

  Future<void> _signOut(BuildContext context) async{
    try{
      final auth = Provider.of<AuthBase>(context, listen: false);
      await auth.signOut();
    }catch(e){
      print(e.toString());
    }
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Signing Out', style: TextStyle(fontFamily: 'AirbnbCereal', fontSize: 20.0),),
            content: Text('Are you sure you want to sign out?', style: TextStyle(fontSize: 16.0, fontFamily: 'AirbnbCerealLight')),
            elevation: 2.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(12.0),
              ),
//          side: BorderSide(color: Colors.grey[300], width: 1.6),
            ),
            actions: [
              FlatButton(
                child: Text(
                  'Cancel',
                  style: TextStyle(fontSize: 14.0),
                ),
                textColor: Theme.of(context).accentColor,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text('Continue'),
                textColor: Theme.of(context).accentColor,
                onPressed: () {
                  _signOut(context);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }
    );
  }

  void _toCreation(BuildContext context){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreatePost()),
    );
  }



  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: myTabs.length);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: Container(
          color: Colors.white,
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ProfileView()
                  ]
              )

              ),
              ListTile(
                leading: Icon(Icons.sort),
                title: Text('Contacts & Helplines'),
                onTap: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Emergency()),
                  ),
                }
              ),

              ListTile(
                  leading: Icon(Icons.exit_to_app, color: Colors.red[400],),
                  title:Text('Sign Out', style: TextStyle(color: Colors.red[400]),),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmSignOut(context);
                  }
              ),

            ],
          ),
        ),
      ),

      appBar: AppBar(
        title: Text(
            'Demo Hood',
            style: TextStyle(color: Colors.black87, fontSize: 22.0, fontFamily: 'AirbnbCerealBold')
        ),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: new IconThemeData(color: Colors.black87),
        titleSpacing: 0.0,
        elevation: 1.0,
        bottom: TabBar(
          controller: _tabController,
          tabs: myTabs,
          indicatorColor: Theme.of(context).accentColor,
          labelColor: Colors.black87,
          unselectedLabelColor: Colors.black54,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[Feed(), Events(), Polls(), Alerts()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _toCreation(context);
          // Add your onPressed code here!
        },
        child: Icon(Icons.add, color: Colors.white, size: 24.0,),
        backgroundColor: Theme.of(context).accentColor,
        elevation: 2.0,
      ),
    );
  }
}
