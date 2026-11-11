class CinRecord {
  const CinRecord({
    required this.cin,
    required this.name,
    required this.status,
    required this.incorporationDate,
    required this.companyType,
    required this.companyTypeId,
    required this.address,
    required this.authorizedCapital,
    required this.paidUpCapital,
    required this.directors,
  });

  final String cin;
  final String name;
  final String status;
  final String incorporationDate;
  final String companyType;
  final String companyTypeId;
  final String address;
  final String authorizedCapital;
  final String paidUpCapital;
  final List<String> directors;
}

class DinRecord {
  const DinRecord({
    required this.din,
    required this.name,
    required this.status,
    required this.companies,
  });

  final String din;
  final String name;
  final String status;
  final List<({String name, String cin})> companies;
}

abstract final class RegistryMock {
  static final cinPattern = RegExp(
    r'^[LU][0-9]{5}[A-Z]{2}[0-9]{4}[A-Z]{3}[0-9]{6}$',
  );
  static final dinPattern = RegExp(r'^[0-9]{8}$');

  static const companies = <CinRecord>[
    CinRecord(
      cin: 'U72900TG2018PTC123456',
      name: 'Established SaaS Platform Pvt Ltd',
      status: 'Active',
      incorporationDate: '14 Mar 2018',
      companyType: 'Pvt Ltd',
      companyTypeId: 'pvt-ltd',
      address: 'HITEC City, Hyderabad, Telangana 500081',
      authorizedCapital: '₹10,00,000',
      paidUpCapital: '₹5,00,000',
      directors: ['Arjun Reddy', 'Meera Iyer'],
    ),
    CinRecord(
      cin: 'L17110MH1995PLC065432',
      name: 'Precision Engineering Company Ltd',
      status: 'Active',
      incorporationDate: '02 Aug 1995',
      companyType: 'Public Limited',
      companyTypeId: 'pvt-ltd',
      address: 'Bandra Kurla Complex, Mumbai, Maharashtra 400051',
      authorizedCapital: '₹25,00,00,000',
      paidUpCapital: '₹12,50,00,000',
      directors: ['Rahul Shah', 'Anita Kulkarni'],
    ),
    CinRecord(
      cin: 'U85100TN2012NPL098765',
      name: 'Carewell Clinics Section 8',
      status: 'Strike off',
      incorporationDate: '19 Nov 2012',
      companyType: 'Section 8 Company',
      companyTypeId: 'section-8',
      address: 'Anna Nagar, Chennai, Tamil Nadu 600040',
      authorizedCapital: '₹1,00,00,000',
      paidUpCapital: '₹25,00,000',
      directors: ['Dr. Kavya Nair'],
    ),
  ];

  static const directors = <DinRecord>[
    DinRecord(
      din: '01234567',
      name: 'Arjun Reddy',
      status: 'Approved',
      companies: [
        (
          name: 'Established SaaS Platform Pvt Ltd',
          cin: 'U72900TG2018PTC123456',
        ),
        (name: 'City Logistics Pvt Ltd', cin: 'U63000KA2016PTC112233'),
      ],
    ),
    DinRecord(
      din: '87654321',
      name: 'Rahul Shah',
      status: 'Deactivated',
      companies: [
        (
          name: 'Precision Engineering Company Ltd',
          cin: 'L17110MH1995PLC065432',
        ),
      ],
    ),
  ];

  static CinRecord? findCin(String cin) {
    final key = cin.trim().toUpperCase();
    for (final record in companies) {
      if (record.cin == key) return record;
    }
    return null;
  }

  static DinRecord? findDin(String din) {
    final key = din.trim();
    for (final record in directors) {
      if (record.din == key) return record;
    }
    return null;
  }
}
