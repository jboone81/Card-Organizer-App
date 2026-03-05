import 'package:flutter/material.dart';

import '../models/card.dart';
import '../repositories/card_repo.dart';
import '../models/folder.dart';

class CardsScreen extends StatefulWidget {
  final Folder folder;

  const CardsScreen({super.key, required this.folder});

  @override
  _CardsScreenState createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final CardRepository _cardRepository = CardRepository();
  List<PlayingCard> _cards = [];

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future _loadCards() async {
    final cards = await _cardRepository.getCardsByFolderId(widget.folder.id!);
    setState(() {
      _cards = cards;
    });
  }

  Future _deleteCard(PlayingCard card) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Card?'),
        content: Text('Are you sure you want to delete this card?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _cardRepository.deleteCard(card.id!);
      _loadCards();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Card deleted')),
      );
    }
  }

  void _editCard(PlayingCard card) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit card pressed')),
    );
  }

  void _addCard() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Add card pressed')),
    );
  }

  // Returns the asset path for the card image
  String getCardAssetPath(PlayingCard card) {
    final name = card.cardName.toLowerCase();
    final suit = card.suit.toLowerCase();
    return 'assets/${name}_of_${suit}.png';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cards in "${widget.folder.folderName}"'),
      ),

      body: _cards.isEmpty
          ? Center(child: Text('No cards in this folder.'))
          : GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: _cards.length,
              itemBuilder: (context, index) {
                final card = _cards[index];

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () {},
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Card image
                        Expanded(
                          child: Image.asset(
                            getCardAssetPath(card),
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(
                              Icons.note,
                              size: 48,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ),

                        SizedBox(height: 8),

                        Text(
                          card.cardName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        Text(
                          card.suit,
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),

                        SizedBox(height: 8),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editCard(card),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteCard(card),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: _addCard,
        child: Icon(Icons.add),
      ),
    );
  }
}