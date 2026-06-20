import 'package:flutter/material.dart';

class ProfilPage extends StatefulWidget {
  final String userName;
  final bool isDarkMode;

  const ProfilPage({
    super.key,
    required this.userName,
    required this.isDarkMode,
  });

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  String _language = 'fr';
  bool _biometricEnabled = false;
  bool _paymentAlerts = true;
  bool _dailySummary = true;

  // Colors
  Color get _bgColor =>
      widget.isDarkMode ? const Color(0xFF0F1117) : const Color(0xFFF2F4F8);
  Color get _cardColor =>
      widget.isDarkMode ? const Color(0xFF1A1D27) : Colors.white;
  Color get _textPrimary =>
      widget.isDarkMode ? Colors.white : const Color(0xFF1A1A2E);
  Color get _textSecondary =>
      widget.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
  Color get _sectionLabelColor =>
      widget.isDarkMode ? Colors.grey.shade500 : Colors.grey.shade500;

  String _t(String fr, String en) => _language == 'fr' ? fr : en;

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF2563EB),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bgColor,
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildProfileSection(),
            const SizedBox(height: 24),
            _buildAccountSection(),
            const SizedBox(height: 20),
            _buildSecuritySection(),
            const SizedBox(height: 20),
            _buildNotificationsSection(),
            const SizedBox(height: 20),
            _buildSupportSection(),
            const SizedBox(height: 24),
            _buildLogoutButton(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _t('Profil', 'Profile'),
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
            ),
          ),
          _buildLanguageToggle(),
        ],
      ),
    );
  }

  Widget _buildLanguageToggle() {
    return Container(
      decoration: BoxDecoration(
        color: widget.isDarkMode
            ? const Color(0xFF2A2D37)
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLangBtn('EN', _language == 'en'),
          _buildLangBtn('FR', _language == 'fr'),
        ],
      ),
    );
  }

  Widget _buildLangBtn(String label, bool active) {
    return GestureDetector(
      onTap: () => setState(() => _language = label.toLowerCase()),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF2563EB) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: active
                ? Colors.white
                : (widget.isDarkMode
                    ? Colors.grey.shade400
                    : Colors.grey.shade600),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Profile avatar
          Stack(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF2563EB),
                    width: 2.5,
                  ),
                ),
                child: ClipOval(
                  child: Container(
                    color: const Color(0xFF2563EB).withOpacity(0.1),
                    child: const Icon(
                      Icons.store_rounded,
                      size: 36,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),
              ),
              // Camera badge
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _cardColor,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 13,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Name and ID
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName.isNotEmpty ? widget.userName : 'Pascal Shop',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID Marchand : AIBAPAY2456',
                  style: TextStyle(
                    fontSize: 13,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection() {
    return _buildSection(
      label: _t('MON COMPTE', 'MY ACCOUNT'),
      children: [
        _buildMenuTile(
          emoji: '🏪',
          title: _t('Nom du commerce', 'Business name'),
          onTap: () => _showSnack(_t('Bientôt disponible', 'Coming soon')),
        ),
        _buildDivider(),
        _buildMenuTile(
          emoji: '🏢',
          title: _t('Type de commerce', 'Business type'),
          onTap: () => _showSnack(_t('Bientôt disponible', 'Coming soon')),
        ),
        _buildDivider(),
        _buildMenuTile(
          emoji: '📱',
          title: _t('Numéro de téléphone', 'Phone number'),
          onTap: () => _showSnack(_t('Bientôt disponible', 'Coming soon')),
        ),
        _buildDivider(),
        _buildMenuTile(
          emoji: '✉️',
          title: 'Email',
          onTap: () => _showSnack(_t('Bientôt disponible', 'Coming soon')),
        ),
        _buildDivider(),
        _buildMenuTile(
          emoji: '🖼️',
          title: _t('Photo de profil', 'Profile photo'),
          onTap: () => _showSnack(_t('Bientôt disponible', 'Coming soon')),
        ),
      ],
    );
  }

  Widget _buildSecuritySection() {
    return _buildSection(
      label: _t('SÉCURITÉ', 'SECURITY'),
      children: [
        _buildMenuTile(
          emoji: '🔑',
          title: _t('Changer le mot de passe', 'Change password'),
          onTap: () => _showSnack(_t('Bientôt disponible', 'Coming soon')),
        ),
        _buildDivider(),
        _buildSwitchTile(
          emoji: '👆',
          title: _t('Connexion biométrique', 'Biometric login'),
          subtitle: _t(
            'Utilise l\'empreinte ou Face ID',
            'Use fingerprint or Face ID',
          ),
          value: _biometricEnabled,
          onChanged: (val) => setState(() => _biometricEnabled = val),
        ),
      ],
    );
  }

  Widget _buildNotificationsSection() {
    return _buildSection(
      label: 'NOTIFICATIONS',
      children: [
        _buildSwitchTile(
          emoji: '🔔',
          title: _t('Alertes de paiement', 'Payment alerts'),
          subtitle: _t(
            'Sois notifié quand tu reçois un paiement',
            'Get notified when you receive a payment',
          ),
          value: _paymentAlerts,
          onChanged: (val) => setState(() => _paymentAlerts = val),
        ),
        _buildDivider(),
        _buildSwitchTile(
          emoji: '📊',
          title: _t('Résumé quotidien', 'Daily summary'),
          subtitle: _t(
            'Reçois un récap quotidien de ton activité',
            'Receive a daily recap of your activity',
          ),
          value: _dailySummary,
          onChanged: (val) => setState(() => _dailySummary = val),
        ),
      ],
    );
  }

  Widget _buildSupportSection() {
    return _buildSection(
      label: 'SUPPORT',
      children: [
        _buildMenuTile(
          emoji: '❓',
          title: 'FAQ',
          onTap: () => _showSnack(_t('Bientôt disponible', 'Coming soon')),
        ),
        _buildDivider(),
        _buildMenuTile(
          emoji: '💬',
          title: _t('Contacter via WhatsApp', 'Contact via WhatsApp'),
          onTap: () => _showSnack(_t('Bientôt disponible', 'Coming soon')),
        ),
        _buildDivider(),
        _buildMenuTile(
          emoji: '🚨',
          title: _t('Signaler un problème', 'Report a problem'),
          onTap: () => _showSnack(_t('Bientôt disponible', 'Coming soon')),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String label,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _sectionLabelColor,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required String emoji,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: widget.isDarkMode
                    ? const Color(0xFF2A2D37)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: _textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: _textSecondary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String emoji,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: widget.isDarkMode
                  ? const Color(0xFF2A2D37)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF2563EB),
            activeTrackColor: const Color(0xFF2563EB).withOpacity(0.4),
            inactiveThumbColor: Colors.grey.shade400,
            inactiveTrackColor: widget.isDarkMode
                ? Colors.grey.shade700
                : Colors.grey.shade300,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 70),
      child: Divider(
        height: 1,
        color: widget.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: _cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Text(
                  _t('Se déconnecter', 'Log out'),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
                content: Text(
                  _t(
                    'Êtes-vous sûr de vouloir vous déconnecter ?',
                    'Are you sure you want to log out?',
                  ),
                  style: TextStyle(color: _textSecondary),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(
                      _t('Annuler', 'Cancel'),
                      style: TextStyle(color: _textSecondary),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showSnack(_t(
                        'Déconnexion...',
                        'Logging out...',
                      ));
                    },
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.logout_rounded,
                  color: Colors.red.shade400,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  _t('Se déconnecter', 'Log out'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade400,
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
//Développer par Ralph Dev 
//ralphurgue@gmail.com
//Watshapp: +237689476780 
//Telegram: +237677968494 
//portfolio: https://ralphdeveloppeur.vercel.app