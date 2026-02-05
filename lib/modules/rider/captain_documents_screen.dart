import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CaptainDocumentsScreen extends StatelessWidget {
  const CaptainDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "My Documents",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Required Documents",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _documentTile(
              "Driving License",
              "Verified",
              Icons.badge,
              Colors.green,
            ),
            _documentTile(
              "Aadhar Card",
              "Verified",
              Icons.credit_card,
              Colors.green,
            ),
            _documentTile(
              "Vehicle RC",
              "Verified",
              Icons.description,
              Colors.green,
            ),
            _documentTile("Insurance", "Expired", Icons.security, Colors.red),
            _documentTile("PAN Card", "Optional", Icons.payment, Colors.blue),
            const SizedBox(height: 32),
            _buildUploadNotice(),
          ],
        ),
      ),
    );
  }

  Widget _documentTile(
    String title,
    String status,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.edit_note_rounded, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildUploadNotice() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.red[100]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red[900]),
              const SizedBox(width: 12),
              const Text(
                "Update Required",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Your vehicle insurance has expired. Please upload the latest document to avoid duty interruption.",
            style: TextStyle(fontSize: 13, color: Colors.red),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[900],
                foregroundColor: Colors.white,
              ),
              child: const Text("UPLOAD NOW"),
            ),
          ),
        ],
      ),
    );
  }
}
