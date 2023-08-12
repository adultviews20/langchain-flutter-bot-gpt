import 'dart:io';



import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path_provider/path_provider.dart';

import '../assets/constvar.dart';
import '../providers/langchain_provider.dart';
import '../widgets/chat_widget.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

String? textDoc;
String? textToCheck;
File? pathFileDisplay;

String? uploadedFilePath;
String? fileName;
bool isFileUploaded = false;
String? userQuestion;
String? answerQuestion;
bool _isUploading = false;

Future<File> saveFilePermanently(PlatformFile file) async {
  final appStorage = await getApplicationDocumentsDirectory();
  final newFile = File('${appStorage!.path}/${file.name}');

  pathFileDisplay = newFile;

  print('path display $pathFileDisplay');

  print('new download path $newFile');

  return File(file.path!).copy(newFile.path);
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  bool _isTyping = false;
  late TextEditingController textEditingController;

  @override
  void initState() {
    textEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 2,
          title: const Text(
            "Ask your File whatever you like",
            textAlign: TextAlign.center,
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Find Your",
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "Document Answer",
                  style: TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage('lib/assets/ils1.png'),
                          fit: BoxFit.cover,
                        )),
                  ),
                ),
                // chat widget implemented later
                SizedBox(
                  height: 15,
                ),

                // if (_isTyping)
                //   const SpinKitThreeBounce(
                //     color: Colors.white,
                //     size: 18,
                //   ),

                // After the if(_isTyping) ... [ ... ],
                if (userQuestion != null && userQuestion!.isNotEmpty) ...[
                  ChatWidget(chatIndex: 0, msg: userQuestion!),
                  SizedBox(height: 5),
                ],
                if (answerQuestion != null && answerQuestion!.isNotEmpty) ...[
                  ChatWidget(chatIndex: 1, msg: answerQuestion!),
                  SizedBox(height: 5),
                ],
                SizedBox(
                  height: 15,
                ),
                if (_isTyping)
                  const SpinKitThreeBounce(
                    color: Colors.white,
                    size: 18,
                  ),
                Material(
                  color: chatCard,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(),
                            child: TextField(
                              controller: textEditingController,
                              style: TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "how can i help you",
                                hintStyle: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            setState(() {
                              _isTyping = true;
                            });
                            var userQuestionText = textEditingController.text;
                            var answer = await ref
                                .read(langChainProvider.notifier)
                                .readFileFromMobile(
                                    textToCheck!, userQuestionText);

                            setState(() {
                              userQuestion = userQuestionText;
                              answerQuestion = answer;
                              _isTyping = false;
                              textEditingController.clear();
                            });
                          },
                          icon: Icon(
                            Icons.send,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(
                  height: 5,
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    // setState(() {});
                    final result = await FilePicker.platform.pickFiles();
                    if (result == null) return;
                    final file = result.files.first;
                    String filePath = result.files.single.path!;

                    String fileContent = await File(filePath).readAsString();
                    print(fileContent);
                    textToCheck = fileContent;

                    final newFile = await saveFilePermanently(file);

                    setState(
                      () {
                        isFileUploaded = true;
                        uploadedFilePath = newFile.path;
                        fileName = result.files.first.name;
                      },
                    );
                  },
                  icon: Icon(Icons.document_scanner_outlined),
                  label: Text('Load File to Ask'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(20.0),
                    fixedSize: Size(240, 60),
                    textStyle:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    primary: Color.fromARGB(255, 134, 203, 243),
                    onPrimary: Colors.black87,
                    elevation: 15,
                    side: BorderSide(color: Colors.black87, width: 3),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                // After the ElevatedButton in the build method
                if (isFileUploaded) ...[
                  Text(
                    'File ${fileName} has uploaded to the app!',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 144, 255, 148),
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'File Path: ${uploadedFilePath ?? ''}',
                    style: TextStyle(
                      color: Color.fromARGB(255, 208, 226, 185),
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  // SizedBox(height: 5),
                ],
              ],
            ),
          ),
        ));
  }
}
