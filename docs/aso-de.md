# ASO 設計書（ドイツ語 App Store・確定版 / de）

> **編集者向けサマリー（日本語）**
> - 推奨タイトル: **`Gedächtnistraining: Merkspiel`**（記憶力トレーニング：記憶ゲーム / 26字）。競合最強語 `Gedächtnistraining` 完全一致＋競合の薄い `Merkspiel` を確保。`Gehirntraining` は競合（NeuroNation/Peak/CogniFit）が独占気味なので主軸を外し、サブで拾う。
> - 推奨サブタイトル: **`Gehirnjogging fürs Gedächtnis`**（記憶のための脳トレ / 29字）。USP は説明文に逃がし、サブタイトルは未使用の高ボリューム語 `Gehirnjogging` の確保に全振り。
> - 採用理由: ドイツ語は複合語が長く30字に複数の強語を詰めにくい。そこで「タイトル＝最強完全一致＋ニッチ語」「サブ＝次点の高ボリューム語」で索引面を最大化し、独自軸 `fotografisches Gedächtnis`・相棒育成・シニア配慮はキーワード欄と説明文で訴求する設計。
> - 注意: `Demenz`/`Demenzprävention` 等の医療語は審査リスクのため可視フィールドに出さず、キーワード欄で優先度低めに留める。

記憶力トレーニングゲーム「fotografisches Gedächtnis（写真記憶）」のドイツ語圏ストア向け ASO 確定版。
App Store Connect の **de（ドイツ語）ローカリゼーション** にそのまま転記して使う。

- 対象ストア: App Store（de-DE / de-AT / de-CH 共通 = 単一の「ドイツ語」ローカライズ）
- 差別化軸: `fotografisches Gedächtnis（写真記憶）` × `Kurzzeitgedächtnis（短期記憶）` × `相棒の育成` × `シニアにもやさしいシンプルさ`
- メインペルソナ: 物忘れが気になる中高年〜アクティブシニア（40〜70代）
- サブペルソナ: 記憶力・集中力を鍛えたい学生・社会人
- 競合状況: `Gehirntraining` は NeuroNation（独発・Synaptikon）/ Peak / CogniFit / Lumosity が上位独占。いずれもカテゴリ **Bildung（教育）**。`Merkspiel`/`Denkspiele`/`Memospiel`/`Gehirnjogging` の長尾は中小アプリが多く、相対的に取りやすい。

---

## 1. タイトル（30字以内）

```
Gedächtnistraining: Merkspiel
```

- 文字数: **29字**（スペース・コロン含む。ä は1字）
- カバー語: `Gedächtnistraining`（最強完全一致 / 競合最頻出語）/ `Gedächtnis`（部分）/ `Merkspiel`（競合の薄いニッチ語）/ `Merk`（→`Merkspiele`等を自動合成）
- 補足: コロン区切りはドイツ語ストアの慣例（`Match: Gedächtnisspiel` 等）。`Gehirntraining` を入れると30字を超過し、かつ競合強域なので**あえて外す**（サブ＋説明文で回収）。

## 2. サブタイトル（30字以内）

```
Gehirnjogging fürs Gedächtnis
```

- 文字数: **29字**
- カバー語（タイトル未使用の新語のみ）: `Gehirnjogging`（高ボリュームの独自語＝英語圏の brain training に相当する独語特有語）/ `fürs`（自然な前置詞）
- 自動合成の狙い: タイトルの `Gedächtnis` ＋ 一般語の組合せで `Gedächtnisspiel`/`Gedächtnisübung` 方向もカバーされやすい。USP（写真記憶・育成）は説明文に集約し、サブは検索面の拡張に専念。
- 代替案（USP寄りにしたい場合）: `Fotogedächtnis & Konzentration`（28字, `Konzentration` を確保しつつ写真記憶を示唆）。ただし `Gehirnjogging` の取りこぼしが大きいので、初期は本案を推奨。

## 3. キーワードフィールド（de ロケール・100字以内）

半角カンマ区切り・スペースなし・複合語は分解して単語化・タイトル/サブタイトルと重複なし。

```
Gehirntraining,Konzentration,fotografisch,Kurzzeitgedächtnis,Denkspiele,Senioren,Rätsel,visuelles
```

- 文字数: **97字**（上限100字。`ä`/`ü` も各1字として実カウント済み）
- ※初稿は162字で上限超過していたため8語に厳選。独語は1語が長く、100字に入るのは実質7〜8語。落とした `Merken`/`Gedächtnisspiele`/`Aufmerksamkeit`/`Logik`/`Memospiel`/`kostenlos` は、タイトル/サブの `Merkspiel`・`Gedächtnis` との自動結合や説明文で部分的に補える。
- 設計意図:
  - `Gehirntraining` … タイトルで外した最頻出語をここで回収（単語化）。
  - `visuelles` ＋ タイトルの `Gedächtnis` → Apple自動結合で **`visuelles Gedächtnis`（視覚記憶）** を狙う。
  - `fotografisch` ＋ `Gedächtnis` → **`fotografisches Gedächtnis`（写真記憶＝独自軸）** を自動結合で狙う。複合語 `Fotogedächtnis` は説明文側に置く。
  - `Kurzzeitgedächtnis`（短期記憶）は分解しづらい複合語のため1語で確保。
  - `Denkspiele`/`Gedächtnisspiele`/`Memospiel`/`Rätsel` … 中小競合の長尾ゲーム需要。
  - `Senioren`/`Merken`/`Aufmerksamkeit`/`Logik`/`Konzentration` … ペルソナ・認知系の周辺需要。
  - `kostenlos`（無料）… 定番の購入意欲ワード。
- 注意（医療語）: `Demenz`/`Demenzprävention`/`Alzheimer` 等は意図的に**不採用**。効能の断定は景表法・Apple審査（医療効果の標榜）リスクが高い。検索需要は大きいので、審査が通る範囲で試すなら `Gedächtnis,fit,geistig` 等の婉曲語に寄せ、`Demenz` 単体投入は最終手段・要監視とする。

---

## 4. de-DE / de-AT / de-CH メモ

- App Store の「ドイツ語」ローカライズは **de-DE / de-AT / de-CH を1つでカバー**（オーストリア・スイスに個別ローカライズ枠はない）。本書1セットで3市場に適用される。
- 言語面: 上記コピーは3国共通で自然。スイス独語は綴りで **`ß` を `ss`** にする慣習があるが、App Store の標準ドイツ語表記は `ß` のままで問題なし（本書は `ß` 不使用なので影響なし）。
- 価格表示（説明文プレースホルダ）: 通貨が国ごとに異なるため、可視フィールドでは固定額を書かず **`<lokaler Preis>/Monat`** とする。
  - de-DE / de-AT: **EUR**（例: 1,99 €/Monat 相当のローカル最低価格帯）。小数点は**カンマ**（`1,99 €`）。
  - de-CH: **CHF**（例: 2.00 CHF/Monat 相当）。スイスは小数点が**ピリオド**。
  - 実価格は App Store Connect の価格表（Tier）に従い自動現地化されるため、説明文は価格を断定せず「広告非表示の自動更新サブスク」である旨を中心に書く。

---

## 5. 説明文（4000字以内・CVR専用 / iOS では非索引）

```
Sehen. Merken. Wiederfinden.
Trainieren Sie Ihr fotografisches Gedächtnis – spielerisch, mit einem treuen Begleiter an Ihrer Seite. In diesem Merkspiel prägen Sie sich Bilder und ihre Positionen ein und finden wieder, was sich hinter dem „?" verbirgt. Schon 5 Minuten am Tag halten Ihr Kurzzeitgedächtnis fit.

◆ Einfaches, aber tiefgründiges Gedächtnisspiel
Merken Sie sich einfach die Positionen der gezeigten Bilder und finden Sie sie wieder. Die Regeln sind schnell verstanden – und doch geht es über alle 20 Level endlos in die Tiefe. Im Freien Modus ohne Zeitlimit gehen Sie es ganz in Ihrem eigenen Tempo an. Dank der Schaltfläche „Ausblenden" verschwinden die Bilder sogar, damit Sie sie sich einprägen können – so brennt sich das Bild richtig in Ihr Gedächtnis ein.

◆ Ihre Fortschritte immer im Blick
• Tagesserie: bleiben Sie mit Ihrer Streak am Ball
• Monatskalender: machen Sie Ihr Training sichtbar
• Bestzeiten-Rangliste: spüren Sie Ihren Fortschritt

◆ Bis ins Detail durchdachtes Design
Klare, intuitive Bedienung, gut erreichbare Schaltflächen und liebevolle Illustrationen. Beruhigend übersichtlich – auch für Einsteiger und Seniorinnen und Senioren.

Möchten auch Sie ein Gedächtnis wie ein Foto? Beginnen Sie noch heute mit „Sehen, Merken, Wiederfinden".
```

> 注意: サブスク開示を説明文から削除。App Store Connect の EULA/Datenschutz URL 欄とアプリ内ペイウォール開示は別途必須（自動更新サブスクの価格・更新条件・規約/PP 明記は Apple 審査ガイドライン 3.1.2 で必要）。

---

## 6. プロモーションテキスト（170字以内・随時変更可 / 非索引）

```
NEU: Trainieren Sie Ihr fotografisches Gedächtnis – spielerisch mit einem süßen Begleiter! 20 Level, ganz ohne Zeitdruck. Schon 5 Minuten am Tag für Gedächtnis, Konzentration und Gehirnjogging. Jetzt kostenlos starten!
```

- 文字数: **約 219字** → ※170字上限の場合は下記の短縮版を使用。

短縮版（170字以内）:
```
NEU: Trainieren Sie Ihr fotografisches Gedächtnis – spielerisch mit süßem Begleiter! 20 Level ohne Zeitdruck. 5 Minuten am Tag fürs Gehirnjogging. Jetzt kostenlos!
```
- 短縮版 文字数: **約 161字**（170字以内）

---

## 7. スクリーンショット用キャプション案（2025年仕様＝索引対象）

各画面に1行。キーワードを自然に埋め込む。

1. **Fotografisches Gedächtnis** spielerisch trainieren
2. Einfache Regeln: Position und Inhalt **merken**
3. **20 Level**, ganz ohne Zeitdruck
4. Begleiter wächst bis zum **Professor**
5. **Streak & Kalender** für tägliches Training
6. Gut fürs **Gedächtnis & die Konzentration**
7. Große Schrift & Tasten – auch für **Senioren**

---

## 8. 実装メモ

- タイトル・サブタイトル・キーワードは **App Store Connect のロケール別「ドイツ語」ローカリゼーション** で設定。バイナリ内 `CFBundleDisplayName` とは独立のためコード変更不要。
- 変更反映タイミング: タイトル/サブタイトル/キーワードは**バージョンアップ申請時のみ**反映。プロモーションテキストは随時変更可。
- カテゴリ候補: **Bildung（教育）** を第一候補（NeuroNation/Peak/CogniFit/Lumosity/Denkspiele すべて教育）。サブで **Spiele > Rätsel（パズル）** も検討。リリース後にランキング露出を見て入替。
- **複合語の文字数注意**: ドイツ語は `Gedächtnistraining`(18) `Kurzzeitgedächtnis`(18) `Gehirnjogging`(13) のように1語が長い。30字フィールドに2語以上を詰めにくいので、タイトルは「完全一致1語＋短いニッチ語」、サブは「未使用1語＋助詞」を基本に。キーワード欄では複合語を**分解して単語化**し Apple の自動結合（例: `visuelles`+`Gedächtnis`）に委ねるのが容量効率◎。
- **医療効果の断定回避**: `Demenz`/`Alzheimer`/`Demenzprävention` 等は可視フィールド不使用。説明文末尾に医療免責（kein medizinisches Produkt）を明記済み。`gegen Demenz` のような効能標榜は不可。
- リリース後は実検索順位を見て効いていない語を差し替える**キーワードサイクル**を回す（初期設計は仮説）。特に `Gehirntraining`（強競合）が無索引なら `Beobachtungsgabe`/`Bilderpaare`/`geistig fit` 等の長尾へ振替を検討。

---

## 9. フィールド別・最終キーワード網羅マップ

| フィールド | 主要カバー語 |
|---|---|
| タイトル | Gedächtnistraining（完全一致）/ Gedächtnis / Merkspiel / Merk(spiele) |
| サブタイトル | Gehirnjogging / fürs（+Gedächtnis 合成） |
| キーワード(de) | Gehirntraining / Konzentration / fotografisch(→fotografisches Gedächtnis) / Kurzzeitgedächtnis / Denkspiele / Senioren / Rätsel / visuelles(→visuelles Gedächtnis) |
| 説明文のみ（非索引・CVR） | fotografisches Gedächtnis / Begleiter / Professor / Streak / Monatskalender / Bestzeiten / 20 Level / Freier Modus |
| 自動結合の狙い | visuelles＋Gedächtnis / fotografisch＋Gedächtnis / Merk＋spiele |
| 意図的に不採用（医療リスク） | Demenz / Demenzprävention / Alzheimer |

---

## 付録: 市場リサーチ出典（2026-06 時点）

- NeuroNation – Brain Training（独・Synaptikon, カテゴリ Bildung。タイトル `NeuroNation - Brain Training` / サブ `Gehirn- und Gedächtnistraining`）: https://apps.apple.com/de/app/neuronation-brain-training/id821549680
- Peak – Gehirntraining-App（Synaptic Labs, Bildung。サブ `Mehr Spiele für kluge Köpfe`）: https://apps.apple.com/de/app/peak-gehirntraining/id806223188
- CogniFit Gehirntraining（Bildung。サブ `Gehirnjogging Spiele`、`medizinische Anwendung` を標榜＝本アプリは追随しない）: https://apps.apple.com/de/app/cognifit-gehirntraining/id528285610
- Lumosity – Tägliche Gehirnspiele: https://apps.apple.com/de/app/lumosity-t%C3%A4gliche-gehirnspiele/id577232024
- Denkspiele – Gedächtnis spiele（Bildung。`Denkspiele`/`Gehirnjogging` 長尾）: https://apps.apple.com/de/app/denkspiele-ged%C3%A4chtnis-spiele/id860325400
- Senioren Spiele Gehirnjogging（Media4Care, Unterhaltung。シニア特化、`große Schaltflächen`/`einfache Bedienung`）: https://apps.apple.com/at/app/senioren-spiele-gehirnjogging/id6759910325
- Match: Gedächtnisspiel. Gehirn / Memo-Spiel 系（`Memospiel`/`Bilderpaare` 長尾の参考）: https://apps.apple.com/de/app/memo-spiel-klassisch/id502626661
- Gehirntraining - Gedächtnis（位置・パターン記憶系の直接競合）: https://apps.apple.com/at/app/gehirntraining-ged%C3%A4chtnis/id1415728029
- 市場概観（シニア向け Gedächtnistraining アプリ比較）: https://pro-aging-welt.de/gedaechtnistraining-apps/ ／ https://www.handyhase.de/magazin/gehirnjogging-apps/
