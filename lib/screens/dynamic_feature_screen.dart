import 'package:flutter/material.dart';

class DynamicFeatureScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const DynamicFeatureScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final type = data['type'];

    return Scaffold(
      appBar: AppBar(title: Text(data['title'] ?? 'Chi tiết')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: buildBodyByType(type, data),
      ),
    );
  }

  Widget buildBodyByType(String? type, Map<String, dynamic> data) {
    switch (type) {
      case 'list':
        return buildList(data['items']);
      case 'form':
        return buildForm(data['fields']);
      case 'text':
        return Text(data['content'] ?? 'No content');
      case 'html':
        return SingleChildScrollView(
          child: Text(data['content'] ?? 'Không có nội dung'),
        );
      default:
        return Text('Unsupported type: $type');
    }
  }

  Widget buildList(List<dynamic> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (_, index) {
        final item = items[index];
        return ListTile(
          title: Text(item['name'] ?? ''),
          subtitle: Text(item['status'] ?? ''),
        );
      },
    );
  }

  Widget buildForm(List<dynamic> fields) {
    return ListView(
      children: fields.map((field) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TextFormField(
            decoration: InputDecoration(
              labelText: field['label'],
              border: OutlineInputBorder(),
            ),
          ),
        );
      }).toList(),
    );
  }
}
