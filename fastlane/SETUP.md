# App Store Connect メタデータ投入手順（実行済み・再現用）

`docs/aso-*.md` の確定ASOを `fastlane/metadata/<locale>/*.txt` に展開し、`deliver` で ASC に投入する。
※ `fastlane/README.md` は `fastlane` 実行のたびに自動再生成され上書きされるため、手順はこの `SETUP.md` に置く。

## 投入状況（2026-06 実行）
- ✅ 全9言語の **サブタイトル / キーワード / 説明文 / プロモーション** … 投入済み
- ✅ 英語以外8言語の **アプリ名** … 投入済み
- ✅ カテゴリ（EDUCATION / HEALTH_AND_FITNESS）、著作権、審査連絡先 … 投入済み
- ✅ **英語(en-US)のアプリ名** … `Short Term Memory: Brain Game` で投入済み（当初案 `Memory Games: Brain Training` は重複のため変更）。
- ❌ スクショ・バイナリ・価格・サブスク(IAP)・年齢制限・プライバシー表示 … 対象外（ASC UIで設定）

## 認証情報の在処（このアカウントで実績あり）
- APIキー: `/Users/user/work/meal-plan/fastlane/private_keys/AuthKey_2Y64997894.p8`（同一Apple アカウント）
- `key_id` / `issuer_id` / `ASC_REVIEW_PHONE`: `/Users/user/work/meal-plan/fastlane/.env`
- 審査連絡先（氏名/メール）: `meal-plan/fastlane/metadata/review_information/` から流用（このリポでは `.gitignore` 済み＝コミットしない）

## 実行コマンド（実際に成功した手順）
```sh
export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8          # ★必須: UTF-8でないとマルチバイトで落ちる
set -a; source /Users/user/work/meal-plan/fastlane/.env; set +a
export ASC_KEY_FILEPATH="/Users/user/work/meal-plan/fastlane/private_keys/AuthKey_2Y64997894.p8"  # 絶対パス
cd /Users/user/work/memory_game
fastlane upload_metadata
```

## ハマりどころ（解決済み）
1. **`invalid byte sequence in US-ASCII`** → `LANG`/`LC_ALL` を `en_US.UTF-8` に。
2. **`No data` (fetch_app_store_review_detail)** → 新規バージョンは Review Detail 未作成。`app_review_information`（電話＝ENV、氏名/メール＝review_information/*.txt）を渡して初期化（Fastfile対応済み）。
3. **`name ... already being used`** → アプリ名はグローバル一意。英語名が重複。一意名にするまで `en-US/name.txt` は置かない。

## 英語名を投入する手順（一意な名前確定後）
```sh
echo -n "決めた一意な英語名" > fastlane/metadata/en-US/name.txt
# 上のexport群を実行後:
fastlane upload_metadata
```
重複していれば再度 `already being used` エラーになる（＝別名を試す）。
