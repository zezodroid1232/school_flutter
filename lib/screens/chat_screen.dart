import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../models/message_model.dart';

class ChatScreen extends StatefulWidget {
  final String studentId;
  final String otherUserName;

  const ChatScreen({
    super.key,
    required this.studentId,
    required this.otherUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  bool _isChatClosed = false;

  @override
  void initState() {
    super.initState();
    _checkChatStatus();
  }

  void _checkChatStatus() {
    _dbRef.child('chats/${widget.studentId}/isClosed').onValue.listen((event) {
      if (mounted) {
        setState(() {
          _isChatClosed = (event.snapshot.value as bool?) ?? false;
        });
      }
    });
  }

  Future<void> _sendMessage({String? type, String? content}) async {
    if (_isChatClosed) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = authService.currentUser!;
    final text = _messageController.text.trim();

    if (text.isEmpty && content == null) return;

    final message = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: currentUser.uid,
      senderName: currentUser.name,
      content: content ?? text,
      type: type ?? 'text',
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    await _dbRef
        .child('chats/${widget.studentId}/messages')
        .push()
        .set(message.toMap());

    _messageController.clear();
  }

  Future<void> _sendImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final File file = File(pickedFile.path);
      final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final Reference ref = _storage.ref().child('chat_images/$fileName');

      try {
        await ref.putFile(file);
        final String downloadUrl = await ref.getDownloadURL();
        _sendMessage(type: 'image', content: downloadUrl);
      } catch (e) {
        debugPrint('Error uploading image: $e');
      }
    }
  }

  void _toggleChatStatus() {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (authService.currentUser!.role == 'teacher') {
      _dbRef.child('chats/${widget.studentId}/isClosed').set(!_isChatClosed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final isTeacher = authService.currentUser!.role == 'teacher';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUserName),
        actions: [
          if (isTeacher)
            IconButton(
              icon: Icon(_isChatClosed ? Icons.lock : Icons.lock_open),
              onPressed: _toggleChatStatus,
              tooltip: _isChatClosed ? 'Open Chat' : 'Close Chat',
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _dbRef
                  .child('chats/${widget.studentId}/messages')
                  .orderByChild('timestamp')
                  .onValue,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData ||
                    snapshot.data!.snapshot.value == null) {
                  return const Center(child: Text('No messages yet.'));
                }

                final Map<dynamic, dynamic> map =
                    snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                final List<MessageModel> messages = [];
                map.forEach((key, value) {
                  messages.add(
                    MessageModel.fromMap(Map<String, dynamic>.from(value)),
                  );
                });

                messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == authService.currentUser!.uid;
                    return _buildMessageBubble(msg, isMe);
                  },
                );
              },
            ),
          ),
          if (_isChatClosed)
            Container(
              padding: const EdgeInsets.all(10),
              color: Colors.grey[200],
              child: const Center(
                child: Text(
                  'Chat is closed by the teacher.',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.image),
                    onPressed: _sendImage,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () => _sendMessage(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(
                msg.senderName,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            if (msg.type == 'text')
              Text(msg.content)
            else if (msg.type == 'image')
              Image.network(
                msg.content,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
          ],
        ),
      ),
    );
  }
}
