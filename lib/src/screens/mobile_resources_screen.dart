import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class MobileResourcesScreen extends StatefulWidget {
  const MobileResourcesScreen({super.key});

  @override
  State<MobileResourcesScreen> createState() => _MobileResourcesScreenState();
}

class _MobileResourcesScreenState extends State<MobileResourcesScreen> {
  static const List<int> _barcodePattern = [
    2,
    1,
    1,
    2,
    3,
    1,
    1,
    2,
    2,
    1,
    3,
    2,
    1,
    1,
    2,
  ];

  String? _lastScan;

  void _openScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _CameraScanner(
          onScan: (value) {
            setState(() {
              _lastScan = value;
            });
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Lectura capturada: $value')),
              );
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recursos Móviles'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Código QR y código de barras',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Acceso a hardware móvil: Uso de cámara, GPS y lectura de códigos QR.',
              style: textTheme.titleMedium,
            ),
            if (_lastScan != null) ...[
              const SizedBox(height: 12),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.qr_code_scanner),
                  title: const Text('Última lectura'),
                  subtitle: Text(_lastScan!),
                  trailing: IconButton(
                    onPressed: () => setState(() => _lastScan = null),
                    icon: const Icon(Icons.clear),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          FractionallySizedBox(
                            widthFactor: 0.6,
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  'https://api.qrserver.com/v1/create-qr-code/?data=Recursos%20Moviles&size=200x200',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: theme.colorScheme.surfaceContainerHighest,
                                      alignment: Alignment.center,
                                      child: const Icon(Icons.qr_code, size: 64),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: AspectRatio(
                              aspectRatio: 3,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHighest,
                                ),
                                child: Center(
                                  child: FractionallySizedBox(
                                    widthFactor: 0.7,
                                    heightFactor: 0.55,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surface,
                                        borderRadius: BorderRadius.circular(4),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: SizedBox.expand(
                                        child: CustomPaint(
                                          painter: _BarcodePainter(_barcodePattern),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'S 123451 294567',
                            style: textTheme.titleMedium?.copyWith(
                              letterSpacing: 2,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Abrir cámara para escanear'),
                onPressed: _openScanner,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CameraScanner extends StatelessWidget {
  const _CameraScanner({required this.onScan});

  final ValueChanged<String> onScan;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escáner de cámara'),
      ),
      body: Stack(
        children: [
          MobileScanner(
            fit: BoxFit.cover,
            onDetect: (capture) {
              final barcode =
                  capture.barcodes.isNotEmpty ? capture.barcodes.first : null;
              final value = barcode?.rawValue ?? barcode?.displayValue;
              if (value != null) {
                onScan(value);
                Navigator.pop(context);
              }
            },
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    'Apunta la cámara hacia un código QR o de barras para escanearlo.',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarcodePainter extends CustomPainter {
  const _BarcodePainter(this.pattern);

  final List<int> pattern;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final totalUnits = pattern.fold<int>(0, (sum, value) => sum + value);
    final unitWidth = size.width / totalUnits;

    var drawBar = true;
    var x = 0.0;
    for (final units in pattern) {
      final width = units * unitWidth;
      if (drawBar) {
        canvas.drawRect(Rect.fromLTWH(x, 0, width, size.height), paint);
      }
      drawBar = !drawBar;
      x += width;
    }
  }

  @override
  bool shouldRepaint(covariant _BarcodePainter oldDelegate) {
    return oldDelegate.pattern != pattern;
  }
}
