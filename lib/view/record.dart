import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memory_game/constant/color_constant.dart';
import 'package:memory_game/constant/text_style.dart';
import 'package:memory_game/l10n/app_localizations.dart';
import 'package:memory_game/model/activity_log.dart';
import 'package:memory_game/services/admob.dart';
import 'package:memory_game/state/activity_log_state.dart';
import 'package:memory_game/view/util/extension.dart';
import 'package:memory_game/view/util/widget.dart';

/// 記録画面。
///
/// 連続日数・累計を上部に示し、月カレンダーで「やった日」を埋める。
/// 各日のマスは、その日のクリア回数（レベルを問わない）でヒートマップのように
/// 濃淡をつけ、回数も数字で表示する。
class RecordView extends ConsumerStatefulWidget {
  const RecordView({super.key});

  @override
  ConsumerState<RecordView> createState() => _RecordViewState();
}

class _RecordViewState extends ConsumerState<RecordView> {
  // 表示中の月（その月の1日を保持）。
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  void _changeMonth(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta));
  }

  @override
  Widget build(BuildContext context) {
    final log = ref.watch(activityLogProvider);
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final streak = log.currentStreak(now);
    final total = log.totalClears;
    final activeDays = log.activeDayCount;

    // 翌月（未来）へは進めないようにする。
    final canGoNext = _month.isBefore(DateTime(now.year, now.month));

    return Scaffold(
      backgroundColor: DefColor.lightBeige,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: context.contentMaxWidth),
            child: Column(
              children: [
                _header(context, l10n),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                        horizontal: context.pagePadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: context.sectionGap),
                        _statsRow(context, l10n, streak, activeDays),
                        SizedBox(height: context.sectionGap),
                        _monthNav(context, canGoNext),
                        const SizedBox(height: 8),
                        _weekdayHeader(context),
                        const SizedBox(height: 4),
                        _calendarGrid(context, log, today),
                        if (total == 0) ...[
                          SizedBox(height: context.sectionGap),
                          Text(
                            l10n.recordEmpty,
                            textAlign: TextAlign.center,
                            style: AppText.body,
                          ),
                        ],
                        SizedBox(height: context.sectionGap),
                      ],
                    ),
                  ),
                ),
                const AdmobBannerWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── 上部バー（ホームへ戻る＋タイトル）──
  Widget _header(BuildContext context, AppLocalizations l10n) {
    return Container(
      decoration: const BoxDecoration(
        color: DefColor.surface,
        border: Border(
          bottom: BorderSide(color: DefColor.darkBeige, width: 2),
        ),
      ),
      child: SizedBox(
        height: context.topBarHeight,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
          child: Row(
            children: [
              const HomeButton(),
              SizedBox(width: context.sectionGap),
              Flexible(
                child: Text(
                  l10n.recordTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.heading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 連続日数・のべ日数の2指標 ──
  Widget _statsRow(
      BuildContext context, AppLocalizations l10n, int streak, int activeDays) {
    final gap = context.sectionGap * 0.75;
    // スクロール内（高さ非有界）で stretch を使うため IntrinsicHeight で高さを確定させ、
    // 2枚のカードの高さを揃える。
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _statCard('$streak', l10n.recordStreakLabel, accent: true),
          ),
          SizedBox(width: gap),
          Expanded(child: _statCard('$activeDays', l10n.recordDaysLabel)),
        ],
      ),
    );
  }

  Widget _statCard(String value, String label, {bool accent = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: DefColor.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DefColor.darkBeige, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.tileNumber.copyWith(
              fontSize: 30,
              color: accent ? DefColor.orange : DefColor.darkBlue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: DefColor.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  // ── 月送り ──
  Widget _monthNav(BuildContext context, bool canGoNext) {
    final title = MaterialLocalizations.of(context).formatMonthYear(_month);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _navArrow(Icons.chevron_left, () => _changeMonth(-1)),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.subheading,
          ),
        ),
        _navArrow(
          Icons.chevron_right,
          canGoNext ? () => _changeMonth(1) : null,
        ),
      ],
    );
  }

  Widget _navArrow(IconData icon, VoidCallback? onPressed) {
    final enabled = onPressed != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: enabled ? DefColor.surface : DefColor.none,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: enabled ? DefColor.darkBeige : DefColor.none,
            width: 2,
          ),
        ),
        child: Icon(
          icon,
          size: 28,
          color: enabled ? DefColor.darkBlue : DefColor.gray,
        ),
      ),
    );
  }

  // ── 曜日見出し（端末ロケールに合わせた並び）──
  Widget _weekdayHeader(BuildContext context) {
    final ml = MaterialLocalizations.of(context);
    final first = ml.firstDayOfWeekIndex;
    return Row(
      children: [
        for (int i = 0; i < 7; i++)
          Expanded(
            child: Center(
              child: Text(
                ml.narrowWeekdays[(first + i) % 7],
                style: const TextStyle(
                  color: DefColor.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ── カレンダー本体 ──
  Widget _calendarGrid(BuildContext context, ActivityLog log, DateTime today) {
    final first = MaterialLocalizations.of(context).firstDayOfWeekIndex;
    final daysInMonth = DateUtils.getDaysInMonth(_month.year, _month.month);
    // DateTime.weekday は 月=1..日=7。% 7 で 日=0..土=6 に揃える。
    final firstWeekday = DateTime(_month.year, _month.month, 1).weekday % 7;
    final leading = (firstWeekday - first + 7) % 7;
    final cellCount = leading + daysInMonth;
    final rowCount = (cellCount / 7).ceil();

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      childAspectRatio: 0.92,
      children: [
        for (int i = 0; i < rowCount * 7; i++)
          _buildCell(i, leading, daysInMonth, log, today),
      ],
    );
  }

  Widget _buildCell(int index, int leading, int daysInMonth, ActivityLog log,
      DateTime today) {
    final dayNum = index - leading + 1;
    if (dayNum < 1 || dayNum > daysInMonth) {
      return const SizedBox.shrink();
    }

    final date = DateTime(_month.year, _month.month, dayNum);
    final activity = log.dayOf(date);
    final isToday = date == today;
    final fill = _cellColor(activity);
    final onDark = activity.plays > 0 && activity.clears >= 6;
    final dateColor = onDark ? DefColor.textWhite : DefColor.textMuted;

    return Container(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isToday ? DefColor.select : DefColor.darkBeige,
          width: isToday ? 2.5 : 1,
        ),
      ),
      child: Stack(
        children: [
          // 日付（小さく左上）。
          Positioned(
            top: 3,
            left: 5,
            child: Text(
              '$dayNum',
              style: TextStyle(
                color: dateColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // クリア回数（中央に大きめ）。0 の日は数字を出さない。
          if (activity.clears > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '${activity.clears}',
                  style: TextStyle(
                    color: onDark ? DefColor.textWhite : DefColor.textBlack,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 「クリア回数」に応じたヒートマップ色。
  // やってない日→塗りなし（枠線だけ）、プレイのみ（クリア0）→淡色、回数が多いほど濃く。
  Color _cellColor(DayActivity activity) {
    if (activity.plays == 0) return DefColor.none;
    if (activity.clears == 0) return DefColor.orangeSoft;
    final c = activity.clears;
    final t = c >= 10
        ? 1.0
        : c >= 6
            ? 0.75
            : c >= 3
                ? 0.5
                : 0.28;
    return Color.lerp(DefColor.orangeSoft, DefColor.orangeDeep, t)!;
  }
}
