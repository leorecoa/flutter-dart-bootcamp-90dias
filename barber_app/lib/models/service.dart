class Service {
  final String id;
  final String name;
  final String description;
  final double price;
  final double discountPrice;
  final int durationMinutes;
  final String imageUrl;
  final bool isPromotion;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice = 0.0,
    required this.durationMinutes,
    required this.imageUrl,
    this.isPromotion = false,
  });

  bool get hasDiscount => discountPrice > 0 && discountPrice < price;
  
  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      discountPrice: (map['discountPrice'] ?? 0.0).toDouble(),
      durationMinutes: map['durationMinutes'] ?? 30,
      imageUrl: map['imageUrl'] ?? '',
      isPromotion: map['isPromotion'] ?? false,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'discountPrice': discountPrice,
      'durationMinutes': durationMinutes,
      'imageUrl': imageUrl,
      'isPromotion': isPromotion,
    };
  }
}

// Lista de serviços pré-definidos
final List<Service> services = [
  Service(
    id: '1',
    name: 'Corte de Cabelo',
    description: 'Corte moderno com acabamento perfeito',
    price: 50.0,
    durationMinutes: 30,
    imageUrl: 'assets/images/haircut.png',
  ),
  Service(
    id: '2',
    name: 'Barba',
    description: 'Barba aparada com toalha quente e produtos premium',
    price: 40.0,
    durationMinutes: 25,
    imageUrl: 'assets/images/beard.png',
  ),
  Service(
    id: '3',
    name: 'Combo Completo',
    description: 'Corte de cabelo + barba com desconto especial',
    price: 120.0,
    discountPrice: 90.0,
    durationMinutes: 60,
    imageUrl: 'assets/images/combo.png',
    isPromotion: true,
  ),
  Service(
    id: '4',
    name: 'Sobrancelha',
    description: 'Design e acabamento de sobrancelha',
    price: 25.0,
    durationMinutes: 15,
    imageUrl: 'assets/images/eyebrow.png',
  ),
];