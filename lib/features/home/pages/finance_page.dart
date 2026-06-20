import 'package:flutter/material.dart';

class FinancePage extends StatefulWidget {
  final bool isDarkMode;

  const FinancePage({
    super.key,
    required this.isDarkMode,
  });

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage>
    with SingleTickerProviderStateMixin {
  String _language = 'fr';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Colors
  Color get _bgColor =>
      widget.isDarkMode ? const Color(0xFF0F1117) : const Color(0xFFF2F4F8);
  Color get _cardColor =>
      widget.isDarkMode ? const Color(0xFF1A1D27) : Colors.white;
  Color get _textPrimary =>
      widget.isDarkMode ? Colors.white : const Color(0xFF1A1A2E);
  Color get _textSecondary =>
      widget.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;

  String _t(String fr, String en) => _language == 'fr' ? fr : en;

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
            const SizedBox(height: 20),
            _buildResumeCard(),
            const SizedBox(height: 16),
            _buildDownloadReport(),
            const SizedBox(height: 24),
            _buildTabs(),
            const SizedBox(height: 24),
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
            'Finances',
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

  Widget _buildResumeCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // RÉSUMÉ header
            Text(
              _t('RÉSUMÉ', 'SUMMARY'),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _textSecondary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            // Bénéfice net
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _t('Bénéfice net', 'Net profit'),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: _textPrimary,
                  ),
                ),
                const Text(
                  '+0 FCFA',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF22C55E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: widget.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200, height: 1),
            const SizedBox(height: 14),
            // Total recettes
            _buildResumeRow(
              _t('Total recettes', 'Total income'),
              '0 FCFA',
            ),
            const SizedBox(height: 12),
            // Total dépenses
            _buildResumeRow(
              _t('Total dépenses', 'Total expenses'),
              '0 FCFA',
            ),
            const SizedBox(height: 12),
            // Trésorerie restante
            _buildResumeRow(
              _t('Trésorerie restante', 'Remaining treasury'),
              '0 FCFA',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumeRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: _textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadReport() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_t(
                'Fonctionnalité bientôt disponible',
                'Feature coming soon',
              )),
              backgroundColor: const Color(0xFF2563EB),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.download_rounded,
                  color: Color(0xFF2563EB),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  _t('Télécharger mon rapport', 'Download my report'),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
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
      ),
    );
  }

  Widget _buildTabs() {
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
        child: Column(
          children: [
            // Tab bar
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              decoration: BoxDecoration(
                color: widget.isDarkMode
                    ? const Color(0xFF2A2D37)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                onTap: (index) => setState(() {}),
                indicator: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: _textPrimary,
                unselectedLabelColor: _textSecondary,
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                tabs: [
                  Tab(text: _t('Recettes', 'Income')),
                  Tab(text: _t('Dépenses', 'Expenses')),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Tab content
            ListenableBuilder(
              listenable: _tabController,
              builder: (context, _) {
                return _tabController.index == 0
                    ? _buildRecettesTab()
                    : _buildDepensesTab();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecettesTab() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section: Ventes via AibaPay
          Text(
            _t('Ventes via AibaPay', 'Sales via AibaPay'),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildFinanceRow(
            _t('Ventes via AibaPay', 'Sales via AibaPay'),
            '0 FCFA',
          ),
          const SizedBox(height: 10),
          _buildFinanceRow(
            _t('Paiements hors plateforme', 'Off-platform payments'),
            '0 FCFA',
          ),
          const SizedBox(height: 20),
          // Add button (dashed border)
          _buildAddButton(
            _t(
              '+ Ajouter une recette (hors plateforme)',
              '+ Add income (off-platform)',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepensesTab() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t('Dépenses', 'Expenses'),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildFinanceRow(
            _t('Dépenses via AibaPay', 'Expenses via AibaPay'),
            '0 FCFA',
          ),
          const SizedBox(height: 10),
          _buildFinanceRow(
            _t('Dépenses hors plateforme', 'Off-platform expenses'),
            '0 FCFA',
          ),
          const SizedBox(height: 20),
          _buildAddButton(
            _t(
              '+ Ajouter une dépense (hors plateforme)',
              '+ Add expense (off-platform)',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: _textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton(String label) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_t(
              'Fonctionnalité bientôt disponible',
              'Feature coming soon',
            )),
            backgroundColor: const Color(0xFF2563EB),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: _textSecondary.withOpacity(0.4),
          borderRadius: 14,
          strokeWidth: 1.5,
          dashWidth: 8,
          dashSpace: 5,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom painter for dashed border
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double borderRadius;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  _DashedBorderPainter({
    required this.color,
    required this.borderRadius,
    this.strokeWidth = 1.5,
    this.dashWidth = 8,
    this.dashSpace = 5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(borderRadius),
      ));

    // Create dashed path
    final dashPath = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final end = distance + dashWidth;
        dashPath.addPath(
          metric.extractPath(distance, end.clamp(0, metric.length)),
          Offset.zero,
        );
        distance = end + dashSpace;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      color != oldDelegate.color ||
      borderRadius != oldDelegate.borderRadius ||
      strokeWidth != oldDelegate.strokeWidth;
}
