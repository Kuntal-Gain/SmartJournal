import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_dairy/services/embedding_services.dart';
import 'package:lottie/lottie.dart';

import '../models/journal.dart';

class MemoryScreen extends StatefulWidget {
  const MemoryScreen({super.key});

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  final TextEditingController _controller = TextEditingController();

  List<MessageBubble> messages = [];
  bool isLoading = false;
  String mention = "";
  Journal? memoryItem;
  String botResponse = "";

  Future<void> sendMessage(String message) async {
    print('💬 Sending: $message');

    final journalHit = await EmbeddingServices().searchJournal(message);
    final lastMemory = journalHit?.content; // may be null

    print('🗃️ lastMemory → ${lastMemory ?? "<none>"}');

    final botReply =
        await EmbeddingServices().generateGeminiResponse(lastMemory!, message);

    setState(() {
      memoryItem = journalHit; // could still be null – that’s fine
      botResponse = botReply;
    });
  }

  Future<String> followup(String prevRes, String newQuery) async =>
      EmbeddingServices().generateFollowup(prevRes, newQuery);

  Future<String> askQuery(bool isFollowup) async {
    if (isFollowup) {
      return await followup(messages.last.message, _controller.text);
    } else {
      await sendMessage(_controller.text);
      return botResponse;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Memory Journal',
          style: TextStyle(
            color: Color(0XFF5D3D3D),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            height: mq.height * 0.2,
            width: double.infinity,
            decoration: const BoxDecoration(
                // color: Colors.black,
                ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: 100,
                  width: 100,
                  child: Image.network(
                      'https://cdn-icons-png.flaticon.com/512/109/109827.png'),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Memory Journal',
                  style: TextStyle(
                    color: Color(0XFF5D3D3D),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ask about your memories...',
                  style: TextStyle(
                    color: Color(0XFF5D3D3D),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (isLoading && index == messages.length) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      // Using SizedBox instead of Container
                      width: 150, // Increased width for better visibility
                      height: 100,
                      child: Lottie.asset(
                        'assets/typing.json',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          if (kDebugMode) {
                            print('Lottie Error: $error');
                          }
                          return const Icon(Icons.error);
                        },
                      ),
                    ),
                  );
                }
                final message = messages[index];
                return MessageBubble(
                  isUser: message.isUser,
                  message: message.message,
                  onReply: (message) {
                    setState(() {
                      mention = message;
                    });
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              children: [
                if (mention.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      border: Border(
                        left: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 4,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Replying to',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                mention,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              mention = "";
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Ask about your memories...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () async {
                        final userMessage = _controller.text;
                        if (userMessage.isEmpty) return;

                        // Add user message immediately
                        setState(() {
                          messages.add(MessageBubble(
                            isUser: true,
                            message: userMessage,
                            onReply: (replyMessage) {
                              setState(() {
                                mention = replyMessage;
                              });
                            },
                          ));
                          isLoading = true; // Show loading indicator
                        });

                        // Get response
                        final response = await askQuery(mention.isNotEmpty);

                        // Add bot response
                        setState(() {
                          isLoading = false;
                          messages.add(MessageBubble(
                            isUser: false,
                            message: response,
                            memoryItem: memoryItem,
                            onReply: (replyMessage) {
                              setState(() {
                                mention = replyMessage;
                              });
                            },
                          ));
                        });
                        _controller.clear(); // Clear input field
                      },
                      icon: const Icon(Icons.send),
                      color: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatefulWidget {
  final String message;
  final bool isUser;
  final Journal? memoryItem;
  final Function(String) onReply;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isUser,
    required this.onReply,
    this.memoryItem,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with SingleTickerProviderStateMixin {
  double _dragExtent = 0;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  void _resetDrag() {
    _controller.reset();
    setState(() {
      _dragExtent = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onHorizontalDragUpdate: (details) {
          setState(() {
            _dragExtent += details.delta.dx;
            _dragExtent = _dragExtent.clamp(0.0, 60.0);
          });
        },
        onHorizontalDragEnd: (details) {
          if (_dragExtent > 40) {
            widget.onReply(widget.message);
            _resetDrag();
          } else {
            _controller.forward().then((_) => _resetDrag());
          }
        },
        onHorizontalDragCancel: _resetDrag,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Reply Icon (Fades In & Out)
            Positioned(
              left: widget.isUser ? null : 8,
              right: widget.isUser ? 8 : null,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _dragExtent > 10 ? 1 : 0,
                child: const Icon(Icons.reply, color: Colors.blue, size: 24),
              ),
            ),

            // Draggable Message Bubble
            Transform.translate(
              offset: Offset(_dragExtent * (widget.isUser ? -1 : 1), 0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6,
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: widget.isUser
                      ? Colors.grey[300]
                      : const Color(0XFF5D3D3D),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  widget.message,
                  style: GoogleFonts.montserrat(
                    textStyle: TextStyle(
                      color: widget.isUser ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            if (widget.memoryItem != null)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: widget.isUser
                      ? Colors.grey[300]
                      : const Color(0XFF5D3D3D),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  widget.memoryItem!.content,
                  style: GoogleFonts.montserrat(
                    textStyle: TextStyle(
                      color: widget.isUser ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
