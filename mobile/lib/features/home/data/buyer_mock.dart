import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';

class BuyerListing {
  const BuyerListing({
    required this.id,
    required this.title,
    required this.location,
    required this.tags,
    required this.askingPrice,
    required this.revenue,
    required this.employees,
    required this.imageUrl,
    required this.companyType,
    this.sellerName = 'Listed seller',
    this.description = 'A running business open to serious buyers.',
    this.mine = false,
  });

  final String id;
  final String title;
  final String location;
  final List<String> tags;
  final String askingPrice;
  final String revenue;
  final String employees;
  final String imageUrl;
  final String companyType;
  final String sellerName;
  final String description;
  final bool mine;
}

abstract final class BuyerMock {
  static const listings = <BuyerListing>[
    BuyerListing(
      id: 'saas',
      title: 'Established IT Services Company',
      location: 'Hyderabad, India',
      tags: ['PALM', 'Technology', 'Profitable'],
      askingPrice: '₹15 - 30 Cr',
      revenue: '₹5 - 7 Cr',
      employees: '50 - 100',
      imageUrl: AppAssets.office,
      companyType: 'pvt-ltd',
      description:
          'A profitable IT services company with strong client base and recurring revenue.',
    ),
    BuyerListing(
      id: 'engineering',
      title: 'Precision Engineering Company',
      location: 'Pune, India',
      tags: ['Manufacturing', 'Profitable'],
      askingPrice: '₹25 - 30 Cr',
      revenue: '₹10 - 12 Cr',
      employees: '100 - 250',
      imageUrl: AppAssets.workshop,
      companyType: 'llp',
      description:
          'Well-established manufacturing business with global clients.',
    ),
    BuyerListing(
      id: 'retail',
      title: 'Premium Retail Brand',
      location: 'Bengaluru, India',
      tags: ['Retail', 'Multi Outlet'],
      askingPrice: '₹10 - 15 Cr',
      revenue: '₹6 - 8 Cr',
      employees: '80 - 120',
      imageUrl: AppAssets.retail,
      companyType: 'opc',
    ),
    BuyerListing(
      id: 'clinic',
      title: 'Multi-Specialty Clinic',
      location: 'Chennai, India',
      tags: ['Healthcare', 'Well Established'],
      askingPrice: '₹20 - 25 Cr',
      revenue: '₹8 - 12 Cr',
      employees: '40 - 80',
      imageUrl: AppAssets.clinic,
      companyType: 'section-8',
    ),
    BuyerListing(
      id: 'construction',
      title: 'Construction Services Business',
      location: 'Hyderabad, India',
      tags: ['Construction', 'Growing'],
      askingPrice: '₹30 - 40 Cr',
      revenue: '₹12 - 18 Cr',
      employees: '150 - 300',
      imageUrl: AppAssets.construction,
      companyType: 'producer',
    ),
    BuyerListing(
      id: 'llp-advisory',
      title: 'Tax Advisory LLP',
      location: 'Hyderabad, India',
      tags: ['LLP', 'Profitable'],
      askingPrice: '₹8 - 10 Cr',
      revenue: '₹3 - 4 Cr',
      employees: '25 - 40',
      imageUrl: AppAssets.officeFloor,
      companyType: 'llp',
    ),
    BuyerListing(
      id: 'pvt-logistics',
      title: 'City Logistics Pvt Ltd',
      location: 'Bengaluru, India',
      tags: ['Pvt Ltd', 'Growing'],
      askingPrice: '₹18 - 22 Cr',
      revenue: '₹7 - 9 Cr',
      employees: '80 - 140',
      imageUrl: AppAssets.workshop,
      companyType: 'pvt-ltd',
    ),
    BuyerListing(
      id: 'opc-studio',
      title: 'Design Studio OPC',
      location: 'Pune, India',
      tags: ['OPC'],
      askingPrice: '₹2 - 3 Cr',
      revenue: '₹80 L - 1 Cr',
      employees: '8 - 15',
      imageUrl: AppAssets.office,
      companyType: 'opc',
    ),
    BuyerListing(
      id: 'section-ngo',
      title: 'Education Trust Section 8',
      location: 'Chennai, India',
      tags: ['Section 8'],
      askingPrice: '₹6 - 8 Cr',
      revenue: '₹2 - 3 Cr',
      employees: '30 - 50',
      imageUrl: AppAssets.clinic,
      companyType: 'section-8',
    ),
    BuyerListing(
      id: 'nidhi-fund',
      title: 'Neighbourhood Nidhi Company',
      location: 'Vijayawada, India',
      tags: ['Nidhi'],
      askingPrice: '₹5 - 7 Cr',
      revenue: '₹1.5 - 2 Cr',
      employees: '15 - 25',
      imageUrl: AppAssets.retail,
      companyType: 'nidhi',
    ),
    BuyerListing(
      id: 'producer-dairy',
      title: 'Dairy Producer Company',
      location: 'Warangal, India',
      tags: ['Producer'],
      askingPrice: '₹9 - 12 Cr',
      revenue: '₹4 - 5 Cr',
      employees: '40 - 70',
      imageUrl: AppAssets.construction,
      companyType: 'producer',
    ),
  ];

  static const companyTypes =
      <
        ({
          String id,
          String label,
          IconData icon,
          Color color,
          Color background,
        })
      >[
        (
          id: 'llp',
          label: 'LLP',
          icon: Icons.apartment_outlined,
          color: Color(0xFF1E3A8A),
          background: Color(0xFFE8EEF9),
        ),
        (
          id: 'pvt-ltd',
          label: 'Pvt Ltd',
          icon: Icons.business_center_outlined,
          color: Color(0xFF0F766E),
          background: Color(0xFFE6F6F3),
        ),
        (
          id: 'opc',
          label: 'OPC',
          icon: Icons.apartment_outlined,
          color: Color(0xFFC2410C),
          background: Color(0xFFFFF1E8),
        ),
        (
          id: 'section-8',
          label: 'Section 8 Company',
          icon: Icons.shield_outlined,
          color: Color(0xFF6D28D9),
          background: Color(0xFFF3E8FF),
        ),
        (
          id: 'nidhi',
          label: 'Nidhi Company',
          icon: Icons.account_balance_outlined,
          color: Color(0xFFB91C1C),
          background: Color(0xFFFEECEC),
        ),
        (
          id: 'producer',
          label: 'Producer Company',
          icon: Icons.domain_outlined,
          color: Color(0xFF0369A1),
          background: Color(0xFFE7F5FC),
        ),
      ];

  static const savedSearches = <({String title, String place})>[
    (title: 'IT Companies', place: 'Hyderabad'),
    (title: 'Manufacturing', place: 'Telangana'),
    (title: 'Retail', place: 'Bengaluru'),
  ];

  static const industries =
      <({IconData icon, String label, Color background, Color foreground})>[
        (
          icon: Icons.memory,
          label: 'Technology',
          background: Color(0xFFE7F8EF),
          foreground: AppColors.featured,
        ),
        (
          icon: Icons.factory_outlined,
          label: 'Manufacturing',
          background: Color(0xFFE8F1FF),
          foreground: AppColors.accent,
        ),
        (
          icon: Icons.shopping_bag_outlined,
          label: 'Retail',
          background: Color(0xFFFFF1E6),
          foreground: AppColors.retail,
        ),
        (
          icon: Icons.favorite_border,
          label: 'Healthcare',
          background: Color(0xFFFFE8F0),
          foreground: Color(0xFFE2557A),
        ),
      ];

  static List<BuyerListing> forTab(int tab) {
    return switch (tab) {
      1 => listings.take(3).toList(),
      2 => listings.skip(3).toList(),
      _ => listings,
    };
  }
}

Color listingTagColor(String tag) {
  return switch (tag) {
    'Technology' || 'Profitable' || 'B2B' => AppColors.featured,
    'Manufacturing' => AppColors.manufacturing,
    'Retail' || 'Multi Outlet' => AppColors.retail,
    'Healthcare' => const Color(0xFFE2557A),
    'Construction' || 'Growing' || 'Well Established' => AppColors.underReview,
    _ => AppColors.textSecondary,
  };
}
