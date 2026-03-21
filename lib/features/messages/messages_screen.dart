import 'package:flutter/material.dart';
import 'package:lego_rental_frontend/core/widgets/app_background.dart';
import 'package:lego_rental_frontend/features/home/home_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  // dummy beszélgetések listanézethez
  final List<_Conversation> _conversations = const [
    _Conversation(
      userName: 'User 1',
      lastMessage: 'Hello there!',
      timeAgo: '2h ago',
    ),
    _Conversation(
      userName: 'User 2',
      lastMessage: 'Sure, I can lend it.',
      timeAgo: '1d ago',
    ),
    _Conversation(
      userName: 'User 223',
      lastMessage: 'Thanks!',
      timeAgo: '2w ago',
    ),
  ];

  _Conversation? _selectedConversation;
  final List<String> _messages = []; // kiválasztott beszélgetés helyi üzenetei
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _openConversation(_Conversation conv) {
    setState(() {
      _selectedConversation = conv;
      _messages.clear();
      _messages.addAll([
        'Hello there!',
        'Sure, I can lend it.',
      ]);
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(text);
      _messageController.clear();
    });
  }

  void _startNewMessage() {
    // később: új user / review flow
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('New Message – későbbi fejlesztés')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool inConversation = _selectedConversation != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5CB58),
      body: AppBackground(
        title: 'Message',
        onBack: inConversation
            ? () {
                // beszélgetésből vissza a listanézetre
                setState(() {
                  _selectedConversation = null;
                  _messages.clear();
                });
              }
            : null, // fő listanézeten nincs vissza
        onHome: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: inConversation
              ? _buildConversationView()
              : _buildConversationListView(),
        ),
      ),
      // bottom nav-ot a MainScreen adja [file:11]
    );
  }

  // --- lista nézet (bal oldali mock) ---

  Widget _buildConversationListView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // New Message gomb
        SizedBox(
          width: 180,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF391713),
              side: BorderSide(color: Colors.grey[400]!),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _startNewMessage,
            icon: const Icon(Icons.add),
            label: const Text('New Message'),
          ),
        ),
        const SizedBox(height: 16),

        const Text(
          'Conversations',
          style: TextStyle(
            color: Color(0xFF252525),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),

        Expanded(
          child: ListView.separated(
            itemCount: _conversations.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final conv = _conversations[index];
              return GestureDetector(
                onTap: () => _openConversation(conv),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              conv.userName,
                              style: const TextStyle(
                                color: Color(0xFF252525),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Last message: ${conv.lastMessage}',
                              style: const TextStyle(
                                color: Color(0xFF848383),
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        conv.timeAgo,
                        style: const TextStyle(
                          color: Color(0xFF848383),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- beszélgetés nézet (jobb oldali mock) ---

  Widget _buildConversationView() {
    final conv = _selectedConversation!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: false,
              onChanged: (_) {},
            ),
            Text(
              conv.userName,
              style: const TextStyle(
                color: Color(0xFF252525),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            padding: const EdgeInsets.all(12),
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final text = _messages[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: Color(0xFF252525),
                      fontSize: 14,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[300]!),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Write your message...',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Color(0xFF391713)),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// egyszerű adatmodell a dummy beszélgetésekhez
class _Conversation {
  final String userName;
  final String lastMessage;
  final String timeAgo;

  const _Conversation({
    required this.userName,
    required this.lastMessage,
    required this.timeAgo,
  });
}
