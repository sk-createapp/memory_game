# ASO 設計書（スペイン語 App Store・確定版）

> **編集者向けサマリー（日本語）**
> - 推奨タイトル: **`Juegos de Memoria-Reto Mental`**（29字）＝「記憶ゲーム-脳の挑戦」。最大ボリューム語 `juegos de memoria` を完全一致で先頭に置き、`memoria`/`mental` も同時に獲得。
> - 推奨サブタイトル: **`Memoria fotográfica y agilidad`**（30字）＝「写真記憶と俊敏さ（agilidad mental）」。USP の `memoria fotográfica` と高需要の `agilidad mental` を新規語として補完。
> - 採用理由: 競合（Lumosity/NeuroNation/Peak）が `entrenamiento cerebral` 軸で飽和する一方、`memoria fotográfica` は Synapse など小規模アプリしか押さえておらず競合が弱い。カテゴリ最強語の `juegos de memoria` を確保しつつ独自軸を立てる二段構え。
> - 中南米(es-MX)とスペイン(es-ES)で脳トレ語彙はほぼ共通。シニア表現のみ es-MX=`adultos mayores`、es-ES=`personas mayores/mayores` と差があるため可視欄では中立な `mayores` を採用。

記憶力トレーニングゲーム「写真記憶（memoria fotográfica）」のスペイン語ストア向け ASO（App Store 最適化）確定版。
App Store Connect の **スペイン語（メキシコ）ローカリゼーション** を主軸に、**スペイン語（スペイン）** にも転用できる設計。

- 対象ストア: App Store（スペイン語 / 主軸 es-MX、射程 es-ES）
- 差別化軸: `memoria fotográfica`（写真記憶）× `memoria a corto plazo`（短期記憶）× `育成する相棒（mascota）`
- メインペルソナ: 物忘れ・ボケ防止が気になる 40〜60代＋アクティブシニア（adultos mayores）
- サブペルソナ: 記憶力・集中力を伸ばしたい学生・社会人

---

## 1. タイトル（30字以内）

```
Juegos de Memoria-Reto Mental
```

- 文字数: **29字**
- カバー語: `juegos de memoria`（完全一致・カテゴリ最大ボリューム語）/ `memoria` / `juegos` / `reto` / `mental`（→ `reto mental`／`juegos mentales` を自動合成）
- ねらい: スペイン語圏で最も検索される `juegos de memoria` を完全一致で押さえる。区切りは Apple が単語結合しやすい半角ハイフン `-` を使用（コロン `:` でも可）。

## 2. サブタイトル（30字以内）

```
Memoria fotográfica y agilidad
```

- 文字数: **30字**
- カバー語（タイトル未使用の新語のみ）: `memoria fotográfica`（USP・競合の弱い独自軸）/ `agilidad`（→ タイトルの `mental` と結合し **`agilidad mental`** を自動獲得。高需要語）
- ねらい: 「写真記憶」という独自軸を可視欄で明示しつつ、`agilidad mental`（中南米で人気の脳トレ語）を1語で取りに行く。
- 代替案: `Memoria visual y concentración`（30字）。`memoria visual`＋`concentración` を優先したい場合に差し替え可。`memoria fotográfica` は本文・キャプションで補完する。

## 3. キーワードフィールド（スペイン語ロケール・100字以内）

半角カンマ区切り・スペースなし・既出語の重複なし（複数語は単語分割し Apple の自動結合に委ねる）。

```
cerebral,gimnasia,visual,puzzle,atención,concentración,mayores,recordar,foco,cerebro,memorizar,test
```

- 文字数: **99字**（上限100字）
- 自動合成のねらい:
  - `cerebral` ＋ 本文外のタイトル/サブタイトル語ではなく、`entrenamiento`（後述の英語欄）や `cerebral` 単体で **`entrenamiento cerebral`** を狙う。`cerebral` 単体でも `gimnasia cerebral` 等に展開。
  - `gimnasia` ＋ `mental`（タイトル）→ **`gimnasia mental`**。
  - `visual` ＋ `memoria`（タイトル）→ **`memoria visual`**。
  - `juegos`（タイトル）＋ `mentales`/`mental` → **`juegos mentales`**。
  - `memoria`（タイトル）＋ `test` → **`test de memoria`**（記憶力テスト系の実需要フレーズ）。
- 注意1: 医療・症状語（`demencia`, `alzheimer`, `deterioro cognitivo`）は**あえて入れていない**。効能の断定回避と審査リスク低減のため。入れる場合は最優先度を下げ、審査指摘で外せるよう末尾に置く。
- 注意2: `senior` は英語ロケール欄（下記）に回し、スペイン語欄は `mayores` のみとした（es-MX/es-ES 共通で通じる中立語）。

## 4. キーワードフィールド（英語 US ロケール・100字以内）

スペイン語ストアでも英語(US)ロケールのキーワードが索引されるため**必ず併設**する。将来の多言語展開とも兼用。

```
memory,brain,training,photographic,puzzle,concentration,senior,focus,recall,visual,mental,test
```

- 文字数: **94字**
- スペイン語ユーザーでも英語混在検索（`memory`, `brain training` 等）があるため設定価値が高い。

---

## 5. es-MX / es-ES 使い分けメモ

| 概念 | es-MX（中南米・主軸） | es-ES（スペイン） | 可視欄での採用 |
|---|---|---|---|
| 高齢者 | `adultos mayores` | `personas mayores` / `mayores` | 中立な **`mayores`**（キーワード欄） |
| 脳トレ全般 | `entrenamiento cerebral` / `juegos mentales` | 同左（共通） | 共通使用 |
| 俊敏な思考 | `agilidad mental` | 同左（共通・スペインで特に定着） | サブタイトルで `agilidad` |
| 脳の体操 | `gimnasia mental` / `gimnasia cerebral` | 同左（共通） | キーワード欄で `gimnasia` |
| パズル | `rompecabezas` / `puzzle` | `puzle` / `puzzle` / `rompecabezas` | `puzzle`（両国で通用、`rompecabezas` は本文で補完） |
| 集中 | `concentración` / `enfoque` | `concentración` | 共通使用 |

- 結論: **脳トレ語彙はほぼ全域共通**。実害のある語彙差はシニア表現のみ。本文(es-MX 主軸)では `adultos mayores` を使い、es-ES 配信時は `personas mayores` に1語置換すれば足りる。
- voseo/tú: 命令形は中南米でも `tú`（`entrena`, `memoriza`）が無難でスペインとも共通。`vos` は不使用。

---

## 6. 説明文（4000字以内・CVR 専用 / iOS では非索引）

```
Ve, memoriza y recuerda.
Entrena tu “memoria fotográfica” de forma divertida con un juego de memoria pensado para todas las edades. Solo 5 minutos al día, junto a tu mascota, para mantener tu mente ágil y despierta.

◆ Para ti, si…
・Olvidas nombres o dónde dejaste las cosas
・Quieres ejercitar tu memoria y concentración
・Buscas un hábito sencillo de gimnasia mental
・Quieres entrenar el cerebro en ratos libres

◆ Sencillo de aprender, difícil de soltar
Observa las ilustraciones, memoriza “qué” había y “en qué lugar”, y adivina lo que se escondió detrás del “?”. La regla es muy simple, pero con 20 niveles el reto crece sin parar. El modo libre no tiene límite de tiempo: avanza a tu propio ritmo, sin prisas.

◆ Una mascota que crece contigo
Cada vez que superas un nivel, tu mascota gana experiencia y evoluciona en 5 etapas: bebé → pequeño → joven → adulto → ¡profesor! Un compañero que te dará ganas de volver cada día.

◆ Tu progreso, siempre a la vista
・Días seguidos jugando para crear hábito
・Calendario mensual con tu historial de entrenamiento
・Ranking de tus mejores tiempos para sentir tu avance

◆ Pensado para que nadie se pierda
Diseño en tonos cálidos que cuidan la vista, botones grandes y fáciles de pulsar, y letras grandes y redondas. Cómodo también para principiantes y para personas mayores.

◆ Precio
Jugar es gratis. Con la suscripción Premium (<precio local>/mes) se eliminan todos los anuncios para que entrenes sin distracciones.

¿Listo para tener una memoria como una cámara?
Empieza hoy el hábito de “ver, memorizar y recordar”.

■ Sobre la suscripción
・Premium: <precio local>/mes (renovación automática)
・El pago se carga a tu cuenta de Apple ID al confirmar la compra.
・La suscripción se renueva automáticamente salvo que desactives la renovación al menos 24 horas antes del fin del periodo; el cargo de renovación se realiza dentro de las 24 horas previas al fin del periodo.
・Puedes gestionar o cancelar la suscripción en cualquier momento desde [Ajustes] > tu cuenta de Apple ID.
・Términos de uso: https://(insertar URL de términos de memory-game)
・Política de privacidad: https://(insertar URL de privacidad de memory-game)

* Este juego es para entrenamiento y entretenimiento y no constituye un producto ni un diagnóstico médico.
```

> 自動更新サブスクは、価格・更新条件・規約/PP リンクの明記が Apple 審査（ガイドライン 3.1.2）で**必須**。`<precio local>` は配信国の最低価格帯（例: es-MX なら MXN 表記、es-ES なら EUR 表記）に差し替え、URL は法務サイト（skcreation-legal / スラッグ `memory-game`）を差し込む。
> es-ES 向けに配信する場合は `personas mayores` への1語置換のみで流用可。

---

## 7. プロモーションテキスト（170字以内・随時変更可 / 非索引）

```
Entrena tu memoria fotográfica con un juego sencillo y adorable: memoriza el dibujo y su lugar, adivina qué se escondió. 20 niveles, sin prisas y con tu mascota. ¡Gratis!
```

- 文字数: **170字**（上限ちょうど）

---

## 8. スクリーンショット用キャプション案（2025 年仕様＝索引対象）

各画面に1行入れる。キーワードを自然に埋め込む。

1. Entrena tu **memoria fotográfica**
2. Reglas simples: memoriza qué había y dónde
3. **20 niveles** y modo libre sin límite de tiempo
4. Supera niveles y tu mascota crece hasta **profesor**
5. **Días seguidos y calendario** para crear hábito
6. **Concentración y agilidad mental** cada día
7. Letras y botones grandes, fácil para **personas mayores**

---

## 9. 実装メモ

- タイトル・サブタイトルは **App Store Connect のロケール別「ローカリゼーション」**（スペイン語(メキシコ) / スペイン語(スペイン)）で設定する。バイナリ内の `CFBundleDisplayName=Memory Game` とは独立のため、コード変更は不要。
- タイトル / サブタイトル / キーワードの変更は**バージョンアップ申請時のみ**反映。プロモーションテキストは随時変更可。
- カテゴリ候補: **Juegos > Rompecabezas（パズル）** を主、**Juegos > Educativos** または **Educación** を副。脳トレ系は `Juegos`配下が定石。リリース後に計測して入替検討。
- `<precio local>/mes` は配信国別に実価格へ置換（es-MX: MXN、es-ES: EUR）。最低価格帯ティアを選択。
- 医療・症状の断定表現（`previene la demencia`, `cura el alzheimer` 等）は可視フィールドで**禁止**。説明文末尾に「医療製品・診断ではない」注意書きを残してある（景表法相当の現地規制＋Apple 審査リスク回避）。
- 文字数: タイトル29／サブタイトル30／キーワード(es)99／キーワード(en)94／プロモ170。いずれも上限内。アクセント文字（á, ó, ñ 等）も1字としてカウント済み。
- リリース後は実検索順位を見て効いていない語を差し替える**キーワードサイクル**を回す（初期設計は仮説）。

---

## 10. フィールド別・最終キーワード網羅マップ

| フィールド | 主要カバー語 |
|---|---|
| タイトル | juegos de memoria（完全一致）/ memoria / juegos / reto / mental（→ reto mental・juegos mentales） |
| サブタイトル | memoria fotográfica / agilidad（→ agilidad mental） |
| キーワード(ES) | cerebral（→ entrenamiento/gimnasia cerebral）/ gimnasia（→ gimnasia mental）/ visual（→ memoria visual）/ puzzle / atención / concentración / mayores / recordar / foco / cerebro / memorizar / test（→ test de memoria） |
| キーワード(EN) | memory / brain / training / photographic / puzzle / concentration / senior / focus / recall / visual / mental / test |
| 自動合成で獲得 | juegos de memoria / juegos mentales / reto mental / agilidad mental / memoria visual / memoria fotográfica / gimnasia mental / entrenamiento cerebral / test de memoria |

---

## 出典（市場リサーチ）

- NeuroNation: Juegos cerebrales — https://apps.apple.com/es/app/neuronation-juegos-cerebrales/id821549680
- Lumosity - Entrenador Cerebral — https://apps.apple.com/es/app/lumosity-entrenador-cerebral/id577232024
- Entrena tu cerebro - Memoria — https://apps.apple.com/es/app/entrena-tu-cerebro-memoria/id1415728029
- Memorix Match Game — https://apps.apple.com/es/app/memorix-match-game/id6563139365
- Memory games for adults (es-MX) — https://apps.apple.com/us/app/memory-games-for-adults/id6504950124?l=es-MX
- Jigsaw Puzzle: Rompecabezas — https://apps.apple.com/ar/app/jigsaw-puzzle-rompecabezas/id1324604053
- Synapse - Juego Memoria Foto — https://play.google.com/store/apps/details?id=com.mmegames.synapse
- Infobae「mejores aplicaciones para ejercitar la memoria」 — https://www.infobae.com/tecno/2023/09/17/las-siete-mejores-aplicaciones-para-ejercitar-la-memoria-y-el-cerebro-mientras-juegas-en-un-movil/
- SinEmbargo MX「apps para estimular la memoria」 — https://www.sinembargo.mx/3571883/once-apps-para-estimular-la-memoria-entrenar-la-mente-y-ser-mas-inteligente/
- Cuideo「apps y juegos para ejercitar memoria personas mayores」 — https://cuideo.com/blog/apps-juegos-ejercitar-memoria-personas-mayores/
- ZonaELE「diferencias léxicas español mexicano y peninsular」 — https://zonaele.com/diferencias-lexicas-entre-el-espanol-mexicano-y-el-peninsular/
