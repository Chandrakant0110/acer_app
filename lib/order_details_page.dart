      import 'package:flutter/material.dart';
import 'main.dart';
import 'dart:ui';

class OrderDetailsPage extends StatelessWidget {
  final Order order;

  const OrderDetailsPage({Key? key, required this.order}) : super(key: key);

  OrderStatus getTimeBasedStatus(Order order) {
    // This is a simplified version - you might want to implement actual time-based logic
    return order.status;
  }

  @override
  Widget build(BuildContext context) {
    final calculatedStatus = getTimeBasedStatus(order);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Enhanced app bar with gradient and blur effect
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            stretch: true,
            backgroundColor: acerPrimaryColor,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: acerPrimaryColor),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: IconButton(
                  icon:
                      const Icon(Icons.share_outlined, color: acerPrimaryColor),
                  onPressed: () {
                    // Add share functionality
                  },
                ),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(bottom: 16),
              title: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Text(
                  'Order Details',
                  style: TextStyle(
                    color: acerPrimaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          acerPrimaryColor,
                          acerAccentColor,
                          acerPrimaryColor.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: 0.1,
                    child: CustomPaint(
                      painter: OrderDetailsPatternPainter(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Enhanced status banner
                _buildStatusBanner(context, calculatedStatus),

                // Order info cards
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Enhanced order summary card
                      _buildOrderSummaryCard(),

                      const SizedBox(height: 24),

                      // Enhanced delivery address card
                      _buildDeliveryAddressCard(),

                      const SizedBox(height: 24),

                      // Enhanced order items
                      _buildOrderItemsSection(),

                      const SizedBox(height: 24),

                      // Enhanced payment information
                      _buildPaymentInformationCard(),

                      const SizedBox(height: 24),

                      // Enhanced order actions with cancellation
                      _buildOrderActions(context, calculatedStatus),

                      const SizedBox(height: 24),

                      // Enhanced order timeline
                      _buildOrderTimeline(calculatedStatus),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(BuildContext context, OrderStatus status) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case OrderStatus.confirmed:
        statusColor = Colors.blue;
        statusIcon = Icons.check_circle_outline;
        statusText = 'Order Confirmed';
        break;
      case OrderStatus.processing:
        statusColor = Colors.orange;
        statusIcon = Icons.sync;
        statusText = 'Processing';
        break;
      case OrderStatus.shipped:
        statusColor = Colors.purple;
        statusIcon = Icons.local_shipping_outlined;
        statusText = 'Shipped';
        break;
      case OrderStatus.delivered:
        statusColor = Colors.green;
        statusIcon = Icons.done_all;
        statusText = 'Delivered';
        break;
      case OrderStatus.cancelled:
        statusColor = Colors.red;
        statusIcon = Icons.cancel_outlined;
        statusText = 'Cancelled';
        break;
      case OrderStatus.pending:
        statusColor = Colors.orange;
        statusIcon = Icons.pending_outlined;
        statusText = 'Pending';
        break;
      case OrderStatus.outForDelivery:
        statusColor = Colors.purple;
        statusIcon = Icons.delivery_dining;
        statusText = 'Out for Delivery';
        break;
      case OrderStatus.returned:
        statusColor = Colors.red;
        statusIcon = Icons.assignment_return;
        statusText = 'Returned';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: statusColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: statusColor.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Order ID: ${order.id}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderDetailsPage(
                      order: order,
                    ),
                  ),
                );
              },
              child: Text(
                'Track Order',
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInfoRow(
              Icons.receipt_long_outlined,
              'Order Date',
              _formatDate(order.orderDate),
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.calendar_today_outlined,
              'Expected Delivery',
              _formatDate(order.orderDate.add(const Duration(days: 5))),
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.local_shipping_outlined,
              'Tracking ID',
              order.trackingId ?? 'Not available',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryAddressCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: acerPrimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: acerPrimaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Delivery Address',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              order.deliveryAddress.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              order.deliveryAddress.street,
              style: TextStyle(
                color: Colors.grey[800],
                height: 1.5,
              ),
            ),
            Text(
              '${order.deliveryAddress.city}, ${order.deliveryAddress.state} - ${order.deliveryAddress.zipCode}',
              style: TextStyle(
                color: Colors.grey[800],
                height: 1.5,
              ),
            ),
            Text(
              'Phone: ${order.deliveryAddress.phone}',
              style: TextStyle(
                color: Colors.grey[800],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: acerPrimaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: acerPrimaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Order Items',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: order.items.length,
          itemBuilder: (context, index) {
            final item = order.items[index];
            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey[200]!),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Product image
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            color: Colors.grey[100],
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                '₹${item.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: acerPrimaryColor,
                                ),
                              ),
                              const Text(' × '),
                              Text(
                                '${item.quantity}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '₹${(item.price * item.quantity).toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
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
          },
        ),
      ],
    );
  }

  Widget _buildPaymentInformationCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: acerPrimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.payment_outlined,
                    color: acerPrimaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Payment Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildInfoRow(
              Icons.credit_card_outlined,
              'Payment Method',
              order.paymentMethod,
            ),
            const Divider(height: 24),
            _buildPriceRow('Item Total',
                '₹${(order.totalAmount / 1.18).toStringAsFixed(0)}'),
            const SizedBox(height: 8),
            _buildPriceRow('Shipping', 'FREE', isGreen: true),
            const SizedBox(height: 8),
            _buildPriceRow('GST (18%)',
                '₹${(order.totalAmount - (order.totalAmount / 1.18)).toStringAsFixed(0)}'),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '₹${order.totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: acerPrimaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderActions(BuildContext context, OrderStatus status) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: acerPrimaryColor.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Invoice downloaded'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.download_outlined),
                  label: const Text('DOWNLOAD INVOICE'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: acerPrimaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: acerPrimaryColor),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: acerPrimaryColor.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Connecting to support...'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.support_agent),
                  label: const Text('NEED HELP?'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: acerPrimaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (status != OrderStatus.cancelled &&
            status != OrderStatus.delivered &&
            status != OrderStatus.returned) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text('Cancel Order'),
                      ],
                    ),
                    content: const Text(
                      'Are you sure you want to cancel this order? This action cannot be undone.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('NO'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Order cancelled successfully'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('YES, CANCEL'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('CANCEL ORDER'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOrderTimeline(OrderStatus status) {
    final steps = [
      {
        'icon': Icons.check_circle_outline,
        'title': 'Order Confirmed',
        'status': OrderStatus.confirmed,
        'description': 'Your order has been confirmed'
      },
      {
        'icon': Icons.sync,
        'title': 'Processing',
        'status': OrderStatus.processing,
        'description': 'Your order is being processed'
      },
      {
        'icon': Icons.local_shipping_outlined,
        'title': 'Shipped',
        'status': OrderStatus.shipped,
        'description': 'Your order is on its way'
      },
      {
        'icon': Icons.done_all,
        'title': 'Delivered',
        'status': OrderStatus.delivered,
        'description': 'Your order has been delivered'
      },
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: acerPrimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.timeline,
                    color: acerPrimaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Order Timeline',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: steps.length,
              itemBuilder: (context, index) {
                final step = steps[index];
                final stepStatus = step['status'] as OrderStatus;
                final isCompleted = status.index >= stepStatus.index;
                final isCurrent = status == stepStatus;

                return Row(
                  children: [
                    // Timeline line
                    if (index > 0)
                      Container(
                        width: 2,
                        height: 40,
                        color:
                            isCompleted ? acerPrimaryColor : Colors.grey[300],
                        margin: const EdgeInsets.only(left: 11),
                      ),
                    // Step icon
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color:
                            isCompleted ? acerPrimaryColor : Colors.grey[300],
                        shape: BoxShape.circle,
                        boxShadow: isCompleted
                            ? [
                                BoxShadow(
                                  color: acerPrimaryColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        step['icon'] as IconData,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Step details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step['title'] as String,
                            style: TextStyle(
                              fontWeight: isCurrent
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color:
                                  isCompleted ? Colors.black : Colors.grey[600],
                            ),
                          ),
                          if (isCurrent) ...[
                            const SizedBox(height: 4),
                            Text(
                              step['description'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          color: acerPrimaryColor,
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isGreen ? Colors.green : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

// Enhanced pattern painter for the order details header
class OrderDetailsPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2;

    const dotSpacing = 20.0;

    for (double x = 0; x < size.width; x += dotSpacing) {
      for (double y = 0; y < size.height; y += dotSpacing) {
        canvas.drawCircle(Offset(x, y), 1, dotPaint);
      }
    }

    // Add some larger circles for visual interest
    final accentPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Add more decorative elements
    canvas.drawCircle(
        Offset(size.width * 0.8, size.height * 0.3), 30, accentPaint);
    canvas.drawCircle(
        Offset(size.width * 0.2, size.height * 0.8), 20, accentPaint);
    canvas.drawCircle(
        Offset(size.width * 0.6, size.height * 0.7), 15, accentPaint);
    canvas.drawCircle(
        Offset(size.width * 0.4, size.height * 0.2), 25, accentPaint);
    canvas.drawCircle(
        Offset(size.width * 0.7, size.height * 0.5), 18, accentPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
