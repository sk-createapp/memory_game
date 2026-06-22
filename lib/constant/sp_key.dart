enum SpKey {
  //レベルごとの情報保存用
  levelInfos,

  //ゲーム情報用
  gameInfo,

  //継続記録（日付別の活動ログ）用
  activityLog,

  //通知の許可ダイアログを表示済みか
  notifPrompted,

  //通知が有効か（OS許可が得られたか）
  notifEnabled,

  //ストアレビュー依頼を最後に出した時刻（millisecondsSinceEpoch）
  reviewLastRequested,

  //ストアレビュー依頼を出した累計回数
  reviewRequestCount,

  //プレミアム（広告非表示サブスク）の権利を保持しているか（端末キャッシュ）
  isPremium,

  //プレミアムのペイウォールを最後に表示した時刻（millisecondsSinceEpoch）
  paywallLastShown,

  //プレミアムのペイウォールを表示した累計回数
  paywallShownCount,

  //効果音（操作音・結果音）が有効か
  soundEnabled,

  //前回プレイしたレベル（次回起動時に選択状態を復元する）
  lastPlayedLevel,
}
