import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../models/app_models.dart';
import 'cook_menu_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final cooks = state.filteredCooks;
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, state),
            _buildSearchBar(state),
            _buildFilters(state),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _buildImpactCard(),
                  const SizedBox(height: 16),
                  _buildMap(),
                  _buildSectionHeader('Nearby Cooks', '${cooks.length} kitchens found'),
                  const SizedBox(height: 12),
                  if (cooks.isEmpty) 
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: Text('No kitchens match your filter.', style: TextStyle(color: AppTheme.textMuted))),
                    ),
                  ...cooks.map((cook) => _buildCookCard(context, cook)),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildSurpriseFab(context),
    );
  }

  Widget _buildHeader(BuildContext context, AppState state) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _showAddressSelector(context, state),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('DELIVERING TO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: AppTheme.primary),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            state.userAddress?.split(',')[0] ?? 'Select Address', 
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down, size: 18),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pushNamed(context, '/cart'),
                icon: Stack(
                  children: [
                    const Icon(Icons.shopping_cart_outlined, color: AppTheme.text),
                    if (state.cart.isNotEmpty)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                          constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
                          child: Text('${state.cart.length}', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.bg,
                  border: Border.all(color: AppTheme.border),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    state.userName?.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primary, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddressSelector(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose Delivery Location', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.my_location, color: AppTheme.primary),
              title: const Text('Use Current Location', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () => Navigator.pop(context),
            ),
            const Divider(),
            ...state.savedAddresses.map((addr) => ListTile(
              leading: const Icon(Icons.home_outlined),
              title: Text(addr),
              onTap: () {
                state.setUserInfo(state.userName ?? 'User', addr);
                Navigator.pop(context);
              },
            )),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () {}, child: const Text('Add New Address')),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(AppState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TextField(
        onChanged: (v) => state.setSearchQuery(v),
        decoration: InputDecoration(
          hintText: 'Search for dishes or cooks',
          prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted),
          fillColor: AppTheme.bg,
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.border)),
        ),
      ),
    );
  }

  Widget _buildFilters(AppState state) {
    final filters = ['All', 'Pure Veg', 'Top Rated', 'Under ₹120', 'Fastest', 'Nearby'];
    return SizedBox(
      height: 60,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 8),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(border: Border.all(color: AppTheme.border), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.tune, size: 20, color: AppTheme.primary),
            ),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: 24, top: 12, bottom: 12),
              itemCount: filters.length,
              itemBuilder: (context, index) {
                final filter = filters[index];
                final isSelected = state.selectedFilter == filter;
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                    selected: isSelected,
                    onSelected: (_) => state.setFilter(filter),
                    selectedColor: AppTheme.primarySoft,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100), side: BorderSide(color: isSelected ? AppTheme.primary : AppTheme.border)),
                  ),
                );
              },
            ),
          ),
        ],
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

  Widget _buildImpactCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.eco, color: Colors.green, size: 24),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Local Impact', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green)),
                Text('You saved 1.2kg CO2 this week by eating local!', style: TextStyle(fontSize: 11, color: Colors.black54)),
              ],
            ),
          ),
          TextButton(onPressed: () {}, child: const Text('View', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green))),
        ],
      ),
    );
  }

  Widget _buildSurpriseFab(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎲 Finding a mystery meal from a Top Cook...'),
            backgroundColor: AppTheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      backgroundColor: AppTheme.text,
      icon: const Text('🎁', style: TextStyle(fontSize: 18)),
      label: const Text('Surprise Me', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CookMenuScreen(cook: cook),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
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
