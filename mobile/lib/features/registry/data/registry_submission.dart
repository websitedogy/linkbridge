class RegistrySubmission {
  const RegistrySubmission({
    required this.id,
    required this.companyType,
    required this.companyTypeLabel,
    required this.companyName,
    required this.directorContact,
    required this.directorEmail,
    required this.location,
    required this.status,
    this.cin,
  });

  final String id;
  final String companyType;
  final String companyTypeLabel;
  final String companyName;
  final String? cin;
  final String directorContact;
  final String directorEmail;
  final String location;
  final String status;

  String get statusLabel {
    final raw = status.replaceAll('_', ' ').trim();
    if (raw.isEmpty) {
      return 'Unverified';
    }
    return raw
        .split(' ')
        .map(
          (part) => part.isEmpty
              ? part
              : '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  factory RegistrySubmission.fromJson(Map<String, dynamic> json) {
    return RegistrySubmission(
      id: json['id']?.toString() ?? '',
      companyType: json['company_type']?.toString() ?? '',
      companyTypeLabel: json['company_type_label']?.toString() ?? '',
      companyName: json['company_name']?.toString() ?? '',
      cin: json['cin']?.toString(),
      directorContact: json['director_contact']?.toString() ?? '',
      directorEmail: json['director_email']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      status: json['status']?.toString() ?? 'UNVERIFIED',
    );
  }
}
