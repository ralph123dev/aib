import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

class EncaisserPage extends StatefulWidget {
  final String userName;
  final bool isDarkMode;

  const EncaisserPage({
    super.key,
    required this.userName,
    required this.isDarkMode,
  });

  @override
  State<EncaisserPage> createState() => _EncaisserPageState();
}

class _EncaisserPageState extends State<EncaisserPage> {
  String _language = 'fr';
  final TextEditingController _amountController = TextEditingController();
  String _currentAmount = '';
  final GlobalKey _qrKey = GlobalKey();
  bool _isSaving = false;

  // Colors
  Color get _bgColor =>
      widget.isDarkMode ? const Color(0xFF0F1117) : const Color(0xFFF2F4F8);
  Color get _cardColor =>
      widget.isDarkMode ? const Color(0xFF1A1D27) : Colors.white;
  Color get _textPrimary =>
      widget.isDarkMode ? Colors.white : const Color(0xFF1A1A2E);
  Color get _textSecondary =>
      widget.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;

  String get _qrData {
    final base = 'aibapay://${widget.userName}';
    if (_currentAmount.isNotEmpty) {
      return '$base?amount=$_currentAmount';
    }
    return base;
  }

  // Localization
  String _t(String fr, String en) => _language == 'fr' ? fr : en;

  Future<Uint8List?> _captureQr() async {
    try {
      final boundary = _qrKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }

  Future<void> _downloadQr() async {
    setState(() => _isSaving = true);
    try {
      final bytes = await _captureQr();
      if (bytes == null) {
        _showSnack(_t('Erreur lors de la capture', 'Error capturing QR'));
        return;
      }
      final result = await ImageGallerySaverPlus.saveImage(
        bytes,
        quality: 100,
        name: 'aibapay_qr_${DateTime.now().millisecondsSinceEpoch}',
      );
      if (result != null && result['isSuccess'] == true) {
        _showSnack(_t('QR code enregistré dans la galerie !',
            'QR code saved to gallery!'));
      } else {
        _showSnack(_t('Erreur lors de l\'enregistrement', 'Error saving'));
      }
    } catch (e) {
      _showSnack(_t('Erreur: $e', 'Error: $e'));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _shareQr() async {
    try {
      final bytes = await _captureQr();
      if (bytes == null) {
        _showSnack(_t('Erreur lors de la capture', 'Error capturing QR'));
        return;
      }
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/aibapay_qr.png');
      await file.writeAsBytes(bytes);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: _t(
            'Scannez mon QR code AibaPay pour me payer !',
            'Scan my AibaPay QR code to pay me!',
          ),
        ),
      );
    } catch (e) {
      _showSnack(_t('Erreur: $e', 'Error: $e'));
    }
  }

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
  void dispose() {
    _amountController.dispose();
    super.dispose();
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
            const SizedBox(height: 16),
            _buildQrSection(),
            const SizedBox(height: 20),
            _buildAmountSection(),
            const SizedBox(height: 24),
            _buildLastTransactions(),
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
            _t('Encaisser', 'Collect'),
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
                : (widget.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600),
          ),
        ),
      ),
    );
  }

  Widget _buildQrSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
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
            Text(
              _t('Mon QR Code', 'My QR Code'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            // QR Code
            RepaintBoundary(
              key: _qrKey,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: QrImageView(
                  data: _qrData,
                  version: QrVersions.auto,
                  size: 200,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Color(0xFF1A1A2E),
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            // Merchant name
            Text(
              widget.userName,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
            if (_currentAmount.isNotEmpty) ...[
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_currentAmount FCFA',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF22C55E),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            // Explanatory text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                _t(
                  'Montre ce code à ton client pour recevoir un paiement',
                  'Show this code to your client to receive a payment',
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: _textSecondary,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Action buttons: Share, Download, Print
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQrActionBtn(
                  icon: Icons.share_rounded,
                  label: _t('Partager', 'Share'),
                  onTap: _shareQr,
                ),
                _buildQrActionBtn(
                  icon: Icons.download_rounded,
                  label: _t('Télécharger', 'Download'),
                  onTap: _downloadQr,
                  isLoading: _isSaving,
                ),
                _buildQrActionBtn(
                  icon: Icons.print_rounded,
                  label: _t('Imprimer', 'Print'),
                  onTap: () {
                    _showSnack(_t(
                      'Fonctionnalité d\'impression bientôt disponible',
                      'Print feature coming soon',
                    ));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrActionBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: isLoading
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                    ),
                  )
                : Icon(icon, color: const Color(0xFF2563EB), size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: _textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountSection() {
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
            Text(
              _t('Demander un montant précis', 'Request a specific amount'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _t(
                'Le montant sera encodé dans le QR code',
                'The amount will be encoded in the QR code',
              ),
              style: TextStyle(
                fontSize: 12,
                color: _textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.isDarkMode
                          ? const Color(0xFF2A2D37)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle: TextStyle(
                          color: _textSecondary.withOpacity(0.5),
                        ),
                        suffixText: 'FCFA',
                        suffixStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _textSecondary,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentAmount = _amountController.text.trim();
                      });
                      FocusScope.of(context).unfocus();
                      if (_currentAmount.isNotEmpty) {
                        _showSnack(_t(
                          'QR code mis à jour avec $_currentAmount FCFA',
                          'QR code updated with $_currentAmount FCFA',
                        ));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    child: Text(
                      _t('Générer', 'Generate'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_currentAmount.isNotEmpty) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _currentAmount = '';
                    _amountController.clear();
                  });
                  _showSnack(_t(
                    'Montant supprimé du QR code',
                    'Amount removed from QR code',
                  ));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.close, size: 16, color: Colors.red.shade400),
                    const SizedBox(width: 4),
                    Text(
                      _t('Supprimer le montant', 'Remove amount'),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.red.shade400,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLastTransactions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t('Dernières transactions', 'Recent transactions'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
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
                Icon(
                  Icons.receipt_long_rounded,
                  size: 48,
                  color: _textSecondary.withOpacity(0.4),
                ),
                const SizedBox(height: 12),
                Text(
                  _t(
                    'Aucune transaction récente',
                    'No recent transactions',
                  ),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _t(
                    'Vos paiements reçus apparaîtront ici',
                    'Your received payments will appear here',
                  ),
                  style: TextStyle(
                    fontSize: 12,
                    color: _textSecondary.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 20),
                // Buttons: Voir le reçu / Partager le reçu
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTransactionBtn(
                      icon: Icons.receipt_outlined,
                      label: _t('Voir le reçu', 'View receipt'),
                      enabled: false,
                    ),
                    const SizedBox(width: 16),
                    _buildTransactionBtn(
                      icon: Icons.share_outlined,
                      label: _t('Partager le reçu', 'Share receipt'),
                      enabled: false,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionBtn({
    required IconData icon,
    required String label,
    required bool enabled,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.45,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF2563EB).withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF2563EB).withOpacity(0.15),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF2563EB)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2563EB),
              ),
            ),
          ],
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