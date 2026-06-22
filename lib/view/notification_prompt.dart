import 'package:flutter/material.dart';
import 'package:memory_game/constant/color_constant.dart';
import 'package:memory_game/constant/sp_key.dart';
import 'package:memory_game/constant/text_style.dart';
import 'package:memory_game/l10n/app_localizations.dart';
import 'package:memory_game/services/notification_service.dart';
import 'package:memory_game/view/util/extension.dart';
import 'package:memory_game/view/util/widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 初回のみ、OSの通知許可ダイアログを出す前に
/// 「継続しやすくするために通知をオンにしてください」という説明を表示し、
/// 同意が得られたときだけ OS の許可要求へ進む。
///
/// 説明は（同意の有無にかかわらず）一度表示したら二度と出さず、
/// 高齢者にしつこく感じさせないようにする。
Future<void> maybeShowNotificationPrompt(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool(SpKey.notifPrompted.name) ?? false) return;
  await prefs.setBool(SpKey.notifPrompted.name, true);

  if (!context.mounted) return;
  final lang = Localizations.localeOf(context).languageCode;

  final agreed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _NotificationRationaleDialog(),
  );
  if (agreed != true) return;

  final granted = await NotificationService.instance.requestPermission();
  if (granted) {
    await NotificationService.instance.rescheduleReengagement(lang);
  }
}

class _NotificationRationaleDialog extends StatelessWidget {
  const _NotificationRationaleDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      backgroundColor: DefColor.darkBeige,
      insetPadding: EdgeInsets.symmetric(
        horizontal: context.pagePadding,
        vertical: 24,
      ),
      contentPadding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      content: SizedBox(
        width: context.contentWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.notifications_active,
              color: DefColor.orange,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.notifRationaleTitle,
              textAlign: TextAlign.center,
              style: AppText.subheading,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.notifRationaleBody,
              textAlign: TextAlign.center,
              style: AppText.body,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: MyTextButton(
                    text: l10n.notifLater,
                    backColor: DefColor.darkBlue,
                    onPressed: () => Navigator.pop(context, false),
                  ),
                ),
                SizedBox(width: context.sectionGap),
                Expanded(
                  child: MyTextButton(
                    text: l10n.notifEnable,
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
