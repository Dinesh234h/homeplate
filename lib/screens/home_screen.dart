import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../models/app_models.dart';
import 'dish_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, state),
            _buildSearchBar(),
            _buildFilters(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _buildMap(),
                  _buildSectionHeader('Nearby Cooks', '${state.cooks.length} cooks'),
                  const SizedBox(height: 12),
                  ...state.cooks.map((cook) => _buildCookCard(context, cook)),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppState state) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('DELIVERING TO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(state.userAddress?.split(',')[0] ?? 'Select Address', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                  const Icon(Icons.keyboard_arrow_down, size: 20),
                ],
              ),
            ],
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.bg,
              border: Border.all(color: AppTheme.border),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                state.userName?.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search for dishes or cooks',
          prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted),
          fillColor: AppTheme.bg,
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.border)),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    final filters = ['All', 'Veg', 'Under ₹120', 'Top Rated', 'Nearby'];
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final isSelected = index == 0;
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filters[index]),
              selected: isSelected,
              onSelected: (_) {},
              selectedColor: AppTheme.primarySoft,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100), side: BorderSide(color: isSelected ? AppTheme.primary : AppTheme.border)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMap() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            const GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(12.9279, 77.6271),
                zoom: 14.5,
              ),
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.2),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.05),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.my_location, color: AppTheme.primary, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        Text(count, style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
      ],
    );
  }

  Widget _buildCookCard(BuildContext context, Cook cook) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DishDetailScreen(cook: cook, dish: cook.menu[0]),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [cook.c1, cook.c2]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(child: Text(cook.avatar, style: const TextStyle(fontSize: 28))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(cook.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                        if (cook.fssai) ...[const SizedBox(width: 4), const Icon(Icons.verified, size: 14, color: AppTheme.secondary)],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: AppTheme.accent),
                        const SizedBox(width: 2),
                        Text('${cook.rating}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.accent)),
                        const SizedBox(width: 8),
                        Text('${cook.distance} km · ${cook.walkMin} min walk', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${cook.cuisines.join(' · ')} · Today: ${cook.menu[0].name.split('+')[0]}',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('₹${cook.menu[0].price}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.primary)),
                const Text('from', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
