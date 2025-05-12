class Philosopher {
  final int id;
  final String name;
  final String image;
  final String quotes;

  const Philosopher({
    required this.id,
    required this.name,
    required this.image,
    required this.quotes,
  });

  factory Philosopher.fromJson(Map<String, dynamic> json) {
    return Philosopher(
      id: json['id'] as int,
      name: json['name'] as String,
      image: json['image'] as String,
      quotes: json['quotes'] as String,
    );
  }
}