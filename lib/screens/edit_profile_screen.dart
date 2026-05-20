import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../utils/app_localizations.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _setPasswordController = TextEditingController();
  final _setConfirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _obscureSet = true;
  bool _obscureSetConfirm = true;
  bool _nameSaved = false;
  String? _photoBase64;
  bool _photoUploaded = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _nameController.text = auth.userName;
    auth.clearError();
    auth.clearSuccess();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _setPasswordController.dispose();
    _setConfirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, maxWidth: 1024, maxHeight: 1024);
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    setState(() => _photoBase64 = base64Encode(bytes));
    _uploadPhoto();
  }

  void _showImagePicker() {
    final loc = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36, height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.iosGray3,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: Text(loc.translate('take_photo')),
                onTap: () { Navigator.pop(ctx); _pickImage(ImageSource.camera); },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(loc.translate('choose_gallery')),
                onTap: () { Navigator.pop(ctx); _pickImage(ImageSource.gallery); },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _uploadPhoto() async {
    if (_photoBase64 == null) return;

    final loc = AppLocalizations.of(context);
    final auth = context.read<AuthProvider>();
    final ok = await auth.updatePhoto(_photoBase64!);
    if (mounted) {
      if (ok) {
        setState(() => _photoUploaded = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.translate('photo_updated')),
            backgroundColor: AppColors.iosGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.error ?? loc.translate('failed_photo')),
            backgroundColor: AppColors.iosRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _saveName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final loc = AppLocalizations.of(context);
    final auth = context.read<AuthProvider>();
    final ok = await auth.updateName(name);
    if (mounted && ok) {
      setState(() => _nameSaved = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.translate('name_updated_success')),
          backgroundColor: AppColors.iosGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? loc.translate('failed_name')),
          backgroundColor: AppColors.iosRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    final loc = AppLocalizations.of(context);
    final auth = context.read<AuthProvider>();
    final ok = await auth.changePassword(
      oldPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
      newPasswordConfirmation: _confirmPasswordController.text,
    );
    if (mounted) {
      if (ok) {
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.translate('password_changed')),
            backgroundColor: AppColors.iosGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.error ?? loc.translate('failed_password_change')),
            backgroundColor: AppColors.iosRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _createPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final loc = AppLocalizations.of(context);
    final auth = context.read<AuthProvider>();
    final ok = await auth.createPassword(
      newPassword: _setPasswordController.text,
      newPasswordConfirmation: _setConfirmPasswordController.text,
    );
    if (mounted) {
      if (ok) {
        _setPasswordController.clear();
        _setConfirmPasswordController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.translate('password_created')),
            backgroundColor: AppColors.iosGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.error ?? loc.translate('failed_password_create')),
            backgroundColor: AppColors.iosRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String? Function(String?)? passwordValidator(AppLocalizations l) {
      return (v) {
        if (v == null || v.isEmpty) return l.translate('enter_password_generic');
        if (v.length < 8) return l.translate('password_8_chars');
        if (!RegExp(r'[A-Z]').hasMatch(v)) return l.translate('password_uppercase');
        if (!RegExp(r'[0-9]').hasMatch(v)) return l.translate('password_digit');
        if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(v)) {
          return l.translate('password_special');
        }
        return null;
      };
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.translate('edit_profile'),
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPhotoSection(cs, isDark, auth),
                const SizedBox(height: 24),
                _buildSectionHeader(loc.translate('profile_section'), cs),
                _buildCard(context, [
                  _buildTextFieldRow(
                    context,
                    icon: Icons.person_outline,
                    controller: _nameController,
                    label: loc.translate('name'),
                    onSave: _saveName,
                    isDark: isDark,
                  ),
                  if (_nameSaved)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(52, 0, 16, 10),
                      child: Text(
                        loc.translate('name_updated'),
                        style: TextStyle(color: AppColors.iosGreen, fontSize: 12),
                      ),
                    ),
                ]),
                const SizedBox(height: 24),
                if (!auth.hasPassword) ...[
                  _buildSectionHeader(loc.translate('set_password'), cs),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: Text(
                      loc.translate('set_password_hint'),
                      style: TextStyle(color: AppColors.iosGray, fontSize: 13),
                    ),
                  ),
                  _buildCard(context, [
                    _buildPasswordField(
                      context,
                      icon: Icons.lock_outline,
                      controller: _setPasswordController,
                      label: loc.translate('new_password'),
                      obscure: _obscureSet,
                      toggle: () => setState(() => _obscureSet = !_obscureSet),
                      validator: passwordValidator(loc),
                    ),
                    _buildDivider(isDark),
                    _buildPasswordField(
                      context,
                      icon: Icons.lock_outline,
                      controller: _setConfirmPasswordController,
                      label: loc.translate('confirm_password'),
                      obscure: _obscureSetConfirm,
                      toggle: () => setState(() => _obscureSetConfirm = !_obscureSetConfirm),
                      validator: (v) {
                        if (v == null || v.isEmpty) return loc.translate('please_confirm_password');
                        if (v != _setPasswordController.text) return loc.translate('passwords_no_match');
                        return null;
                      },
                    ),
                  ]),
                  const SizedBox(height: 8),
                  _buildSaveButton(context, loc.translate('create_password'), _createPassword, auth.isLoading),
                ] else ...[
                  _buildSectionHeader(loc.translate('change_password'), cs),
                  _buildCard(context, [
                    _buildPasswordField(
                      context,
                      icon: Icons.lock_open,
                    controller: _currentPasswordController,
                    label: loc.translate('old_password'),
                      obscure: _obscureCurrent,
                      toggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
                      validator: (v) {
                        if (v == null || v.isEmpty) return loc.translate('enter_old_password');
                        return null;
                      },
                    ),
                    _buildDivider(isDark),
                    _buildPasswordField(
                      context,
                      icon: Icons.lock_outline,
                      controller: _newPasswordController,
                      label: loc.translate('new_password'),
                      obscure: _obscureNew,
                      toggle: () => setState(() => _obscureNew = !_obscureNew),
                      validator: passwordValidator(loc),
                    ),
                    _buildDivider(isDark),
                    _buildPasswordField(
                      context,
                      icon: Icons.lock_outline,
                      controller: _confirmPasswordController,
                      label: loc.translate('confirm_password'),
                      obscure: _obscureConfirm,
                      toggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      validator: (v) {
                        if (v == null || v.isEmpty) return loc.translate('please_confirm_password');
                        if (v != _newPasswordController.text) return loc.translate('passwords_no_match');
                        return null;
                      },
                    ),
                  ]),
                  const SizedBox(height: 8),
                  _buildSaveButton(context, loc.translate('change_password_btn'), _changePassword, auth.isLoading),
                ],
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPhotoSection(ColorScheme cs, bool isDark, AuthProvider auth) {
    final loc = AppLocalizations.of(context);
    return GestureDetector(
      onTap: _showImagePicker,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: cs.primary.withValues(alpha: 0.15),
                  backgroundImage: _photoBase64 != null
                      ? MemoryImage(base64Decode(_photoBase64!))
                      : (auth.userPhoto != null
                          ? CachedNetworkImageProvider(auth.userPhoto!)
                          : null),
                  child: _photoBase64 == null && auth.userPhoto == null
                      ? Icon(Icons.person, size: 48, color: cs.primary)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppColors.iosBackgroundDark : AppColors.iosCardLight,
                        width: 2,
                      ),
                    ),
                    child: Icon(Icons.camera_alt, size: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              loc.translate('tap_change_photo'),
              style: TextStyle(color: AppColors.iosGray, fontSize: 13),
            ),
            if (_photoUploaded)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  loc.translate('photo_updated_label'),
                  style: TextStyle(color: AppColors.iosGreen, fontSize: 12),
                ),
              ),
            if (auth.isLoading && _photoBase64 != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: SpinKitFadingCircle(
                  size: 20,
                  color: cs.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.iosGray,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.iosCardDark : AppColors.iosCardLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 0,
      indent: 52,
      color: isDark
          ? AppColors.iosSeparatorDark.withValues(alpha: 0.3)
          : AppColors.iosSeparatorLight.withValues(alpha: 0.08),
    );
  }

  Widget _buildTextFieldRow(
    BuildContext context, {
    required IconData icon,
    required TextEditingController controller,
    required String label,
    required VoidCallback onSave,
    required bool isDark,
  }) {
    final loc = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: cs.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: cs.onSurface,
              ),
              decoration: InputDecoration(
                hintText: label,
                border: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => onSave(),
            ),
          ),
          GestureDetector(
            onTap: onSave,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                loc.translate('save'),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(
    BuildContext context, {
    required IconData icon,
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback toggle,
    required String? Function(String?)? validator,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: cs.primary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: controller,
              obscureText: obscure,
              validator: validator,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: cs.onSurface,
              ),
              decoration: InputDecoration(
                hintText: label,
                border: InputBorder.none,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscure ? Icons.visibility_off : Icons.visibility,
                    size: 20,
                    color: AppColors.iosGray,
                  ),
                  onPressed: toggle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, String label, VoidCallback onPressed, bool isLoading) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          child: isLoading
              ? const SpinKitFadingCircle(color: Colors.white, size: 22)
              : Text(label),
        ),
      ),
    );
  }
}
