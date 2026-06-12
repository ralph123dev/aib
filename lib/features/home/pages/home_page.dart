import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  final String userName;
  const HomePage({super.key, required this.userName});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  bool _isBalanceVisible = true;
  bool _isDarkMode = false;
  int _selectedNavIndex = 0;
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;
  bool _popupShown = false;
  String _language = 'fr';
  bool _isActivityLoading = true;

  final double _balance = 125750;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _waveAnimation = Tween<double>(begin: -0.15, end: 0.15).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );
    _waveController.repeat(reverse: true);

    // Activity loading timer (70 seconds)
    Future.delayed(const Duration(seconds: 70), () {
      if (mounted) {
        setState(() => _isActivityLoading = false);
      }
    });

    // Show popup after a short delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_popupShown) {
        _popupShown = true;
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) _showAccountPopup();
        });
      }
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  void _showAccountPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _AccountPopupDialog(
        isDarkMode: _isDarkMode,
      ),
    );
  }

  String _formatBalance(double amount) {
    final formatter = NumberFormat('#,###', 'fr_FR');
    return formatter.format(amount.toInt());
  }

  // Colors based on theme
  Color get _bgColor => _isDarkMode ? const Color(0xFF0F1117) : const Color(0xFFF2F4F8);
  Color get _cardColor => _isDarkMode ? const Color(0xFF1A1D27) : Colors.white;
  Color get _textPrimary => _isDarkMode ? Colors.white : const Color(0xFF1A1A2E);
  Color get _textSecondary => _isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
  Color get _dividerColor => _isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE d MMMM yyyy', 'fr_FR');
    String formattedDate;
    try {
      formattedDate = dateFormat.format(now);
      // Capitalize first letter
      formattedDate = formattedDate[0].toUpperCase() + formattedDate.substring(1);
    } catch (_) {
      formattedDate = '${now.day}/${now.month}/${now.year}';
    }

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: _selectedNavIndex == 0
            ? _buildHomePage(formattedDate)
            : _buildPlaceholderPage(_getNavLabel(_selectedNavIndex)),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomePage(String formattedDate) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(formattedDate),
          const SizedBox(height: 20),
          // Balance Card
          _buildBalanceCard(),
          const SizedBox(height: 24),
          // Stats Row
          _buildStatsRow(),
          const SizedBox(height: 24),
          // Recent Activity
          _buildRecentActivity(),
          const SizedBox(height: 20),
          // Encaisser button
          _buildEncaisserButton(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeader(String formattedDate) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Bonjour ',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        widget.userName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2563EB), // Blue
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Waving hand animation
                    _WavingHand(animation: _waveAnimation),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 13,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              // Dark/Light mode toggle
              GestureDetector(
                onTap: () {
                  setState(() => _isDarkMode = !_isDarkMode);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _isDarkMode
                        ? const Color(0xFF2A2D37)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    color: _isDarkMode ? Colors.amber : Colors.orange,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Notification bell
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _isDarkMode
                      ? const Color(0xFF2A2D37)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.notifications_outlined,
                        color: _textPrimary,
                        size: 22,
                      ),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1B3A5C), Color(0xFF2563EB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2563EB).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Solde actuel label + eye icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      'Solde actuel',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() => _isBalanceVisible = !_isBalanceVisible);
                      },
                      child: Icon(
                        _isBalanceVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.white70,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                // Card icon
                Container(
                  width: 42,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.credit_card_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Balance amount
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isBalanceVisible
                  ? Text(
                      '${_formatBalance(_balance)} FCFA',
                      key: const ValueKey('visible'),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    )
                  : const Text(
                      '••••••• FCFA',
                      key: ValueKey('hidden'),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
            ),
            const SizedBox(height: 24),
            // Action buttons row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.arrow_downward_rounded,
                  label: 'Demander\nun retrait',
                ),
                _buildActionButton(
                  icon: Icons.send_rounded,
                  label: 'Effectuer\nun paiement',
                ),
                _buildActionButton(
                  icon: Icons.account_balance_rounded,
                  label: 'Demander\nun crédit',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label}) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white70,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(
                label: 'Ventes du jour',
                value: '45 000',
                suffix: ' FCFA',
                extra: '↗ 12%',
                extraColor: const Color(0xFF22C55E),
              ),
            ),
            Container(
              width: 1,
              height: 50,
              color: _dividerColor,
            ),
            Expanded(
              child: _buildStatItem(
                label: 'Transactions',
                value: '28',
                suffix: '',
                extra: 'Clients',
                extraColor: _textSecondary,
                extraIcon: Icons.people_outline,
              ),
            ),
            Container(
              width: 1,
              height: 50,
              color: _dividerColor,
            ),
            Expanded(
              child: _buildStatItem(
                label: 'Revenus semaine',
                value: '320 000',
                suffix: ' FCFA',
                showProgress: true,
                progressValue: 0.80,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required String suffix,
    String? extra,
    Color? extraColor,
    IconData? extraIcon,
    bool showProgress = false,
    double progressValue = 0,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: _textSecondary,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              TextSpan(
                text: suffix,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: _textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        if (extra != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (extraIcon != null) ...[
                Icon(extraIcon, size: 14, color: extraColor),
                const SizedBox(width: 2),
              ],
              Text(
                extra,
                style: TextStyle(
                  fontSize: 11,
                  color: extraColor ?? _textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        if (showProgress)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progressValue,
                      backgroundColor: _isDarkMode
                          ? Colors.grey.shade700
                          : Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF2563EB),
                      ),
                      minHeight: 5,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${(progressValue * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 10,
                    color: _textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _language == 'fr' ? 'Activité récente' : 'Recent Activity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  _language == 'fr' ? 'Voir tout' : 'See all',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF2563EB),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: _isActivityLoading
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: CircularProgressIndicator(
                            strokeWidth: 3.5,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF2563EB),
                            ),
                            backgroundColor: _isDarkMode
                                ? Colors.grey.shade700
                                : Colors.grey.shade200,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _language == 'fr'
                              ? 'Chargement des activités...'
                              : 'Loading activities...',
                          style: TextStyle(
                            fontSize: 14,
                            color: _textSecondary,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inbox_rounded,
                          size: 48,
                          color: _textSecondary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _language == 'fr'
                              ? 'Pas d\'activité détectée'
                              : 'No activity detected',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _language == 'fr'
                              ? 'Vos transactions apparaîtront ici'
                              : 'Your transactions will appear here',
                          style: TextStyle(
                            fontSize: 12,
                            color: _textSecondary.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEncaisserButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            elevation: 4,
            shadowColor: const Color(0xFF2563EB).withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.qr_code_scanner_rounded, size: 22),
              const SizedBox(width: 10),
              const Text(
                'Encaisser maintenant',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_rounded, 'activeIcon': Icons.home_rounded, 'label': 'Accueil'},
      {'icon': Icons.qr_code_scanner_outlined, 'activeIcon': Icons.qr_code_scanner_rounded, 'label': 'Encaisser'},
      {'icon': Icons.account_balance_wallet_outlined, 'activeIcon': Icons.account_balance_wallet_rounded, 'label': 'Finances'},
      {'icon': Icons.history_outlined, 'activeIcon': Icons.history_rounded, 'label': 'Historique'},
      {'icon': Icons.person_outline_rounded, 'activeIcon': Icons.person_rounded, 'label': 'Profil'},
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final isActive = _selectedNavIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedNavIndex = index),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  transform: Matrix4.translationValues(0.0, isActive ? -6.0 : 0.0, 0.0),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF2563EB)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: const Color(0xFF2563EB).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isActive
                            ? items[index]['activeIcon'] as IconData
                            : items[index]['icon'] as IconData,
                        color: isActive
                            ? Colors.white
                            : _textSecondary,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items[index]['label'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                          color: isActive
                              ? Colors.white
                              : _textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  String _getNavLabel(int index) {
    const labels = ['Accueil', 'Encaisser', 'Finances', 'Historique', 'Profil'];
    return labels[index];
  }

  Widget _buildPlaceholderPage(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction_rounded,
            size: 64,
            color: _textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bientôt disponible',
            style: TextStyle(
              fontSize: 14,
              color: _textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Account Verification Popup ──
class _AccountPopupDialog extends StatelessWidget {
  final bool isDarkMode;
  const _AccountPopupDialog({required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final cardColor = isDarkMode ? const Color(0xFF1A1D27) : Colors.white;
    final textPrimary = isDarkMode ? Colors.white : const Color(0xFF1A1A2E);
    final textSecondary =
        isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Shield icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFA726).withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.shield_outlined,
                color: Colors.white,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Compte Standard',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Vous êtes actuellement sur un compte standard. Souhaitez-vous passer à un compte vérifié pour débloquer toutes les fonctionnalités ?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            // Accept button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Cette fonctionnalité sera bientôt disponible !',
                      ),
                      backgroundColor: const Color(0xFF2563EB),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Obtenir un compte vérifié',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Decline button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: isDarkMode
                          ? Colors.grey.shade700
                          : Colors.grey.shade300,
                    ),
                  ),
                ),
                child: Text(
                  'Non merci, plus tard',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Waving Hand Widget ──
class _WavingHand extends AnimatedWidget {
  const _WavingHand({required Animation<double> animation})
      : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    return Transform.rotate(
      angle: animation.value,
      child: const Text(
        '👋',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
