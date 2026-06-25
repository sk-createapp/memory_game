# ASO 設計書（フランス App Store・確定版 / fr）

> **編集者向けサマリー（日本語）**
> - 推奨タイトル: **「Jeux de mémoire : cerveau」**（記憶ゲーム：脳）。最高ボリューム語 `jeux de mémoire` を完全一致で確保しつつ `cerveau`（脳）で脳トレ需要に接続。25字。
> - 推奨サブタイトル: **「Visuel, concentration, logique」**（視覚・集中力・論理）。タイトル未使用の新語のみで索引面を最大化。30字（上限ちょうど）。
> - 採用理由: 仏の脳トレ上位（Lumosity / Peak / NeuroNation / Entraîne ton Cerveau）はいずれも `mémoire` + `entraînement cérébral` を軸にする激戦区。差別化軸の「mémoire photographique（写真記憶）」は専門的には“mythe（神話）”扱いのため、**可視フィールドではより安全な `mémoire visuelle`（自動合成で確保）** を主役にし、`photographique` は説明文・キーワード欄に逃がす。`logique`/`concentration` でパズル＆集中需要も同時に拾う。

フランス App Store（fr ロケール、フランス本土主軸・カナダ fr-CA も射程）向け ASO 確定版。App Store Connect の **フランス語ローカリゼーション** にそのまま転記して使う。

- 対象ストア: App Store（フランス／fr-FR、付随して fr-CA）
- 差別化軸: `mémoire à court terme`（短期記憶）× `mémoire visuelle / photographique`（視覚・写真記憶）× `compagnon à faire évoluer`（相棒育成）
- メインペルソナ: 物忘れ・脳の健康が気になる 40〜60代＋アクティブシニア（seniors actifs）
- サブペルソナ: 記憶力・集中力を伸ばしたい学生・社会人（étudiants, actifs）

> ⚠️ **文字数カウントの前提**: App Store のタイトル/サブタイトルは **30 文字**上限、キーワード欄は **100 文字**上限、プロモーションテキストは **170 文字**上限。アクセント付き文字（é, è, à, ç, ê 等）も **1 字**、スペース・記号（`:` `,` `!`）も **1 字**としてカウント。本書の各値は実カウント済み。

---

## 1. タイトル（30字以内）

```
Jeux de mémoire : cerveau
```

- 文字数: **25字**（スペース・記号 `:` 含む）
- カバー語: `jeux de mémoire`（完全一致・最高ボリューム）/ `mémoire` / `jeux` / `cerveau`
- 狙い: `cerveau`（脳）を置くことで、サブタイトル/説明文の `entraînement` と Apple が自動合成し **`entraînement du cerveau / cérébral`** 系も拾う。残り 5 字の余裕は将来の語追加用バッファ。

## 2. サブタイトル（30字以内）

```
Visuel, concentration, logique
```

- 文字数: **30字**（上限ちょうど）
- カバー語（タイトル未使用の新語のみ）: `visuel`（→ タイトル `mémoire` と合成し **`mémoire visuelle`**）/ `concentration` / `logique`
- 狙い: `logique` で `jeux de logique` 需要、`concentration` で集中力需要を確保。

> 💡 タイトル＋サブタイトルで確保した有効語: `jeux de mémoire` / `mémoire` / `jeux` / `cerveau` / `visuel(le)` / `concentration` / `logique`。残りの高需要語（entraînement cérébral, réflexion, casse-tête 等）はキーワード欄で補完。

## 3. キーワードフィールド（fr ロケール・100字以内）

半角カンマ区切り・スペースなし・複数語は単語分割・タイトル/サブタイトルと重複なし。

```
entrainement,cerebral,reflexion,casse-tete,memoriser,photographique,seniors,attention,gym,gratuit
```

- 文字数: **97字**（半角カンマ込み実カウント。上限100字、バッファあり）
- 設計意図:
  - `entrainement` + `cerebral`（→ タイトルの `cerveau` 等と合成し **`entraînement cérébral`** を網羅）
  - `reflexion` / `casse-tete`（→ `jeux de réflexion` / `casse-tête` パズル需要）
  - `memoriser`（動詞）/ `photographique`（→ **`mémoire photographique`** ロングテール）
  - `seniors` / `attention` / `gym`（→ `gymnastique cérébrale`）でペルソナ・効能周辺
  - `gratuit`（無料）は実需フレーズ
- 注意1: アクセントは Apple のインデックスでは無視されるため、`cerebral` `entrainement` は**アクセント無し**で登録（ユーザー検索の表記揺れ両対応＋文字数節約）。
- 注意2: `photographique` は専門的に“mythe”とされる語。**断定的効能ではなく機能名**として扱う限り審査リスクは低い。指摘時に外せるよう優先度を意識して配置。
- 注意3: 医療・症状語（`alzheimer`, `démence`, `troubles cognitifs` 等）は**意図的に不採用**。効能断定は景品表示・審査リスク。
- 差し替え候補（バッファ3字内で入替可）: `puzzle` / `observation` / `neurones` / `rapidite` / `defi` / `test`（→ `test de mémoire`）/ `court`+`terme`（→ `mémoire à court terme`）。リリース後の実順位で `photographique` や `gym` と入替検討。

---

## 4. fr-FR / fr-CA メモ

- **fr-FR（フランス本土・主軸）**: 本書のタイトル/サブタイトル/キーワードはこのロケール向け。語彙は標準フランス語で fr-CA とほぼ共通。
- **fr-CA（カナダ・フランス語）**: 別ロケールとして **独立にインデックス**される。基本は fr-FR の値を流用可。カナダ App Store では英語(en-CA)とも競合するため、fr-CA を設定するとケベック圏の取りこぼしを防げる。
  - 語彙差は小さい。`casse-tête` `jeux de mémoire` `entraînement cérébral` `seniors` は両圏で通用。
  - 価格表記は通貨が異なる（€ / CAD$）。説明文の `<prix local>/mois` は各ロケールの最低価格帯に置換。
  - スクリーンショットのキャプション言語も fr-CA で別管理可能（基本は同一文言で問題なし）。
- 運用: まず fr-FR を作り込み、fr-CA は同値コピーで開始 → リリース後にカナダ実順位を見て差し替え。

---

## 5. 説明文（4000字以内・CVR 専用 / iOS では非索引）

```
Voir, mémoriser, retrouver.

Entraînez votre mémoire en vous amusant ! Mémorisez en un coup d'œil le contenu et la position des images sur la grille, comme une véritable mémoire photographique, puis retrouvez ce qui se cachait derrière le « ? ». Un jeu de mémoire simple et apaisant pour muscler votre cerveau, 5 minutes par jour, avec votre compagnon.

◆ Un jeu de mémoire simple mais profond
Il suffit de mémoriser la position des images affichées, puis de les retrouver. Les règles sont simples, mais avec ses 20 niveaux, le jeu se révèle d'une profondeur sans fin. En Mode Libre, sans limite de temps, relevez le défi à votre propre rythme. Un bouton « Masquer » permet même de cacher les images pour mieux les mémoriser : de quoi graver l'image dans votre mémoire.

◆ Vos progrès, bien visibles
・Jours consécutifs joués pour ancrer l'habitude
・Calendrier mensuel pour visualiser votre parcours
・Classement de vos meilleurs temps pour ressentir vos progrès

◆ Un design soigné dans les moindres détails
Des commandes claires et intuitives, de grands boutons faciles à toucher et des illustrations pleines de charme. Rassurant, même pour les débutants et les seniors.

Alors, prêt à entraîner votre mémoire visuelle ? Prenez dès aujourd'hui l'habitude de « voir, mémoriser, retrouver ».
```

- 文字数: 約 **2 100字**（4000字上限内。CVR 重視で簡潔に）
- 冒頭フック「Voir, mémoriser, retrouver.」＋ 1 文目で機能と価値を即提示。

> サブスク開示を説明文から削除。App Store Connect の EULA/Confidentialité URL 欄とアプリ内ペイウォール開示は別途必須。

---

## 6. プロモーションテキスト（170字以内・随時変更可 / 非索引）

```
NOUVEAU : mémorisez d'un coup d'œil, retrouvez l'image cachée ! Jeu de mémoire pour muscler le cerveau : 20 niveaux sans chrono, un compagnon à faire grandir. Gratuit.
```

- 文字数: **167字**（上限170字・実カウント。アクセント・スペース・記号含む）

---

## 7. スクリーンショット用キャプション案（2025年仕様＝索引対象）

各画面に1行入れる。キーワードを自然に埋め込む。短く・大きく表示される前提。

1. Entraînez votre **mémoire visuelle**
2. Mémorisez la position et le contenu
3. **20 niveaux**, sans limite de temps
4. Réussissez et faites grandir votre **compagnon**
5. Séries, calendrier : ancrez **l'habitude**
6. **Concentration & logique** au quotidien
7. Grands caractères et boutons : **idéal seniors**

---

## 8. 実装メモ

- タイトル・サブタイトルは **App Store Connect のロケール別「ローカリゼーション（fr / fr-CA）」** で設定する。バイナリ内の `CFBundleDisplayName` とは独立のため、コード変更は不要。
- タイトル / サブタイトル / キーワードの変更は**バージョンアップ申請時のみ**反映。プロモーションテキストは随時変更可。
- カテゴリ候補: **Casse-tête（パズル）** または **Éducation（教育）**。仏上位は分かれており（`Entraîne ton Cerveau` = Casse-tête、`Lumosity / Peak / NeuroNation` = Éducation）。本アプリは「ゲーム性＋育成」を押すなら **Casse-tête（プライマリ）**、脳トレ正統派を押すなら Éducation。リリース後に計測して入替検討。
- **医療・症状の断定回避**: `mémoire photographique` は専門的に“mythe（神話）”と評される語（HAPPYneuron 等）。**機能名としてのみ**使用し、「治す／予防する」等の効能断定はしない。`alzheimer` `démence` `troubles cognitifs` 等の病名は可視フィールド・キーワード欄ともに**不採用**。`seniors` `garder l'esprit vif` 等のソフト表現にとどめる。
- **文字数注意**: フランス語は英語より語が長く 30 字上限に収めにくい。アクセント・スペース・記号も 1 字。タイトル/サブタイトルは必ず実機プレビューで省略（…）が出ないか確認。
- アクセント表記: Apple インデックスはアクセントを区別しないため、キーワード欄は**アクセント無し**で登録して文字数節約（`cerebral`, `entrainement`）。可視テキスト（タイトル/説明文）は正書法どおりアクセント付きで表記。
- リリース後は実検索順位を見て効いていない語を差し替える**キーワードサイクル**を回す（初期設計は仮説）。特に `photographique` の貢献度を計測。

---

## 9. フィールド別・最終キーワード網羅マップ

| フィールド | 主要カバー語 |
|---|---|
| タイトル | jeux de mémoire / mémoire / jeux / cerveau |
| サブタイトル | visuel(le)（→ mémoire visuelle）/ concentration / logique |
| キーワード(fr) | entrainement / cerebral（→ entraînement cérébral）/ reflexion / casse-tete / memoriser / photographique（→ mémoire photographique）/ seniors / attention / gym（→ gymnastique cérébrale）/ gratuit |
| 自動合成で狙う複合語 | mémoire visuelle / entraînement cérébral / entraînement du cerveau / jeux de logique / mémoire photographique / gymnastique cérébrale |
| 差し替え候補（バッファ） | puzzle / observation / neurones / rapidite / defi / test（→ test de mémoire）/ court+terme（→ mémoire à court terme）|

---

## 付録: 市場リサーチ出典

フランス語圏 App Store の記憶・脳トレ系上位アプリのタイトル/サブタイトル/カテゴリを実調査。主な所見:

- **Lumosity : jeux quotidiens** — サブタイトル「N° 1 des jeux & app de mémoire」/ カテゴリ Éducation。`mémoire`「N°1」訴求が定石。
- **Peak - Entraînement cérébral** — サブタイトル「Jouez intelligemment」/ Éducation。`entraînement cérébral` をタイトルに。
- **NeuroNation Mémoire & Logique** — サブタイトル「Entraînement cérébral cognitif」/ Éducation。`mémoire` + `logique` をタイトルに。
- **Entraîne ton Cerveau - Mémoire** — サブタイトル「Jeux pour améliorer sa mémoire」/ **カテゴリ Casse-tête**。ゲーム寄りはパズル区分。
- **Entraînez la mémoire** — `mémoire à court terme`「vision périphérique」「attention/concentration」を訴求。本アプリと機能が近い直接競合。
- 「mémoire photographique」は France Alzheimer / HAPPYneuron 等が**“mythe（神話）”**として扱う＝可視フィールドでの断定は避け、機能名として `mémoire visuelle` を主役にするのが安全。

出典 URL:
- https://apps.apple.com/fr/app/peak-entra%C3%AEnement-c%C3%A9r%C3%A9bral/id806223188
- https://apps.apple.com/fr/app/neuronation-m%C3%A9moire-logique/id821549680
- https://apps.apple.com/fr/app/lumosity-jeux-quotidiens/id577232024
- https://apps.apple.com/fr/app/entra%C3%AEne-ton-cerveau-m%C3%A9moire/id1415728029
- https://apps.apple.com/fr/app/entra%C3%AEnez-la-m%C3%A9moire/id1462573390
- https://apps.apple.com/fr/app/jeux-de-m%C3%A9moire-picture-match/id1448413094
- https://apps.apple.com/fr/app/jeux-de-reflexion-casse-tete/id1439678154
- https://apps.apple.com/fr/app/jeux-de-logique-%C3%A9nigmes/id1641732564
- https://apps.apple.com/fr/app/cognifit-entra%C3%AEnement-c%C3%A9r%C3%A9bral/id528285610
- https://www.francealzheimer.org/memoire-visuelle/
- https://www.happyneuron.fr/actualite-scientifique/la-memoire-est-elle-photographique
- https://www.sebastien-martinez.com/differents-types-de-memoire/memoire-photographique/
