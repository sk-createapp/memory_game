#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""既存の最終ストア画像の矢印だけを差し替える後処理スクリプト。

元の端末キャプチャ素材が失われており再生成できないため、確定済みの
最終PNG(iPhone/iPad)を直接編集する。やることは2つ:
  1) 矢印は 1→2→3 のフローのみを繋ぐ。4枚目以降の矢印は消す。
  2) 残す矢印の矢じり(先)の幅を広げる。

端末の左右の縁は矢印帯(y~1530)では完全に縦方向一様なので、矢印の少し上の
「きれいな1行」を帯全体に引き伸ばす(smear)ことで、影や数pxのベゼルまで
正確に復元してから、必要な側にだけ新しい(太い)矢印を描き直す。
"""
import os
import numpy as np
from PIL import Image

import generate_screenshots as gen  # half_arrow / _arrow_mask を再利用

HERE = os.path.dirname(os.path.abspath(__file__))
LANGS = ["ja", "en", "de", "es", "fr", "ru", "hi", "ko", "zh"]

# プラットフォーム別パラメータ
PLATFORMS = {
    "iphone": dict(
        root=os.path.join(HERE, "screenshots"),
        CW=1290, CH=2796, arrow_y=1534,
        left_cols=(0, 260), right_cols=(1030, 1290),
    ),
    "ipad": dict(
        root=os.path.join(HERE, "screenshots_ipad"),
        CW=2064, CH=2752, arrow_y=1539,
        left_cols=(0, 285), right_cols=(1755, 2064),
    ),
}

DONOR_Y = 1315           # 矢印帯より上の、きれいなドナー行
BAND = (1330, 1748)      # 旧/新どちらの矢印+影も覆う消去帯

# 矢印は 1→2→3 のフローのみを繋ぐ。残す矢印は新しい寸法(先を太く・短く)で
# 全て描き直すため、旧矢印は常にドナー行で消去してから必要な側に再描画する。
# s1: 右のみ / s2: 左+右 / s3: 左のみ / s4,s5: なし
ACTIONS = {
    # name        erase_left, erase_right, draw_left, draw_right
    "store_01": (True, True, False, True),    # 右(1→2)を新寸法で描き直し
    "store_02": (True, True, True,  True),    # 左(矢じり)+右を描き直し
    "store_03": (True, True, True,  False),   # 左を描き直し、右(3→4)を消去
    "store_04": (True, True, False, False),   # 両側消去
    "store_05": (True, False, False, False),  # 左を消去
}


def smear(arr, cols, donor_y=DONOR_Y, band=BAND):
    x0, x1 = cols
    y0, y1 = band
    arr[y0:y1, x0:x1, :] = arr[donor_y:donor_y + 1, x0:x1, :]


def process(platform):
    p = PLATFORMS[platform]
    gen.CW, gen.CH = p["CW"], p["CH"]
    ay = p["arrow_y"]
    for lang in LANGS:
        for name, (eL, eR, dL, dR) in ACTIONS.items():
            path = os.path.join(p["root"], lang, f"{name}.png")
            if not (eL or eR or dL or dR):
                continue
            arr = np.asarray(Image.open(path).convert("RGB")).astype(np.uint8).copy()
            if eL:
                smear(arr, p["left_cols"])
            if eR:
                smear(arr, p["right_cols"])
            canvas = Image.fromarray(arr, "RGB").convert("RGBA")
            if dL:
                gen.half_arrow(canvas, 0, ay)
            if dR:
                gen.half_arrow(canvas, p["CW"], ay)
            canvas.convert("RGB").save(path, "PNG")
        print("fixed", platform, lang)


if __name__ == "__main__":
    for plat in PLATFORMS:
        process(plat)
    print("done")
