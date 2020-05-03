import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neighborhood/creation/result.dart';
import 'package:neighborhood/services/auth.dart';

class Message extends StatefulWidget {
  @override
  _MessageState createState() => _MessageState();
}

class _MessageState extends State<Message> {
  final db = Firestore.instance;
  Result result;

  List<String> _category = [
    'General',
    'For Sale',
    'Crime & Safety',
    'Lost & Found'
  ];

  final title = TextEditingController();

  @override
  final message = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    message.dispose();
    title.dispose();
    super.dispose();
  }

  void sendData() async {
    await db
        .collection("Neighborhoods")
        .document("Demo")
        .collection("Messages")
        .add({
      'user': "Insert UserID",
      'category': categoryField,
      'title': titleField,
      'post': messageField,
    });
  }

  String categoryField;
  String titleField;
  String messageField;
  var userID;

  final _messageKey = GlobalKey<FormState>();
  //Result result = Result();
  String _selectedCategory;
  File _image;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    var width = MediaQuery.of(context).size.width;
    var blockSize = width / 100;
    var form = Form(
      key: _messageKey,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // FutureBuilder(
            //   future: auth.currentUserID(),
            //   builder: (context,snapshot){
            //     if(snapshot.connectionState == ConnectionState.done){
            //       userID=snapshot.data;
            //       return ;
            //       }
            //   }
            // ),
            Container(
              margin: new EdgeInsets.only(
                  left: blockSize * 10,
                  right: blockSize * 10.0,
                  top: blockSize * 10.0),
              child: DropdownButtonFormField(
                hint: Text('Please choose a category'),
                value: _selectedCategory,
                onChanged: (newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                    categoryField = newValue;
                  });
                },
                items: _category.map((_category) {
                  return DropdownMenuItem(
                    child: new Text(_category),
                    value: _category,
                  );
                }).toList(),
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(blockSize * 10),
                    borderSide: BorderSide(),
                  ),
                ),
              ),
            ),
            Container(
              margin:
                  EdgeInsets.only(top: blockSize * 5, right: blockSize * 10),
              child: TextFormField(
                controller: title,
                maxLength: 30,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter a Title';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  icon: Icon(Icons.keyboard_arrow_right),
                  fillColor: Colors.white,
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(blockSize * 25.0),
                    borderSide: BorderSide(),
                  ),
                  hintText: 'Enter your Title',
                  labelText: 'Title',
                ),
                onSaved: (String value) {},
              ),
            ),
            Container(
              margin:
                  EdgeInsets.only(right: blockSize * 10, top: blockSize * 5),
              child: TextFormField(
                controller: message,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter your Message';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(blockSize * 25.0),
                    borderSide: BorderSide(),
                  ),
                  icon: Icon(Icons.keyboard_arrow_right),
                  hintText: 'Enter your Message',
                  labelText: 'Message',
                ),
                onSaved: (String value) {},
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                  left: blockSize * 10.0, top: blockSize * 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 0.0, right: 0.0),
                    child: FloatingActionButton(
                      onPressed: getImage,
                      tooltip: 'Pick Image',
                      child: new Icon(Icons.add_a_photo),
                      backgroundColor: Theme.of(context).accentColor,
                      elevation: 1.0,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: blockSize * 15),
                    child: SizedBox(
                      height: blockSize * 15,
                      width: blockSize * 50,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                new BorderRadius.circular(blockSize * 18.0),
                            side: BorderSide(
                                color: Theme.of(context).accentColor)),
                        color: Theme.of(context).accentColor,
                        elevation: 1.0,
                        onPressed: () {
                          if (_messageKey.currentState.validate()) {
                            Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text('Posting your Message')));
                          }
                          titleField = title.text;
                          messageField = message.text;
                          sendData();
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Post',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin:
                  EdgeInsets.only(right: blockSize * 50, top: blockSize * 5),
              child: _image == null
                  ? Text('No Image Selected.')
                  : SizedBox(
                      height: 100 % blockSize,
                      width: 100 % blockSize,
                      child: Image.file(_image),
                    ),
            ),
          ],
        ),
      ),
    );

    return form;
  }
}
