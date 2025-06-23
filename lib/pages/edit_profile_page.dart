import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart' show acerPrimaryColor, acerSecondaryColor, acerAccentColor;
import '../models/user_model.dart';
import '../providers/user_provider.dart';

class EditProfilePage extends StatefulWidget {
  final User user;

  const EditProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage>
    with TickerProviderStateMixin {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  String? _selectedImageUrl;
  File? _selectedImageFile;
  bool _isLoading = false;
  bool _nameError = false;
  bool _emailError = false;
  bool _phoneError = false;
  final _formKey = GlobalKey<FormState>();

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phone);
    _selectedImageUrl = widget.user.imageUrl;

    // Initialize animations
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    // Start animations
    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    bool isValid = true;

    if (_nameController.text.trim().isEmpty) {
      setState(() => _nameError = true);
      isValid = false;
    } else {
      setState(() => _nameError = false);
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      setState(() => _emailError = true);
      isValid = false;
    } else {
      setState(() => _emailError = false);
    }

    final phoneRegex = RegExp(r'^\d{10}$');
    if (!phoneRegex.hasMatch(_phoneController.text.trim())) {
      setState(() => _phoneError = true);
      isValid = false;
    } else {
      setState(() => _phoneError = false);
    }

    return isValid;
  }

  Future<void> _selectImage() async {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 16,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                acerPrimaryColor.withOpacity(0.02),
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: acerPrimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: acerPrimaryColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              
              const Text(
                'Update Profile Picture',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: acerPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              
              Text(
                'Choose how you\'d like to update your photo',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Options
              Row(
                children: [
                  Expanded(
                    child: _buildImageOption(
                      icon: Icons.photo_library_rounded,
                      title: 'Gallery',
                      subtitle: 'Choose from photos',
                      color: acerAccentColor,
                      onTap: () {
                        Navigator.pop(context);
                        _pickImageFromGallery();
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildImageOption(
                      icon: Icons.camera_alt_rounded,
                      title: 'Camera',
                      subtitle: 'Take new photo',
                      color: acerPrimaryColor,
                      onTap: () {
                        Navigator.pop(context);
                        _pickImageFromCamera();
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(16),
            color: color.withOpacity(0.05),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImageFile = File(image.path);
          _selectedImageUrl = null;
        });
        
        _showSuccessSnackBar('Photo selected successfully!');
      }
    } catch (e) {
      _showErrorSnackBar('Error selecting photo: $e');
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImageFile = File(image.path);
          _selectedImageUrl = null;
        });
        
        _showSuccessSnackBar('Photo captured successfully!');
      }
    } catch (e) {
      _showErrorSnackBar('Error taking photo: $e');
    }
  }

  Widget _buildProfileImage(String imageUrl, double width, double height) {
    if (imageUrl.startsWith('data:image')) {
      final base64Data = imageUrl.split(',').last;
      final bytes = base64Decode(base64Data);
      return Image.memory(
        bytes,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
      );
    } else {
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              color: acerPrimaryColor,
              strokeWidth: 2,
            ),
          );
        },
      );
    }
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            acerPrimaryColor.withOpacity(0.7),
            acerAccentColor.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(70),
      ),
      child: const Icon(
        Icons.person_rounded,
        size: 70,
        color: Colors.white,
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_validateInputs()) return;

    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(seconds: 2));

      final userProvider = Provider.of<UserProvider>(context, listen: false);

      String? imageUrl = _selectedImageUrl;
      
      if (_selectedImageFile != null) {
        final bytes = await _selectedImageFile!.readAsBytes();
        final base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        imageUrl = base64String;
      }

      final updatedUser = User(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        imageUrl: imageUrl,
      );

      userProvider.setUser(updatedUser);

      if (mounted) {
        _showSuccessSnackBar('Profile updated successfully!');
        await Future.delayed(const Duration(milliseconds: 500));
        Navigator.pop(context);
      }
    } catch (e) {
      _showErrorSnackBar('Error updating profile: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              acerPrimaryColor.withOpacity(0.1),
              Colors.white,
              acerAccentColor.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      elevation: 2,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          child: const Icon(
                            Icons.arrow_back_ios_rounded,
                            color: acerPrimaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Edit Profile',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: acerPrimaryColor,
                            ),
                          ),
                          Text(
                            'Update your personal information',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Profile Picture Section
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: acerPrimaryColor.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    'Profile Picture',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: acerPrimaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  
                                  // Profile Image
                                  Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              acerPrimaryColor.withOpacity(0.1),
                                              acerAccentColor.withOpacity(0.1),
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: acerPrimaryColor.withOpacity(0.2),
                                              blurRadius: 20,
                                              spreadRadius: 2,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: CircleAvatar(
                                          radius: 70,
                                          backgroundColor: Colors.transparent,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(70),
                                            child: _selectedImageFile != null
                                                ? Image.file(
                                                    _selectedImageFile!,
                                                    width: 140,
                                                    height: 140,
                                                    fit: BoxFit.cover,
                                                  )
                                                : _selectedImageUrl != null
                                                    ? _buildProfileImage(_selectedImageUrl!, 140, 140)
                                                    : _buildDefaultAvatar(),
                                          ),
                                        ),
                                      ),
                                      
                                      // Edit Button
                                      Positioned(
                                        right: 0,
                                        bottom: 0,
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(25),
                                            onTap: _selectImage,
                                            child: Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [acerAccentColor, acerPrimaryColor],
                                                ),
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: acerAccentColor.withOpacity(0.4),
                                                    blurRadius: 12,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(
                                                Icons.camera_alt_rounded,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Form Fields
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Personal Information',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: acerPrimaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  _buildModernTextField(
                                    controller: _nameController,
                                    label: 'Full Name',
                                    icon: Icons.person_outline_rounded,
                                    hasError: _nameError,
                                    errorText: 'Please enter your full name',
                                  ),
                                  
                                  const SizedBox(height: 20),

                                  _buildModernTextField(
                                    controller: _emailController,
                                    label: 'Email Address',
                                    icon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                    hasError: _emailError,
                                    errorText: 'Please enter a valid email address',
                                  ),
                                  
                                  const SizedBox(height: 20),

                                  _buildModernTextField(
                                    controller: _phoneController,
                                    label: 'Phone Number',
                                    icon: Icons.phone_outlined,
                                    keyboardType: TextInputType.phone,
                                    hasError: _phoneError,
                                    errorText: 'Please enter a valid 10-digit phone number',
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Save Button
                            Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                gradient: const LinearGradient(
                                  colors: [acerPrimaryColor, acerAccentColor],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: acerPrimaryColor.withOpacity(0.4),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(28),
                                  onTap: _isLoading ? null : _saveProfile,
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.save_rounded,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                'SAVE CHANGES',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  letterSpacing: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool hasError = false,
    String errorText = '',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey.shade50,
                Colors.white,
              ],
            ),
            border: Border.all(
              color: hasError
                  ? Colors.red.withOpacity(0.5)
                  : acerPrimaryColor.withOpacity(0.2),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: hasError
                    ? Colors.red.withOpacity(0.1)
                    : acerPrimaryColor.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(
                color: hasError ? Colors.red : acerPrimaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: hasError
                      ? Colors.red.withOpacity(0.1)
                      : acerPrimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: hasError ? Colors.red : acerPrimaryColor,
                  size: 20,
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  errorText,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
