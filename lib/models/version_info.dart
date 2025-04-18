class VersionInfo {
  final String version;
  final String releaseDate;
  final List<String> newFeatures;
  final List<String> bugFixes;
  final List<String> improvements;

  const VersionInfo({
    required this.version,
    required this.releaseDate,
    required this.newFeatures,
    required this.bugFixes,
    required this.improvements,
  });

  // Static method to get current version info
  static VersionInfo getCurrentVersionInfo() {
    return const VersionInfo(
      version: '1.0.1',
      releaseDate: 'June 10, 2023',
      newFeatures: [
        'Added About Version section in Settings',
        'Improved user profile management',
        'Enhanced product search with category filters',
        'Added new Acer product categories and exclusive deals'
      ],
      bugFixes: [
        'Fixed cart item quantity update issues',
        'Resolved payment gateway integration problems',
        'Fixed product image loading on slow connections',
        'Corrected pricing display for discounted items'
      ],
      improvements: [
        'Optimized app performance and load times',
        'Reduced memory usage',
        'Improved UI responsiveness',
        'Enhanced security for user data'
      ],
    );
  }

  // Method to get version history (for future implementation)
  static List<VersionInfo> getVersionHistory() {
    return [
      // Current version
      getCurrentVersionInfo(),

      // Previous versions - add these as app is updated
      const VersionInfo(
        version: '1.0.0',
        releaseDate: 'May 15, 2023',
        newFeatures: [
          'Initial public release',
          'Complete product catalog',
          'User account management',
          'Secure checkout process'
        ],
        bugFixes: [
          'Fixed critical launch issues on some devices',
          'Resolved UI layout problems on smaller screens'
        ],
        improvements: [
          'Polished UI design',
          'Performance optimizations',
          'Enhanced navigation flow'
        ],
      ),

      const VersionInfo(
        version: '0.9.0',
        releaseDate: 'April 5, 2023',
        newFeatures: [
          'Initial beta release',
          'Basic product browsing',
          'User account creation'
        ],
        bugFixes: [
          'Fixed initial authentication issues',
          'Resolved UI layout problems on smaller devices'
        ],
        improvements: [
          'Basic app structure and navigation',
          'Product catalog initial implementation'
        ],
      ),
    ];
  }
}
