import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:viva_livre_app/features/map/presentation/map_bloc.dart';
import 'package:viva_livre_app/features/map/presentation/widgets/bathroom_card.dart';
import 'package:viva_livre_app/features/map/presentation/widgets/emergency_button.dart';
import 'package:viva_livre_app/features/map/domain/entities/bathroom.dart';

// ── Constantes ──
const _kBlue = Color(0xFF2563EB);
const _kText = Color(0xFF111827);
const _kSubText = Color(0xFF6B7280);
const _kInitialCenter = LatLng(-23.66070438587852, -46.43089117960558);
const _kInitialZoom = 17.0;

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  bool _isLocating = false;
  final Distance _distance = const Distance();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchRealGps();
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  // ── GPS Real ──
  Future<void> _fetchRealGps() async {
    if (_isLocating) return;
    setState(() => _isLocating = true);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnack('GPS desativado. Ativa o GPS nas definições do dispositivo.');
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showSnack('Permissão de localização negada.');
        return;
      }

      final accuracy = await Geolocator.getLocationAccuracy();
      if (accuracy == LocationAccuracyStatus.reduced) {
        _showSnack('O VivaLivre precisa da localização EXATA. Altere nas configurações.');
        await Future.delayed(const Duration(seconds: 2));
        await Geolocator.openAppSettings();
        return;
      }

      final LocationSettings locationSettings;
      if (defaultTargetPlatform == TargetPlatform.android) {
        locationSettings = AndroidSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          forceLocationManager: true,
          timeLimit: const Duration(seconds: 15),
        );
      } else if (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS) {
        locationSettings = AppleSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          activityType: ActivityType.fitness,
          timeLimit: const Duration(seconds: 15),
          pauseLocationUpdatesAutomatically: false,
        );
      } else {
        locationSettings = const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          timeLimit: Duration(seconds: 15),
        );
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      if (!mounted) return;

      if (pos.accuracy > 50) {
        _showSnack(
          'Precisão baixa (±${pos.accuracy.toInt()} m). '
          'Vai para um local aberto para melhor sinal GPS.',
        );
      }

      final newPos = LatLng(pos.latitude, pos.longitude);
      context.read<MapBloc>().add(MapUpdateCurrentPosition(newPos));
      _animatedMove(newPos, _kInitialZoom);

    } on TimeoutException {
      if (mounted) {
        _showSnack('GPS sem sinal. Vai para um local aberto e tenta novamente.');
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Não foi possível obter a localização real: $e');
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  // ── "Achar Banheiro Agora" ────────────────────────────────────────────────
  //  BUG-1 FIX: cálculo matemático com Distance() do latlong2.
  //  Nenhuma chamada de rede, nenhum geocoding.

  void _handleFindNearest() {
    Vibration.vibrate(duration: 150, amplitude: 255);
    setState(() => _showEmergency = true);

    // Encontra o banheiro matematicamente mais próximo usando Distance()
    Map<String, dynamic>? nearest;
    double nearestMeters = double.infinity;

    for (final b in _kBathroomsDb) {
      final meters = _distance.as(
        LengthUnit.Meter,
        _currentPosition,
        LatLng(b['lat'] as double, b['lng'] as double),
      );
      if (meters < nearestMeters) {
        nearestMeters = meters;
        nearest = b;
      }
    }

    if (nearest != null) {
      final target = LatLng(nearest['lat'] as double, nearest['lng'] as double);

      _animatedMove(target, _kInitialZoom);

      Future.delayed(const Duration(milliseconds: 1100), () {
        if (!mounted) return;
        setState(() {
          _showEmergency = false;
          _selectedPin = nearest!['id'] as int;
        });
      });
    } else {
      if (mounted) setState(() => _showEmergency = false);
    }
  }

  // ── Animação suave do mapa ────────────────────────────────────────────────

  void _animatedMove(LatLng dest, double zoom) {
    final latTween = Tween<double>(
      begin: camera.center.latitude,
      end: destLocation.latitude,
    );
    final lngTween = Tween<double>(
      begin: camera.center.longitude,
      end: destLocation.longitude,
    );
    final zoomTween = Tween<double>(begin: camera.zoom, end: destZoom);

    final controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    final Animation<double> animation = CurvedAnimation(
      parent: controller,
      curve: Curves.fastOutSlowIn,
    );

    controller.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Flutter Map ────────────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              // BUG-4 FIX: centro inicial = casa do utilizador (-23.681121, -46.435728)
              initialCenter: _kInitialCenter,
              initialZoom: _kInitialZoom,
              onTap: (_, __) {
                if (_selectedPin != null) setState(() => _selectedPin = null);
              },
            ),
            children: [
              // ── Tile Layer ─────────────────────────────────────────────────
              // CartoDB Positron: Design minimalista e médico, tons de cinza suaves.
              // Base de dados: OpenStreetMap (mesmas ruas), renderização limpa.
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.vivalivre.app',

                // Cache agressivo: evita re-downloads e garante que tiles
                // já carregados continuam visíveis ao fazer pan/zoom.
                maxNativeZoom: 19,
                maxZoom: 22,

                // Fallback visual enquanto o tile ainda está a carregar.
                errorTileCallback: (tile, error, stackTrace) {
                  // tile falhou → não mostra nada (padrão), sem crash.
                },
              ),

              // ── Marker Layer ───────────────────────────────────────────────
              MarkerLayer(
                markers: [
                  // Marcador da posição actual — bolinha vermelha sólida
                  _buildCurrentLocationMarker(),

                  // Marcadores dos banheiros — círculo azul com ícone WC
                  ..._kBathroomsDb.map(_buildBathroomMarker),
                ],
              ),
            ],
          ),

          // ── Loading spinner do GPS ─────────────────────────────────────────
          if (_isLocating)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Container(
                  color: Colors.white.withValues(alpha: 0.3),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: _kBlue, strokeWidth: 3),
                          SizedBox(height: 16),
                          Text(
                            'A procurar satélites...',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // ── Barra de busca superior ────────────────────────────────────────
          _TopBar(
            searchController: _searchController,
            openCount: _kBathroomsDb.where((b) => b['open'] == true).length,
            isLocating: _isLocating,
            onLocate: _fetchRealGps,
          ),

          // ── Overlay de emergência ──────────────────────────────────────────
          if (_showEmergency) const _EmergencyOverlay(),

          if (state is MapLoaded) {
            return Stack(
              children: [
                // ── Mapa ──
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _kInitialCenter,
                    initialZoom: _kInitialZoom,
                    minZoom: 10,
                    maxZoom: 22,
                    onTap: (_, __) => context.read<MapBloc>().add(const MapClearSelection()),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c', 'd'],
                      userAgentPackageName: 'com.vivalivre.app',
                      maxNativeZoom: 19,
                      maxZoom: 22,
                    ),
                    MarkerLayer(
                      markers: [
                        if (state.currentPosition != null)
                          Marker(
                            point: state.currentPosition!,
                            width: 24,
                            height: 24,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.red.shade600,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ...state.bathrooms.map((bathroom) {
                          final isSelected = state.selectedBathroom?.id == bathroom.id;
                          return Marker(
                            point: bathroom.location,
                            width: isSelected ? 56 : 48,
                            height: isSelected ? 56 : 48,
                            child: GestureDetector(
                              onTap: () => context.read<MapBloc>().add(MapSelectBathroom(bathroom)),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _kBlue,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _kBlue.withValues(alpha: 0.4),
                                      blurRadius: isSelected ? 16 : 8,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.wc_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),

                // ── Loading GPS ──
                if (_isLocating)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.3),
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                    ),
                  ),

                // ── Botão Localizar ──
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  right: 16,
                  child: FloatingActionButton(
                    heroTag: 'locate',
                    onPressed: _fetchRealGps,
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.my_location_rounded, color: _kBlue),
                  ),
                ),

                // ── Card do Banheiro Selecionado ──
                if (state.selectedBathroom != null)
                  Positioned(
                    bottom: 140,
                    left: 16,
                    right: 16,
                    child: BathroomCard(
                      bathroom: state.selectedBathroom!,
                      distanceInMeters: state.currentPosition != null
                          ? _distance.as(
                              LengthUnit.Meter,
                              state.currentPosition!,
                              state.selectedBathroom!.location,
                            )
                          : null,
                      onTap: () => context.read<MapBloc>().add(const MapClearSelection()),
                    ),
                  ),

                // ── Botão de Emergência ──
                Positioned(
                  bottom: 24,
                  left: 16,
                  right: 16,
                  child: EmergencyButton(
                    onPressed: () => context.read<MapBloc>().add(const MapFindNearestBathroom()),
                    isLoading: false,
                  ),
                ),
              ],
            );
          }

          return const Center(child: Text('Erro ao carregar mapa'));
        },
      ),
    );
  }
}
