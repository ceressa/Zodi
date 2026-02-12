// Tarot Card Model
class TarotCard {
  final String name;
  final int number;
  final TarotSuit suit;
  final bool reversed;
  final String imageUrl;
  final String basicMeaning;

  TarotCard({
    required this.name,
    required this.number,
    required this.suit,
    required this.reversed,
    required this.imageUrl,
    required this.basicMeaning,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'number': number,
        'suit': suit.toString().split('.').last,
        'reversed': reversed,
        'imageUrl': imageUrl,
        'basicMeaning': basicMeaning,
      };

  factory TarotCard.fromJson(Map<String, dynamic> json) => TarotCard(
        name: json['name'] as String,
        number: json['number'] as int,
        suit: TarotSuit.values.firstWhere(
          (e) => e.toString().split('.').last == json['suit'],
        ),
        reversed: json['reversed'] as bool,
        imageUrl: json['imageUrl'] as String,
        basicMeaning: json['basicMeaning'] as String,
      );
}

enum TarotSuit {
  majorArcana,
  wands,
  cups,
  swords,
  pentacles,
}

// Tarot Reading Model
class TarotReading {
  final DateTime date;
  final List<TarotCard> cards;
  final String interpretation;
  final String zodiacSign;
  final String type; // 'daily' or 'three_card'

  TarotReading({
    required this.date,
    required this.cards,
    required this.interpretation,
    required this.zodiacSign,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'cards': cards.map((c) => c.toJson()).toList(),
        'interpretation': interpretation,
        'zodiacSign': zodiacSign,
        'type': type,
      };

  factory TarotReading.fromJson(Map<String, dynamic> json) => TarotReading(
        date: DateTime.parse(json['date'] as String),
        cards: (json['cards'] as List)
            .map((c) => TarotCard.fromJson(c as Map<String, dynamic>))
            .toList(),
        interpretation: json['interpretation'] as String,
        zodiacSign: json['zodiacSign'] as String,
        type: json['type'] as String,
      );
}
