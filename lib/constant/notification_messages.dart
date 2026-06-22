// 再エンゲージ通知（しばらく起動がないときに送るお誘い）に使う文言集。
//
// 高齢者の毎日の習慣づくりを後押しするため、急かさず・責めず・やさしい
// トーンの一言を約50種類用意し、予約のたびにランダムで選ぶことで、
// 毎回同じ通知にならないようにする。
//
// result_messages.dart と同様、対応言語ぶんを Dart 側に持ち、未対応の言語は
// 英語へフォールバックする（通知はバックグラウンドで組み立てるため、
// AppLocalizations ではなくこの定数から取得する）。
class NotificationMessages {
  const NotificationMessages._();

  /// 指定言語のお誘い一言（通知タイトル用）の一覧を返す。
  static List<String> nudges(String languageCode) =>
      _nudges[languageCode] ?? _nudges['en']!;

  /// 指定言語の行動喚起（通知本文用）を返す。
  static String cta(String languageCode) => _cta[languageCode] ?? _cta['en']!;

  static const Map<String, List<String>> _nudges = {
    'ja': _ja,
    'en': _en,
  };

  static const Map<String, String> _cta = {
    'ja': 'タップして脳トレを始めましょう',
    'en': 'Tap to start your brain training',
  };

  // ---------------------------------------------------------------------------
  // 日本語
  // ---------------------------------------------------------------------------
  static const List<String> _ja = [
    '今日も脳トレしませんか？',
    '写真記憶でひとやすみしましょう',
    '毎日の脳の体操、はじめましょう',
    '今日の1問、いかがですか？',
    '少しの時間で記憶力アップ',
    '脳のウォーミングアップの時間です',
    '今日も頭をスッキリさせましょう',
    'ちょっと一息、記憶トレーニング',
    '記憶力、今日も鍛えましょう',
    '今日もコツコツ続けましょう',
    'すきま時間に脳トレを',
    '今日の調子はいかが？1問どうぞ',
    '毎日続けると記憶力が育ちます',
    '今日も写真記憶で脳活しましょう',
    '1日1回、楽しく脳トレ',
    '今日の脳トレ、お待ちしています',
    '頭の体操で気分もスッキリ',
    '続ける力が記憶を伸ばします',
    '今日も新しい記録をめざしましょう',
    'ほんの少し、脳に刺激を',
    '記憶のトレーニングを再開しましょう',
    'お久しぶりです、また遊びましょう',
    'そろそろ脳トレの時間です',
    '今日もあなたの記憶力に挑戦',
    '楽しく続けて、もの忘れ対策',
    '一日のはじまりに脳トレを',
    '寝る前のひと脳トレはいかが？',
    '今日も記憶力みがきましょう',
    'コツコツが記憶力の近道です',
    '今日も楽しくトレーニング',
    '脳に栄養、記憶のトレーニング',
    '今日もあと1問、続けましょう',
    'きょうの脳トレ、お忘れなく',
    '続けるほど冴えていきます',
    '記憶力チャレンジの時間です',
    '今日も元気に脳トレしましょう',
    '少しの習慣が大きな力に',
    '今日の脳トレで気分転換',
    'また会えてうれしいです、1問どうぞ',
    '今日も一緒に脳トレしましょう',
    '写真記憶で頭の体操',
    '今日も記憶のトレーニングを',
    'ひと休みに脳トレはいかが？',
    '毎日の積み重ねが記憶を育てます',
    'さあ、今日の脳トレを始めましょう',
    '今日も笑顔で脳トレ',
    '記憶力、まだまだ伸びますよ',
    '今日も1問チャレンジしましょう',
    '続けることが何よりの脳トレ',
    '今日もあなたの挑戦を待っています',
  ];

  // ---------------------------------------------------------------------------
  // English
  // ---------------------------------------------------------------------------
  static const List<String> _en = [
    "Time for today's brain training?",
    'Take a break with a memory game',
    "Let's exercise your brain today",
    'How about one quick puzzle?',
    'Boost your memory in just a minute',
    'Time to warm up your brain',
    'Freshen up your mind today',
    'A little memory training awaits',
    "Let's train your memory today",
    'Keep it up, one day at a time',
    'How about a quick brain workout?',
    'How are you today? One puzzle awaits',
    'Daily practice grows your memory',
    'Keep your mind sharp today',
    'One round a day, just for fun',
    'Your brain training is waiting',
    'Clear your mind with a puzzle',
    'Consistency builds a strong memory',
    'Aim for a new record today',
    'Give your brain a little spark',
    "Let's get back to training",
    "Welcome back! Let's play again",
    "It's time for some brain training",
    'Challenge your memory today',
    'Stay sharp, keep forgetfulness away',
    'Start your day with a brain workout',
    'How about a puzzle before bed?',
    "Let's polish your memory today",
    'Small steps lead to a sharp mind',
    'Have some fun training today',
    'Feed your brain with a puzzle',
    'Just one more round today',
    "Don't forget today's brain training",
    'The more you play, the sharper you get',
    'Time for a memory challenge',
    "Let's train your brain today",
    'A small habit, a big difference',
    'Refresh yourself with a puzzle',
    'Great to see you — one puzzle?',
    "Let's train together today",
    'Exercise your mind with a memory game',
    'Time for a little memory training',
    'A puzzle for your break?',
    'Daily practice nurtures your memory',
    "Come on, let's start today's training",
    'Keep smiling and keep training',
    'Your memory can still grow',
    "Let's try one puzzle today",
    'Keeping at it is the best brain training',
    'Your challenge is waiting today',
  ];
}
