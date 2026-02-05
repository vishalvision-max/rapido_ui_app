import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/colors.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController messageController = TextEditingController();
    final RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[
      {
        'text': 'I have arrived at the pickup location.',
        'isMe': false,
        'time': '2:45 PM',
      },
      {
        'text': 'Okay, I am coming in 2 minutes.',
        'isMe': true,
        'time': '2:46 PM',
      },
      {'text': 'Great! See you soon.', 'isMe': false, 'time': '2:46 PM'},
    ].obs;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlack),
          onPressed: () => Get.back(),
        ),
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryYellow,
              child: Icon(
                Icons.person,
                color: AppColors.primaryBlack,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rajesh Kumar (Captain)',
                  style: TextStyle(
                    color: AppColors.primaryBlack,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Online',
                  style: TextStyle(color: Colors.green[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.phone_rounded,
              color: AppColors.primaryBlack,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isMe = msg['isMe'] as bool;
                  return FadeInUp(
                    duration: const Duration(milliseconds: 400),
                    child: Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: isMe
                              ? AppColors.primaryYellow
                              : Colors.grey[100],
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(20),
                            topRight: const Radius.circular(20),
                            bottomLeft: Radius.circular(isMe ? 20 : 0),
                            bottomRight: Radius.circular(isMe ? 0 : 20),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg['text'],
                              style: TextStyle(
                                color: isMe
                                    ? AppColors.primaryBlack
                                    : Colors.black87,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              msg['time'],
                              style: TextStyle(
                                color: isMe
                                    ? AppColors.primaryBlack.withValues(
                                        alpha: 0.5,
                                      )
                                    : Colors.black38,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Quick replies
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _quickReply('I\'m coming', () {
                    messages.add({
                      'text': 'I\'m coming',
                      'isMe': true,
                      'time': 'Now',
                    });
                  }),
                  _quickReply('Where are you?', () {
                    messages.add({
                      'text': 'Where are you?',
                      'isMe': true,
                      'time': 'Now',
                    });
                  }),
                  _quickReply('Wait 2 mins', () {
                    messages.add({
                      'text': 'Wait 2 mins',
                      'isMe': true,
                      'time': 'Now',
                    });
                  }),
                  _quickReply('At the gate', () {
                    messages.add({
                      'text': 'At the gate',
                      'isMe': true,
                      'time': 'Now',
                    });
                  }),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    if (messageController.text.isNotEmpty) {
                      messages.add({
                        'text': messageController.text,
                        'isMe': true,
                        'time': 'Now',
                      });
                      messageController.clear();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryYellow,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: AppColors.primaryBlack,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickReply(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8, bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
