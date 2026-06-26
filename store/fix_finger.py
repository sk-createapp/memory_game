#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""スライド2(hidden)の指イラストを修正する後処理。

既知の不具合:
  - iPhone es/fr/ru: 「隠す」ボタンがラベル長に応じて大きく(高く)なり、固定位置に
    描いた指がボタンからずれる。
  - iPad 全言語: 指ではなくライムグリーンの照準マーカーが描かれている。

元の端末キャプチャ素材(iPhone)は失われているため最終PNGを直接補修する。
同一言語のスライド1(memorize)は端末フレーム/「隠す」ボタンが完全に同一で指が
無いので、これをドナーにして不正なオーバーレイを消し、検出したボタン位置に
正しい指(generate_screenshots.add_tap_hand と同一スタイル)を描き直す。
"""
import os
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

import generate_screenshots as gen

HERE = os.path.dirname(os.path.abspath(__file__))
TEAL = np.array((60, 139, 139))


def load(path):
    return np.asarray(Image.open(path).convert("RGB")).astype(np.uint8).copy()


def detect_button(arr, x0, x1, y0, y1):
    """指定領域内のティール色「隠す」ボタンの中心と半径(高さ/2)を返す。"""
    sub = arr[y0:y1, x0:x1].astype(int)
    m = np.abs(sub - TEAL).sum(2) < 70
    ys, xs = np.where(m)
    if len(xs) < 50:
        return None
    cx = int(xs.mean() + x0)
    cy = int(ys.mean() + y0)
    br = int((ys.max() - ys.min()) / 2)
    return cx, cy, br


def place_finger(canvas, bx, by, br):
    """generate_screenshots.add_tap_hand と同一スタイルで指＋押下フィードバックを描く。"""
    fx = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    fd = ImageDraw.Draw(fx)
    fd.ellipse([bx - br * 0.96, by - br * 0.96, bx + br * 0.96, by + br * 0.96], fill=(255, 255, 255, 70))
    fd.ellipse([bx - br - 18, by - br - 18, bx + br + 18, by + br + 18], outline=(255, 255, 255, 150), width=7)
    fd.ellipse([bx - br - 40, by - br - 40, bx + br + 40, by + br + 40], outline=(255, 255, 255, 70), width=6)
    canvas.alpha_composite(fx)
    hand = gen._hand_img(int(br * 5.0))
    ftx, fty = hand.width * gen.FINGER_TIP[0], hand.height * gen.FINGER_TIP[1]
    px = int(bx - ftx)
    py = int(by - br * 0.15 - fty)
    sh = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    sil = Image.new("RGBA", hand.size, (45, 33, 22, 255))
    sil.putalpha(hand.getchannel("A").point(lambda v: int(v * 0.45)))
    sh.alpha_composite(sil, (px + 12, py + 18))
    sh = sh.filter(ImageFilter.GaussianBlur(16))
    canvas.alpha_composite(sh)
    canvas.alpha_composite(hand, (px, py))


def fix_iphone(langs=("es", "fr", "ru")):
    root = os.path.join(HERE, "screenshots")
    for lang in langs:
        p2 = os.path.join(root, lang, "store_02.png")
        s1 = load(os.path.join(root, lang, "store_01.png"))
        s2 = load(p2)
        # 旧・指＋リング＋影をスライド1(指なし・同一フレーム)で丸ごと差し替え。
        # この帯はボタン群と余白だけでタイルより下＝両スライドで完全一致する。
        bx0, by0, bx1, by1 = 650, 2080, 1290, 2796
        s2[by0:by1, bx0:bx1] = s1[by0:by1, bx0:bx1]
        # クリーンになったボタンを検出して正しい位置に指を描く。
        btn = detect_button(s1, 700, 1130, 1950, 2450)
        canvas = Image.fromarray(s2, "RGB").convert("RGBA")
        if btn:
            place_finger(canvas, *btn)
        canvas.convert("RGB").save(p2, "PNG")
        print("iphone finger fixed:", lang, btn)


def fix_ipad(langs=("ja", "en", "de", "es", "fr", "ru", "hi", "ko", "zh")):
    root = os.path.join(HERE, "screenshots_ipad")
    for lang in langs:
        p2 = os.path.join(root, lang, "store_02.png")
        s1 = load(os.path.join(root, lang, "store_01.png"))
        s2 = load(p2)
        # 照準マーカー(ライムグリーン十字)はボタン中心(全言語で同一位置)に固定で
        # 描かれている。淡いアンチエイリアス縁まで残らないよう、十字を覆う矩形を
        # スライド1(マーカー無し・同一フレーム)で丸ごと差し替える。タイルより下の
        # ボタン＋余白だけの帯なので両スライドで一致する。
        cx0, cy0, cx1, cy1 = 1300, 2100, 1630, 2380
        s2[cy0:cy1, cx0:cx1] = s1[cy0:cy1, cx0:cx1]
        # iPad はボタンが端末中央下にある。ホームボタン(左上)を避けて下側で検出。
        btn = detect_button(s1, 700, 2064, 1900, 2752) or detect_button(s1, 0, 2064, 1900, 2752)
        canvas = Image.fromarray(s2, "RGB").convert("RGBA")
        if btn:
            place_finger(canvas, *btn)
        canvas.convert("RGB").save(p2, "PNG")
        print("ipad finger fixed:", lang, btn)


if __name__ == "__main__":
    fix_iphone()
    fix_ipad()
    print("done")
