import 'package:flutter/material.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<_Message> _messages = [];

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(_Message(text, true));
      _messages.add(_Message(_getBotResponse(text), false));
    });

    _controller.clear();
  }

  String _getBotResponse(String input) {
    input = input.toLowerCase();

    if (input.contains('hello') || input.contains('hi')) {
      return "Hello! How can I assist you with waste management today?";
    } else if (input.contains('plastic')) {
      return "Plastic waste can be recycled at collection centers like Green Recycling Ltd. Be sure to clean it first!";
    } else if (input.contains('organic') || input.contains('food')) {
      return "Organic waste like food scraps can be composted. You can contact Eco-Friendly Solutions for pickup.";
    } else if (input.contains('e-waste') || input.contains('electronic')) {
      return "E-waste includes phones, laptops, batteries, etc. Tech Recyclers handles safe disposal.";
    } else if (input.contains('metal')) {
      return "Metal waste such as cans or scrap can be sold to Metal Scrap Co. for proper recycling.";
    } else if (input.contains('paper')) {
      return "Paper waste should be kept dry and clean. Paper Recycle Hub is a good place to send it.";
    } else if (input.contains('contact')) {
      return "You can use the 'Contact' button on vendor listings to reach a recycler.";
    } else if (input.contains('location') || input.contains('where')) {
      return "Most vendors have pickup services. You can check their availability in the vendor list.";
    } else if (input.contains('bye')) {
      return "Goodbye! Stay eco-friendly and keep recycling!";
    } else if (input.contains('what') && input.contains('recycle')) {
      return "You can recycle plastics, paper, metals, glass, and electronics. Avoid mixing wet waste with dry waste.";
    } else {
      return "I'm sorry, I didn't understand that. Try asking about plastic, paper, e-waste, or vendors.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WasteWise Chatbot'),
        backgroundColor: Colors.green[700],
        automaticallyImplyLeading: false, // This removes the leading icon (back button)
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment:
                  message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: message.isUser ? Colors.green[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(message.text),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Ask about waste, recycling, or vendors...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _sendMessage(_controller.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                  ),
                  child: const Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Message {
  final String text;
  final bool isUser;

  _Message(this.text, this.isUser);
}
