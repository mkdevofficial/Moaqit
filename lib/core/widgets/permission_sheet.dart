import 'dart:ui';
import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:moaqit/core/theme/app_theme.dart';
import 'package:moaqit/core/localization/app_localizations.dart';

class PermissionBottomSheet extends StatelessWidget {
  final VoidCallback onPermissionsHandled;

  const PermissionBottomSheet({
    super.key,
    required this.onPermissionsHandled,
  });

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onPermissionsHandled,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PermissionBottomSheet(
        onPermissionsHandled: onPermissionsHandled,
      ),
    );
  }

  Future<void> _handlePermissions(BuildContext context) async {
    Navigator.of(context).pop();

    try {
      // Request location
      await Permission.locationWhenInUse.request();
      // Request notification
      await Permission.notification.request();
      // Request exact alarm if on Android
      await Permission.scheduleExactAlarm.request();
    } catch (_) {}

    onPermissionsHandled();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 34),
        decoration: BoxDecoration(
          color: const Color(0xFF0D171F).withValues(alpha: 0.94),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 32,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top pull handle
            Center(
              child: Container(
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Icon + Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.gold.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.security_rounded,
                    color: AppTheme.gold,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.translate('permissionTitle'),
                        style: GoogleFonts.cairo(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        loc.translate('permissionDesc'),
                        style: GoogleFonts.cairo(
                          fontSize: 12.5,
                          color: Colors.white70,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 3 Permission Explain Cards
            _buildPermissionItem(
              icon: Icons.location_on_rounded,
              color: AppTheme.emerald,
              title: loc.isArabic ? 'الموقع الجغرافي (GPS)' : 'Location (GPS)',
              description: loc.translate('permissionLocation'),
            ),
            const SizedBox(height: 10),
            _buildPermissionItem(
              icon: Icons.notifications_active_rounded,
              color: AppTheme.gold,
              title: loc.isArabic ? 'إشعارات الأذان' : 'Prayer Notifications',
              description: loc.translate('permissionNotification'),
            ),
            const SizedBox(height: 10),
            _buildPermissionItem(
              icon: Icons.alarm_on_rounded,
              color: AppTheme.sapphire,
              title: loc.isArabic ? 'المنبهات الدقيقة' : 'Exact Alarms',
              description: loc.translate('permissionAlarm'),
            ),
            const SizedBox(height: 24),

            // Grant Button
            ElevatedButton(
              onPressed: () => _handlePermissions(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.gold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              child: Text(
                loc.translate('grantPermissions'),
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Dismiss Button
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                loc.translate('later'),
                style: GoogleFonts.cairo(
                  fontSize: 13.5,
                  color: Colors.white54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionItem({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 0.8,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: Colors.white60,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
