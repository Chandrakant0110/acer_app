import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../main.dart';
import '../services/connectivity_service.dart';

class OfflinePage extends StatefulWidget {
  const OfflinePage({Key? key}) : super(key: key);

  @override
  State<OfflinePage> createState() => _OfflinePageState();
}

class _OfflinePageState extends State<OfflinePage> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late AnimationController _rotateController;
  late AnimationController _floatingController;
  late AnimationController _waveController;
  late AnimationController _particleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _waveAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();
    
    _rotateController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _waveController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
    
    _particleController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();
    
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.elasticOut,
    ));
    
    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotateController,
      curve: Curves.linear,
    ));
    
    _floatingAnimation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));
    
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.linear,
    ));
    
    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    _rotateController.dispose();
    _floatingController.dispose();
    _waveController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.white,
              Colors.grey.shade50,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Consumer<ConnectivityService>(
          builder: (context, connectivityService, child) {
            if (connectivityService.isOnline) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacementNamed(context, '/home');
              });
            }
            
            return Stack(
              children: [
                // Background decorative elements
                _buildBackgroundDecorations(),
                
                // Main content
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          // Top section with logo and store name
                          _buildTopSection(),
                          
                          // Middle section with wifi icon and message
                          Expanded(
                            child: _buildMiddleSection(),
                          ),
                          
                          // Bottom section with retry button
                          _buildBottomSection(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBackgroundDecorations() {
    return Stack(
      children: [
        // Gradient overlay waves
        AnimatedBuilder(
          animation: _waveAnimation,
          builder: (context, child) {
            return Positioned.fill(
              child: CustomPaint(
                painter: WavePainter(_waveAnimation.value),
              ),
            );
          },
        ),
        
        // Floating particles
        ...List.generate(8, (index) {
          return AnimatedBuilder(
            animation: _particleAnimation,
            builder: (context, child) {
              final offset = (_particleAnimation.value + index * 0.125) % 1.0;
              final size = 4.0 + (index % 3) * 2.0;
              final opacity = (0.3 + (index % 4) * 0.1);
              
              return Positioned(
                left: 50.0 + index * 40.0 + offset * 100,
                top: 80.0 + index * 60.0 + offset * 200,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: [
                      acerPrimaryColor,
                      Colors.blue,
                      Colors.cyan,
                      Colors.indigo,
                    ][index % 4].withOpacity(opacity),
                  ),
                ),
              );
            },
          );
        }),
        
        // Large floating circles with different animations
        AnimatedBuilder(
          animation: _floatingAnimation,
          builder: (context, child) {
            return Positioned(
              top: 100 + _floatingAnimation.value,
              right: 50,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      acerPrimaryColor.withOpacity(0.15),
                      acerPrimaryColor.withOpacity(0.05),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        
        AnimatedBuilder(
          animation: _floatingAnimation,
          builder: (context, child) {
            return Positioned(
              bottom: 200 - _floatingAnimation.value,
              left: 30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.blue.withOpacity(0.12),
                      Colors.blue.withOpacity(0.04),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        
        // Additional floating shapes
        AnimatedBuilder(
          animation: _particleAnimation,
          builder: (context, child) {
            return Positioned(
              top: 150 + _particleAnimation.value * 20,
              left: 20,
              child: Transform.rotate(
                angle: _particleAnimation.value * 2 * 3.14159,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple.withOpacity(0.1),
                        Colors.pink.withOpacity(0.05),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        
        AnimatedBuilder(
          animation: _waveAnimation,
          builder: (context, child) {
            return Positioned(
              bottom: 150 + _waveAnimation.value * 30,
              right: 30,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.teal.withOpacity(0.1),
                      Colors.green.withOpacity(0.05),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        
        // Rotating geometric elements
        AnimatedBuilder(
          animation: _rotateAnimation,
          builder: (context, child) {
            return Positioned(
              top: 200,
              left: 50,
              child: Transform.rotate(
                angle: _rotateAnimation.value * 2 * 3.14159,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: acerPrimaryColor.withOpacity(0.2),
                      width: 2,
                    ),
                    gradient: LinearGradient(
                      colors: [
                        acerPrimaryColor.withOpacity(0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        
        // Counter-rotating element
        AnimatedBuilder(
          animation: _rotateAnimation,
          builder: (context, child) {
            return Positioned(
              bottom: 100,
              right: 80,
              child: Transform.rotate(
                angle: -_rotateAnimation.value * 1.5 * 3.14159,
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        
        // Floating hexagons
        AnimatedBuilder(
          animation: _floatingAnimation,
          builder: (context, child) {
            return Positioned(
              top: 300 - _floatingAnimation.value * 1.5,
              right: 20,
              child: Transform.rotate(
                angle: _floatingAnimation.value * 0.5,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            );
          },
        ),
        
        AnimatedBuilder(
          animation: _waveAnimation,
          builder: (context, child) {
            return Positioned(
              top: 400 + _waveAnimation.value * 15,
              left: 80,
              child: Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.withOpacity(0.15),
                      Colors.yellow.withOpacity(0.05),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTopSection() {
    return Column(
      children: [
        const SizedBox(height: 40),
        // Enhanced logo container
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Image.asset(
            'assets/logos/acer_logo.png',
            height: 50,
            errorBuilder: (context, error, stackTrace) => 
              const Icon(
                Icons.store,
                size: 50,
                color: acerPrimaryColor,
              ),
          ),
        ),
        const SizedBox(height: 16),
        // Enhanced store name
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [acerPrimaryColor, Colors.blue.shade700],
          ).createShader(bounds),
          child: const Text(
            'Acer Store',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Premium Technology Solutions',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildMiddleSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Enhanced WiFi off icon with container
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Icon(
                  Icons.wifi_off_rounded,
                  size: 60,
                  color: Colors.grey[400],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 28),
        
        // Enhanced message card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Connection Unavailable',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Please check your internet connection and try again',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Connection status indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Offline',
                    style: TextStyle(
                      color: Colors.red.shade600,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSection() {
    return Column(
      children: [
        // Enhanced Retry Connection Button
        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: acerPrimaryColor.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: () async {
              final connectivityService = Provider.of<ConnectivityService>(context, listen: false);
              
              // Show loading feedback
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('Checking connection...'),
                    ],
                  ),
                  backgroundColor: Colors.blue,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: const EdgeInsets.all(20),
                ),
              );
              
              await connectivityService.refreshConnectivity();
              
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(
                        connectivityService.isOnline 
                          ? Icons.check_circle 
                          : Icons.error_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        connectivityService.isOnline 
                          ? 'Connection restored!' 
                          : 'Still no connection. Please try again.',
                      ),
                    ],
                  ),
                  backgroundColor: connectivityService.isOnline 
                    ? Colors.green.shade600
                    : Colors.red.shade600,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: const EdgeInsets.all(20),
                ),
              );
            },
            icon: const Icon(Icons.refresh_rounded, size: 20),
            label: const Text(
              'Retry Connection',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: acerPrimaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        
        // Additional helpful text
        Text(
          'Make sure WiFi or mobile data is enabled',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[500],
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
      ],
          );
    }
  }

class WavePainter extends CustomPainter {
  final double animationValue;

  WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Create multiple wave layers
    _drawWave(canvas, size, paint, animationValue, 0.02, Colors.blue.withOpacity(0.03));
    _drawWave(canvas, size, paint, animationValue * 0.8, 0.025, acerPrimaryColor.withOpacity(0.02));
    _drawWave(canvas, size, paint, animationValue * 1.2, 0.015, Colors.cyan.withOpacity(0.02));
  }

  void _drawWave(Canvas canvas, Size size, Paint paint, double phase, double frequency, Color color) {
    paint.color = color;
    
    final path = Path();
    final amplitude = size.height * 0.05;
    
    path.moveTo(0, size.height * 0.7);
    
    for (double x = 0; x <= size.width; x += 2) {
      final y = size.height * 0.7 + 
                amplitude * math.sin((x * frequency) + (phase * 2 * math.pi));
      path.lineTo(x, y);
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
} 