// Aether OS UI Framework
// Flutter-based mobile UI for Aether OS

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:ffi' as ffi;
import 'dart:io';

// Native Aether OS bindings
class AetherNative {
  static final ffi.DynamicLibrary _lib = Platform.isLinux
      ? ffi.DynamicLibrary.open('libaether.so')
      : ffi.DynamicLibrary.process();
  
  // Native function bindings
  static final Function getPowerLevel = _lib
      .lookup<ffi.NativeFunction<ffi.Int32 Function()>>('aether_get_battery')
      .asFunction<int Function()>();
  
  static final Function getSignalStrength = _lib
      .lookup<ffi.NativeFunction<ffi.Int32 Function()>>('aether_get_signal')
      .asFunction<int Function()>();
}

// Main Aether OS App
void main() {
  runApp(AetherOS());
}

class AetherOS extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aether OS',
      theme: AetherTheme.light(),
      darkTheme: AetherTheme.dark(),
      themeMode: ThemeMode.system,
      home: AetherHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Aether OS Theme
class AetherTheme {
  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: Color(0xFF6C63FF),
      accentColor: Color(0xFF00BFA5),
      scaffoldBackgroundColor: Color(0xFFF5F7FA),
      fontFamily: 'AetherSans',
      colorScheme: ColorScheme.light(
        primary: Color(0xFF6C63FF),
        secondary: Color(0xFF00BFA5),
        surface: Colors.white,
        background: Color(0xFFF5F7FA),
      ),
    );
  }
  
  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Color(0xFF6C63FF),
      accentColor: Color(0xFF00BFA5),
      scaffoldBackgroundColor: Color(0xFF0F0F1E),
      fontFamily: 'AetherSans',
      colorScheme: ColorScheme.dark(
        primary: Color(0xFF6C63FF),
        secondary: Color(0xFF00BFA5),
        surface: Color(0xFF1A1A2E),
        background: Color(0xFF0F0F1E),
      ),
    );
  }
}

// Aether Home Screen
class AetherHome extends StatefulWidget {
  @override
  _AetherHomeState createState() => _AetherHomeState();
}

class _AetherHomeState extends State<AetherHome> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  int _selectedIndex = 0;
  bool _isAppDrawerOpen = false;
  bool _isNotificationPanelOpen = false;
  bool _isControlCenterOpen = false;
  
  List<AppInfo> installedApps = [
    AppInfo('Phone', Icons.phone, Color(0xFF4CAF50)),
    AppInfo('Messages', Icons.message, Color(0xFF2196F3)),
    AppInfo('Browser', Icons.language, Color(0xFFFF9800)),
    AppInfo('Camera', Icons.camera_alt, Color(0xFF9C27B0)),
    AppInfo('Gallery', Icons.photo_library, Color(0xFFE91E63)),
    AppInfo('Settings', Icons.settings, Color(0xFF607D8B)),
    AppInfo('Files', Icons.folder, Color(0xFFFFEB3B)),
    AppInfo('Music', Icons.music_note, Color(0xFF00BCD4)),
    AppInfo('Store', Icons.shopping_bag, Color(0xFF8BC34A)),
    AppInfo('Weather', Icons.wb_sunny, Color(0xFFFFC107)),
    AppInfo('Clock', Icons.access_time, Color(0xFF795548)),
    AppInfo('Calculator', Icons.calculate, Color(0xFF9E9E9E)),
  ];
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Wallpaper
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: Theme.of(context).brightness == Brightness.dark
                    ? [Color(0xFF1A1A2E), Color(0xFF0F0F1E)]
                    : [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
            ),
          ),
          
          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Status Bar
                AetherStatusBar(),
                
                // Home Screen Content
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildHomeContent(),
                  ),
                ),
                
                // Navigation Bar
                AetherNavigationBar(
                  selectedIndex: _selectedIndex,
                  onIndexChanged: (index) {
                    setState(() {
                      _selectedIndex = index;
                      if (index == 2) {
                        _isAppDrawerOpen = !_isAppDrawerOpen;
                      }
                    });
                  },
                ),
              ],
            ),
          ),
          
          // App Drawer
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: _isAppDrawerOpen ? 0 : -MediaQuery.of(context).size.height * 0.7,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.7,
            child: AetherAppDrawer(
              apps: installedApps,
              onClose: () {
                setState(() {
                  _isAppDrawerOpen = false;
                });
              },
            ),
          ),
          
          // Notification Panel
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            top: _isNotificationPanelOpen ? 0 : -MediaQuery.of(context).size.height * 0.8,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.8,
            child: AetherNotificationPanel(
              onClose: () {
                setState(() {
                  _isNotificationPanelOpen = false;
                });
              },
            ),
          ),
          
          // Control Center
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: _isControlCenterOpen ? 0 : -MediaQuery.of(context).size.height * 0.4,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.4,
            child: AetherControlCenter(
              onClose: () {
                setState(() {
                  _isControlCenterOpen = false;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHomeContent() {
    return PageView(
      children: [
        // Main Home Page
        _buildMainPage(),
        
        // Widgets Page
        _buildWidgetsPage(),
      ],
    );
  }
  
  Widget _buildMainPage() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          AetherSearchBar(),
          
          SizedBox(height: 24),
          
          // Quick Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickAction(Icons.phone, 'Phone', Color(0xFF4CAF50)),
              _buildQuickAction(Icons.message, 'Messages', Color(0xFF2196F3)),
              _buildQuickAction(Icons.camera_alt, 'Camera', Color(0xFF9C27B0)),
              _buildQuickAction(Icons.language, 'Browser', Color(0xFFFF9800)),
            ],
          ),
          
          SizedBox(height: 24),
          
          // Widgets
          Expanded(
            child: ListView(
              children: [
                AetherWeatherWidget(),
                SizedBox(height: 16),
                AetherMusicWidget(),
                SizedBox(height: 16),
                AetherCalendarWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWidgetsPage() {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return AetherWidget(
          title: 'Widget ${index + 1}',
          icon: Icons.widgets,
        );
      },
    );
  }
  
  Widget _buildQuickAction(IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // Launch app
      },
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Status Bar
class AetherStatusBar extends StatefulWidget {
  @override
  _AetherStatusBarState createState() => _AetherStatusBarState();
}

class _AetherStatusBarState extends State<AetherStatusBar> {
  late Timer _timer;
  DateTime _currentTime = DateTime.now();
  int _batteryLevel = 85;
  int _signalStrength = 4;
  
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
    _updateSystemInfo();
  }
  
  void _updateSystemInfo() async {
    // Update battery and signal from native
    // _batteryLevel = AetherNative.getPowerLevel();
    // _signalStrength = AetherNative.getSignalStrength();
  }
  
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Time
          Text(
            '${_currentTime.hour.toString().padLeft(2, '0')}:${_currentTime.minute.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          
          // Status Icons
          Row(
            children: [
              // Signal
              Icon(
                _getSignalIcon(),
                size: 16,
                color: Colors.white,
              ),
              SizedBox(width: 8),
              
              // WiFi
              Icon(
                Icons.wifi,
                size: 16,
                color: Colors.white,
              ),
              SizedBox(width: 8),
              
              // Battery
              Stack(
                children: [
                  Icon(
                    Icons.battery_full,
                    size: 16,
                    color: Colors.white,
                  ),
                  Positioned(
                    right: 2,
                    top: 2,
                    child: Text(
                      '$_batteryLevel',
                      style: TextStyle(
                        fontSize: 8,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  IconData _getSignalIcon() {
    switch (_signalStrength) {
      case 0:
        return Icons.signal_cellular_0_bar;
      case 1:
        return Icons.signal_cellular_alt_1_bar;
      case 2:
        return Icons.signal_cellular_alt_2_bar;
      default:
        return Icons.signal_cellular_alt;
    }
  }
}

// Navigation Bar
class AetherNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onIndexChanged;
  
  AetherNavigationBar({
    required this.selectedIndex,
    required this.onIndexChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.black.withOpacity(0.8)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(0, Icons.home_rounded, 'Home'),
          _buildNavItem(1, Icons.search_rounded, 'Search'),
          _buildNavItem(2, Icons.apps_rounded, 'Apps'),
          _buildNavItem(3, Icons.notifications_rounded, 'Alerts'),
        ],
      ),
    );
  }
  
  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = selectedIndex == index;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onIndexChanged(index);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Color(0xFF6C63FF).withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          color: isSelected ? Color(0xFF6C63FF) : Colors.grey,
          size: 24,
        ),
      ),
    );
  }
}

// Search Bar
class AetherSearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(width: 16),
          Icon(Icons.search, color: Colors.grey),
          SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search apps, web, and more...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.mic, color: Colors.grey),
            onPressed: () {
              // Voice search
            },
          ),
        ],
      ),
    );
  }
}

// App Drawer
class AetherAppDrawer extends StatelessWidget {
  final List<AppInfo> apps;
  final VoidCallback onClose;
  
  AetherAppDrawer({required this.apps, required this.onClose});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Apps Grid
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: apps.length,
              itemBuilder: (context, index) {
                return AppIcon(app: apps[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// App Icon
class AppIcon extends StatelessWidget {
  final AppInfo app;
  
  AppIcon({required this.app});
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // Launch app
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: app.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              app.icon,
              color: app.color,
              size: 28,
            ),
          ),
          SizedBox(height: 8),
          Text(
            app.name,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// Models
class AppInfo {
  final String name;
  final IconData icon;
  final Color color;
  
  AppInfo(this.name, this.icon, this.color);
}

// Widgets
class AetherWeatherWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '23°',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Partly Cloudy',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.wb_cloudy,
                size: 64,
                color: Colors.white,
              ),
            ],
          ),
          Spacer(),
          Text(
            'San Francisco',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class AetherMusicWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFAB47BC), Color(0xFF9C27B0)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.music_note,
              size: 40,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Now Playing',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Cosmic Journey',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Aether Sounds',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.skip_previous, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.pause, color: Colors.white, size: 32),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.skip_next, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AetherCalendarWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${DateTime.now().day}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _getMonthName(DateTime.now().month),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Today',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Team Meeting',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '10:00 AM - 11:00 AM',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  String _getMonthName(int month) {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
                   'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return months[month - 1];
  }
}

class AetherWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  
  AetherWidget({required this.title, required this.icon});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: Theme.of(context).primaryColor),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Notification Panel
class AetherNotificationPanel extends StatelessWidget {
  final VoidCallback onClose;
  
  AetherNotificationPanel({required this.onClose});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.clear_all),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            
            // Notifications List
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return NotificationTile(
                    app: 'Messages',
                    title: 'New message',
                    content: 'Hey, are you free for lunch today?',
                    time: '5 min ago',
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final String app;
  final String title;
  final String content;
  final String time;
  
  NotificationTile({
    required this.app,
    required this.title,
    required this.content,
    required this.time,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.message, color: Colors.blue, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      app,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Control Center
class AetherControlCenter extends StatefulWidget {
  final VoidCallback onClose;
  
  AetherControlCenter({required this.onClose});
  
  @override
  _AetherControlCenterState createState() => _AetherControlCenterState();
}

class _AetherControlCenterState extends State<AetherControlCenter> {
  bool _wifiEnabled = true;
  bool _bluetoothEnabled = false;
  bool _airplaneModeEnabled = false;
  bool _doNotDisturbEnabled = false;
  double _brightness = 0.8;
  double _volume = 0.5;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Quick Settings Grid
          Padding(
            padding: EdgeInsets.all(16),
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                QuickSettingTile(
                  icon: Icons.wifi,
                  label: 'WiFi',
                  enabled: _wifiEnabled,
                  onTap: () {
                    setState(() {
                      _wifiEnabled = !_wifiEnabled;
                    });
                  },
                ),
                QuickSettingTile(
                  icon: Icons.bluetooth,
                  label: 'Bluetooth',
                  enabled: _bluetoothEnabled,
                  onTap: () {
                    setState(() {
                      _bluetoothEnabled = !_bluetoothEnabled;
                    });
                  },
                ),
                QuickSettingTile(
                  icon: Icons.airplanemode_active,
                  label: 'Airplane',
                  enabled: _airplaneModeEnabled,
                  onTap: () {
                    setState(() {
                      _airplaneModeEnabled = !_airplaneModeEnabled;
                    });
                  },
                ),
                QuickSettingTile(
                  icon: Icons.do_not_disturb,
                  label: 'DND',
                  enabled: _doNotDisturbEnabled,
                  onTap: () {
                    setState(() {
                      _doNotDisturbEnabled = !_doNotDisturbEnabled;
                    });
                  },
                ),
                QuickSettingTile(
                  icon: Icons.flashlight_on,
                  label: 'Flashlight',
                  enabled: false,
                  onTap: () {},
                ),
                QuickSettingTile(
                  icon: Icons.screen_rotation,
                  label: 'Rotate',
                  enabled: false,
                  onTap: () {},
                ),
                QuickSettingTile(
                  icon: Icons.location_on,
                  label: 'Location',
                  enabled: true,
                  onTap: () {},
                ),
                QuickSettingTile(
                  icon: Icons.dark_mode,
                  label: 'Dark',
                  enabled: Theme.of(context).brightness == Brightness.dark,
                  onTap: () {},
                ),
              ],
            ),
          ),
          
          // Sliders
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Brightness
                Row(
                  children: [
                    Icon(Icons.brightness_low, size: 20),
                    Expanded(
                      child: Slider(
                        value: _brightness,
                        onChanged: (value) {
                          setState(() {
                            _brightness = value;
                          });
                        },
                      ),
                    ),
                    Icon(Icons.brightness_high, size: 20),
                  ],
                ),
                
                // Volume
                Row(
                  children: [
                    Icon(Icons.volume_down, size: 20),
                    Expanded(
                      child: Slider(
                        value: _volume,
                        onChanged: (value) {
                          setState(() {
                            _volume = value;
                          });
                        },
                      ),
                    ),
                    Icon(Icons.volume_up, size: 20),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class QuickSettingTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  
  QuickSettingTile({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          color: enabled
              ? Theme.of(context).primaryColor
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: enabled ? Colors.white : Colors.grey,
              size: 24,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: enabled ? Colors.white : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}