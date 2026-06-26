#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""App Store 掲載用スクショ生成スクリプト（全言語）。
各言語の実機UIキャプチャに各言語のキャッチコピーを重ね、
6.7インチ(1290x2796)のストア画像を言語別に書き出す。
矢印は隣り合う2枚に跨って1本に見えるよう、右端/左端に半分ずつ描画する。
"""
import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter

SRC = "/Users/user/Downloads/名称未設定フォルダ 3"   # 元スクショ(言語別の実機UI)
OUT_ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "screenshots")

CW, CH = 1290, 2796

CREAM = (247, 241, 228)
TEAL = (60, 139, 139)
ORANGE = (217, 115, 74)
BROWN = (74, 60, 48)
BROWN_L = (120, 104, 90)
WHITE = (255, 255, 255)

FW8 = "/System/Library/Fonts/ヒラギノ角ゴシック W8.ttc"
FW6 = "/System/Library/Fonts/ヒラギノ角ゴシック W6.ttc"
ARIALB = "/System/Library/Fonts/Supplemental/Arial Bold.ttf"
ARIAL = "/System/Library/Fonts/Supplemental/Arial.ttf"
KOHINOOR = "/System/Library/Fonts/Kohinoor.ttc"
APPLEKR = "/System/Library/Fonts/AppleSDGothicNeo.ttc"
HIRAGB = "/System/Library/Fonts/Hiragino Sans GB.ttc"

# 言語 -> (見出しフォント, index), (サブフォント, index)
FONTS = {
    "ja": ((FW8, 0), (FW6, 0)),
    "en": ((ARIALB, 0), (ARIAL, 0)),
    "de": ((ARIALB, 0), (ARIAL, 0)),
    "es": ((ARIALB, 0), (ARIAL, 0)),
    "fr": ((ARIALB, 0), (ARIAL, 0)),
    "ru": ((ARIALB, 0), (ARIAL, 0)),
    "hi": ((KOHINOOR, 3), (KOHINOOR, 1)),
    "ko": ((APPLEKR, 6), (APPLEKR, 2)),
    "zh": ((HIRAGB, 2), (HIRAGB, 0)),
}

# 各言語のコピー: s1..s4=(タイトル, サブ), s5=(リード, 大タイトル, インストール文言)
T = {
    "ja": {
        "s1": ("イラストの位置を", "出てくる絵をしっかり記憶"),
        "s2": ("隠して覚えて", "ボタンひとつでサッと隠す"),
        "s3": ("答えを選ぶ", "覚えた絵をタップで回答"),
        "s4": ("継続が記録でわかる", "毎日のトレーニングを振り返る"),
        "s5": ("使いやすさ・わかりやすさにこだわり抜いた", "シンプルな記憶ゲーム", "まずはインストール"),
    },
    "en": {
        "s1": ("Memorize the positions", "Take in where each picture sits"),
        "s2": ("Hide and recall", "Hide them all with one tap"),
        "s3": ("Choose the answer", "Tap the pictures you remember"),
        "s4": ("Your streak, in the records", "Look back on your daily training"),
        "s5": ("Crafted to be simple and easy to use", "A simple memory game", "Start by installing"),
    },
    "de": {
        "s1": ("Positionen merken", "Präg dir jedes Bild gut ein"),
        "s2": ("Verdecken & erinnern", "Mit einem Tipp alles verdecken"),
        "s3": ("Antwort wählen", "Tippe die gemerkten Bilder"),
        "s4": ("Dranbleiben sichtbar gemacht", "Tägliches Training im Rückblick"),
        "s5": ("Auf Einfachheit und Klarheit getrimmt", "Einfaches Memo-Spiel", "Jetzt installieren"),
    },
    "es": {
        "s1": ("Memoriza las posiciones", "Fíjate dónde está cada dibujo"),
        "s2": ("Esconde y recuerda", "Ocúltalos con un solo toque"),
        "s3": ("Elige la respuesta", "Toca los dibujos que recuerdas"),
        "s4": ("Tu constancia en el registro", "Repasa tu entrenamiento diario"),
        "s5": ("Pensado para ser simple y fácil de usar", "Juego de memoria simple", "Empieza por instalar"),
    },
    "fr": {
        "s1": ("Mémorise les positions", "Repère bien chaque image"),
        "s2": ("Cache et mémorise", "Masque tout d’un seul geste"),
        "s3": ("Choisis la réponse", "Touche les images mémorisées"),
        "s4": ("Ta régularité dans l’historique", "Revois ton entraînement quotidien"),
        "s5": ("Pensé pour rester simple et clair", "Jeu de mémoire simple", "Commence par installer"),
    },
    "hi": {
        "s1": ("चित्रों की जगह याद रखें", "हर चित्र की जगह ध्यान से देखें"),
        "s2": ("छिपाकर याद करें", "एक टैप में सब छिपाएँ"),
        "s3": ("सही जवाब चुनें", "याद किए चित्रों पर टैप करें"),
        "s4": ("निरंतरता रिकॉर्ड में दिखे", "रोज़ के अभ्यास पर नज़र डालें"),
        "s5": ("सरल और आसान बनाया गया", "सरल मेमोरी गेम", "पहले इंस्टॉल करें"),
    },
    "ko": {
        "s1": ("위치를 기억하세요", "나오는 그림을 잘 외워요"),
        "s2": ("가리고 외우기", "버튼 하나로 가리기"),
        "s3": ("정답을 고르기", "기억한 그림을 탭하세요"),
        "s4": ("꾸준함이 기록으로", "매일의 훈련을 돌아봐요"),
        "s5": ("쉽고 편하게 끝까지 다듬은", "심플한 기억력 게임", "먼저 설치하세요"),
    },
    "ru": {
        "s1": ("Запомните позиции", "Замечайте, где какая картинка"),
        "s2": ("Спрячьте и вспомните", "Скройте всё одной кнопкой"),
        "s3": ("Выберите ответ", "Нажимайте знакомые картинки"),
        "s4": ("Постоянство видно в записях", "Просматривайте ежедневные тренировки"),
        "s5": ("Просто и понятно до мелочей", "Простая игра на память", "Начните с установки"),
    },
    "zh": {
        "s1": ("记住图案的位置", "看清每个图案的位置"),
        "s2": ("隐藏后凭记忆", "一键即可全部隐藏"),
        "s3": ("选出正确答案", "点选你记住的图案"),
        "s4": ("坚持成果看得见", "回顾每天的训练记录"),
        "s5": ("极致简单 清晰易用", "简单的记忆游戏", "先安装体验"),
    },
}

# 言語別の元スクショ（各言語の実機UIキャプチャ）。
# 各グループは順に home / memorize / hidden / answer / result / record。
# s1=memorize, s2=hidden, s3=answer, s4=record, s5=home を使う。
def _grp(home, memorize, hidden, answer, record):
    return {"s1": f"IMG_{memorize}.png", "s2": f"IMG_{hidden}.png",
            "s3": f"IMG_{answer}.png", "s4": f"IMG_{record}.png", "s5": f"IMG_{home}.png"}

SRC_BY_LANG = {
    "ja": _grp(1424, 1425, 1426, 1427, 1429),
    "de": _grp(1440, 1441, 1442, 1443, 1445),
    "es": _grp(1446, 1447, 1448, 1449, 1451),
    "hi": _grp(1452, 1453, 1454, 1455, 1457),
    "fr": _grp(1458, 1459, 1460, 1461, 1463),
    "ru": _grp(1464, 1465, 1466, 1467, 1470),
    "zh": _grp(1471, 1475, 1476, 1477, 1479),
    "ko": _grp(1480, 1483, 1484, 1485, 1487),
    "en": _grp(1488, 1489, 1490, 1491, 1493),
}

ARROW_Y = 1534
DEV_W = 860
DEV_DY = 600

_cache = {}
def font(path, size, index=0):
    return ImageFont.truetype(path, size, index=index)

def measure(draw, s, f):
    b = draw.textbbox((0, 0), s, font=f)
    return b[2] - b[0]

def fit_text(draw, text, path, index, max_w, hi, lo, max_lines=2):
    if " " in text:
        # 先に単一行を試す
        for s in range(hi, lo - 1, -2):
            f = font(path, s, index)
            if measure(draw, text, f) <= max_w:
                return [text], f
        words = text.split(" ")
        for s in range(hi, max(lo - 24, 30) - 1, -2):
            f = font(path, s, index)
            lines, cur, ok = [], "", True
            for w in words:
                t = (cur + " " + w).strip()
                if measure(draw, t, f) <= max_w:
                    cur = t
                else:
                    if cur:
                        lines.append(cur)
                    cur = w
                    if measure(draw, cur, f) > max_w:
                        ok = False
            if cur:
                lines.append(cur)
            if ok and len(lines) <= max_lines:
                return lines, f
        f = font(path, max(lo - 24, 30), index)
        return [text], f
    else:
        for s in range(hi, lo - 1, -2):
            f = font(path, s, index)
            if measure(draw, text, f) <= max_w:
                return [text], f
        return [text], font(path, lo, index)

def draw_lines_center(draw, cx, top, lines, f, fill, lh_factor=1.16):
    asc, desc = f.getmetrics()
    lh = int((asc + desc) * lh_factor)
    y = top
    for ln in lines:
        w = measure(draw, ln, f)
        draw.text((cx - w / 2, y), ln, font=f, fill=fill)
        y += lh
    return y

def rounded_mask(size, radius):
    m = Image.new("L", size, 0)
    ImageDraw.Draw(m).rounded_rectangle([0, 0, size[0] - 1, size[1] - 1], radius=radius, fill=255)
    return m

def device(src_name, target_w):
    im = Image.open(os.path.join(SRC, src_name)).convert("RGB")
    sw, sh = im.size
    tw = target_w
    th = int(sh * tw / sw)
    im = im.resize((tw, th), Image.LANCZOS)
    radius = 70
    shot = Image.new("RGBA", (tw, th), (0, 0, 0, 0))
    shot.paste(im, (0, 0))
    shot.putalpha(rounded_mask((tw, th), radius))
    bez = 16
    bw, bh = tw + bez * 2, th + bez * 2
    bezel = Image.new("RGBA", (bw, bh), (0, 0, 0, 0))
    ImageDraw.Draw(bezel).rounded_rectangle([0, 0, bw - 1, bh - 1], radius=radius + bez, fill=(38, 36, 33, 255))
    bezel.paste(shot, (bez, bez), shot)
    return bezel

def paste_device(canvas, dev, x, y):
    sh = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    bw, bh = dev.size
    ImageDraw.Draw(sh).rounded_rectangle([x, y + 26, x + bw, y + bh + 26], radius=86, fill=(60, 45, 30, 90))
    sh = sh.filter(ImageFilter.GaussianBlur(34))
    canvas.alpha_composite(sh)
    canvas.alpha_composite(dev.convert("RGBA"), (x, y))

def _arrow_mask(center_x, cy):
    """太い矢印のシルエットマスクを返す。軸＋矢じりを描き、ぼかし＋閾値で
    全ての角を均一に丸める（頂点に円を足さないので余計なコブが出ない）。
    アンチエイリアスのため 2倍解像度で作って縮小する。"""
    S = 2
    big = Image.new("L", (CW * S, CH * S), 0)
    d = ImageDraw.Draw(big)
    cx, cyy = center_x * S, cy * S
    # 軸
    d.rectangle([cx - 205 * S, cyy - 50 * S, cx + 60 * S, cyy + 50 * S], fill=255)
    # 矢じり
    d.polygon([(cx + 0, cyy - 138 * S), (cx + 0, cyy + 138 * S), (cx + 210 * S, cyy)], fill=255)
    big = big.filter(ImageFilter.GaussianBlur(11 * S))
    big = big.point(lambda v: 255 if v >= 128 else 0)
    return big.resize((CW, CH), Image.LANCZOS)

def half_arrow(canvas, center_x, cy):
    """center_x を中心に太い立体的な矢印を描く。画面外はクリップされ、
    右端(center_x=CW)では軸、左端(center_x=0)では矢じりが見える。
    隣接2枚を並べると1本の矢印に繋がる。"""
    mask = _arrow_mask(center_x, cy)
    # 縦グラデーション（上=明るい橙 / 下=濃い橙）で立体感
    y0, y1 = cy - 165, cy + 165
    top, bot = (240, 146, 96), (190, 84, 46)
    grad = Image.new("RGBA", (CW, CH), (0, 0, 0, 0))
    gd = ImageDraw.Draw(grad)
    for yy in range(y0, y1 + 1):
        t = (yy - y0) / (y1 - y0)
        gd.line([(0, yy), (CW, yy)],
                fill=(int(top[0] + (bot[0] - top[0]) * t),
                      int(top[1] + (bot[1] - top[1]) * t),
                      int(top[2] + (bot[2] - top[2]) * t), 255))
    arrow = Image.new("RGBA", (CW, CH), (0, 0, 0, 0))
    arrow.paste(grad, (0, 0), mask)
    # ドロップシャドウ
    shadow = Image.new("RGBA", (CW, CH), (0, 0, 0, 0))
    shadow.paste(Image.new("RGBA", (CW, CH), (66, 42, 26, 150)), (0, 18), mask)
    shadow = shadow.filter(ImageFilter.GaussianBlur(20))
    # 上面のハイライト（艶）
    hi = Image.new("RGBA", (CW, CH), (0, 0, 0, 0))
    ImageDraw.Draw(hi).rounded_rectangle(
        [center_x - 188, cy - 38, center_x + 150, cy - 6], radius=16, fill=(255, 255, 255, 70))
    hi.putalpha(Image.composite(hi.getchannel("A"), Image.new("L", (CW, CH), 0), mask))
    canvas.alpha_composite(shadow)
    canvas.alpha_composite(arrow)
    canvas.alpha_composite(hi)

# 元スクショ(1206x2622)における「隠す」ボタンの中心と半径
BTN_HIDE = (1050, 2383, 88)

# 指イラスト: Microsoft Fluent Emoji "Backhand index pointing up"(Flat, Light)。
# MIT ライセンス（商用無料・帰属不要）。SVG を白/黒背景で描画しアルファ復元してPNG化済み。
ASSET_FINGER = os.path.join(os.path.dirname(os.path.abspath(__file__)), "assets", "finger_pointing.png")
FINGER_TIP = (0.363, 0.0)   # アセット内の指先の相対位置(x,y)
_HAND_CACHE = {}

def _hand_img(target_h):
    if target_h in _HAND_CACHE:
        return _HAND_CACHE[target_h]
    im = Image.open(ASSET_FINGER).convert("RGBA")
    w = max(1, int(im.width * target_h / im.height))
    out = im.resize((w, target_h), Image.LANCZOS)
    _HAND_CACHE[target_h] = out
    return out

def add_tap_hand(canvas):
    """隠すボタンを押す指イラスト＋押下フィードバックを重ねる（全言語共通位置）。"""
    sx = DEV_W / 1206.0
    cx0 = (CW - (DEV_W + 32)) // 2 + 16   # 端末内スクショの原点X
    cy0 = DEV_DY + 16                      # 原点Y
    bx = cx0 + BTN_HIDE[0] * sx
    by = cy0 + BTN_HIDE[1] * sx
    br = BTN_HIDE[2] * sx
    # 押下フィードバック（白の発光＋外側リング）
    fx = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    fd = ImageDraw.Draw(fx)
    fd.ellipse([bx - br * 0.96, by - br * 0.96, bx + br * 0.96, by + br * 0.96], fill=(255, 255, 255, 70))
    fd.ellipse([bx - br - 18, by - br - 18, bx + br + 18, by + br + 18], outline=(255, 255, 255, 150), width=7)
    fd.ellipse([bx - br - 40, by - br - 40, bx + br + 40, by + br + 40], outline=(255, 255, 255, 70), width=6)
    canvas.alpha_composite(fx)
    # 指イラスト（指先がボタンに触れるよう配置）
    hand = _hand_img(int(br * 5.0))
    fingertip_x, fingertip_y = hand.width * FINGER_TIP[0], hand.height * FINGER_TIP[1]
    px = int(bx - fingertip_x)
    py = int(by - br * 0.15 - fingertip_y)
    # 影
    sh = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    sil = Image.new("RGBA", hand.size, (45, 33, 22, 255))
    sil.putalpha(hand.getchannel("A").point(lambda v: int(v * 0.45)))
    sh.alpha_composite(sil, (px + 12, py + 18))
    sh = sh.filter(ImageFilter.GaussianBlur(16))
    canvas.alpha_composite(sh)
    canvas.alpha_composite(hand, (px, py))

def make_step(lang, key, exit_right, enter_left):
    head_path, head_idx = FONTS[lang][0]
    sub_path, sub_idx = FONTS[lang][1]
    title, sub = T[lang][key]
    c = Image.new("RGBA", (CW, CH), CREAM + (255,))
    d = ImageDraw.Draw(c)
    lines, hf = fit_text(d, title, head_path, head_idx, 1150, 124, 78, max_lines=2)
    end_y = draw_lines_center(d, CW / 2, 178, lines, hf, BROWN, 1.12)
    sf = font(sub_path, 50, sub_idx)
    sublines, sf = fit_text(d, sub, sub_path, sub_idx, 1120, 52, 40, max_lines=2)
    draw_lines_center(d, CW / 2, end_y + 26, sublines, sf, BROWN_L, 1.2)
    dev = device(SRC_BY_LANG[lang][key], DEV_W)
    dw, dh = dev.size
    paste_device(c, dev, (CW - dw) // 2, DEV_DY)
    if key == "s2":
        add_tap_hand(c)
    if exit_right:
        half_arrow(c, CW, ARROW_Y)
    if enter_left:
        half_arrow(c, 0, ARROW_Y)
    return c

def make_cta(lang, enter_left):
    head_path, head_idx = FONTS[lang][0]
    sub_path, sub_idx = FONTS[lang][1]
    lead, title, cta = T[lang]["s5"]
    c = Image.new("RGBA", (CW, CH), CREAM + (255,))
    d = ImageDraw.Draw(c)
    leadlines, lf = fit_text(d, lead, sub_path, sub_idx, 1120, 54, 40, max_lines=2)
    y = draw_lines_center(d, CW / 2, 150, leadlines, lf, BROWN_L, 1.2)
    tlines, tf = fit_text(d, title, head_path, head_idx, 1150, 128, 80, max_lines=2)
    draw_lines_center(d, CW / 2, y + 18, tlines, tf, TEAL, 1.1)
    dev = device(SRC_BY_LANG[lang]["s5"], 760)
    dw, dh = dev.size
    dx, dy = (CW - dw) // 2, 600
    paste_device(c, dev, dx, dy)
    # インストール文言（ボタンにせずテキスト表示）
    clines, cf = fit_text(d, cta, head_path, head_idx, 1120, 78, 52, max_lines=1)
    draw_lines_center(d, CW / 2, dy + dh + 64, clines, cf, ORANGE, 1.1)
    if enter_left:
        half_arrow(c, 0, ARROW_Y)
    return c

def build(lang):
    out = os.path.join(OUT_ROOT, lang)
    os.makedirs(out, exist_ok=True)
    slides = [
        make_step(lang, "s1", exit_right=True, enter_left=False),
        make_step(lang, "s2", exit_right=True, enter_left=True),
        make_step(lang, "s3", exit_right=True, enter_left=True),
        make_step(lang, "s4", exit_right=True, enter_left=True),
        make_cta(lang, enter_left=True),
    ]
    for i, s in enumerate(slides, 1):
        s.convert("RGB").save(os.path.join(out, f"store_{i:02d}.png"), "PNG")
    print("built", lang)

if __name__ == "__main__":
    for lang in FONTS:
        build(lang)
    print("done ->", OUT_ROOT)
