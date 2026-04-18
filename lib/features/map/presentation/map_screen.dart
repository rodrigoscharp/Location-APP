import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../../listings/domain/listing.dart';
import 'map_provider.dart';
import 'widgets/map_listing_bottom_card.dart';

// Ubatuba center coordinates
const _ubatuba = LatLng(-23.4328, -45.0713);

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  Set<Marker> _buildMarkers(List<Listing> listings) {
    return listings.where((l) => l.lat != null && l.lng != null).map((l) {
      return Marker(
        markerId: MarkerId(l.id),
        position: LatLng(l.lat!, l.lng!),
        onTap: () {
          ref.read(selectedMapListingProvider.notifier).state = l;
        },
        infoWindow: InfoWindow(
          title: CurrencyFormatter.format(l.pricePerNight),
          snippet: l.title,
        ),
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final listingsAsync = ref.watch(mapListingsProvider);
    final selected = ref.watch(selectedMapListingProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Mapa',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppColors.charcoal,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.lightGray),
        ),
      ),
      body: listingsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.coral),
        ),
        error: (_, __) => const ErrorStateWidget(),
        data: (listings) => Stack(
          children: [
            GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: _ubatuba,
                zoom: 12,
              ),
              markers: _buildMarkers(listings),
              onMapCreated: (_) {},
              onTap: (_) =>
                  ref.read(selectedMapListingProvider.notifier).state = null,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
            ),
            // Selected listing card
            if (selected != null)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: MapListingBottomCard(
                  listing: selected,
                  onTap: () =>
                      context.go('/explore/listing/${selected.id}'),
                  onClose: () =>
                      ref.read(selectedMapListingProvider.notifier).state = null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
