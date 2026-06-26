#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""App Store 掲載用スクショ生成スクリプト（全言語）。
元画像（日本語UIのスクショ）に各言語のキャッチコピーを重ね、
6.7インチ(1290x2796)のストア画像を言語別に書き出す。
矢印は隣り合う2枚に跨って1本に見えるよう、右端/左端に半分ずつ描画する。
"""
import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter

SRC = "/Users/user/Downloads/名称未設定フォルダ 3"   # 元スクショ(日本語UI)
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

SRC_MAP = {"s1": "IMG_1425.png", "s2": "IMG_1426.png", "s3": "IMG_1427.png", "s4": "IMG_1429.png", "s5": "IMG_1424.png"}

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

def half_arrow(canvas, center_x, cy):
    """center_x を中心に水平の矢印を描く。画面外は自動でクリップされ、
    右端(center_x=CW)では軸、左端(center_x=0)では矢じりが見える。"""
    # 影
    sh = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    sd = ImageDraw.Draw(sh)
    sd.rounded_rectangle([center_x - 215, cy - 28 + 8, center_x + 55, cy + 28 + 8], radius=16, fill=(60, 45, 30, 80))
    sd.polygon([(center_x + 30, cy - 92 + 8), (center_x + 30, cy + 92 + 8), (center_x + 215, cy + 8)], fill=(60, 45, 30, 80))
    sh = sh.filter(ImageFilter.GaussianBlur(12))
    canvas.alpha_composite(sh)
    d = ImageDraw.Draw(canvas)
    d.rounded_rectangle([center_x - 215, cy - 28, center_x + 55, cy + 28], radius=16, fill=ORANGE + (255,))
    d.polygon([(center_x + 30, cy - 92), (center_x + 30, cy + 92), (center_x + 215, cy)], fill=ORANGE + (255,))

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
    dev = device(SRC_MAP[key], DEV_W)
    dw, dh = dev.size
    paste_device(c, dev, (CW - dw) // 2, DEV_DY)
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
    dev = device(SRC_MAP["s5"], 760)
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
