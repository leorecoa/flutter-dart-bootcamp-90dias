import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/barber.dart';
import '../models/service.dart';
import '../models/user.dart';
import '../services/analytics_service.dart';
import '../services/barber_service.dart';
import '../utils/constants.dart';
import '../widgets/barber_card.dart';
import '../widgets/custom_notification.dart';
import '../widgets/loading_animation.dart';
import 'appointment_screen.dart';
import 'appointments_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late TabController _tabController;
  bool _isLoading = true;
  List<Service> _promotions = [];
  List<Barber> _featuredBarbers = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final barberService = Provider.of<BarberService>(context, listen: false);
      
      // Get services and barbers
      final services = await barberService.getServices();
      final barbers = await barberService.getBarbers();
      
      // Filter promotions
      _promotions = services.where((service) => service.isPromotion).toList();
      
      // Get featured barbers (top rated)
      _featuredBarbers = List.from(barbers)
        ..sort((a, b) => b.rating.compareTo(a.rating));
      if (_featuredBarbers.length > 5) {
        _featuredBarbers = _featuredBarbers.sublist(0, 5);
      }
      
      // Track app open
      await AnalyticsService().trackEvent('view_home_screen');
    } catch (e) {
      if (mounted) {
        CustomNotification.show(
          context: context,
          message: 'Erro ao carregar dados: $e',
          type: NotificationType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final services = Provider.of<List<Service>>(context);
    
    return Scaffold(
      body: _isLoading
          ? const Center(
              child: LoadingAnimation(
                size: 60,
                message: 'Carregando...',
              ),
            )
          : NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 200,
                    floating: false,
                    pinned: true,
                    backgroundColor: AppColors.primary,
                    flexibleSpace: FlexibleSpaceBar(
                      title: const Text(
                        'BARBER SHOP',
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 2,
                        ),
                      ),
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Background image with overlay
                          Image.network(
                            'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?ixlib=rb-1.2.1&auto=format&fit=crop&w=1950&q=80',
                            fit: BoxFit.cover,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  AppColors.primary.withAlpha(180),
                                  AppColors.primary,
                                ],
                              ),
                            ),
                          ),
                          
                          // Welcome text
                          Positioned(
                            bottom: 60,
                            left: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Olá, ${user?.name.split(' ')[0] ?? 'Visitante'}',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'Pronto para ficar no estilo?',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.notifications, color: AppColors.secondary),
                        onPressed: () {
                          // Implement notifications
                        },
                      ),
                    ],
                  ),
                  SliverPersistentHeader(
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        controller: _tabController,
                        labelColor: AppColors.secondary,
                        unselectedLabelColor: AppColors.textSecondary,
                        indicatorColor: AppColors.secondary,
                        tabs: const [
                          Tab(text: 'SERVIÇOS'),
                          Tab(text: 'PROMOÇÕES'),
                          Tab(text: 'BARBEIROS'),
                        ],
                      ),
                    ),
                    pinned: true,
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  // Services tab
                  _buildServicesTab(services),
                  
                  // Promotions tab
                  _buildPromotionsTab(),
                  
                  // Barbers tab
                  _buildBarbersTab(),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          
          // Navigate to the corresponding screen
          if (index == 1) { // Appointments
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AppointmentsScreen()),
            );
          } else if (index == 2) { // Profile
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          }
        },
        backgroundColor: AppColors.primary,
        selectedItemColor: AppColors.secondary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Agendamentos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  Widget _buildServicesTab(List<Service> services) {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.secondary,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Featured barbers section
          const Text(
            'Barbeiros em Destaque',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _featuredBarbers.length,
              itemBuilder: (context, index) {
                return BarberCard(
                  barber: _featuredBarbers[index],
                  onTap: () {
                    // View barber details
                    AnalyticsService().trackViewBarber(_featuredBarbers[index]);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 30),
          
          // Services section
          const Text(
            'Nossos Serviços',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          // Services grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return _buildServiceCard(service);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionsTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.secondary,
      child: _promotions.isEmpty
          ? const Center(
              child: Text(
                'Nenhuma promoção disponível no momento',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _promotions.length,
              itemBuilder: (context, index) {
                return _buildPromotionCard(_promotions[index]);
              },
            ),
    );
  }

  Widget _buildBarbersTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.secondary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _featuredBarbers.length,
        itemBuilder: (context, index) {
          return BarberCard(
            barber: _featuredBarbers[index],
            showDetails: true,
            onTap: () {
              // View barber details
              AnalyticsService().trackViewBarber(_featuredBarbers[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildServiceCard(Service service) {
    return GestureDetector(
      onTap: () {
        // Track service view
        AnalyticsService().trackViewService(service);
        
        // Navigate to appointment screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AppointmentScreen(
              service: service,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(30),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service image
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppSizes.borderRadius),
                  topRight: Radius.circular(AppSizes.borderRadius),
                ),
              ),
              child: Center(
                child: Icon(
                  _getServiceIcon(service.name),
                  color: AppColors.secondary,
                  size: 50,
                ),
              ),
            ),
            
            // Service details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${service.durationMinutes} min',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (service.hasDiscount) ...[
                        Text(
                          'R\$${service.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        'R\$${service.hasDiscount ? service.discountPrice.toStringAsFixed(2) : service.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromotionCard(Service promotion) {
    return GestureDetector(
      onTap: () {
        // Track promotion view
        AnalyticsService().trackViewService(promotion);
        
        // Navigate to appointment screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AppointmentScreen(
              service: promotion,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(30),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Promotion header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppSizes.borderRadius),
                  topRight: Radius.circular(AppSizes.borderRadius),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'PROMOÇÃO',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${((promotion.price - promotion.discountPrice) / promotion.price * 100).toInt()}% OFF',
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            
            // Promotion content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Promotion icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                    ),
                    child: Center(
                      child: Icon(
                        _getServiceIcon(promotion.name),
                        color: AppColors.secondary,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Promotion details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          promotion.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          promotion.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'R\$${promotion.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'R\$${promotion.discountPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Promotion footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(AppSizes.borderRadius),
                  bottomRight: Radius.circular(AppSizes.borderRadius),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    color: AppColors.textSecondary,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${promotion.durationMinutes} minutos',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'AGENDAR AGORA',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward,
                    color: AppColors.secondary,
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getServiceIcon(String serviceName) {
    final name = serviceName.toLowerCase();
    if (name.contains('corte')) {
      return Icons.content_cut;
    } else if (name.contains('barba')) {
      return Icons.face;
    } else if (name.contains('sobrancelha')) {
      return Icons.remove_red_eye;
    } else if (name.contains('combo')) {
      return Icons.style;
    } else {
      return Icons.spa;
    }
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.primary,
      child: _tabBar,
    );
  }

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}