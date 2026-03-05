import 'package:flutter/material.dart';
import '../models/card.dart';
import '../models/folder.dart';
import '../repositories/card_repo.dart';

class AddEditCardScreen extends StatefulWidget {
  final PlayingCard? card; // null means creating a new card
  final List<Folder> folders;

  const AddEditCardScreen({super.key, this.card, required this.folders});

  @override
  _AddEditCardScreenState createState() => _AddEditCardScreenState();
}

class _AddEditCardScreenState extends State<AddEditCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final CardRepository _cardRepository = CardRepository();

  late TextEditingController _nameController;
  late TextEditingController _imageController;
  String? _selectedSuit;
  Folder? _selectedFolder;

  final List<String> suits = ['Spades', 'Hearts', 'Diamonds', 'Clubs'];

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.card?.cardName ?? '');
    _imageController =
        TextEditingController(text: widget.card?.imageUrl ?? '');
    _selectedSuit = widget.card?.suit ?? suits.first;
    _selectedFolder = widget.card != null
        ? widget.folders.firstWhere(
            (f) => f.id == widget.card!.folderId,
            orElse: () => widget.folders.first,
          )
        : widget.folders.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _saveCard() async {
    if (!_formKey.currentState!.validate()) return;

    final newCard = PlayingCard(
      id: widget.card?.id,
      cardName: _nameController.text.trim(),
      suit: _selectedSuit!,
      imageUrl: _imageController.text.trim().isEmpty
          ? null
          : _imageController.text.trim(),
      folderId: _selectedFolder!.id!,
    );

    if (widget.card == null) {
      await _cardRepository.insertCard(newCard);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Card added')));
    } else {
      await _cardRepository.updateCard(newCard);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Card updated')));
    }

    Navigator.pop(context, true); // return true to indicate changes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.card == null ? 'Add Card' : 'Edit Card'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Card Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Card Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter card name' : null,
              ),
              SizedBox(height: 16),

              // Suit Dropdown
              DropdownButtonFormField<String>(
                value: _selectedSuit,
                decoration: InputDecoration(labelText: 'Suit'),
                items: suits
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSuit = value;
                  });
                },
              ),
              SizedBox(height: 16),

              // Image URL / asset path
              TextFormField(
                controller: _imageController,
                decoration:
                    InputDecoration(labelText: 'Image URL or Asset Path'),
              ),
              SizedBox(height: 16),

              // Folder Dropdown
              DropdownButtonFormField<Folder>(
                value: _selectedFolder,
                decoration: InputDecoration(labelText: 'Folder'),
                items: widget.folders
                    .map((f) => DropdownMenuItem(
                          value: f,
                          child: Text(f.folderName),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFolder = value;
                  });
                },
              ),
              SizedBox(height: 32),

              // Save & Cancel Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _saveCard,
                    child: Text('Save'),
                  ),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}