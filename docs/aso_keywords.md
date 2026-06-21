# ASO キーワード設計書（写真記憶 - 記憶力トレーニングアプリ）

対象プラットフォーム: **iOS App Store**（タイトル30字 / サブタイトル30字 / キーワード欄100字）
対象市場: **全9言語均等**（ja / en / es / fr / de / hi / ko / ru / zh）
作成日: 2026-06-21

---

## 1. 結論サマリ

- **タイトルのメインキーワード = 「写真記憶」（＋ヘッド語「記憶力」「脳トレ」を併記）**
- 戦略: **ニッチ語（写真記憶・映像記憶・カメラアイ等）を看板に置いて上位独占を狙い、
  超激戦のヘッド語（記憶力・脳トレ・memory・brain training）はサブタイトルとキーワード欄で拾う。**
- 根拠: `記憶力` `脳トレ` 単体は Lumosity / Peak / Elevate / DNB など大手がひしめく超激戦区で、
  小規模アプリが単体で上位は困難。一方 `写真記憶` `映像記憶` `カメラアイ` は
  「このアプリそのものを探している人」が使う語で**競合が薄くCVRが高い**。看板にすべきはこちら。

---

## 2. 市場調査の要点

### 競合・市場構造
- 脳トレ／記憶アプリの最上位は **Lumosity・Peak・Elevate・NeuroNation・Memorado・DNB（DaiGo）・HAMARU** など。
  いずれも `brain training` `memory` `記憶力` `脳トレ` を押さえており、ここは正面突破しない。
- 日本語の定番タイトル構成は「**メイン語 ＋ ":" や "-" ＋ 特徴サブタイトル**」。
  例: 「ふつうの神経衰弱: 記憶力の脳トレ！暇つぶしトランプゲーム！」「神経衰弱オンライン対戦 - 記憶力バトルアプリ」。

### キーワードのタイプ分け
| 区分 | 例 | 性質 | 使い所 |
|---|---|---|---|
| ヘッド語（高ボリューム・高競合） | 記憶力 / 脳トレ / memory / brain training | 流入大だが上位困難 | サブタイトル・キーワード欄 |
| ミドル語 | 短期記憶 / ワーキングメモリ / メモリーゲーム / 集中力 | 中ボリューム・中競合 | キーワード欄の主力 |
| ニッチ語（本アプリ固有・高意図） | 写真記憶 / 映像記憶 / 瞬間記憶 / 直観像記憶 / カメラアイ | 低競合・高CVR | **タイトルの看板** |

### 本アプリの実メカニクスと相性
- ゲーム内容＝「イラストの**位置**を覚えて、？の位置にあった絵を選ぶ」＝**視覚記憶・空間記憶・ワーキングメモリ**寄り。
  → `空間記憶` `visual memory` `working memory` `spatial` も意味的に合致するので積極採用。
- `神経衰弱`（ペア合わせ）は厳密には別メカニクスだが隣接・大ボリューム語。
  タイトルには使わず**キーワード欄のみ**で拾う（タイトルに使うと「神経衰弱じゃない」という低評価レビューを招くため）。

### 注意点（重要）
- **誇大・医療表現を避ける**: `認知症が治る` 等の医療効果断定は審査リスク。`ボケ防止` `脳トレ` 程度に留める。
  （`写真記憶` は学術的には実在が議論されるが、ストア表現としては「鍛える/トレーニング」の範囲で使用すれば問題は小さい）
- **商標を入れない**: `Lumosity` `Peak` `Elevate` 等の競合アプリ名・著名人名はキーワード欄に入れない（審査拒否対象）。
- **語の重複はムダ**: Appleは アプリ名／サブタイトル／キーワード欄の語を自動で掛け合わせる。
  同じ語を複数フィールドに入れない。`記憶力`＋`アップ`を別々に入れれば `記憶力アップ` は自動生成される。
- キーワード欄は **カンマ区切り・スペース無し**。複合語より**単語ステム**で入れる方が組み合わせ効率が良い。

---

## 3. 言語別 メタデータ案

> 文字数は全角=1・半角=1（Appleの数え方）。タイトル/サブタイトルは30字、キーワード欄は100字が上限。
> 下記は上限内に収めた素案。実装時に最新の各ストア表示で最終微調整すること。

### 日本語 (ja) ★主力市場
- **アプリ名**: `写真記憶 記憶力トレーニング脳トレ`
- **サブタイトル**: `映像記憶・瞬間記憶・短期記憶を鍛える`
- **キーワード欄**:
  `ワーキングメモリ,カメラアイ,直観像記憶,記憶術,神経衰弱,メモリーゲーム,暗記,集中力,知育,記憶ゲーム,空間記憶,右脳,認知,記憶トレ,ボケ防止,物覚え,イラスト,パズル,IQ`

### English (en)
- **App Name**: `Photographic Memory: Brain Game`
- **Subtitle**: `Visual & working memory trainer`
- **Keywords**:
  `memory,brain,training,eidetic,visual,working,short term,recall,concentration,focus,cognitive,iq,puzzle,matrix,grid,spatial,memorize,remember,match,seniors,kids`

### Español (es)
- **Nombre**: `Memoria Fotográfica: Cerebro`
- **Subtítulo**: `Entrena memoria visual y mental`
- **Keywords**:
  `memoria,cerebro,entrenamiento,fotografica,visual,concentracion,agilidad,mental,juegos,recordar,cognitivo,atencion,inteligencia,corto plazo,trabajo,puzzle`

### Français (fr)
- **Nom**: `Mémoire Photographique: Cerveau`
- **Sous-titre**: `Mémoire visuelle et entraînement`
- **Keywords**:
  `memoire,cerveau,entrainement,photographique,visuelle,concentration,cognitif,jeux,memoriser,attention,logique,court terme,travail,reflexion,puzzle`

### Deutsch (de)
- **Name**: `Fotografisches Gedächtnis Spiel`
- **Untertitel**: `Visuelles Gedächtnistraining`
- **Keywords**:
  `gedachtnis,gehirntraining,gehirnjogging,fotografisch,visuell,konzentration,merken,denksport,kognitiv,kurzzeit,arbeitsspeicher,merkfahigkeit,ratsel,iq`

### 한국어 (ko)
- **앱 이름**: `사진기억: 기억력 두뇌 훈련`
- **부제**: `순간기억·영상기억 두뇌 게임`
- **키워드**:
  `기억력,사진기억,두뇌훈련,집중력,순간기억,영상기억,기억력게임,두뇌게임,치매예방,단기기억,작업기억,공간기억,인지,암기,두뇌,퍼즐`

### 中文（简体, zh）
- **名称**: `照相记忆：记忆力训练`
- **副标题**: `视觉记忆·瞬间记忆脑力训练`
- **关键词**:
  `记忆力,照相记忆,脑力训练,记忆游戏,专注力,瞬间记忆,视觉记忆,短期记忆,工作记忆,大脑训练,认知,益智,空间记忆,记忆术,集中`

### Русский (ru)
- **Название**: `Фотопамять: тренировка мозга`
- **Подзаголовок**: `Зрительная и рабочая память`
- **Keywords**:
  `память,тренировка,мозг,фотографическая,зрительная,концентрация,запоминание,когнитивный,внимание,логика,кратковременная,рабочая,игра,интеллект`

### हिन्दी (hi)
> インド圏は英語検索も多いため英語語幹を併用。
- **नाम**: `फोटोग्राफिक मेमोरी: दिमागी खेल`
- **उपशीर्षक**: `याददाश्त और दिमागी कसरत`
- **Keywords**:
  `memory,brain,training,photographic,yaddasht,dimag,smriti,concentration,focus,visual,puzzle,iq,cognitive,short term,recall,मेमोरी`

---

## 4. メインキーワード決定の論拠（タイトル設計）

1. **看板＝「写真記憶」**: 本アプリの固有名詞的ニッチ語。検索者の意図が本アプリと完全一致し、
   競合が薄いため**上位表示と高CVRを同時に取れる**。既存のアプリ名・README・ブランドとも整合。
2. **同居させるヘッド語＝「記憶力」「脳トレ」**: 単体上位は困難でも、タイトルに置くことで
   ロングテール（`写真記憶 記憶力`、`記憶力 トレーニング` 等）の掛け合わせ流入を確保。
3. **サブタイトル＝「映像記憶・瞬間記憶・短期記憶」**: タイトルと重複しない第2〜第4のニッチ／ミドル語を配置し、
   インデックス対象語を最大化。
4. **キーワード欄＝残りのミドル＆隣接語**: `ワーキングメモリ` `カメラアイ` `直観像記憶` `神経衰弱`
   `メモリーゲーム` `空間記憶` `集中力` `知育` `右脳` 等で網羅。

> 想定する主要ロングテール（自動掛け合わせで獲得）:
> 写真記憶 / 写真記憶 鍛える / 映像記憶 トレーニング / 記憶力 脳トレ / 瞬間記憶 アプリ /
> 短期記憶 トレーニング / ワーキングメモリ ゲーム / カメラアイ / 直観像記憶 / 記憶力 ゲーム

---

## 5. 運用メモ

- リリース後は App Store Connect の検索インプレッション／CVRを見て、伸びない語を
  ミドル語（`記憶ゲーム` `集中力` 等）と差し替える A/B を回す。
- スクリーンショット1枚目にも `写真記憶／映像記憶を鍛える` のコピーを載せ、検索結果でのCVRを補強する。
- ローカライズ文言（特に ko/zh/ru/hi）はネイティブチェックを推奨。直訳の不自然さがCVRを下げるため。

---

### 参考（調査ソース）
- [App Store アプリ名とキーワードのASO（Repro Journal）](https://repro.io/contents/app-store-optimization-aso-app-name-and-keywords/)
- [脳トレアプリ おすすめ人気ランキング（mybest）](https://my-best.com/2007)
- [記憶力ゲームアプリおすすめ（app-liv）](https://app-liv.jp/games/puzzles/3042/)
- [映像記憶とは（Wikipedia）](https://ja.wikipedia.org/wiki/%E6%98%A0%E5%83%8F%E8%A8%98%E6%86%B6)
- [映像記憶トレーニング方法（Wonder Education）](https://wonder-education.co.jp/media/visual-memory-training/)
- [神経衰弱オンライン対戦（App Store）](https://apps.apple.com/jp/app/id6449814564)
- [Photographic Memory: Mind test（App Store）](https://apps.apple.com/gd/app/photographic-memory-mind-test/id6578423386)
- [Memory Training: Brain Games（Google Play）](https://play.google.com/store/apps/details?id=com.nixgames.cognitive.training.memory)
- [Lumosity（App Store JP）](https://apps.apple.com/jp/app/id577232024)
