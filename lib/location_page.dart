import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'main.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage>
    with SingleTickerProviderStateMixin {
  String _selectedCity = 'Mumbai';
  String _selectedType = 'all'; // 'all', 'shop', 'service'
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Sample data for Acer stores and service centers
  final Map<String, List<Map<String, dynamic>>> _locations = {
    'Mumbai': [
      {
        'name': 'Acer Mall - Exclusive Store',
        'address': 'Shop no 18, Rizvi building, Milan Subway, Rizvi Nagar, MSEB Colony, Santacruz (West), Mumbai, Maharashtra 400054',
        'type': 'shop',
        'lat': 19.05227,
        'lng': 72.85184,
        'phone': '+91 9876543210',
      },
      {
        'name': 'Acer Service Center - Malad',
        'address': 'Shop 204, Inorbit Mall, Malad West, Mumbai 400064',
        'type': 'service',
        'lat': 19.1890,
        'lng': 72.8347,
        'phone': '+91 22 6789 1235',
      },
      {
        'name': 'Acer Premium Store - Bandra',
        'address': 'G-18, Palladium Mall, High Street Phoenix, Lower Parel, Mumbai 400013',
        'type': 'shop',
        'lat': 19.0136,
        'lng': 72.8320,
        'phone': '+91 22 6789 1236',
      },
      {
        'name': 'Acer Service Hub - Powai',
        'address': 'Office 301, Hiranandani Business Park, Powai, Mumbai 400076',
        'type': 'service',
        'lat': 19.1197,
        'lng': 72.9073,
        'phone': '+91 22 6789 1237',
      },
    ],
    'Delhi': [
      {
        'name': 'Acer Store - Connaught Place',
        'address': 'Shop 15, Block A, Connaught Place, New Delhi 110001',
        'type': 'shop',
        'lat': 28.6315,
        'lng': 77.2167,
        'phone': '+91 11 4567 8901',
      },
      {
        'name': 'Acer Service Hub - Nehru Place',
        'address': 'Unit 108, Nehru Place Market, New Delhi 110019',
        'type': 'service',
        'lat': 28.5494,
        'lng': 77.2519,
        'phone': '+91 11 4567 8902',
      },
      {
        'name': 'Acer Exclusive Store - Saket',
        'address': 'LG-25, Select City Walk Mall, Saket District Centre, New Delhi 110017',
        'type': 'shop',
        'lat': 28.5245,
        'lng': 77.2066,
        'phone': '+91 11 4567 8903',
      },
      {
        'name': 'Acer Service Center - Rajouri Garden',
        'address': 'B-24, Rajouri Garden Main Market, New Delhi 110027',
        'type': 'service',
        'lat': 28.6466,
        'lng': 77.1207,
        'phone': '+91 11 4567 8904',
      },
    ],
    'Bangalore': [
      {
        'name': 'Acer Mall Store - MG Road',
        'address': 'UB City Mall, Level 2, Vittal Mallya Road, Bangalore 560001',
        'type': 'shop',
        'lat': 12.9722,
        'lng': 77.6191,
        'phone': '+91 80 2345 6789',
      },
      {
        'name': 'Acer Care - Koramangala',
        'address': 'Forum Mall, 5th Block, Koramangala, Bangalore 560095',
        'type': 'service',
        'lat': 12.9320,
        'lng': 77.6139,
        'phone': '+91 80 2345 6790',
      },
      {
        'name': 'Acer Premium Store - Indiranagar',
        'address': '1216, 100 Feet Road, Indiranagar, Bangalore 560038',
        'type': 'shop',
        'lat': 12.9719,
        'lng': 77.6412,
        'phone': '+91 80 2345 6791',
      },
      {
        'name': 'Acer Service Hub - Whitefield',
        'address': 'Phoenix Marketcity, Mahadevapura, Whitefield, Bangalore 560048',
        'type': 'service',
        'lat': 12.9973,
        'lng': 77.6957,
        'phone': '+91 80 2345 6792',
      },
    ],
    'Chennai': [
      {
        'name': 'Acer Exclusive Store - T Nagar',
        'address': '45, North Usman Road, T Nagar, Chennai 600017',
        'type': 'shop',
        'lat': 13.0434,
        'lng': 80.2340,
        'phone': '+91 44 3456 7890',
      },
      {
        'name': 'Acer Service Center - Anna Nagar',
        'address': 'No. 12, 2nd Avenue, Anna Nagar, Chennai 600040',
        'type': 'service',
        'lat': 13.0827,
        'lng': 80.2076,
        'phone': '+91 44 3456 7891',
      },
      {
        'name': 'Acer Premium Store - Velachery',
        'address': 'Phoenix MarketCity, Level 2, Velachery, Chennai 600042',
        'type': 'shop',
        'lat': 12.9815,
        'lng': 80.2207,
        'phone': '+91 44 3456 7892',
      },
    ],
    'Hyderabad': [
      {
        'name': 'Acer Mall Store - Banjara Hills',
        'address': 'GVK One Mall, Road No. 12, Banjara Hills, Hyderabad 500034',
        'type': 'shop',
        'lat': 17.4239,
        'lng': 78.4738,
        'phone': '+91 40 4567 8901',
      },
      {
        'name': 'Acer Service Hub - Hitech City',
        'address': 'Cyber Gateway, Plot 12-19, HITEC City, Madhapur, Hyderabad 500081',
        'type': 'service',
        'lat': 17.4485,
        'lng': 78.3908,
        'phone': '+91 40 4567 8902',
      },
      {
        'name': 'Acer Exclusive Store - Jubilee Hills',
        'address': 'The Forum Sujana Mall, Road No. 36, Jubilee Hills, Hyderabad 500033',
        'type': 'shop',
        'lat': 17.4241,
        'lng': 78.4480,
        'phone': '+91 40 4567 8903',
      },
    ],
    'Kolkata': [
      {
        'name': 'Acer Store - Park Street',
        'address': 'Forum Mall, 10/3 Elgin Road, Park Street, Kolkata 700020',
        'type': 'shop',
        'lat': 22.5448,
        'lng': 88.3426,
        'phone': '+91 33 5678 9012',
      },
      {
        'name': 'Acer Service Center - Salt Lake',
        'address': 'City Centre Salt Lake, DC Block, Sector I, Salt Lake City, Kolkata 700064',
        'type': 'service',
        'lat': 22.5744,
        'lng': 88.4248,
        'phone': '+91 33 5678 9013',
      },
    ],
    'Pune': [
      {
        'name': 'Acer Premium Store - Koregaon Park',
        'address': 'Phoenix MarketCity, Viman Nagar, Pune 411014',
        'type': 'shop',
        'lat': 18.5679,
        'lng': 73.9143,
        'phone': '+91 20 6789 0123',
      },
      {
        'name': 'Acer Service Hub - Aundh',
        'address': 'Westend Mall, Aundh IT Park, Aundh, Pune 411007',
        'type': 'service',
        'lat': 18.5584,
        'lng': 73.7731,
        'phone': '+91 20 6789 0124',
      },
    ],
    'Ahmedabad': [
      {
        'name': 'Acer Exclusive Store - CG Road',
        'address': 'CG Road, Navrangpura',
        'type': 'shop',
        'lat': 23.0225,
        'lng': 72.5714,
        'phone': '+91 9876543226',
      },
      {
        'name': 'Acer Service Center - Satellite',
        'address': 'Satellite Road, Ahmedabad',
        'type': 'service',
        'lat': 23.0117,
        'lng': 72.5253,
        'phone': '+91 9876543227',
      },
    ],
    'Jaipur': [
      {
        'name': 'Acer Store - Tonk Road',
        'address': 'Tonk Road, Jaipur',
        'type': 'shop',
        'lat': 26.8578,
        'lng': 75.8020,
        'phone': '+91 9876543228',
      },
      {
        'name': 'Acer Service Hub - Vaishali Nagar',
        'address': 'Vaishali Nagar, Jaipur',
        'type': 'service',
        'lat': 26.9124,
        'lng': 75.7495,
        'phone': '+91 9876543229',
      },
    ],
    'Chandigarh': [
      {
        'name': 'Acer Premium Store - Sector 17',
        'address': 'Sector 17-C, Chandigarh',
        'type': 'shop',
        'lat': 30.7333,
        'lng': 76.7794,
        'phone': '+91 9876543230',
      },
      {
        'name': 'Acer Service Center - Industrial Area',
        'address': 'Phase 2, Industrial Area',
        'type': 'service',
        'lat': 30.7046,
        'lng': 76.8011,
        'phone': '+91 9876543231',
      },
    ],
    'Kochi': [
      {
        'name': 'Acer Exclusive Store - MG Road',
        'address': 'MG Road, Ernakulam',
        'type': 'shop',
        'lat': 9.9775,
        'lng': 76.2808,
        'phone': '+91 9876543232',
      },
      {
        'name': 'Acer Service Hub - Edappally',
        'address': 'Lulu Mall, Edappally',
        'type': 'service',
        'lat': 10.0274,
        'lng': 76.3083,
        'phone': '+91 9876543233',
      },
    ],
    'Lucknow': [
      {
        'name': 'Acer Store - Hazratganj',
        'address': 'Hazratganj, Lucknow',
        'type': 'shop',
        'lat': 26.8540,
        'lng': 80.9477,
        'phone': '+91 9876543234',
      },
      {
        'name': 'Acer Service Center - Gomti Nagar',
        'address': 'Vibhuti Khand, Gomti Nagar',
        'type': 'service',
        'lat': 26.8606,
        'lng': 81.0089,
        'phone': '+91 9876543235',
      },
    ],
    'Guwahati': [
      {
        'name': 'Acer Premium Store - GS Road',
        'address': 'GS Road, Christian Basti',
        'type': 'shop',
        'lat': 26.1445,
        'lng': 91.7362,
        'phone': '+91 9876543236',
      },
      {
        'name': 'Acer Service Hub - Zoo Road',
        'address': 'R.G. Baruah Road, Zoo Road',
        'type': 'service',
        'lat': 26.1758,
        'lng': 91.7673,
        'phone': '+91 9876543237',
      },
    ],
    'Bhopal': [
      {
        'name': 'Acer Exclusive Store - MP Nagar',
        'address': 'Zone I, MP Nagar',
        'type': 'shop',
        'lat': 23.2329,
        'lng': 77.4349,
        'phone': '+91 9876543238',
      },
      {
        'name': 'Acer Service Center - New Market',
        'address': 'New Market, TT Nagar',
        'type': 'service',
        'lat': 23.2350,
        'lng': 77.4027,
        'phone': '+91 9876543239',
      },
    ],
    'Patna': [
      {
        'name': 'Acer Premium Store - Boring Road',
        'address': 'Boring Road Crossing, Patna',
        'type': 'shop',
        'lat': 25.6131,
        'lng': 85.1230,
        'phone': '+91 9876543240',
      },
      {
        'name': 'Acer Service Center - Kankarbagh',
        'address': 'Main Road, Kankarbagh',
        'type': 'service',
        'lat': 25.5941,
        'lng': 85.1676,
        'phone': '+91 9876543241',
      },
    ],
    'Raipur': [
      {
        'name': 'Acer Exclusive Store - Pandri',
        'address': 'Pandri Market, Raipur',
        'type': 'shop',
        'lat': 21.2514,
        'lng': 81.6296,
        'phone': '+91 9876543242',
      },
      {
        'name': 'Acer Service Hub - Civil Lines',
        'address': 'Civil Lines, Raipur',
        'type': 'service',
        'lat': 21.2624,
        'lng': 81.6367,
        'phone': '+91 9876543243',
      },
    ],
    'Ranchi': [
      {
        'name': 'Acer Store - Main Road',
        'address': 'Main Road, Ranchi',
        'type': 'shop',
        'lat': 23.3441,
        'lng': 85.3096,
        'phone': '+91 9876543244',
      },
      {
        'name': 'Acer Service Center - Harmu',
        'address': 'Harmu Housing Colony, Ranchi',
        'type': 'service',
        'lat': 23.3704,
        'lng': 85.3273,
        'phone': '+91 9876543245',
      },
    ],
    'Srinagar': [
      {
        'name': 'Acer Premium Store - Lal Chowk',
        'address': 'Lal Chowk, Srinagar',
        'type': 'shop',
        'lat': 34.0837,
        'lng': 74.8000,
        'phone': '+91 9876543246',
      },
      {
        'name': 'Acer Service Hub - Rajbagh',
        'address': 'Rajbagh, Srinagar',
        'type': 'service',
        'lat': 34.0723,
        'lng': 74.8142,
        'phone': '+91 9876543247',
      },
    ],
    'Gangtok': [
      {
        'name': 'Acer Exclusive Store - MG Marg',
        'address': 'MG Marg, Gangtok',
        'type': 'shop',
        'lat': 27.3314,
        'lng': 88.6138,
        'phone': '+91 9876543248',
      },
      {
        'name': 'Acer Service Center - Deorali',
        'address': 'Deorali Market, Gangtok',
        'type': 'service',
        'lat': 27.3226,
        'lng': 88.6070,
        'phone': '+91 9876543249',
      },
    ],
    'Shillong': [
      {
        'name': 'Acer Store - Police Bazar',
        'address': 'Police Bazar, Shillong',
        'type': 'shop',
        'lat': 25.5693,
        'lng': 91.8822,
        'phone': '+91 9876543250',
      },
      {
        'name': 'Acer Service Hub - Laitumkhrah',
        'address': 'Laitumkhrah Main Road, Shillong',
        'type': 'service',
        'lat': 25.5705,
        'lng': 91.8956,
        'phone': '+91 9876543251',
      },
    ],
    'Aizawl': [
      {
        'name': 'Acer Premium Store - Dawrpui',
        'address': 'Dawrpui, Aizawl',
        'type': 'shop',
        'lat': 23.7272,
        'lng': 92.7178,
        'phone': '+91 9876543252',
      },
      {
        'name': 'Acer Service Center - Chanmari',
        'address': 'Chanmari, Aizawl',
        'type': 'service',
        'lat': 23.7422,
        'lng': 92.7206,
        'phone': '+91 9876543253',
      },
    ],
    'Kohima': [
      {
        'name': 'Acer Exclusive Store - Main Town',
        'address': 'Main Town, Kohima',
        'type': 'shop',
        'lat': 25.6751,
        'lng': 94.1086,
        'phone': '+91 9876543254',
      },
      {
        'name': 'Acer Service Hub - New Market',
        'address': 'New Market Area, Kohima',
        'type': 'service',
        'lat': 25.6762,
        'lng': 94.1106,
        'phone': '+91 9876543255',
      },
    ],
    'Imphal': [
      {
        'name': 'Acer Store - Thangal Bazar',
        'address': 'Thangal Bazar, Imphal',
        'type': 'shop',
        'lat': 24.8170,
        'lng': 93.9368,
        'phone': '+91 9876543256',
      },
      {
        'name': 'Acer Service Center - Kwakeithel',
        'address': 'Kwakeithel Main Road, Imphal',
        'type': 'service',
        'lat': 24.8003,
        'lng': 93.9145,
        'phone': '+91 9876543257',
      },
    ],
    'Agartala': [
      {
        'name': 'Acer Premium Store - Battala',
        'address': 'Battala, Agartala',
        'type': 'shop',
        'lat': 23.8315,
        'lng': 91.2793,
        'phone': '+91 9876543258',
      },
      {
        'name': 'Acer Service Hub - Central Road',
        'address': 'Central Road, Agartala',
        'type': 'service',
        'lat': 23.8358,
        'lng': 91.2812,
        'phone': '+91 9876543259',
      },
    ],
    'Itanagar': [
      {
        'name': 'Acer Exclusive Store - Bank Tinali',
        'address': 'Bank Tinali, Itanagar',
        'type': 'shop',
        'lat': 27.0844,
        'lng': 93.6053,
        'phone': '+91 9876543260',
      },
      {
        'name': 'Acer Service Center - Ganga Market',
        'address': 'Ganga Market, Itanagar',
        'type': 'service',
        'lat': 27.0871,
        'lng': 93.6082,
        'phone': '+91 9876543261',
      },
    ],
    'Panaji': [
      {
        'name': 'Acer Store - 18th June Road',
        'address': '18th June Road, Panaji',
        'type': 'shop',
        'lat': 15.4909,
        'lng': 73.8278,
        'phone': '+91 9876543262',
      },
      {
        'name': 'Acer Service Hub - Miramar',
        'address': 'Miramar Circle, Panaji',
        'type': 'service',
        'lat': 15.4767,
        'lng': 73.8128,
        'phone': '+91 9876543263',
      },
    ],
    'Silvassa': [
      {
        'name': 'Acer Premium Store - Silvassa Main Road',
        'address': 'Silvassa Main Road',
        'type': 'shop',
        'lat': 20.2739,
        'lng': 72.9967,
        'phone': '+91 9876543264',
      },
      {
        'name': 'Acer Service Center - Amli',
        'address': 'Amli, Silvassa',
        'type': 'service',
        'lat': 20.2770,
        'lng': 73.0076,
        'phone': '+91 9876543265',
      },
    ],
    'Daman': [
      {
        'name': 'Acer Exclusive Store - Nani Daman',
        'address': 'Main Market, Nani Daman',
        'type': 'shop',
        'lat': 20.4198,
        'lng': 72.8324,
        'phone': '+91 9876543266',
      },
      {
        'name': 'Acer Service Hub - Moti Daman',
        'address': 'Fort Area, Moti Daman',
        'type': 'service',
        'lat': 20.4177,
        'lng': 72.8448,
        'phone': '+91 9876543267',
      },
    ],
    'Kavaratti': [
      {
        'name': 'Acer Store - Main Market',
        'address': 'Main Market, Kavaratti',
        'type': 'shop',
        'lat': 10.5626,
        'lng': 72.6369,
        'phone': '+91 9876543268',
      },
      {
        'name': 'Acer Service Center - Beach Road',
        'address': 'Beach Road, Kavaratti',
        'type': 'service',
        'lat': 10.5659,
        'lng': 72.6421,
        'phone': '+91 9876543269',
      },
    ],
    'Port Blair': [
      {
        'name': 'Acer Premium Store - Aberdeen Bazaar',
        'address': 'Aberdeen Bazaar, Port Blair',
        'type': 'shop',
        'lat': 11.6702,
        'lng': 92.7457,
        'phone': '+91 9876543270',
      },
      {
        'name': 'Acer Service Hub - Phoenix Bay',
        'address': 'Phoenix Bay, Port Blair',
        'type': 'service',
        'lat': 11.6772,
        'lng': 92.7508,
        'phone': '+91 9876543271',
      },
    ],
    'Puducherry': [
      {
        'name': 'Acer Exclusive Store - Mission Street',
        'address': 'Mission Street, Puducherry',
        'type': 'shop',
        'lat': 11.9321,
        'lng': 79.8354,
        'phone': '+91 9876543272',
      },
      {
        'name': 'Acer Service Center - White Town',
        'address': 'White Town, Puducherry',
        'type': 'service',
        'lat': 11.9338,
        'lng': 79.8323,
        'phone': '+91 9876543273',
      },
    ],
    'Dehradun': [
      {
        'name': 'Acer Store - Rajpur Road',
        'address': 'Rajpur Road, Dehradun',
        'type': 'shop',
        'lat': 30.3255,
        'lng': 78.0436,
        'phone': '+91 9876543274',
      },
      {
        'name': 'Acer Service Hub - Paltan Bazaar',
        'address': 'Paltan Bazaar, Dehradun',
        'type': 'service',
        'lat': 30.3252,
        'lng': 78.0452,
        'phone': '+91 9876543275',
      },
    ],
    'Shimla': [
      {
        'name': 'Acer Premium Store - The Mall',
        'address': 'The Mall Road, Shimla',
        'type': 'shop',
        'lat': 31.1048,
        'lng': 77.1734,
        'phone': '+91 9876543276',
      },
      {
        'name': 'Acer Service Center - Lower Bazaar',
        'address': 'Lower Bazaar, Shimla',
        'type': 'service',
        'lat': 31.1021,
        'lng': 77.1750,
        'phone': '+91 9876543277',
      },
    ],
    'Thiruvananthapuram': [
      {
        'name': 'Acer Exclusive Store - MG Road',
        'address': 'MG Road, Thiruvananthapuram',
        'type': 'shop',
        'lat': 8.4875,
        'lng': 76.9525,
        'phone': '+91 9876543278',
      },
      {
        'name': 'Acer Service Hub - Palayam',
        'address': 'Palayam, Thiruvananthapuram',
        'type': 'service',
        'lat': 8.5012,
        'lng': 76.9488,
        'phone': '+91 9876543279',
      },
    ],
    'Vijayawada': [
      {
        'name': 'Acer Store - MG Road',
        'address': 'MG Road, Vijayawada',
        'type': 'shop',
        'lat': 16.5062,
        'lng': 80.6480,
        'phone': '+91 9876543280',
      },
      {
        'name': 'Acer Service Center - Governorpet',
        'address': 'Governorpet, Vijayawada',
        'type': 'service',
        'lat': 16.5152,
        'lng': 80.6321,
        'phone': '+91 9876543281',
      },
    ],
    'Visakhapatnam': [
      {
        'name': 'Acer Premium Store - Dwaraka Nagar',
        'address': 'Dwaraka Nagar, Visakhapatnam',
        'type': 'shop',
        'lat': 17.7231,
        'lng': 83.3041,
        'phone': '+91 9876543282',
      },
      {
        'name': 'Acer Service Hub - MVP Colony',
        'address': 'MVP Colony, Visakhapatnam',
        'type': 'service',
        'lat': 17.7308,
        'lng': 83.3170,
        'phone': '+91 9876543283',
      },
    ],
    'Indore': [
      {
        'name': 'Acer Exclusive Store - MG Road',
        'address': 'MG Road, Indore',
        'type': 'shop',
        'lat': 22.7196,
        'lng': 75.8577,
        'phone': '+91 9876543284',
      },
      {
        'name': 'Acer Service Center - Vijay Nagar',
        'address': 'Vijay Nagar Square, Indore',
        'type': 'service',
        'lat': 22.7532,
        'lng': 75.8937,
        'phone': '+91 9876543285',
      },
    ],
    'Nagpur': [
      {
        'name': 'Acer Store - Dharampeth',
        'address': 'Dharampeth, Nagpur',
        'type': 'shop',
        'lat': 21.1458,
        'lng': 79.0682,
        'phone': '+91 9876543286',
      },
      {
        'name': 'Acer Service Hub - Sadar',
        'address': 'Sadar, Nagpur',
        'type': 'service',
        'lat': 21.1535,
        'lng': 79.0864,
        'phone': '+91 9876543287',
      },
    ],
    'Rajkot': [
      {
        'name': 'Acer Premium Store - Race Course Road',
        'address': 'Race Course Road, Rajkot',
        'type': 'shop',
        'lat': 22.2908,
        'lng': 70.7985,
        'phone': '+91 9876543288',
      },
      {
        'name': 'Acer Service Center - Kalawad Road',
        'address': 'Kalawad Road, Rajkot',
        'type': 'service',
        'lat': 22.2812,
        'lng': 70.7745,
        'phone': '+91 9876543289',
      },
    ],
    'Surat': [
      {
        'name': 'Acer Exclusive Store - Ghod Dod Road',
        'address': 'Ghod Dod Road, Surat',
        'type': 'shop',
        'lat': 21.1702,
        'lng': 72.8011,
        'phone': '+91 9876543290',
      },
      {
        'name': 'Acer Service Hub - Adajan',
        'address': 'Adajan, Surat',
        'type': 'service',
        'lat': 21.2049,
        'lng': 72.7741,
        'phone': '+91 9876543291',
      },
    ],
    'Vadodara': [
      {
        'name': 'Acer Store - Alkapuri',
        'address': 'RC Dutt Road, Alkapuri, Vadodara',
        'type': 'shop',
        'lat': 22.3099,
        'lng': 73.1853,
        'phone': '+91 9876543292',
      },
      {
        'name': 'Acer Service Center - Sayajigunj',
        'address': 'Sayajigunj, Vadodara',
        'type': 'service',
        'lat': 22.3149,
        'lng': 73.1788,
        'phone': '+91 9876543293',
      },
    ],
    'Coimbatore': [
      {
        'name': 'Acer Premium Store - RS Puram',
        'address': 'DB Road, RS Puram, Coimbatore',
        'type': 'shop',
        'lat': 11.0018,
        'lng': 76.9629,
        'phone': '+91 9876543294',
      },
      {
        'name': 'Acer Service Hub - Peelamedu',
        'address': 'Avinashi Road, Peelamedu, Coimbatore',
        'type': 'service',
        'lat': 11.0223,
        'lng': 77.0018,
        'phone': '+91 9876543295',
      },
    ],
    'Madurai': [
      {
        'name': 'Acer Exclusive Store - South Masi Street',
        'address': 'South Masi Street, Madurai',
        'type': 'shop',
        'lat': 9.9252,
        'lng': 78.1198,
        'phone': '+91 9876543296',
      },
      {
        'name': 'Acer Service Center - K.K. Nagar',
        'address': 'K.K. Nagar, Madurai',
        'type': 'service',
        'lat': 9.9147,
        'lng': 78.1327,
        'phone': '+91 9876543297',
      },
    ],
    'Amritsar': [
      {
        'name': 'Acer Store - Lawrence Road',
        'address': 'Lawrence Road, Amritsar',
        'type': 'shop',
        'lat': 31.6340,
        'lng': 74.8723,
        'phone': '+91 9876543298',
      },
      {
        'name': 'Acer Service Hub - Mall Road',
        'address': 'Mall Road, Amritsar',
        'type': 'service',
        'lat': 31.6398,
        'lng': 74.8770,
        'phone': '+91 9876543299',
      },
    ],
    'Ludhiana': [
      {
        'name': 'Acer Premium Store - Ferozepur Road',
        'address': 'Ferozepur Road, Ludhiana',
        'type': 'shop',
        'lat': 30.9010,
        'lng': 75.8573,
        'phone': '+91 9876543300',
      },
      {
        'name': 'Acer Service Center - Model Town',
        'address': 'Model Town, Ludhiana',
        'type': 'service',
        'lat': 30.8594,
        'lng': 75.8311,
        'phone': '+91 9876543301',
      },
    ],
    'Jalandhar': [
      {
        'name': 'Acer Exclusive Store - Model Town',
        'address': 'Model Town, Jalandhar',
        'type': 'shop',
        'lat': 31.3260,
        'lng': 75.5762,
        'phone': '+91 9876543302',
      },
      {
        'name': 'Acer Service Hub - BMC Chowk',
        'address': 'BMC Chowk, Jalandhar',
        'type': 'service',
        'lat': 31.3216,
        'lng': 75.5761,
        'phone': '+91 9876543303',
      },
    ],
    'Jammu': [
      {
        'name': 'Acer Store - Residency Road',
        'address': 'Residency Road, Jammu',
        'type': 'shop',
        'lat': 32.7266,
        'lng': 74.8570,
        'phone': '+91 9876543304',
      },
      {
        'name': 'Acer Service Center - Gandhi Nagar',
        'address': 'Gandhi Nagar, Jammu',
        'type': 'service',
        'lat': 32.7294,
        'lng': 74.8707,
        'phone': '+91 9876543305',
      },
    ],
    'Faridabad': [
      {
        'name': 'Acer Premium Store - Crown Plaza',
        'address': 'Crown Plaza, Sector 15, Faridabad',
        'type': 'shop',
        'lat': 28.4089,
        'lng': 77.3178,
        'phone': '+91 9876543306',
      },
      {
        'name': 'Acer Service Hub - NIT',
        'address': 'NIT, Faridabad',
        'type': 'service',
        'lat': 28.4269,
        'lng': 77.3201,
        'phone': '+91 9876543307',
      },
    ],
    'Gurgaon': [
      {
        'name': 'Acer Exclusive Store - MG Road',
        'address': 'MG Road, Gurgaon',
        'type': 'shop',
        'lat': 28.4799,
        'lng': 77.0880,
        'phone': '+91 9876543308',
      },
      {
        'name': 'Acer Service Center - Sector 14',
        'address': 'Sector 14 Market, Gurgaon',
        'type': 'service',
        'lat': 28.4681,
        'lng': 77.0367,
        'phone': '+91 9876543309',
      },
    ],
    'Noida': [
      {
        'name': 'Acer Store - Sector 18',
        'address': 'Sector 18 Market, Noida',
        'type': 'shop',
        'lat': 28.5708,
        'lng': 77.3260,
        'phone': '+91 9876543310',
      },
      {
        'name': 'Acer Service Hub - Sector 62',
        'address': 'Sector 62, Noida',
        'type': 'service',
        'lat': 28.6236,
        'lng': 77.3666,
        'phone': '+91 9876543311',
      },
    ],
  };

  void _showLocationDetails(Map<String, dynamic> location) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(30),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with image
            Stack(
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: location['type'] == 'shop'
                          ? [acerPrimaryColor, acerAccentColor]
                          : [acerAccentColor, Colors.purple],
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    child: Icon(
                      location['type'] == 'shop'
                          ? Icons.storefront
                          : Icons.build_circle,
                      color: Colors.white.withAlpha(60),
                      size: 120,
                    ),
                  ),
                ),
                // Store/Service details card
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(20),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: location['type'] == 'shop'
                                  ? acerPrimaryColor.withAlpha(30)
                                  : acerAccentColor.withAlpha(30),
                              child: Icon(
                                location['type'] == 'shop'
                                    ? Icons.store
                                    : Icons.build,
                                color: location['type'] == 'shop'
                                    ? acerPrimaryColor
                                    : acerAccentColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    location['name'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    location['type'] == 'shop'
                                        ? 'Exclusive Store'
                                        : 'Service Center',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: location['type'] == 'shop'
                                          ? acerPrimaryColor
                                          : acerAccentColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Close button
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(180),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            // Additional details
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Location Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      Icons.location_on_outlined,
                      'Address',
                      location['address'],
                    ),
                    _buildDetailRow(
                      Icons.phone_outlined,
                      'Phone',
                      location['phone'],
                    ),
                    _buildDetailRow(
                      Icons.access_time_outlined,
                      'Opening Hours',
                      '10:00 AM - 8:00 PM',
                    ),
                    _buildDetailRow(
                      Icons.calendar_today_outlined,
                      'Working Days',
                      'Monday - Saturday',
                    ),
                    const SizedBox(height: 24),
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.directions, color: Colors.white),
                            label: const Text('Directions'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: acerPrimaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => _launchMaps(location),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.phone, color: Colors.white),
                            label: const Text('Call'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: acerAccentColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => _launchPhone(location['phone']),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: acerAccentColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _launchMaps(Map<String, dynamic> location) async {
    final double lat = location['lat'];
    final double lng = location['lng'];
    final String name = location['name'];
    
    // Create Google Maps URL with directions
    final String googleMapsUrl = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&destination_place_id=$name';
    
    // Alternative URLs for different map apps
    final String appleMapsUrl = 'https://maps.apple.com/?daddr=$lat,$lng&dirflg=d';
    final String universalMapsUrl = 'geo:$lat,$lng?q=$lat,$lng($name)';
    
    try {
      // Try to launch Google Maps first
      if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
        await launchUrl(
          Uri.parse(googleMapsUrl),
          mode: LaunchMode.externalApplication,
        );
      } 
      // Fallback to Apple Maps (iOS)
      else if (await canLaunchUrl(Uri.parse(appleMapsUrl))) {
        await launchUrl(
          Uri.parse(appleMapsUrl),
          mode: LaunchMode.externalApplication,
        );
      }
      // Fallback to universal geo URL
      else if (await canLaunchUrl(Uri.parse(universalMapsUrl))) {
        await launchUrl(
          Uri.parse(universalMapsUrl),
          mode: LaunchMode.externalApplication,
        );
      }
      else {
        // If no maps app is available, show error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('No maps application found on this device'),
                  ),
                ],
              ),
              backgroundColor: Colors.red[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    } catch (e) {
      // Handle any errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Could not open maps: ${e.toString()}'),
                ),
              ],
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  void _launchPhone(String phone) async {
    final String phoneUrl = 'tel:$phone';
    
    try {
      if (await canLaunchUrl(Uri.parse(phoneUrl))) {
        await launchUrl(
          Uri.parse(phoneUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Cannot make phone calls on this device'),
                  ),
                ],
              ),
              backgroundColor: Colors.red[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Could not make call: ${e.toString()}'),
                ),
              ],
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with animated title
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              decoration: BoxDecoration(
                color: acerPrimaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(30),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Store Locator',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 50,
                    child: Row(
                      children: [
                        Expanded(
                          child: AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return Transform.translate(
                                offset:
                                    Offset(0, (1 - _fadeAnimation.value) * 20),
                                child: Opacity(
                                  opacity: _fadeAnimation.value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _selectedCity,
                                        icon: const Icon(
                                            Icons.keyboard_arrow_down),
                                        isExpanded: true,
                                        items: (_locations.keys.toList()
                                              ..sort())
                                            .map((city) {
                                          return DropdownMenuItem(
                                            value: city,
                                            child: Text(city),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          if (value != null) {
                                            setState(() {
                                              _selectedCity = value;
                                              _animationController.reset();
                                              _animationController.forward();
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset:
                                  Offset(0, (1 - _fadeAnimation.value) * 20),
                              child: Opacity(
                                opacity: _fadeAnimation.value,
                                child: Container(
                                  width: 140,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedType,
                                      icon:
                                          const Icon(Icons.keyboard_arrow_down),
                                      isExpanded: true,
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'all',
                                          child: Text('All'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'shop',
                                          child: Text('Stores'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'service',
                                          child: Text('Service'),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        if (value != null) {
                                          setState(() {
                                            _selectedType = value;
                                            _animationController.reset();
                                            _animationController.forward();
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Location cards
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildLocationList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationList() {
    List<Map<String, dynamic>> filteredLocations = [];

    if (_locations.containsKey(_selectedCity)) {
      filteredLocations = _locations[_selectedCity]!
          .where((location) =>
              _selectedType == 'all' || location['type'] == _selectedType)
          .toList();
    }

    if (filteredLocations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No locations found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try changing your filters',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredLocations.length,
      itemBuilder: (context, index) {
        final location = filteredLocations[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: LocationCard(
            location: location,
            onTap: () => _showLocationDetails(location),
          ),
        );
      },
    );
  }
}

class LocationCard extends StatelessWidget {
  final Map<String, dynamic> location;
  final VoidCallback onTap;

  const LocationCard({
    Key? key,
    required this.location,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isStore = location['type'] == 'shop';
    final Color primaryColor = isStore ? acerPrimaryColor : acerAccentColor;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: isDarkMode ? Theme.of(context).cardColor : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header with tag
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: primaryColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isStore ? Icons.storefront : Icons.build,
                        color: primaryColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            location['name'],
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            location['address'],
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Tag
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor.withAlpha(30),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              isStore ? 'Exclusive Store' : 'Service Center',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Chevron
                    Icon(
                      Icons.chevron_right,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[400],
                    ),
                  ],
                ),
              ),
              // Footer with actions
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: isDarkMode ? Colors.grey[300] : Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '10 AM - 8 PM',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode ? Colors.grey[300] : Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Row(
                      children: [
                        Icon(
                          Icons.phone,
                          size: 14,
                          color: acerAccentColor,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Call',
                          style: TextStyle(
                            fontSize: 12,
                            color: acerAccentColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    const Row(
                      children: [
                        Icon(
                          Icons.directions,
                          size: 14,
                          color: acerPrimaryColor,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Directions',
                          style: TextStyle(
                            fontSize: 12,
                            color: acerPrimaryColor,
                            fontWeight: FontWeight.w500,
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
    );
  }
}
