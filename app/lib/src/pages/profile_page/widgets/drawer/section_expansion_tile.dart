import 'package:flutter/material.dart';

class SectionExpansionTile extends StatefulWidget {
  final int index;
  final String title;
  final String content;
  final bool initiallyExpanded;

  const SectionExpansionTile({
    Key? key,
    required this.index,
    required this.title,
    required this.content,
    this.initiallyExpanded = false,
  }) : super(key: key);

  @override
  State<SectionExpansionTile> createState() => _SectionExpansionTileState();
}

class _SectionExpansionTileState extends State<SectionExpansionTile> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      key: PageStorageKey(widget.index),
      tilePadding: EdgeInsets.zero,
      title: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
      ),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      initiallyExpanded: _isExpanded,
      onExpansionChanged: (expanded) {
        setState(() {
          _isExpanded = expanded;
        });
      },
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.content,
              style: const TextStyle(fontSize: 16, height: 1.5),
              textAlign: TextAlign.left,
            ),
          ),
        ),
      ],
    );
  }
}
