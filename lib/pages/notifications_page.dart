import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../providers/order_provider.dart';
import '../location_page.dart';
import '../order_details_page.dart';

// Define Acer brand colors locally
const Color acerPrimaryColor = Color(0xFF83B81A); // Acer green

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          Consumer<NotificationsProvider>(
            builder: (context, notificationProvider, child) {
              if (notificationProvider.hasUnreadNotifications) {
                return TextButton(
                  onPressed: () {
                    notificationProvider.markAllAsRead();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('All notifications marked as read'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Text(
                    'Mark all read',
                    style: TextStyle(
                      color: acerPrimaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Consumer<NotificationsProvider>(
          builder: (context, notificationProvider, child) {
            final notifications = notificationProvider.notifications;

            if (notifications.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: () async {
                // Simulate refresh delay
                await Future.delayed(const Duration(seconds: 1));
                // You can add logic to fetch new notifications here
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return _buildNotificationCard(notification, notificationProvider, index);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll notify you when something important happens',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification, NotificationsProvider provider, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: notification.isRead ? 1 : 3,
        shadowColor: notification.isRead ? Colors.grey[300] : acerPrimaryColor.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: notification.isRead 
              ? BorderSide.none 
              : BorderSide(color: acerPrimaryColor.withOpacity(0.2), width: 1),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (!notification.isRead) {
              provider.markAsRead(notification.id);
            }
            _handleNotificationTap(notification);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: notification.isRead ? Colors.white : acerPrimaryColor.withOpacity(0.02),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getNotificationColor(notification.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getNotificationIcon(notification.type),
                    color: _getNotificationColor(notification.type),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: acerPrimaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notification.body,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatTimestamp(notification.timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (notification.type == NotificationType.service)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Action Required',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.orange[700],
                                  fontWeight: FontWeight.w600,
                                ),
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
        ),
      ),
    );
  }

  void _handleNotificationTap(NotificationItem notification) {
    switch (notification.type) {
      case NotificationType.welcome:
        // Navigate to home or profile
        Navigator.pop(context);
        break;
      case NotificationType.order:
        // Extract order ID from notification ID and navigate to order details
        _navigateToOrderDetails(notification);
        break;
      case NotificationType.service:
        // Navigate to service booking
        _showServiceDialog();
        break;
      case NotificationType.cart:
        // Navigate to cart page
        _navigateToCart();
        break;
      case NotificationType.discount:
        // Show discount details or navigate to product
        _showDiscountDialog(notification);
        break;
    }
  }

  void _navigateToOrderDetails(NotificationItem notification) {
    try {
      // Extract order ID from notification ID (format: 'order_${orderId}_${timestamp}')
      final notificationIdParts = notification.id.split('_');
      if (notificationIdParts.length >= 3 && notificationIdParts[0] == 'order') {
        final orderId = notificationIdParts[1];
        
        // Get the order from OrderProvider
        final orderProvider = Provider.of<OrderProvider>(context, listen: false);
        final order = orderProvider.getOrderById(orderId);
        
        if (order != null) {
          // Navigate to order details page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailsPage(order: order),
            ),
          );
        } else {
          // Order not found, show error message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order not found. It may have been removed.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        // Invalid notification ID format
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open order details.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error opening order details.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _navigateToCart() {
    Navigator.pop(context); // Close notifications page
    // You may need to adjust this based on your navigation structure
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening cart...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showDiscountDialog(NotificationItem notification) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            notification.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(notification.body),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Later',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to product or cart
                _navigateToCart();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: acerPrimaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Shop Now'),
            ),
          ],
        );
      },
    );
  }

  void _showServiceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Service Reminder',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'It\'s time for your device service check-up. Would you like to find the nearest Acer service center?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Later',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to store locator page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LocationPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: acerPrimaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Find Centers'),
            ),
          ],
        );
      },
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.welcome:
        return Icons.waving_hand;
      case NotificationType.order:
        return Icons.shopping_bag_outlined;
      case NotificationType.service:
        return Icons.build_outlined;
      case NotificationType.cart:
        return Icons.shopping_cart_outlined;
      case NotificationType.discount:
        return Icons.local_offer_outlined;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.welcome:
        return acerPrimaryColor;
      case NotificationType.order:
        return Colors.blue;
      case NotificationType.service:
        return Colors.orange;
      case NotificationType.cart:
        return Colors.purple;
      case NotificationType.discount:
        return Colors.red;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
} 