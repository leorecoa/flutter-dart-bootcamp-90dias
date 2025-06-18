class Barber {
  final String id;
  final String name;
  final String imageUrl;
  final String whatsapp;
  final List<String> specialties;
  final double rating;
  final bool available;

  Barber({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.whatsapp,
    required this.specialties,
    required this.rating,
    this.available = true,
  });
  
  factory Barber.fromMap(Map<String, dynamic> map) {
    return Barber(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      whatsapp: map['whatsapp'] ?? '',
      specialties: List<String>.from(map['specialties'] ?? []),
      rating: (map['rating'] ?? 0.0).toDouble(),
      available: map['available'] ?? true,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'whatsapp': whatsapp,
      'specialties': specialties,
      'rating': rating,
      'available': available,
    };
  }
}

// Lista de barbeiros pré-definidos
final List<Barber> barbers = [
  Barber(
    id: '1',
    name: 'Carlos Silva',
    imageUrl: 'assets/images/barber1.png',
    whatsapp: '5511999999999',
    specialties: ['Corte Moderno', 'Barba', 'Degradê'],
    rating: 4.8,
  ),
  Barber(
    id: '2',
    name: 'André Santos',
    imageUrl: 'assets/images/barber2.png',
    whatsapp: '5511988888888',
    specialties: ['Corte Clássico', 'Barba Completa', 'Tintura'],
    rating: 4.7,
  ),
  Barber(
    id: '3',
    name: 'Marcos Oliveira',
    imageUrl: 'assets/images/barber3.png',
    whatsapp: '5511977777777',
    specialties: ['Degradê', 'Desenhos', 'Sobrancelha'],
    rating: 4.9,
  ),
];