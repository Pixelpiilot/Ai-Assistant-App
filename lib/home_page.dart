
import 'dart:io';
//import 'dart:nativewrappers/_internal/vm/lib/typed_data_patch.dart';
//import 'dart:nativewrappers/_internal/vm/lib/typed_data_patch.dart';
import 'dart:typed_data';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);


  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Gemini gemini = Gemini.instance;

  List<ChatMessage> messages = [];

  ChatUser currentUser = ChatUser(id: "0", firstName: "User");
  ChatUser geminiUser = ChatUser(id: "1", firstName: "Gemini",
  profileImage: "https://freebiehive.com/wp-content/uploads/2023/04/Google-Bard-Logo.jpg");
//

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        title:   const Text(
          "Ai Assistant",
          style: TextStyle(
            color: Colors.blueAccent,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),


        ),
      ),

      body: _buildUI(),
    );

  }
  Widget _buildUI() {
    return DashChat(

       inputOptions: InputOptions(trailing: [




         IconButton(onPressed: _sendMediaMessage,








           icon: const Icon( Icons.image_search),)
       ]),
        currentUser:currentUser, onSend: _sendMessage,
        messages: messages);
  }

  void _sendMessage(ChatMessage chatMessage){
    setState(() {
      messages = [chatMessage, ...messages];
    });
    try {
     String question = chatMessage.text;

   List<Uint8List>? images;
    if(chatMessage.medias?.isNotEmpty ??  false) {
     images = [
       File (chatMessage.medias!.first.url).readAsBytesSync(),
     ];
    }

     gemini.streamGenerateContent(
       question,
        images: images,
     )
         .listen((event) {
       ChatMessage? lastMessage = messages.firstOrNull;
       if (lastMessage != null && lastMessage.user == geminiUser) {
         lastMessage = messages.removeAt(0);
         String response = event.content?.parts?.fold("", (previous,current) => "$previous ${current.text}") ??
             "";
         lastMessage.text += response;
         setState(() {
           messages = [lastMessage!, ...messages];
         });

       }else {
         String response = event.content?.parts?.fold("", (previous,current) => "$previous ${current.text}") ?? "";
         ChatMessage message = ChatMessage(user: geminiUser, createdAt: DateTime.now(),
             text: response,
         );

         setState(() {
           messages = [message, ...messages];
         });

       }
     } );

    }catch(e) {
          print(e);
        }


  }
  void _sendMediaMessage()async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(
        source: ImageSource.gallery,
    );
if (file != null) {

  ChatMessage chatMessage = ChatMessage(user: currentUser, createdAt: DateTime.now(),
  text: "Describe the image", medias: [
    ChatMedia(url: file.path, fileName: "", type: MediaType.image
    ),
      ],
  );
  _sendMessage(chatMessage);
     }



    }
  }






