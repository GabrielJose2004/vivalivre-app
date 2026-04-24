import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with TickerProviderStateMixin {
  int? _selectedPin;
  bool _showEmergency = false;
  final TextEditingController _searchController = TextEditingController();

  // Mock data — identical to the prototype
  final List<Map<String, dynamic>> _bathrooms = [
    {'id': 1, 'name': 'Shopping Iguatemi', 'rating': 4.8, 'distance': '0.2 km', 'tags': ['Acessível', 'Limpo'], 'open': true},
    {'id': 2, 'name': 'Terminal Rodoviário', 'rating': 4.3, 'distance': '0.5 km', 'tags': ['24h', 'Gratuito'], 'open': true},
    {'id': 3, 'name': 'Parque Ibirapuera', 'rating': 4.1, 'distance': '0.8 km', 'tags': ['Gratuito'], 'open': true},
    {'id': 4, 'name': "McDonald's Paulista", 'rating': 3.7, 'distance': '0.3 km', 'tags': ['Rápido'], 'open': false},
    {'id': 5, 'name': 'Metrô Consolação', 'rating': 4.5, 'distance': '1.1 km', 'tags': ['Acessível', '24h'], 'open': true},
  ];

  final List<Offset> _pinPositions = const [
    Offset(0.12, 0.36),
    Offset(0.26, 0.62),
    Offset(0.44, 0.28),
    Offset(0.68, 0.50),
    Offset(0.82, 0.68),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleEmergency() {
    HapticFeedback.mediumImpact();
    setState(() => _showEmergency = true);
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _showEmergency = false;
          _selectedPin = 1;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // ── Simulated Map Background ──────────────────────────────────
          _MapBackground(),

          // ── Current location pulsing dot ──────────────────────────────
          _LocationDot(size: size),

          // ── Bathroom pins ─────────────────────────────────────────────
          ...List.generate(_bathrooms.length, (i) {
            final b = _bathrooms[i];
            final pos = _pinPositions[i];
            final isSelected = _selectedPin == b['id'];
            return _BathroomPin(
              bathroom: b,
              position: pos,
              isSelected: isSelected,
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _selectedPin = isSelected ? null : b['id'] as int);
              },
            );
          }),

          // ── Top search bar ────────────────────────────────────────────
          _TopBar(controller: _searchController, openCount: _bathrooms.where((b) => b['open'] == true).length),

          // ── Location info card (when a pin is selected) ───────────────
          if (_selectedPin != null && !_showEmergency)
            _LocationCard(
              bathroom: _bathrooms.firstWhere((b) => b['id'] == _selectedPin),
              onClose: () => setState(() => _selectedPin = null),
            ),

          // ── Emergency overlay ─────────────────────────────────────────
          if (_showEmergency) const _EmergencyOverlay(),

          // ── FABs (Emergency + Add) ────────────────────────────────────
          _FabRow(onEmergency: _handleEmergency),
        ],
      ),
    );
  }
}

// ── Map background (simulated like prototype) ─────────────────────────────────

class _MapBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(painter: _MapPainter()),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFFDCE8F0);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bg);

    // Main roads — horizontal
    final roadPaint = Paint()..color = Colors.white.withValues(alpha: 0.9);
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.25, size.width, 10), roadPaint);
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.55, size.width, 14), roadPaint);
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.80, size.width, 8), Paint()..color = Colors.white.withValues(alpha: 0.85));

    // Main roads — vertical
    canvas.drawRect(Rect.fromLTWH(size.width * 0.17, 0, 10, size.height), roadPaint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.57, 0, 14, size.height), roadPaint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.83, 0, 8, size.height), Paint()..color = Colors.white.withValues(alpha: 0.85));

    // Buildings
    final buildingPaint = Paint()..color = const Color(0xFFC5D8E6);
    final buildings = [
      Rect.fromLTWH(size.width * 0.05, size.height * 0.08, size.width * 0.18, size.height * 0.14),
      Rect.fromLTWH(size.width * 0.26, size.height * 0.08, size.width * 0.12, size.height * 0.09),
      Rect.fromLTWH(size.width * 0.41, size.height * 0.08, size.width * 0.14, size.height * 0.14),
      Rect.fromLTWH(size.width * 0.60, size.height * 0.30, size.width * 0.20, size.height * 0.26),
      Rect.fromLTWH(size.width * 0.02, size.height * 0.30, size.width * 0.13, size.height * 0.18),
      Rect.fromLTWH(size.width * 0.62, size.height * 0.58, size.width * 0.11, size.height * 0.18),
    ];
    for (final b in buildings) {
      canvas.drawRRect(RRect.fromRectAndRadius(b, const Radius.circular(4)), buildingPaint);
    }

    // Park / green area
    final parkPaint = Paint()..color = const Color(0xFFA8CC98).withValues(alpha: 0.6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.33, size.height * 0.56, size.width * 0.22, size.height * 0.22),
        const Radius.circular(8),
      ),
      parkPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Pulsing location dot ───────────────────────────────────────────────────────

class _LocationDot extends StatefulWidget {
  final Size size;
  const _LocationDot({required this.size});

  @override
  State<_LocationDot> createState() => _LocationDotState();
}

class _LocationDotState extends State<_LocationDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _anim = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.size.width / 2 - 24,
      top: widget.size.height * 0.50,
      child: SizedBox(
        width: 48,
        height: 48,
        child: AnimatedBuilder(
          animation: _anim,
          builder: (context, child) => Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: 1.0 + _anim.value,
                child: Opacity(
                  opacity: 1.0 - _anim.value,
                  child: Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                    ),
                  ),
                ),
              ),
              Container(
                width: 20, height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2563EB),
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: const [BoxShadow(color: Color(0x442563EB), blurRadius: 8)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Bathroom Pin ──────────────────────────────────────────────────────────────

class _BathroomPin extends StatelessWidget {
  final Map<String, dynamic> bathroom;
  final Offset position;
  final bool isSelected;
  final VoidCallback onTap;

  const _BathroomPin({
    required this.bathroom,
    required this.position,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isOpen = bathroom['open'] as bool;

    return Positioned(
      left: size.width * position.dx - 20,
      top: size.height * position.dy - 46,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          scale: isSelected ? 1.25 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: SizedBox(
            width: 40,
            height: 56,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // Pin body
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? const Color(0xFF2563EB) : Colors.white,
                    border: Border.all(
                      color: isSelected ? Colors.white : (isOpen ? const Color(0xFF2563EB) : Colors.grey),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? const Color(0xFF2563EB).withValues(alpha: 0.35)
                            : Colors.black.withValues(alpha: 0.15),
                        blurRadius: isSelected ? 12 : 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.wc_rounded,
                    size: 18,
                    color: isSelected ? Colors.white : (isOpen ? const Color(0xFF2563EB) : Colors.grey),
                  ),
                ),
                // Pin tail
                Positioned(
                  bottom: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    transform: Matrix4.rotationZ(0.785),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF2563EB) : Colors.white,
                      border: isSelected
                          ? null
                          : Border.all(
                              color: isOpen ? const Color(0xFF2563EB) : Colors.grey,
                              width: 1.5,
                            ),
                    ),
                  ),
                ),
                // Rating badge
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4)],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, size: 9, color: Color(0xFFFBBF24)),
                        const SizedBox(width: 1),
                        Text(
                          '${bathroom['rating']}',
                          style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Color(0xFF374151)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Top search bar ─────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final TextEditingController controller;
  final int openCount;

  const _TopBar({required this.controller, required this.openCount});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Search field
                  Expanded(
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.10),
                            blurRadius: 16,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 14),
                          const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: controller,
                              decoration: const InputDecoration(
                                hintText: 'Buscar banheiros...',
                                hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                                border: InputBorder.none,
                                filled: false,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: const TextStyle(fontSize: 15, color: Color(0xFF1E293B)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Locate button
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.10),
                          blurRadius: 16,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                    ),
                    child: const Icon(Icons.my_location_rounded, color: Color(0xFF2563EB), size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Brand chip
              Row(
                children: [
                  Container(
                    width: 26, height: 26,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.wc_rounded, size: 14, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'VivaLivre',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1E293B)),
                  ),
                  const Text(
                    ' · ',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  ),
                  Text(
                    '$openCount banheiros próximos',
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Location card when pin is selected ────────────────────────────────────────

class _LocationCard extends StatelessWidget {
  final Map<String, dynamic> bathroom;
  final VoidCallback onClose;

  const _LocationCard({required this.bathroom, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final isOpen = bathroom['open'] as bool;
    final tags = bathroom['tags'] as List;

    return Positioned(
      left: 16,
      right: 16,
      bottom: 80,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isOpen ? const Color(0xFF10B981) : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isOpen ? 'Aberto agora' : 'Fechado',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isOpen ? const Color(0xFF059669) : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        bathroom['name'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${bathroom['distance']} de distância',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onClose,
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF6B7280)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Tags
            Wrap(
              spacing: 6,
              children: [
                _TagChip(
                  icon: Icons.star_rounded,
                  label: '${bathroom['rating']}',
                  bg: const Color(0xFFFFFBEB),
                  border: const Color(0xFFFDE68A),
                  fg: const Color(0xFFB45309),
                ),
                ...tags.map((tag) => _TagChip(
                  label: tag as String,
                  bg: const Color(0xFFEFF6FF),
                  border: const Color(0xFFBFDBFE),
                  fg: const Color(0xFF2563EB),
                )),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.navigation_rounded, size: 18),
                    label: const Text('Ir agora'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFF374151)),
                    label: const Text('Detalhes', style: TextStyle(color: Color(0xFF374151))),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final Color bg, border, fg;
  final IconData? icon;

  const _TagChip({required this.label, required this.bg, required this.border, required this.fg, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 3),
          ],
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
        ],
      ),
    );
  }
}

// ── Emergency overlay ─────────────────────────────────────────────────────────

class _EmergencyOverlay extends StatelessWidget {
  const _EmergencyOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: const Color(0xFF2563EB).withValues(alpha: 0.4), blurRadius: 32, spreadRadius: 4),
              ],
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bolt_rounded, size: 36, color: Colors.white),
                SizedBox(height: 8),
                Text('Localizando...', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                SizedBox(height: 4),
                Text('Banheiro mais próximo', style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── FAB row ───────────────────────────────────────────────────────────────────

class _FabRow extends StatelessWidget {
  final VoidCallback onEmergency;

  const _FabRow({required this.onEmergency});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 80,
      child: Row(
        children: [
          // Emergency pill
          Expanded(
            child: GestureDetector(
              onTap: onEmergency,
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.45),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bolt_rounded, color: Colors.white, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Achar Banheiro Agora',
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Add bathroom FAB
          Container(
            width: 54, height: 54,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 16, offset: const Offset(0, 4)),
              ],
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: const Icon(Icons.add_rounded, color: Color(0xFF2563EB), size: 26),
          ),
        ],
      ),
    );
  }
}
