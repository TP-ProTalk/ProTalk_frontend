
import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _showSoftDetails = false;
  bool _showHardDetails = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9CCB7),
      appBar: AppBar(
        title: const Text('История', style: TextStyle(fontSize: 24)),
        backgroundColor: Colors.black45,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Блок Soft
            _buildHistoryBlock(
              title: '10 soft',
              isExpanded: _showSoftDetails,
              onTap: () {
                setState(() {
                  _showSoftDetails = !_showSoftDetails;
                });
              },
              child: _buildSoftDetails(),
            ),
            
            const SizedBox(height: 20),
            
            // Блок Hard
            _buildHistoryBlock(
              title: '7 hard',
              isExpanded: _showHardDetails,
              onTap: () {
                setState(() {
                  _showHardDetails = !_showHardDetails;
                });
              },
              child: _buildHardDetails(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryBlock({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: onTap,
              child: Text(
                isExpanded ? 'свернуть' : 'подробнее',
                style: const TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        if (isExpanded) child,
      ],
    );
  }

  Widget _buildSoftDetails() {
    return Column(
      children: [
        const SizedBox(height: 10),
        _buildHistoryItem('Тема 1', '3 статьи'),
        _buildHistoryItem('Тема 2', '5 статей'),
        _buildHistoryItem('Тема 3', '2 статьи'),
      ],
    );
  }

  Widget _buildHardDetails() {
    return Column(
      children: [
        const SizedBox(height: 10),
        _buildHistoryItem('Тема A', '2 статьи'),
        _buildHistoryItem('Тема B', '3 статьи'),
        _buildHistoryItem('Тема C', '2 статьи'),
      ],
    );
  }

  Widget _buildHistoryItem(String title, String count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          Text(
            count,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}