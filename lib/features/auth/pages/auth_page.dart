import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../home/pages/home_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  bool _isSignUp = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  String _language = 'fr'; // 'fr' or 'en'

  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _telController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    _animController.reset();
    setState(() => _isSignUp = !_isSignUp);
    _formKey.currentState?.reset();
    _animController.forward();
  }

  Map<String, String> _getTexts() {
    if (_language == 'en') {
      return {
        'createAccount': 'Create Account',
        'welcome': 'Welcome Back',
        'fillForm': 'Fill in the fields to sign up',
        'connectForm': 'Log in to your account',
        'signUp': 'Sign Up',
        'signIn': 'Sign In',
        'firstName': 'First Name',
        'lastName': 'Last Name',
        'email': 'Email Address',
        'phone': 'Phone Number',
        'password': 'Password',
        'confirmPassword': 'Confirm Password',
        'required': 'Required',
        'invalidEmail': 'Invalid email',
        'phoneTooShort': 'Phone number too short',
        'min8Chars': 'Minimum 8 characters',
        'passwordNotMatch': 'Passwords do not match',
        'forgotPassword': 'Forgot password?',
        'createBtn': 'Create my account',
        'signInBtn': 'Sign In',
        'haveAccount': 'Already have an account? ',
        'noAccount': 'No account yet? ',
        'successCreate': 'Account created successfully!',
        'successSignIn': 'Sign in successful!',
      };
    } else {
      return {
        'createAccount': 'Créer un compte',
        'welcome': 'Bon retour',
        'fillForm': 'Remplis les champs pour t\'inscrire',
        'connectForm': 'Connecte-toi à ton compte',
        'signUp': 'S\'inscrire',
        'signIn': 'Se connecter',
        'firstName': 'Prénom',
        'lastName': 'Nom',
        'email': 'Adresse email',
        'phone': 'Numéro de téléphone',
        'password': 'Mot de passe',
        'confirmPassword': 'Confirmer le mot de passe',
        'required': 'Requis',
        'invalidEmail': 'Email invalide',
        'phoneTooShort': 'Numéro trop court',
        'min8Chars': 'Minimum 8 caractères',
        'passwordNotMatch': 'Les mots de passe ne correspondent pas',
        'forgotPassword': 'Mot de passe oublié ?',
        'createBtn': 'Créer mon compte',
        'signInBtn': 'Se connecter',
        'haveAccount': 'Déjà un compte ? ',
        'noAccount': 'Pas encore de compte ? ',
        'successCreate': 'Compte créé avec succès !',
        'successSignIn': 'Connexion réussie !',
      };
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);
    final texts = _getTexts();
    try {
      if (_isSignUp) {
        final email = _emailController.text.trim();
        final password = _passwordController.text;
        final firstName = _prenomController.text.trim();
        final lastName = _nomController.text.trim();
        final phone = _telController.text.trim();

        try {
          final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          final user = userCredential.user;
          if (user != null) {
            try {
              await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
                'uid': user.uid,
                'firstName': firstName,
                'lastName': lastName,
                'email': email,
                'phone': phone,
                'createdAt': FieldValue.serverTimestamp(),
              });
              debugPrint('User document created: ${user.uid}');
            } on FirebaseException catch (firestoreError) {
              final message = _language == 'fr'
                  ? 'Erreur lors de l\'enregistrement du profil, mais vous êtes connecté.'
                  : 'Error saving profile, but you are signed in.';
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: const Color(0xFFFFA500),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }
              debugPrint('Firestore save failed for user ${user.uid}: ${firestoreError.message}');
            }
            await user.updateDisplayName('$firstName $lastName');
          }
        } on FirebaseAuthException catch (signUpError) {
          if (signUpError.code == 'email-already-in-use') {
            await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: email,
              password: password,
            );
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_language == 'fr'
                    ? 'Compte existant détecté. Connexion en cours...'
                    : 'Existing account detected. Signing in...'),
                backgroundColor: const Color(0xFF4FA3D1),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
            final userName = email.split('@').first;
            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(userName: userName.isNotEmpty ? userName : 'Utilisateur'),
                ),
                (route) => false,
              );
            }
            return;
          }
          rethrow;
        }
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isSignUp ? texts['successCreate']! : texts['successSignIn']!),
          backgroundColor: const Color(0xFF4FA3D1),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      final userName = _isSignUp
          ? _prenomController.text.trim()
          : _emailController.text.split('@').first;
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(userName: userName.isNotEmpty ? userName : 'Utilisateur'),
          ),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (error) {
      final message = _firebaseErrorMessage(error.code, texts);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: const Color(0xFFFF5C5C),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_language == 'fr'
                ? 'Une erreur est survenue. Réessayez.'
                : 'An error occurred. Please try again.'),
            backgroundColor: const Color(0xFFFF5C5C),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _firebaseErrorMessage(String code, Map<String, String> texts) {
    return switch (code) {
      'email-already-in-use' => _language == 'fr'
          ? 'Cet email est déjà utilisé.'
          : 'This email is already in use.',
      'invalid-email' => texts['invalidEmail']!,
      'weak-password' => _language == 'fr'
          ? 'Le mot de passe est trop faible.'
          : 'The password is too weak.',
      'wrong-password' => _language == 'fr'
          ? 'Mot de passe incorrect.'
          : 'Wrong password.',
      'user-not-found' => _language == 'fr'
          ? 'Utilisateur introuvable.'
          : 'User not found.',
      _ => _language == 'fr'
          ? 'Une erreur est survenue, réessayez.'
          : 'An error occurred, please try again.',
    };
  }

  @override
  Widget build(BuildContext context) {
    final texts = _getTexts();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F4FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _language = 'en'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _language == 'en'
                          ? const Color(0xFF4FA3D1).withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '🇬🇧 EN',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _language == 'en'
                            ? const Color(0xFF4FA3D1)
                            : Colors.grey.shade500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() => _language = 'fr'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _language == 'fr'
                          ? const Color(0xFF4FA3D1).withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '🇫🇷 FR',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _language == 'fr'
                            ? const Color(0xFF4FA3D1)
                            : Colors.grey.shade500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4FA3D1), Color(0xFF87CEEB)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4FA3D1).withOpacity(0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _isSignUp ? texts['createAccount']! : texts['welcome']!,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isSignUp
                          ? texts['fillForm']!
                          : texts['connectForm']!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _buildToggleButton(texts['signUp']!, true),
                    _buildToggleButton(texts['signIn']!, false),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (_isSignUp) ...[
                          Row(
                            children: [
                              Expanded(
                                child: _buildField(
                                  controller: _nomController,
                                  label: texts['lastName']!,
                                  icon: Icons.person_outline_rounded,
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                          ? texts['required']!
                                          : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildField(
                                  controller: _prenomController,
                                  label: texts['firstName']!,
                                  icon: Icons.badge_outlined,
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                          ? texts['required']!
                                          : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                        ],

                        _buildField(
                          controller: _emailController,
                          label: texts['email']!,
                          icon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return texts['required']!;
                            final emailRegex = RegExp(r'^[\w\.\+\-]+@\w+\.\w+$');
                            if (!emailRegex.hasMatch(v.trim())) {
                              return texts['invalidEmail']!;
                            }
                            return null;
                          },
                        ),

                        if (_isSignUp) ...[
                          const SizedBox(height: 14),
                          _buildField(
                            controller: _telController,
                            label: texts['phone']!,
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return texts['required']!;
                              if (v.trim().length < 8) return texts['phoneTooShort']!;
                              return null;
                            },
                          ),
                        ],

                        const SizedBox(height: 14),

                        _buildPasswordField(
                          controller: _passwordController,
                          label: texts['password']!,
                          showPassword: _showPassword,
                          onToggle: () =>
                              setState(() => _showPassword = !_showPassword),
                          validator: (v) {
                            if (v == null || v.isEmpty) return texts['required']!;
                            if (v.length < 8) {
                              return texts['min8Chars']!;
                            }
                            return null;
                          },
                        ),

                        if (_isSignUp) ...[
                          const SizedBox(height: 14),
                          _buildPasswordField(
                            controller: _confirmPasswordController,
                            label: texts['confirmPassword']!,
                            showPassword: _showConfirmPassword,
                            onToggle: () => setState(() =>
                                _showConfirmPassword = !_showConfirmPassword),
                            validator: (v) {
                              if (v == null || v.isEmpty) return texts['required']!;
                              if (v != _passwordController.text) {
                                return texts['passwordNotMatch']!;
                              }
                              return null;
                            },
                          ),
                        ],

                        if (!_isSignUp) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                texts['forgotPassword']!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF4FA3D1),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 28),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4FA3D1),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  const Color(0xFF4FA3D1).withOpacity(0.6),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Text(
                                    _isSignUp ? texts['createBtn']! : texts['signInBtn']!,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isSignUp
                                  ? texts['haveAccount']!
                                  : texts['noAccount']!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            GestureDetector(
                              onTap: _toggleMode,
                              child: Text(
                                _isSignUp ? texts['signIn']! : texts['signUp']!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF4FA3D1),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildToggleButton(String label, bool isSignUp) {
    final isActive = _isSignUp == isSignUp;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_isSignUp != isSignUp) _toggleMode();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF4FA3D1) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : Colors.grey.shade500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(fontSize: 15, color: Color(0xFF1A1A2E)),
      decoration: _inputDecoration(label, icon),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool showPassword,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !showPassword,
      validator: validator,
      style: const TextStyle(fontSize: 15, color: Color(0xFF1A1A2E)),
      decoration: _inputDecoration(label, Icons.lock_outline_rounded).copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            showPassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: Colors.grey.shade500,
            size: 20,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(fontSize: 14, color: Colors.grey.shade500),
      prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4FA3D1), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFF5C5C), width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFF5C5C), width: 1.5),
      ),
      errorStyle: const TextStyle(fontSize: 12),
    );
  }
}
//Développer par Ralph Dev 
//ralphurgue@gmail.com
//Watshapp: +237689476780 
//Telegram: +237677968494 
//portfolio: https://ralphdeveloppeur.vercel.app