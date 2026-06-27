# App Store Connect 提出前セットアップ（実施記録・レビュー用）

最終更新: 2026-06-26 / 実施者: Claude（fastlane API + ブラウザ操作）

このドキュメントは、iOS版「記憶力トレーニング-短期記憶の脳トレゲーム」（Memory Blink）を
**App Review に提出できる状態**にするために行った ASC 各種設定の**確定値**と、
**ユーザ対応が必要な残件**をまとめたもの。値はすべて ASC に反映済み（下記「再確認コマンド」で検証可）。

## 対象アプリ識別子

| 項目 | 値 |
|---|---|
| App 名（ja/主要ロケール） | 記憶力トレーニング-短期記憶の脳トレゲーム |
| Apple ID | `6783421578` |
| Bundle ID | `com.skcreation.memorygame` |
| SKU | `memorygame` |
| 主要言語（Primary Language） | **英語（en-US）** ← `ja` から変更。グローバルのフォールバック＆審査が円滑になるため。日本語ロケールは完全ローカライズ済みなので日本のリスティング表示は不変。 |
| バージョン | 1.0（build `1` = `1.0.0`） |
| バージョン状態 | `PREPARE_FOR_SUBMISSION`（リリース方法=手動 `MANUAL`） |

---

## ✅ 今回設定した値（反映済み）

### 1. メタデータURL（全9ロケール） — fastlane API
- **プライバシーポリシーURL**（App情報ローカリゼーション）
  - `ja` → `https://skcreation-legal.pages.dev/memory-game/ja/privacy`
  - `en-US` ほか7ロケール（es-MX/ru/fr-FR/de-DE/zh-Hans/ko/hi） → `https://skcreation-legal.pages.dev/memory-game/en/privacy`（英語版を流用）
- **サポートURL**（バージョンローカリゼーション）= お問い合わせフォーム
  - `ja` → `https://forms.gle/Xa8C1A8jMhm4WVCB9`
  - その他8ロケール → `https://forms.gle/4c6knQW3qB7yEWMt8`（英語フォーム）
  - マーケティングURLは任意のため未設定。
- 出典: [[legal-site-deploy]]（URL定義は `lib/constant/app_links.dart`）。

### 2. 年齢評価 / コンテンツ権利 / IDFA — fastlane API
- **年齢評価 = 4+**（`appStoreAgeRating=FOUR_PLUS`）。年齢評価アンケートの全コンテンツ項目を `NONE` で確定。
  能力系ブールは **`advertising=true`**（AdMob 広告を表示するため。Apple定義「アプリ内での商品/サービスの有料プロモーション＝バナー/動画/プレイアブル等」に該当。Advertising は 4+ カテゴリのため**評価は4+のまま上がらない**）、
  それ以外（ageAssurance/gambling/healthOrWellnessTopics/lootBox/messagingAndChat/parentalControls/unrestrictedWebAccess/userGeneratedContent）は全て `false` で確定。
  - `healthOrWellnessTopics=false` は妥当（脳トレ訴求はあるが、アプリ自体は「セルフケア/ライフスタイルの推奨」を提供しないため非該当）。
  - **2026-06-26 修正**: 当初 `advertising=false` だったが広告表示の実態と矛盾するため `true` に訂正（読み取り専用検証は `fastlane/asc_state.rb`、本文と一致）。
- **コンテンツ権利 = `DOES_NOT_USE_THIRD_PARTY_CONTENT`**（第三者コンテンツ非使用。広告は「コンテンツ」に当たらない）。
- **IDFA**: ATT 未実装・`NSUserTrackingUsageDescription` なし → **IDFA 不使用**。よって IDFA アテステーション不要。
  AdMob は非パーソナライズ広告（IDFAトラッキングなし）。

### 3. 価格 = 無料 — fastlane API
- `appPriceSchedule` を作成。基準地域 `USA`、無料プライスポイント（customerPrice `0.0`）。全175地域に無料で配信。

### 4. ビルド添付 + 輸出コンプライアンス — fastlane API + Info.plist
- バージョン1.0 に **build `1`（1.0.0, id `a6a8726d…`, processingState=VALID）** を添付。
- **輸出コンプライアンス**: build `usesNonExemptEncryption=false`（除外対象の標準暗号のみ）。
  併せて [ios/Runner/Info.plist](ios/Runner/Info.plist) に `ITSAppUsesNonExemptEncryption=false` を追記
  （**次回以降のビルドは自動で輸出コンプライアンス回答済みになる**）。

### 5. App Review に関する情報 — fastlane API
- 連絡先: 氏名 `Keisuke Inazawa` / メール `sk.createapp@gmail.com` / 電話 = `ASC_REVIEW_PHONE`（個人情報のため本書では非掲載）。
- **サインイン不要**（`demo_account_required=false`）。
- レビューメモ（要旨）: 全年齢向けの短期視覚記憶トレーニングゲーム。**ログイン/アカウント/デモ資格情報は不要**で全機能利用可。
  「プレミアム（広告なし）」は月額¥200の自動更新サブスク（`premium_monthly`）で**広告非表示のみ**を提供しゲーム機能は全て無料。
  無料ユーザには AdMob 広告（バナー/インタースティシャル/App Open）を表示。**ATTプロンプトは出さず IDFA トラッキングなし**。サブスク権利は RevenueCat 管理。

### 6. サブスクリプション — fastlane API + ブラウザ
- グループ「Premium」に**サブスクグループ・ローカリゼーション**を追加（`ja`=「プレミアム」, `en-US`=「Premium」）。
  → これで「Monthly Premium」が `MISSING_METADATA` を解消し **`READY_TO_SUBMIT`** へ。
- 商品 `premium_monthly`（自動更新・1ヶ月・**全175地域を単一ティア10016に統一**）。審査用スクショ=COMPLETE、ja表示名「プレミアム（広告なし）」。
  - **価格改定（2026-06-27）**: 当初は ¥200 基準だが海外が円換算で日本より2〜4割安かったため、海外アンカーを **US$1.49 相当（ティア10016）に底上げ**。同ティアで日本は **¥200 据え置き**、USA=$1.49 / GBP=£1.49 / EUR=€1.49 / KRW=₩1,200 等。155地域↑・日本据え置き・19地域（中国¥8→¥6 CNY 等、元設定が単一ティアでなかった分）↓。`subscriptionPrices` を地域ごとに `preserveCurrentPrice=false` で個別POST（`preserveCurrentPrice` は既存購読者の据え置き用で、地域カスケードはしないため一括設定は不可）。
- **バージョン1.0 の「アプリ内購入とサブスクリプション」に Monthly Premium を添付済み**（アプリ初版と同時審査に載せる構成）。

### 7. App プライバシー（データ収集の栄養ラベル） — ブラウザ（ASC Web UI / 公開済み）
> Apple 公式 API に該当エンドポイントが無く fastlane 設定不可のため、接続中Chromeで ASC Web UI を操作して設定し**公開済み**。
> 申告方針: AdMob=非トラッキング広告、RevenueCat=購入。**全データ「ユーザにリンクされない」「トラッキングなし」**。

| データタイプ | カテゴリ | 目的 | リンク | トラッキング |
|---|---|---|---|---|
| デバイスID | ID | サードパーティ広告, アナリティクス | されない | なし |
| おおよその場所 | 位置情報 | サードパーティ広告, アナリティクス | されない | なし |
| 製品の操作 | 使用状況 | アナリティクス, アプリの機能 | されない | なし |
| 広告データ | 使用状況 | サードパーティ広告 | されない | なし |
| クラッシュデータ | 診断 | アプリの機能 | されない | なし |
| パフォーマンスデータ | 診断 | アプリの機能 | されない | なし |
| その他の診断データ | 診断 | アプリの機能 | されない | なし |
| 購入履歴 | 購入 | アプリの機能, アナリティクス | されない | なし |

- 由来: AdMob（`lib/services/admob.dart`）= デバイスID/おおよその場所/製品の操作/広告データ/クラッシュ/パフォーマンス/その他診断。
  RevenueCat・StoreKit（[[premium-plan-concept]]）= 購入履歴。Firebase等の自前分析は未導入。
- プロダクトページ・プレビュー: 全項目が「**ユーザに関連付けられないデータ**」に分類。

---

## ✅ 有料App契約・銀行・税務（2026-06-26 確認済み＝完了）

ビジネス→契約（Agreements, Tax, and Banking）を確認したところ**すべて有効**で、追加入力は不要だった:
- **有料アプリ契約（Paid Applications Agreement）= 有効**（2026/6/11–2027/5/11、全地域）。
- 無料アプリ契約 = 有効。
- **銀行口座** = Rakuten Bank Ltd (4868) / JPY→USD / 有効。
- **納税フォーム** = U.S. Certificate of Foreign Status of Beneficial Owner・U.S. Form W-8BEN（2026/6/14送信）/ 有効。
- コンプライアンス（デジタルサービス法、27地域）= 有効。

→ **サブスクを含む初版の提出ブロッカーにはならない**。

### 8. 説明文への法務リンク追記 + カスタムEULA（2026-06-26 追加） — fastlane API
Apple ガイドライン 3.1.2（自動更新サブスク）対応で、**説明文とEULAの双方**に利用規約/プライバシーポリシーへの動作するリンクを記載。
- **各言語の説明文（概要）末尾**に、ロケール別ラベルで**利用規約＋プライバシーポリシー**のURLを追記（[fastlane/metadata/<locale>/description.txt](fastlane/metadata) が源泉。ASC にも反映済み）。
  - リンク先ページは ja/en の2系統（非ja言語は en ページ）。ラベルのみ各言語化（例 de=Nutzungsbedingungen/Datenschutzerklärung, ko=이용약관/개인정보처리방침）。
  - **日本語の説明文のみ「特定商取引法に基づく表記」URL も追記** → `https://skcreation-legal.pages.dev/tokushoho`（skcreation 共通の特商法ページ。IAP/サブスクにも適用）。
- **カスタムEULA を新規作成**（従来は Apple 標準EULA）。[fastlane/metadata/eula.txt](fastlane/metadata/eula.txt) が源泉。**EN/JA 併記**で、利用規約・**プライバシーポリシー**（ユーザ要望）・（日本語側に）特商法のURL＋自動更新サブスクの定型文言を含む。**全175地域**に適用。
- 確認URL（全て 200）: `…/memory-game/{ja,en}/{terms,privacy}` と `…/tokushoho`。

| 対象 | 利用規約 | プライバシーポリシー | 特商法 |
|---|---|---|---|
| 日本語 説明文 / EULA(ja節) | `…/memory-game/ja/terms` | `…/memory-game/ja/privacy` | `…/tokushoho` |
| その他8言語 説明文 / EULA(en節) | `…/memory-game/en/terms` | `…/memory-game/en/privacy` | — |

### 9. 価格関連ワードの削除（2026-06-26） — fastlane API
Apple は**メタデータ（キーワードを除く）に価格訴求語（"無料"/"Free" 等）があるとリジェクト**するため、該当箇所を削除/言い換え:
- **全9言語の プロモーション用テキスト 末尾の価格訴求を削除**（ja「まずは無料で。」/ en「Free to start.」/ es「¡Gratis!」/ fr「Gratuit.」/ de「Jetzt kostenlos!」/ ru「Начните бесплатно!」/ ko「먼저 무료로 시작하세요.」/ zh「先免费试试！」/ hi「मुफ़्त शुरू करें!」）。
- **en/hi の説明文の "Free Mode"/"फ्री मोड"**（＝時間無制限モードの意。価格ではないが誤検知回避）を価格中立に言い換え（「時間無制限で、自分のペースで」相当）。zh は元々 "自由模式" で価格語なし＝据え置き。
- **カスタムEULA** の "free"/"無料" を「広告により運営」「サブスクなしで全機能利用可」に言い換え。
  - ただし「料金は購入確定時に Apple ID に請求…」等の**自動更新サブスクの課金開示は Apple 必須のため保持**（これは価格訴求ではない）。
- 検証: name / subtitle / promo / description / EULA すべて価格語なしを確認。
- **キーワード（keywords）はユーザ指示により対象外**（非表示フィールドで Apple も価格語を許容。en/zh/ko/ja/fr に "free" 系が残るが意図的）。

## ⏳ 残件（提出前にこれだけ）

1. **スクリーンショット（必須・未設定）** ← ユーザが用意/撮影
   - このアプリは **iPhone+iPad ユニバーサル**（`TARGETED_DEVICE_FAMILY=1,2`）。**iPhone と iPad の両方**が必要。
   - iPhone スロットは **6.5インチ**: `1242×2688` または `1284×2778`px（6.9インチ `1320×2868` でも可）。
   - iPad は 13インチ `2064×2752` または 12.9インチ `2048×2732`px。
   - 各サイズ最低1枚（最大10枚、先頭3枚がインストールシート表示）。
   - 撮影用シードは worktree `screenshot-seed`（`lib/domain/screenshot_seed.dart`, `kScreenshotSeed=true`）に用意済み。
     シミュレータ: iPhone 16 Pro Max / iPad Pro 13-inch(M4) が利用可。**撮影後はシードを戻すこと**（同ファイルの注意書き参照）。
2. **最終提出** ← スクショ追加後
   - ASC のバージョン1.0 画面右上「**審査用に追加**」→ レビュー提出。本タスクでは**自動提出はしていない**（外部公開操作のため）。
   - 有料App契約は有効なので、サブスク `premium_monthly` を含めたまま初版提出できる。

---

## 再確認コマンド（状態の検証）

```sh
cd /Users/user/work/memory_game
export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
set -a; source /Users/user/work/meal-plan/fastlane/.env; set +a
export ASC_KEY_FILEPATH="/Users/user/work/meal-plan/fastlane/private_keys/AuthKey_2Y64997894.p8"
/Users/user/.local/share/mise/installs/ruby/3.3.11/bin/ruby fastlane/asc_state.rb
```
> `fastlane/asc_state.rb` は**読み取り専用**の検証スクリプト（無害・再実行可）。認証情報の在処は [[ios-asc-distribution]] と同じ。
> 設定の書き込みは fastlane API（spaceship）とブラウザ操作で実施済み（一度きりの作業スクリプトは削除済み）。

## 確定状態スナップショット（2026-06-26 時点）

```
VERSION 1.0  state=PREPARE_FOR_SUBMISSION  releaseType=MANUAL
build attached = a6a8726d (1.0.0, VALID)
price = 0.0 (Free, 175地域)
ageRating = FOUR_PLUS
contentRights = DOES_NOT_USE_THIRD_PARTY_CONTENT
subscription premium_monthly = READY_TO_SUBMIT（バージョンに添付済み）
subscription price = 全175地域 ティア10016（JPN ¥200 / USA $1.49）※2026-06-27 改定
appAvailability = 全175地域配信（除外なし。v2リソース未作成＝デフォルト全地域）
App プライバシー = 公開済み（全データ「リンクされない/トラッキングなし」）
privacyPolicyUrl / supportUrl = 全9ロケール設定済み
審査連絡先 = 設定済み（サインイン不要）
有料App契約/銀行/税務 = 有効（確認済み）
残: スクリーンショット / 最終提出
```

## 判断・前提メモ
- **サポートURLにお問い合わせフォーム（Googleフォーム）を採用**。専用サポートページが無いため。変更したい場合は
  `fastlane/metadata/<locale>/` に `support_url.txt` を置くか ASC で直接編集。
- **非ja/en ロケールのプライバシーポリシーは英語版URLを流用**（ローカライズ版ページが未作成のため）。法務ページを各言語化する場合は [[legal-site-deploy]] を更新。
- **おおよその場所**を申告に含めたのは Google の AdMob プライバシー開示ガイダンスに準拠したもの（過小申告回避の保守側）。
  位置情報パーミッションは要求していないため実質IPベース。気になる場合は ASC で当該データタイプを外して再公開可。
- App プライバシー・年齢評価は**いつでも編集→再公開**できる（不可逆ではない）。
