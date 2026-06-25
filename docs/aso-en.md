# ASO Plan — English App Store (Final)

> **編集者向けサマリー（日本語）**
> - 推奨タイトル: **`Memory Games: Brain Training`**（25字）＝「メモリゲーム（完全一致の最強需要語）」＋「ブレイントレーニング（脳トレの定番検索語）」。米国ストアで実需要が最も太い2語を両取りする構成。
> - 推奨サブタイトル: **`Photographic Memory & Focus`**（27字）＝差別化軸の「写真記憶（photographic memory）」とタイトル未使用の「focus（集中力）」を補完。ニッチで競合が弱い photographic memory を可視フィールドに置くのが肝。
> - キーワード欄は seniors / visual / spatial / concentration / recall など、競合が弱いロングテールで100字を埋め切る。dementia 等の医療断定語は審査リスクのため**入れない**方針（注意書きあり）。
> - 想定カテゴリ: **Education**（大手 Lumosity/Elevate/Memory Match が採用）。サブで Puzzle も検討。

英語圏 App Store（主に米国 / en、二次的に en-GB・en-AU）向けの ASO 確定版。App Store Connect の **English (U.S.) ローカリゼーション** にそのまま転記して使う。

- 対象ストア: App Store（United States 中心 / English）
- 差別化軸: `photographic memory (camera eye)` × `short-term visual memory` × `cute animal buddy growth`
- メインペルソナ: 物忘れが気になる中高年〜アクティブシニア（brain training / brain games for seniors）
- サブペルソナ: 記憶力・集中力・ワーキングメモリを鍛えたい学生・社会人

---

## 1. Title (≤ 30 chars)

```
Memory Games: Brain Training
```

- Character count: **28** (incl. space + colon)
- Covers: `Memory`, `Memory Games` (exact match), `Brain`, `Brain Training`, `Games`, `Training`
- なぜこれか: 競合（Lumosity「Brain Training Games」/ Memory Match「Brain Training, Memory Games」/ Elevate「Brain Training Games」）が示す通り、米国の太い実需要は **memory games** と **brain training** の2フレーズ。両方を完全一致で抱える。「photographic」はニッチでサブタイトル側に置き、タイトルは王道ボリュームを取りに行く。

## 2. Subtitle (≤ 30 chars)

```
Photographic Memory & Focus
```

- Character count: **27**
- Covers (title 未使用の新語のみ): `Photographic`, `Photographic Memory`, `Focus`
- Apple は title × subtitle を自動結合するため、`Memory`(title) + `Photographic`(subtitle) などの組合せも索引対象。`Brain`(title) + `Focus`(subtitle) で「brain focus」系もカバー。
- 差別化の核 **photographic memory** を可視フィールドに置くのが狙い。競合の同名アプリ（"Photographic Memory Games"）は存在するが、上位大手はこの語を取りに来ていないため、相対的にチャンスが残る。

## 3. Keyword Field (English U.S. locale, ≤ 100 chars)

半角カンマ区切り・スペースなし。単数形のみ（Apple が複数形を自動マッチ）。title/subtitle と重複させない。

```
visual,spatial,concentration,recall,senior,puzzle,brain teaser,working memory,attention,test,free
```

- Character count: **97 字**（上限100字。`wc -m` 実カウント済み）
- 設計意図:
  - `visual` / `spatial` … `memory`(title) と自動結合し **visual memory** / **spatial memory** を狙う。
  - `concentration` / `attention` / `focus`(subtitle) … 集中力クラスタ。
  - `recall` / `test` … `memory test` / `memory recall` を自動合成。
  - `senior` … 米国の「brain games for seniors」需要（低難度ロングテール）。複数形 seniors も自動マッチ。
  - `brain teaser` / `working memory` … 2語フレーズ。Apple は語に分解して再結合するため、`brain`(title)＋`teaser`、`working`＋`memory`(title) なども拾う。
  - `puzzle` … カテゴリ周辺の関連需要（memory puzzle）。`mind` / `card` は字数の都合で本欄から外し、ES-Mexico 拡張枠に回す（下記 §4）。
  - `free` … 無料訴求の定番。
- 注意: 医療・症状の断定語（`dementia` / `Alzheimer` / `ADHD` / `cognitive decline`）は**意図的に不採用**。審査（医療効果の暗示）と将来の表現リスクを避けるため。順位が伸び悩んだ場合のみ `cognitive` / `memory loss` などを慎重にテスト（下記 実装メモ参照）。

## 4. 二次ロケール / 関連キーワードのメモ

- **en-GB / en-AU の綴り差**: 本アプリのキーワードは綴り差の影響をほぼ受けない（`memory` `focus` `concentration` `recall` などは英米共通）。`practice`(米) / `practise`(英) のような差は今回の語彙に出ないため、英国・豪州ストアでも **同一キーワードで流用可**。`senior`(米) は英国でも通用するが、英国では「pensioner」「older adults」表現も一般的——必要なら en-GB ロケールの keyword 欄に `pensioner` を1語足す余地あり（任意）。
- **米国ストアの隠れ枠**: 米国 App Store は **Spanish (Mexico)** ロケールのキーワードも索引する。ここに英語の追加ロングテール（例: `mind,card,eidetic,photographic memory game,attention span,brain exercise,memory improvement,grid,tile`）を入れると、実質 200 字に拡張できる（重複を避けて配置）。スペイン語話者向けの真面目な ES 対応をしないなら、この枠を「英語キーワードの拡張領域」として使うのが定石。
- **同義語の取りこぼし防止**: `camera eye`（写真記憶の俗称）は description / screenshot caption 側で自然に登場させ、ブランド語として浸透を狙う（keyword 欄には字数の都合で未収録）。

---

## 5. Description (≤ 4000 chars / CVR copy — not indexed on iOS)

冒頭3行が勝負。サブスク自動更新の開示は Apple ガイドライン 3.1.2 で必須。

```
See it. Remember it. Find it.

Train your "photographic memory" the fun way — a memory game that sharpens short-term visual memory, focus, and concentration in just 5 minutes a day. Memorize what's on the grid, then recall where it was hidden behind the "?". Simple to learn, deeply rewarding to master.

◆ Made for everyone — especially gentle on the eyes
Warm, cozy colors (cream & terracotta), big easy-to-tap buttons, and large rounded text. Designed so first-timers and seniors can play with confidence — no clutter, no rush.

◆ Who it's for
• Anyone who forgets names, faces, or where things were
• Students and professionals training memory, focus & working memory
• Older adults who want a friendly daily brain-training habit
• Busy people who want a quick brain game between tasks

◆ Easy to play, endlessly deep
Remember the position AND the content of the pictures, then tap what was hidden. One simple rule — but 20 levels of escalating challenge. Free Mode has no time limit, so you can take it at your own pace. Levels 1–7 are open from the start; clear them to unlock 8–20.

◆ Grow a buddy, keep coming back
Each level has an animal buddy. Every clear earns EXP, and your buddy grows through five stages — baby, child, youth, adult, and finally a "professor." A companion that's all your own keeps you coming back day after day.

◆ See your progress
• Daily streak counter to build the habit
• Monthly calendar to visualize your training
• Best-time ranking to feel yourself improve

◆ Pricing
Free to play. Upgrade to Premium (<local price>/month) to remove all ads and focus fully on your training.

Ready to build a memory like a camera? Start the "see it, remember it, find it" habit today.

■ About the subscription
• Premium: <local price>/month (auto-renewable)
• Payment is charged to your Apple ID at confirmation of purchase.
• Subscription automatically renews unless auto-renew is turned off at least 24 hours before the end of the current period. Your account is charged for renewal within 24 hours prior to the end of the current period.
• You can manage or cancel anytime in Settings > your Apple ID > Subscriptions.
• Terms of Use: https://(insert memory-game Terms URL)
• Privacy Policy: https://(insert memory-game Privacy Policy URL)
```

- Character count: **約 2,050 字**（上限4000字。十分なバッファあり）
- `<local price>` は各市場のローカル価格（最低価格帯相当）を差し込む。
- URL は法務サイト（skcreation-legal / スラッグ `memory-game`）の Terms / Privacy Policy を差し込む。
- 医療効果の断定（"prevents dementia" 等）は description でも使用しない。"brain-training habit" / "sharpens memory" など習慣・トレーニング表現に留める。

---

## 6. Promotional Text (≤ 170 chars — editable anytime / not indexed)

```
NEW! Train your photographic memory with a cute animal buddy. 20 levels, no time limit, daily streaks & best-time ranking. A gentle brain game for memory, focus & seniors. Free to start.
```

- Character count: **約 185 字** → 上限超過のため下記に短縮版を採用。

```
NEW! Train your photographic memory with a cute buddy. 20 levels, no timer, daily streaks & rankings. A gentle brain game for memory & focus. Free to start.
```

- Character count: **156 字**（上限170字。`wc -m` 実測）

---

## 7. Screenshot Captions (2025 仕様＝索引対象)

各画面に1行。キーワードを自然に埋め込む。

1. Train your **photographic memory**
2. Just remember the position & content
3. **20 levels**, no time limit — at your pace
4. Clear levels to grow your buddy into a **professor**
5. **Daily streaks & calendar** build the habit
6. Sharpen **focus & concentration**, brain training
7. Big text & buttons — **easy for seniors**

---

## 8. 実装メモ（市場特有の注意）

- **設定場所**: タイトル・サブタイトルは App Store Connect の **English (U.S.) ローカリゼーション**で設定。バイナリ内の `CFBundleDisplayName` とは独立のため、コード変更不要。
- **反映タイミング**: タイトル / サブタイトル / キーワードの変更は**バージョン申請時のみ**反映。Promotional Text は随時変更可。
- **カテゴリ候補**:
  - 第一候補 **Education**（Lumosity / Elevate / Memory Match / Train Your Brain がこのカテゴリ）。脳トレ系の王道で、競合と同じ土俵に乗れる。
  - サブ候補 **Puzzle**（"Photographic Memory Games" 等のニッチ系がこちら）。リリース後にランキング露出を計測して入替検討。
- **医療効果表現の回避**: `dementia` / `Alzheimer` / `cognitive decline` / `prevents memory loss` のような医療・症状の断定は可視フィールド（title/subtitle/keyword/description/caption）で避ける。FTC（米国）の健康効果表示規制と Apple 審査の両面でリスク。使うとしても "brain training" / "memory exercise" / "mental fitness" など習慣・トレーニング表現に留める。
- **文字数カウント**: title 28 / subtitle 27 / keyword 97 / promo 156 ——いずれも上限内（`wc -m` 実測）。半角スペース・カンマも1字としてカウント済み。keyword 欄は**スペースを入れない**（カンマのみ）。`brain teaser` `working memory` の語内スペースは意図的（フレーズ一致用）で、字数に含めて計算済み。
- **米国ストアの ES-Mexico 枠**: §4 の通り、Spanish (Mexico) ロケールの keyword 欄を英語ロングテールの拡張領域として活用すると実質200字に拡張できる。真面目なスペイン語対応をしない場合の定石。
- **キーワードサイクル**: リリース後に実検索順位を計測し、効いていない語を差し替える（初期設計は仮説）。特に `photographic` が伸びるか、`brain training` の競合に埋もれるかを早期にウォッチ。伸び悩めば title と subtitle のフレーズを入替テスト（例: title を `Memory Game: Photographic` に振る案）。

---

## 9. フィールド別・最終キーワード網羅マップ

| フィールド | 主要カバー語 |
|---|---|
| Title | memory / memory games / brain / brain training / games / training |
| Subtitle | photographic / photographic memory / focus |
| Keyword (EN-US) | visual / spatial / concentration / recall / senior / puzzle / brain teaser / working memory / attention / test / free |
| 自動結合で拾える語 | visual memory / spatial memory / memory test / memory recall / brain focus / brain teaser / working memory / memory puzzle |
| ES-Mexico 拡張枠（任意） | mind / card / eidetic / attention span / brain exercise / memory improvement / grid / tile / photographic memory game |
| 不採用（医療リスク） | dementia / Alzheimer / ADHD / cognitive decline |

---

## 出典（市場リサーチ）

- Lumosity: Brain Training Games — App Store (US) — https://apps.apple.com/us/app/lumosity-brain-training-games/id577232024
- Elevate - Brain Training Games — App Store (US) — https://apps.apple.com/us/app/elevate-brain-training-games/id875063456
- Memory Match - Brain Training, Memory Games — App Store (US) — https://apps.apple.com/us/app/memory-match-brain-training-memory-games/id1172020731
- Photographic Memory Games — App Store (US) — https://apps.apple.com/us/app/photographic-memory-games/id410318229
- Photographic Memory: Mind test — App Store — https://apps.apple.com/gd/app/photographic-memory-mind-test/id6578423386
- Senior Brain Training / Senior Game — App Store (US) — https://apps.apple.com/us/app/senior-game-senior-brain/id1630633267
- Train your brain - Memory — App Store (US) — https://apps.apple.com/us/app/train-your-brain-memory/id1415728029
- "brain games" App Store Keywords Research Case — ASOTools — https://asotools.io/app-store-keywords/brain-games
- ASO for Mobile Games in 2025 — ASO Mobile — https://asomobile.net/en/blog/aso-features-of-mobile-games-in-2025/
- App Store Keyword Rules to Remember — Gummicube — https://www.gummicube.com/blog/app-store-keyword-rules-to-remember
- Creating Your Product Page — Apple Developer — https://developer.apple.com/app-store/product-page/
