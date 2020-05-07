import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:neighborhood/creation/result.dart';
import 'package:neighborhood/services/auth.dart';
import 'package:uuid/uuid.dart';

class Message extends StatefulWidget {
  @override
  _MessageState createState() => _MessageState();
}

class _MessageState extends State<Message> {
  var uuid = Uuid();
  final db = Firestore.instance;//Link to database
  //Result result;

  List<String> _category = [
    'General',
    'For Sale',
    'Crime & Safety',
    'Lost & Found'
  ];

  String categoryField;
  String titleField;
  String messageField;
  var userID;

  final _messageKey = GlobalKey<FormState>();
  //Result result = Result();
  String _selectedCategory;
  File _image;

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
  //This function allows the user to upload an image.
  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);//await function, waits for image to upload
    setState(() {
      _image = image;
    });
  }
//This function uploads  all the data from the Message field to the database
  void sendData() async {
    String url;
    if (_image != null){
      var fName = uuid.v4();
      final StorageReference firebaseStorageRef = FirebaseStorage.instance.ref()
          .child(fName);
      final StorageUploadTask task = firebaseStorageRef.putFile(_image);
      var downUrl = await(await task.onComplete).ref.getDownloadURL();
      url = downUrl.toString();
    }//uploading image to database

    final auth = Provider.of<AuthBase>(context, listen: false);
    final user = await auth.getUserData();
    var comments = new Map();
    //Accesses database tree structure for appropriate storage
    await db
        .collection("Neighborhoods")
        .document("Demo")
        .collection("Messages")
        .add({
      'user': user.uid,
      'user_name': user.displayName,
      'category': categoryField,
      'title': titleField,
      'description': messageField,
      'image': url,
      'comments': comments,
      'timestamp': DateTime.now(),
    });
  }




  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width; //Gets the width of the user's screen to adjust size of text boxes accordingly
    var blockSize = width / 100; //
    var form = Form(
      key: _messageKey,
      child: SingleChildScrollView(//Creates a scrollable page incase the height of the page is longer than the user's phone screen.
        child: Column(
          children: <Widget>[
            Container(
              margin: new EdgeInsets.only(
                  left: blockSize * 10,
                  right: blockSize * 10.0,
                  top: blockSize * 10.0),
              child: DropdownButtonFormField( //DropDown menu for Selected a category
                hint: Text('Please choose a category'),
                value: _selectedCategory,
                onChanged: (newValue) {
                  setState(() { //Stores chosen category into variables for later use
                    _selectedCategory = newValue;
                    categoryField = newValue;
                  });
                },
                items: _category.map((_category) { //maps the category list at the start of the code onto the dropdown menue
                  return DropdownMenuItem(
                    child: new Text(_category),
                    value: _category,
                  );
                }).toList(),
                //This is for aesthetic purposes, creates rounded border
                decoration: InputDecoration(
                  fillColor: Colors.white,//Background color is white for the list
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(blockSize * 5), //Creates a tapered border.
                    borderSide: BorderSide(),
                  ),
                ),
              ),
            ),
            //Container for Title Textbox.
            Container(
              margin:
                  EdgeInsets.only(top: blockSize * 5, right: blockSize * 10),
              child: TextFormField(
                controller: title,//textfieldcontroller for retrieving value later
                maxLength: 30,//Max title length is 30 characters
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter a Title';//Error shown if Title box is left empty
                  }
                  return null;
                },
                decoration: InputDecoration(
                  icon: Icon(Icons.keyboard_arrow_right),//Generates arrow on the left side of the title box
                  fillColor: Colors.white,//Background color is white for the textbox
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(blockSize * 5.0),//Sets the border curve of the Title box
                    borderSide: BorderSide(),
                  ),
                  hintText: 'Enter your Title',
                  labelText: 'Title',
                ),
                onSaved: (String value) {},
              ),
            ),
            //Container for Message box
            Container(
              margin:
                  EdgeInsets.only(right: blockSize * 10, top: blockSize * 5),//Alligns the Message Field on the screen
              child: TextFormField(
                controller: message,//textfieldcontroller for retrieving value later
                keyboardType: TextInputType.multiline,// Message can be of multiple lines
                maxLines: null,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter your Message';//Error shown if left empty
                  }
                  return null;
                },
                decoration: InputDecoration(
                  fillColor: Colors.white,//Background color is white for the textbox
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(blockSize * 5.0),//Sets the tapered border
                    borderSide: BorderSide(),
                  ),
                  icon: Icon(Icons.keyboard_arrow_right),//arrow on the left side of the message box
                  hintText: 'Enter your Message',
                  labelText: 'Message',
                ),
                onSaved: (String value) {},
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                  left: blockSize * 10.0, top: blockSize * 10.0),//Aligns the image and Post button
                  //Row to hold image button and post button
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 0.0, right: 0.0),
                    child: FloatingActionButton(
                      onPressed: getImage,//Function for uploading image defined above
                      tooltip: 'Pick Image',
                      child: new Icon(Icons.add_a_photo),
                      backgroundColor: Theme.of(context).accentColor,
                      elevation: 1.0,
                    ),
                  ),
                  //Container for Post Button
                  Container(
                    margin: EdgeInsets.only(left: blockSize * 15),
                    child: SizedBox(
                      height: blockSize * 15,//Defines height of the button
                      width: blockSize * 50,//Defines width of the button
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                new BorderRadius.circular(blockSize * 5.0),//Tapers the border
                            side: BorderSide(
                                color: Theme.of(context).accentColor)),
                        color: Theme.of(context).accentColor,
                        elevation: 1.0,
                        onPressed: () {
                          //Shows a snackbar if all fields are filled and valid
                          if (_messageKey.currentState.validate()) {
                            Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text('Message Created!')));
                          }
                          titleField = title.text;//stores title value
                          messageField = message.text;//stores message value
                          sendData();//function send data to the database
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
            //Container to show the uploaded image
            Container(
              margin:
                  EdgeInsets.only(right: blockSize * 40, top: blockSize * 2),
              child: _image == null
                  ? Text('No Image')//Message if no image is uploaded
                  : SizedBox(
                      height: blockSize*50,
                      width: blockSize*50,
                      child: Image.file(_image),
                    ),
            ),
          ],
        ),
      ),
    );

    return form;//returns widget
  }
}
