import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Brand tokens (matches home + profile screens) ─────
const kGold       = Color(0xFFC8DC32);
const kGoldDark   = Color(0xFF8FA000);
const kGoldDeep   = Color(0xFF3A4500);
const kGoldLight  = Color(0xFFF5F8D6);
const kGoldBorder = Color(0xFFE2EC8A);
const kBg         = Color(0xFFF7F7F5);
const kSurface    = Color(0xFFFFFFFF);
const kSurface2   = Color(0xFFF5F5F5);
const kBorder     = Color(0xFFEFEFEF);
const kBorderFocus= Color(0xFFC8DC32);
const kText1      = Color(0xFF111111);
const kText2      = Color(0xFFAAAAAA);
const kTextHint   = Color(0xFFCCCCCC);

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController         = TextEditingController();
  final _phoneController        = TextEditingController();
  final _emailController        = TextEditingController();
  final _gymController          = TextEditingController();
  final _specializationController = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text  = prefs.getString("name")  ?? "";
      _emailController.text = prefs.getString("email") ?? "";
      _gymController.text   = prefs.getString("gym")   ?? "";
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("name",  _nameController.text.trim());
    await prefs.setString("email", _emailController.text.trim());
    await prefs.setString("gym",   _gymController.text.trim());

    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _isSaving = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          "Profile updated successfully",
          style: TextStyle(color: kGoldDeep, fontWeight: FontWeight.w600),
        ),
        backgroundColor: kGold,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _gymController.dispose();
    _specializationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildTopBar(context),
            _buildAvatarSection(),
            _buildFormBody(),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
      bottomNavigationBar: _buildSaveBar(),
    );
  }

  // ── TOP BAR ──────────────────────────────────────────
  Widget _buildTopBar(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(color: kSurface),
        padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: kSurface2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kBorder),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 15,
                  color: kText1,
                ),
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                "Edit Profile",
                style: TextStyle(
                  color: kText1,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── AVATAR SECTION ───────────────────────────────────
  Widget _buildAvatarSection() {
    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          color: kSurface,
          border: Border(bottom: BorderSide(color: kBorder)),
        ),
        child: Column(
          children: [
            // Gold cover strip
            Stack(
              children: [
                Container(
                  height: 90,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [kGold, Color(0xFFDDED60), kGoldLight],
                      stops: [0, 0.55, 1],
                    ),
                  ),
                ),
                CustomPaint(
                  size: const Size(double.infinity, 90),
                  painter: _HatchPainter(),
                ),
              ],
            ),

            // Avatar + info
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  // Avatar pulled over cover
                  Transform.translate(
                    offset: const Offset(0, -40),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(color: kSurface, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: kGold.withOpacity(.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: Image.network(
                              "https://i.pravatar.cc/300?img=68",
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: kGoldLight,
                                child: const Icon(
                                  Icons.person,
                                  color: kGoldDark,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Edit badge
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: kGold,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: kSurface, width: 2),
                            ),
                            child: const Icon(
                              Icons.edit_rounded,
                              color: kGoldDeep,
                              size: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Name + email (compensate the transform offset)
                  Transform.translate(
                    offset: const Offset(0, -28),
                    child: Column(
                      children: [
                        Text(
                          _nameController.text.isNotEmpty
                              ? _nameController.text
                              : "Your Name",
                          style: const TextStyle(
                            color: kText1,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _emailController.text.isNotEmpty
                              ? _emailController.text
                              : "your@email.com",
                          style: const TextStyle(
                            color: kText2,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: kGoldLight,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: kGoldBorder),
                          ),
                          child: const Text(
                            "HEAD TRAINER",
                            style: TextStyle(
                              color: kGoldDark,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Change photo button
                        GestureDetector(
                          onTap: () {
                            // TODO: image picker
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 10),
                            decoration: BoxDecoration(
                              color: kGoldLight,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: kGoldBorder),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.camera_alt_outlined,
                                  size: 15,
                                  color: kGoldDark,
                                ),
                                SizedBox(width: 7),
                                Text(
                                  "Change Photo",
                                  style: TextStyle(
                                    color: kGoldDark,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── FORM BODY ────────────────────────────────────────
  Widget _buildFormBody() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const _SectionLabel("Personal Info"),

            _PremiumField(
              label: "Full Name",
              icon: Icons.person_outline_rounded,
              controller: _nameController,
              iconBg: kGoldLight,
              iconColor: kGoldDark,
              keyboardType: TextInputType.name,
              validator: (v) => (v == null || v.isEmpty) ? "Name is required" : null,
            ),

            _PremiumField(
              label: "Phone Number",
              icon: Icons.phone_outlined,
              controller: _phoneController,
              iconBg: kSurface2,
              iconColor: kText2,
              keyboardType: TextInputType.phone,
              validator: (v) => (v == null || v.isEmpty) ? "Phone is required" : null,
            ),

            _PremiumField(
              label: "Email Address",
              icon: Icons.mail_outline_rounded,
              controller: _emailController,
              iconBg: kSurface2,
              iconColor: kText2,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return "Email is required";
                if (!v.contains("@")) return "Enter a valid email";
                return null;
              },
            ),

            const SizedBox(height: 8),
            const _SectionLabel("Gym Info"),

            _PremiumField(
              label: "Gym Name",
              icon: Icons.fitness_center_outlined,
              controller: _gymController,
              iconBg: kGoldLight,
              iconColor: kGoldDark,
              validator: (v) => (v == null || v.isEmpty) ? "Gym name is required" : null,
            ),

            _PremiumField(
              label: "Specialization",
              icon: Icons.workspace_premium_outlined,
              controller: _specializationController,
              iconBg: kGoldLight,
              iconColor: kGoldDark,
              validator: null,
            ),
          ],
        ),
      ),
    );
  }

  // ── SAVE BAR ─────────────────────────────────────────
  Widget _buildSaveBar() {
    return Container(
      decoration: BoxDecoration(
        color: kBg,
        border: const Border(top: BorderSide(color: kBorder)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      child: GestureDetector(
        onTap: _isSaving ? null : _saveProfile,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 56,
          decoration: BoxDecoration(
            color: _isSaving ? kGold.withOpacity(.7) : kGold,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: _isSaving
                ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: kGoldDeep,
              ),
            )
                : Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.check_rounded, color: kGoldDeep, size: 20),
                SizedBox(width: 8),
                Text(
                  "Save Changes",
                  style: TextStyle(
                    color: kGoldDeep,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── HATCH PAINTER ────────────────────────────────────────────
class _HatchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.06)
      ..strokeWidth = 1;
    const spacing = 14.0;
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_HatchPainter old) => false;
}

// ── SECTION LABEL ────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: kText2,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    ),
  );
}

// ── PREMIUM FIELD ────────────────────────────────────────────
class _PremiumField extends StatefulWidget {
  final String            label;
  final IconData          icon;
  final Color             iconBg, iconColor;
  final TextEditingController controller;
  final TextInputType     keyboardType;
  final String? Function(String?)? validator;

  const _PremiumField({
    required this.label,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  State<_PremiumField> createState() => _PremiumFieldState();
}

class _PremiumFieldState extends State<_PremiumField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Focus(
        onFocusChange: (v) => setState(() => _focused = v),
        child: TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          style: const TextStyle(
            color: kText1,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: widget.label,
            hintStyle: const TextStyle(
              color: kTextHint,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: kSurface,
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _focused ? kGoldLight : widget.iconBg,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  widget.icon,
                  size: 18,
                  color: _focused ? kGoldDark : widget.iconColor,
                ),
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 64),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: kBorder, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: kBorderFocus, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Color(0xFFE53935), width: 2),
            ),
          ),
        ),
      ),
    );
  }
}