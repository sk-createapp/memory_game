#!/usr/bin/env python3
"""育成キャラの成長5段階SVGを生成する（全20種）。

承認済み「くまv2」の構造を共通エンジン化。各動物は「おとなの特徴 + 種別パーツ」
だけ定義すれば、共通の成長ランプ（目の高さ/大きさ・口元・耳・色の濃さ・全体サイズ）
を適用して 赤ちゃん→こども→わかもの→おとな→はかせ の5段階を自動生成する。
たてがみ・角・牙などは年齢で育つ（MANE ランプ）。

出力: assets/images/growth/<animal>_s<0-4>.svg （各 viewBox 0 0 120 140）
検証用コンタクトシート: assets/images/growth/_preview_<n>.svg
"""
import math
import os

OUT_DIR = os.path.join(os.path.dirname(__file__), "..", "assets", "images", "growth")
CANVAS_W, CANVAS_H, BASELINE, BOTTOM = 120, 140, 120, 110

# --- 成長ランプ（全動物共通・stage 0..4） -------------------------------------
SCALE = [0.70, 0.80, 0.90, 1.00, 1.00]   # 全体サイズ
LIGHT = [0.34, 0.20, 0.09, 0.00, 0.00]   # 体色を白に寄せる割合（幼いほど淡い）
DROP  = [16,   10,   5,    0,    0]       # 目を下げる量（幼いほど下＝幼く見える）
EYE   = [1.34, 1.18, 1.08, 1.00, 1.00]   # 目の大きさ倍率
MUZ   = [0.58, 0.76, 0.88, 1.00, 1.00]   # 口元の大きさ倍率
EAR   = [0.70, 0.83, 0.93, 1.00, 1.00]   # 耳の大きさ倍率
NOSE  = [0.80, 0.90, 0.96, 1.00, 1.00]   # 鼻の大きさ倍率
PATCH = [0.82, 0.90, 0.96, 1.00, 1.00]   # 目の周りの模様の大きさ倍率
MANE  = [0.00, 0.30, 0.62, 1.00, 1.00]   # たてがみ/角/牙など 年齢で育つ要素
STAGE_NAMES = ["あかちゃん", "こども", "わかもの", "おとな", "はかせ ★"]

INK, GOLD = "#2b2b2b", "#e0a93b"


def lighten(hex_color, amt):
    h = hex_color.lstrip("#")
    r, g, b = int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16)
    return f"#{round(r+(255-r)*amt):02x}{round(g+(255-g)*amt):02x}{round(b+(255-b)*amt):02x}"


def darken(hex_color, amt):
    h = hex_color.lstrip("#")
    r, g, b = int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16)
    return f"#{round(r*(1-amt)):02x}{round(g*(1-amt)):02x}{round(b*(1-amt)):02x}"


def params(a, i):
    p = dict(a)
    p["i"] = i
    p["s"] = SCALE[i]
    p["body"] = lighten(a["body"], LIGHT[i])
    p["body_dk"] = darken(p["body"], 0.12)
    p["eye_cy"] = a["eye_cy"] + DROP[i]
    p["eye_rx"] = a["eye_rx"] * EYE[i]
    p["eye_ry"] = a["eye_ry"] * EYE[i]
    p["pupil_r"] = a["pupil_r"] * EYE[i]
    p["muz_rx"] = a.get("muz_rx", 0) * MUZ[i]
    p["muz_ry"] = a.get("muz_ry", 0) * MUZ[i]
    p["nose_f"] = NOSE[i]
    p["ear_f"] = EAR[i]
    p["mane_f"] = MANE[i]
    if a.get("patch") or a.get("twin_patch"):
        base = a.get("patch") or a.get("twin_patch")
        p["patch_color"] = lighten(base, LIGHT[i]) if a.get("patch") else base
        p["patch_cy"] = p["eye_cy"]
        p["patch_rx"] = a["patch_rx"] * PATCH[i]
        p["patch_ry"] = a["patch_ry"] * PATCH[i]
    return p


# --- 共通パーツ ---------------------------------------------------------------
def head(p):
    return f'<ellipse cx="60" cy="{p["head_cy"]}" rx="{p["head_rx"]}" ry="{p["head_ry"]}" fill="{p["body"]}"/>'


def patch(p):
    if p.get("twin_patch"):
        g, cy, col = p["gap"], p["patch_cy"], p["patch_color"]
        rx, ry = p["patch_rx"], p["patch_ry"]
        return (f'<g transform="rotate(22 {60-g} {cy:.1f})"><ellipse cx="{60-g}" cy="{cy:.1f}" rx="{rx:.1f}" ry="{ry:.1f}" fill="{col}"/></g>'
                f'<g transform="rotate(-22 {60+g} {cy:.1f})"><ellipse cx="{60+g}" cy="{cy:.1f}" rx="{rx:.1f}" ry="{ry:.1f}" fill="{col}"/></g>')
    if not p.get("patch"):
        return ""
    return f'<ellipse cx="60" cy="{p["patch_cy"]:.1f}" rx="{p["patch_rx"]:.1f}" ry="{p["patch_ry"]:.1f}" fill="{p["patch_color"]}"/>'


def eyes(p):
    g, cy, ew, eh, pr = p["gap"], p["eye_cy"], p["eye_rx"], p["eye_ry"], p["pupil_r"]
    out = (f'<ellipse cx="{60-g}" cy="{cy:.1f}" rx="{ew:.1f}" ry="{eh:.1f}" fill="#f5f2ef"/>'
           f'<ellipse cx="{60+g}" cy="{cy:.1f}" rx="{ew:.1f}" ry="{eh:.1f}" fill="#f5f2ef"/>'
           f'<circle cx="{60-g+1}" cy="{cy+2:.1f}" r="{pr:.1f}" fill="#3f2d20"/>'
           f'<circle cx="{60+g+1}" cy="{cy+2:.1f}" r="{pr:.1f}" fill="#3f2d20"/>')
    if p["i"] == 0:
        hl = max(1.8, ew * 0.24)
        out += (f'<circle cx="{60-g-2}" cy="{cy-2:.1f}" r="{hl:.1f}" fill="#fff"/>'
                f'<circle cx="{60+g-2}" cy="{cy-2:.1f}" r="{hl:.1f}" fill="#fff"/>')
    return out


def muzzle(p):
    if not p.get("muz_rx"):
        return ""
    return f'<ellipse cx="60" cy="{p["muz_cy"]}" rx="{p["muz_rx"]:.1f}" ry="{p["muz_ry"]:.1f}" fill="{p.get("muz_color","#efe9e2")}"/>'


def nose(p):
    kind = p.get("nose", "nose")
    f, cy = p["nose_f"], p.get("nose_cy", 77)
    col = p.get("nose_color", "#3f2d20")
    if kind == "none":
        return ""
    if kind == "nose":
        return f'<ellipse cx="60" cy="{cy}" rx="{6.5*f:.1f}" ry="{4.5*f:.1f}" fill="{col}"/>'
    if kind == "bignose":
        return f'<ellipse cx="60" cy="{cy}" rx="{11*f:.1f}" ry="{9*f:.1f}" fill="{col}"/>'
    if kind == "snout":
        c = p.get("nose_color", p["body_dk"])
        return (f'<ellipse cx="60" cy="{cy}" rx="{13*f:.1f}" ry="{8.5*f:.1f}" fill="{c}"/>'
                f'<ellipse cx="{60-4.5*f:.1f}" cy="{cy}" rx="1.7" ry="2.6" fill="{darken(c,0.35)}"/>'
                f'<ellipse cx="{60+4.5*f:.1f}" cy="{cy}" rx="1.7" ry="2.6" fill="{darken(c,0.35)}"/>')
    return ""


def mouth(p):
    if p.get("mouth", "smile") == "none":
        return ""
    cy = p.get("nose_cy", 77)
    return (f'<path d="M60 {cy+5} L60 {cy+11}" stroke="#3f2d20" stroke-width="2" fill="none" stroke-linecap="round"/>'
            f'<path d="M49 {cy+14} Q60 {cy+21} 71 {cy+14}" stroke="#3f2d20" stroke-width="2" fill="none" stroke-linecap="round"/>')


def shadow(p, uid):
    cx, cy, rx, ry = 60, p["head_cy"], p["head_rx"], p["head_ry"]
    return (f'<clipPath id="sh{uid}"><ellipse cx="{cx}" cy="{cy}" rx="{rx}" ry="{ry}"/></clipPath>'
            f'<polygon points="74,2 124,2 124,128 12,128" fill="#000" opacity="0.10" clip-path="url(#sh{uid})"/>')


def prof(p):
    g, cy, ew = p["gap"], p["eye_cy"], p["eye_rx"]
    gr = ew + 4.5
    top = p["head_cy"] - p["head_ry"]
    glasses = (f'<circle cx="{60-g}" cy="{cy:.1f}" r="{gr:.1f}" stroke="{INK}" stroke-width="2.4" fill="none"/>'
               f'<circle cx="{60+g}" cy="{cy:.1f}" r="{gr:.1f}" stroke="{INK}" stroke-width="2.4" fill="none"/>'
               f'<path d="M{60-g+gr:.1f} {cy:.1f} L{60+g-gr:.1f} {cy:.1f}" stroke="{INK}" stroke-width="2.4" fill="none"/>')
    cap = (f'<polygon points="60,{top-7} 100,{top+9} 60,{top+25} 20,{top+9}" fill="{INK}"/>'
           f'<ellipse cx="60" cy="{top+14}" rx="13" ry="6" fill="{INK}"/>'
           f'<circle cx="60" cy="{top+9}" r="2.2" fill="{GOLD}"/>'
           f'<path d="M60 {top+9} L86 {top+13} L86 {top+25}" stroke="{GOLD}" stroke-width="2" fill="none"/>'
           f'<circle cx="86" cy="{top+27}" r="3" fill="{GOLD}"/>')
    sx = (f'<polygon points="13,{cy:.0f} 15,{cy+5:.0f} 20,{cy+7:.0f} 15,{cy+9:.0f} 13,{cy+14:.0f} 11,{cy+9:.0f} 6,{cy+7:.0f} 11,{cy+5:.0f}" fill="{GOLD}"/>'
          f'<polygon points="108,{cy-8:.0f} 110,{cy-3:.0f} 115,{cy-1:.0f} 110,{cy+1:.0f} 108,{cy+6:.0f} 106,{cy+1:.0f} 101,{cy-1:.0f} 106,{cy-3:.0f}" fill="{GOLD}"/>')
    return glasses + cap + sx


# --- 耳 -----------------------------------------------------------------------
def ears(p):
    e = p.get("ear", {})
    kind, f = e.get("kind", "none"), p["ear_f"]
    body = p["body"]
    inner = lighten(e.get("inner", "#cda05f"), LIGHT[p["i"]])
    if kind == "round":
        r = e["r"] * f
        dx, ey = e.get("dx", 32), e.get("cy", 30)
        ic = e.get("inner", "#cda05f")
        ic = ic if ic == "#000000" else inner
        return (f'<circle cx="{60-dx}" cy="{ey}" r="{r:.1f}" fill="{e.get("color", body)}"/>'
                f'<circle cx="{60+dx}" cy="{ey}" r="{r:.1f}" fill="{e.get("color", body)}"/>'
                f'<circle cx="{60-dx}" cy="{ey}" r="{r*0.5:.1f}" fill="{inner}"/>'
                f'<circle cx="{60+dx}" cy="{ey}" r="{r*0.5:.1f}" fill="{inner}"/>')
    if kind == "triangle":
        dx, ty, by = e.get("dx", 30), e.get("ty", 2), e.get("by", 34)
        w = e.get("w", 18) * f
        tip = e.get("tip")
        out = (f'<polygon points="{60-dx-w/2:.1f},{by} {60-dx:.1f},{ty} {60-dx+w/2:.1f},{by}" fill="{body}"/>'
               f'<polygon points="{60+dx-w/2:.1f},{by} {60+dx:.1f},{ty} {60+dx+w/2:.1f},{by}" fill="{body}"/>'
               f'<polygon points="{60-dx-w*0.28:.1f},{by-2} {60-dx:.1f},{ty+8} {60-dx+w*0.28:.1f},{by-2}" fill="{inner}"/>'
               f'<polygon points="{60+dx-w*0.28:.1f},{by-2} {60+dx:.1f},{ty+8} {60+dx+w*0.28:.1f},{by-2}" fill="{inner}"/>')
        if tip:
            out += (f'<polygon points="{60-dx-w*0.34:.1f},{ty+9} {60-dx:.1f},{ty} {60-dx+w*0.34:.1f},{ty+9}" fill="{tip}"/>'
                    f'<polygon points="{60+dx-w*0.34:.1f},{ty+9} {60+dx:.1f},{ty} {60+dx+w*0.34:.1f},{ty+9}" fill="{tip}"/>')
        return out
    return ""


def ears_back(p):
    e = p.get("ear", {})
    kind, f = e.get("kind", "none"), p["ear_f"]
    body = p["body"]
    inner = lighten(e.get("inner", "#f0c6cd"), LIGHT[p["i"]])
    if kind == "long":
        rx, ry = e.get("rx", 9) * f, e.get("ry", 30) * f
        dx, cy, rot = e.get("dx", 16), e.get("cy", 20), e.get("rot", 10)
        out = ""
        for sgn in (-1, 1):
            cx = 60 + sgn * dx
            out += (f'<g transform="rotate({sgn*rot} {cx} {cy})">'
                    f'<ellipse cx="{cx}" cy="{cy}" rx="{rx:.1f}" ry="{ry:.1f}" fill="{body}"/>'
                    f'<ellipse cx="{cx}" cy="{cy}" rx="{rx*0.5:.1f}" ry="{ry*0.75:.1f}" fill="{inner}"/></g>')
        return out
    if kind == "wide":
        rx, ry = e.get("rx", 30) * f, e.get("ry", 34) * f
        dx, cy = e.get("dx", 44), e.get("cy", 56)
        out = ""
        for sgn in (-1, 1):
            cx = 60 + sgn * dx
            out += (f'<ellipse cx="{cx}" cy="{cy}" rx="{rx:.1f}" ry="{ry:.1f}" fill="{body}"/>'
                    f'<ellipse cx="{cx-sgn*4:.1f}" cy="{cy+2}" rx="{rx*0.6:.1f}" ry="{ry*0.62:.1f}" fill="{darken(body,0.12)}"/>')
        return out
    if kind == "floppy":
        rx, ry = e.get("rx", 13) * f, e.get("ry", 26) * f
        dx, cy = e.get("dx", 42), e.get("cy", 46)
        col = e.get("color", darken(body, 0.08))
        out = ""
        for sgn in (-1, 1):
            cx = 60 + sgn * dx
            out += f'<ellipse cx="{cx}" cy="{cy}" rx="{rx:.1f}" ry="{ry:.1f}" fill="{col}"/>'
        return out
    return ""


# --- 種別パーツ（extras） -----------------------------------------------------
def whiskers(p):
    cy = p.get("nose_cy", 77) + 3
    s = "#cfc6bd"
    return (f'<path d="M68 {cy} L90 {cy-3}" stroke="{s}" stroke-width="1.2" fill="none"/>'
            f'<path d="M68 {cy+3} L90 {cy+4}" stroke="{s}" stroke-width="1.2" fill="none"/>'
            f'<path d="M52 {cy} L30 {cy-3}" stroke="{s}" stroke-width="1.2" fill="none"/>'
            f'<path d="M52 {cy+3} L30 {cy+4}" stroke="{s}" stroke-width="1.2" fill="none"/>')


def pinknose(p):
    cy, f = p.get("nose_cy", 77), p["nose_f"]
    return f'<path d="M{60-4.2*f:.1f} {cy-2} L{60+4.2*f:.1f} {cy-2} Q60 {cy+4} 60 {cy+4} Z" fill="#e0899a"/>'


def cat_extras(p):
    return pinknose(p) + whiskers(p)


def cat_blaze(p):
    ec = p["eye_cy"]
    bot = p.get("muz_cy", 82) + 16
    return (f'<path d="M60 {ec-16} Q48 {ec-6} 38 {ec+16} Q38 {bot-4} 60 {bot} '
            f'Q82 {bot-4} 82 {ec+16} Q72 {ec-6} 60 {ec-16} Z" fill="#f4f0ea"/>')


def cat_face(p):
    ec = p["eye_cy"]
    nose = f'<path d="M56 {ec+6} L64 {ec+6} Q60 {ec+12} 60 {ec+12} Z" fill="#e0899a"/>'
    mouth = (f'<path d="M60 {ec+11} L60 {ec+16}" stroke="#6f6052" stroke-width="1.8" fill="none" stroke-linecap="round"/>'
             f'<path d="M60 {ec+16} Q53 {ec+20} 48 {ec+17}" stroke="#6f6052" stroke-width="1.8" fill="none" stroke-linecap="round"/>'
             f'<path d="M60 {ec+16} Q67 {ec+20} 72 {ec+17}" stroke="#6f6052" stroke-width="1.8" fill="none" stroke-linecap="round"/>')
    wh = (f'<path d="M70 {ec+9} L92 {ec+6}" stroke="#cfc6bd" stroke-width="1.2" fill="none"/>'
          f'<path d="M70 {ec+13} L92 {ec+14}" stroke="#cfc6bd" stroke-width="1.2" fill="none"/>'
          f'<path d="M50 {ec+9} L28 {ec+6}" stroke="#cfc6bd" stroke-width="1.2" fill="none"/>'
          f'<path d="M50 {ec+13} L28 {ec+14}" stroke="#cfc6bd" stroke-width="1.2" fill="none"/>')
    return nose + mouth + wh


def mouse_extras(p):
    return pinknose(p) + whiskers(p)


def squirrel_extras(p):
    cy = p.get("nose_cy", 77)
    teeth = f'<rect x="57.5" y="{cy+4}" width="2.4" height="5" rx="0.6" fill="#fff"/><rect x="60.1" y="{cy+4}" width="2.4" height="5" rx="0.6" fill="#fff"/>'
    return pinknose(p) + teeth


def duck_bill(p):
    cy = p["eye_cy"] + 13
    return (f'<ellipse cx="60" cy="{cy}" rx="17" ry="8.5" fill="#f3a13a"/>'
            f'<path d="M44 {cy+1} Q60 {cy+7} 76 {cy+1}" stroke="#d98a2c" stroke-width="1.4" fill="none"/>')


def koala_extras(p):
    return ""


def panda_extras(p):
    return ""


def monkey_extras(p):
    cy = p.get("nose_cy", 77)
    return (f'<ellipse cx="{60-3.5}" cy="{cy}" rx="1.6" ry="2.2" fill="#5b4636"/>'
            f'<ellipse cx="{60+3.5}" cy="{cy}" rx="1.6" ry="2.2" fill="#5b4636"/>')


def sheep_wool(p):
    col = lighten("#f4f0ea", LIGHT[p["i"]] * 0.5)
    cy0 = p["head_cy"] - p["head_ry"] + 6
    pts = [(28, cy0 + 8), (40, cy0 - 4), (54, cy0 - 8), (68, cy0 - 8), (82, cy0 - 4), (92, cy0 + 8)]
    out = "".join(f'<circle cx="{x}" cy="{y}" r="13" fill="{col}"/>' for x, y in pts)
    return out


def fox_extras(p):
    return ""


def deer_antlers(p):
    mf = p["mane_f"]
    if mf <= 0.02:
        return ""
    col = "#b98e54"
    top = p["head_cy"] - p["head_ry"] + 4
    L = 18 * mf
    out = ""
    for sgn in (-1, 1):
        bx = 60 + sgn * 16
        out += (f'<path d="M{bx} {top} L{bx+sgn*4} {top-L}" stroke="{col}" stroke-width="3" fill="none" stroke-linecap="round"/>'
                f'<path d="M{bx+sgn*2:.0f} {top-L*0.55:.0f} L{bx+sgn*12:.0f} {top-L*0.7:.0f}" stroke="{col}" stroke-width="2.4" fill="none" stroke-linecap="round"/>')
    return out


def horse_mane(p):
    top = p["head_cy"] - p["head_ry"]
    col = "#9c5a4a"
    return f'<path d="M49 {top+6} Q60 {top-8} 71 {top+6} Q66 {top+24} 60 {top+18} Q54 {top+24} 49 {top+6} Z" fill="{col}"/>'


def cow_extras(p):
    return ""


def cow_horns(p):
    top = p["head_cy"] - p["head_ry"] + 6
    col = "#dccfb8"
    return (f'<path d="M44 {top} Q34 {top-8} 36 {top-2}" stroke="{col}" stroke-width="5" fill="none" stroke-linecap="round"/>'
            f'<path d="M76 {top} Q86 {top-8} 84 {top-2}" stroke="{col}" stroke-width="5" fill="none" stroke-linecap="round"/>')


def cow_spot(p):
    return f'<path d="M78 {p["head_cy"]-18} Q96 {p["head_cy"]-16} 92 {p["head_cy"]+2} Q82 {p["head_cy"]+4} 78 {p["head_cy"]-18} Z" fill="{darken(p["body"],0.55)}" opacity="0.9"/>'


def tiger_stripes(p):
    col = "#3a2a1c"
    cy = p["head_cy"]
    return (f'<path d="M60 {cy-30} L60 {cy-20}" stroke="{col}" stroke-width="2.6" fill="none" stroke-linecap="round"/>'
            f'<path d="M52 {cy-29} L50 {cy-20}" stroke="{col}" stroke-width="2.2" fill="none" stroke-linecap="round"/>'
            f'<path d="M68 {cy-29} L70 {cy-20}" stroke="{col}" stroke-width="2.2" fill="none" stroke-linecap="round"/>'
            f'<path d="M22 {cy-6} L33 {cy-4}" stroke="{col}" stroke-width="2.4" fill="none" stroke-linecap="round"/>'
            f'<path d="M21 {cy+6} L32 {cy+6}" stroke="{col}" stroke-width="2.4" fill="none" stroke-linecap="round"/>'
            f'<path d="M98 {cy-6} L87 {cy-4}" stroke="{col}" stroke-width="2.4" fill="none" stroke-linecap="round"/>'
            f'<path d="M99 {cy+6} L88 {cy+6}" stroke="{col}" stroke-width="2.4" fill="none" stroke-linecap="round"/>')


def _star(cx, cy, outer, inner, n):
    pts = []
    for k in range(2 * n):
        r = outer if k % 2 == 0 else inner
        ang = math.pi * k / n - math.pi / 2
        pts.append(f"{cx+r*math.cos(ang):.1f},{cy+r*math.sin(ang):.1f}")
    return " ".join(pts)


def lion_mane(p):
    mf = p["mane_f"]
    if mf <= 0.02:
        return ""
    cx, cy = 60, p["head_cy"] + 2
    outer = p["head_rx"] + 10 + 12 * mf
    inner = p["head_rx"] - 4
    return (f'<polygon points="{_star(cx, cy, outer+4, inner, 10)}" fill="#946231"/>'
            f'<polygon points="{_star(cx, cy, outer, inner+2, 10)}" fill="#a9743a"/>')


def sheep_horns(p):
    mf = max(0.4, p["mane_f"])
    cy = p["head_cy"]
    col, w = "#d9c7a3", 4 + 2 * mf
    left = f'<path d="M34 {cy-8} C18 {cy-6} 16 {cy+14} 30 {cy+18} C38 {cy+19} 38 {cy+9} 33 {cy+8}" stroke="{col}" stroke-width="{w:.1f}" fill="none" stroke-linecap="round"/>'
    right = f'<path d="M86 {cy-8} C102 {cy-6} 104 {cy+14} 90 {cy+18} C82 {cy+19} 82 {cy+9} 87 {cy+8}" stroke="{col}" stroke-width="{w:.1f}" fill="none" stroke-linecap="round"/>'
    return left + right


def elephant_trunk(p):
    body = p["body"]
    edge = darken(body, 0.22)
    y0 = p["eye_cy"] - 2
    bot = y0 + 64
    tusks = (f'<path d="M50 {y0+30} Q44 {y0+44} 49 {y0+52}" stroke="#f3efe7" stroke-width="4.5" fill="none" stroke-linecap="round"/>'
             f'<path d="M70 {y0+30} Q76 {y0+44} 71 {y0+52}" stroke="#f3efe7" stroke-width="4.5" fill="none" stroke-linecap="round"/>')
    trunk = (f'<path d="M52 {y0} C48 {y0+28} 51 {y0+50} 55 {bot-6} C57 {bot-1} 63 {bot-1} 65 {bot-6} '
             f'C69 {y0+50} 72 {y0+28} 68 {y0} Z" fill="{body}" stroke="{edge}" stroke-width="1.8" stroke-linejoin="round"/>')
    ring = f'<path d="M54.5 {y0+38} Q60 {y0+42} 65.5 {y0+38}" stroke="{edge}" stroke-width="1.4" fill="none"/>'
    tip = (f'<ellipse cx="60" cy="{bot-6}" rx="7" ry="4.5" fill="{edge}"/>'
           f'<circle cx="57" cy="{bot-6}" r="1.4" fill="#2f3133"/>'
           f'<circle cx="63" cy="{bot-6}" r="1.4" fill="#2f3133"/>')
    return tusks + trunk + ring + tip


# --- 動物定義（Lv順・小→大） -------------------------------------------------
ANIMALS = {
    "chick": dict(name="ヒヨコ", body="#ffd24d", head_cy=66, head_rx=44, head_ry=44,
                  eye_cy=60, eye_rx=6.5, eye_ry=8, pupil_r=5, gap=13,
                  nose="none", mouth="none", ear={"kind": "none"},
                  back=lambda p: chick_tuft(p), front=lambda p: chick_face(p)),
    "mouse": dict(name="ねずみ", body="#b3aca6", head_cy=64, head_rx=46, head_ry=44,
                  eye_cy=57, eye_rx=7.5, eye_ry=9.5, pupil_r=5, gap=15,
                  muz_rx=14, muz_ry=10, muz_cy=80, muz_color="#efeae4",
                  nose="none", mouth="none", nose_cy=76,
                  ear={"kind": "round", "r": 19, "dx": 30, "cy": 26, "inner": "#f0c6cd"},
                  front=lambda p: mouse_extras(p)),
    "rabbit": dict(name="うさぎ", body="#efe9e4", head_cy=66, head_rx=44, head_ry=43,
                   eye_cy=58, eye_rx=8, eye_ry=10, pupil_r=5, gap=15,
                   muz_rx=15, muz_ry=11, muz_cy=82, muz_color="#fbf8f5",
                   nose="none", mouth="none", nose_cy=76,
                   ear={"kind": "long", "rx": 9, "ry": 30, "dx": 18, "cy": 18, "rot": 12, "inner": "#f0c6cd"},
                   front=lambda p: rabbit_extras(p)),
    "squirrel": dict(name="りす", body="#c8884a", head_cy=64, head_rx=46, head_ry=44,
                     eye_cy=57, eye_rx=8, eye_ry=10, pupil_r=5, gap=15,
                     muz_rx=15, muz_ry=12, muz_cy=82, muz_color="#f0e6d6",
                     nose="none", mouth="none", nose_cy=76,
                     ear={"kind": "triangle", "dx": 28, "ty": 4, "by": 30, "w": 20, "inner": "#e8c9a0"},
                     front=lambda p: squirrel_extras(p)),
    "cat": dict(name="ねこ", body="#7d6e60", head_cy=64, head_rx=48, head_ry=45,
                eye_cy=57, eye_rx=8, eye_ry=10.5, pupil_r=5, gap=18,
                nose="none", mouth="none", nose_cy=76, muz_cy=82,
                ear={"kind": "triangle", "dx": 30, "ty": 2, "by": 32, "w": 22, "inner": "#e6bda0"},
                mid=lambda p: cat_blaze(p), front=lambda p: cat_face(p)),
    "dog": dict(name="いぬ", body="#cb9c64", head_cy=62, head_rx=46, head_ry=44,
                eye_cy=56, eye_rx=8, eye_ry=10, pupil_r=5, gap=16,
                muz_rx=20, muz_ry=14, muz_cy=84, muz_color="#f2ebdd",
                nose="nose", nose_cy=77, mouth="smile",
                ear={"kind": "floppy", "rx": 13, "ry": 26, "dx": 44, "cy": 48, "color": "#b07f48"}),
    "duck": dict(name="あひる", body="#ffd24d", head_cy=64, head_rx=45, head_ry=44,
                 eye_cy=55, eye_rx=7, eye_ry=9, pupil_r=5, gap=14,
                 nose="none", mouth="none", ear={"kind": "none"},
                 front=lambda p: duck_bill(p)),
    "pig": dict(name="ぶた", body="#f0b0b4", head_cy=64, head_rx=48, head_ry=45,
                eye_cy=56, eye_rx=7.5, eye_ry=9.5, pupil_r=5, gap=17,
                nose="snout", nose_cy=80, nose_color="#e79aa0", mouth="none",
                ear={"kind": "triangle", "dx": 32, "ty": 6, "by": 30, "w": 24, "inner": "#e79aa0"}),
    "sheep": dict(name="ひつじ", body="#d9cfc1", head_cy=68, head_rx=38, head_ry=40,
                  eye_cy=62, eye_rx=7, eye_ry=9, pupil_r=5, gap=14,
                  muz_rx=15, muz_ry=11, muz_cy=84, muz_color="#efe9e1",
                  nose="nose", nose_cy=80, mouth="none",
                  ear={"kind": "floppy", "rx": 11, "ry": 18, "dx": 40, "cy": 56, "color": "#cbb8a8"},
                  back=lambda p: sheep_horns(p) + sheep_wool(p)),
    "fox": dict(name="きつね", body="#e3a458", head_cy=64, head_rx=48, head_ry=44,
                eye_cy=56, eye_rx=8, eye_ry=10, pupil_r=5, gap=16,
                muz_rx=17, muz_ry=12, muz_cy=84, muz_color="#f6f1ea",
                nose="nose", nose_cy=78, mouth="none",
                ear={"kind": "triangle", "dx": 30, "ty": 2, "by": 32, "w": 22, "inner": "#f6f1ea", "tip": "#5a4632"}),
    "koala": dict(name="コアラ", body="#b3bcc1", head_cy=64, head_rx=48, head_ry=46,
                  eye_cy=58, eye_rx=7, eye_ry=9, pupil_r=5, gap=18,
                  nose="bignose", nose_cy=78, nose_color="#4c4a4a", mouth="none",
                  ear={"kind": "round", "r": 21, "dx": 38, "cy": 38, "inner": "#dde4e7"}),
    "bear": dict(name="くま", body="#9d8a7d", patch="#5d4334", patch_rx=38, patch_ry=24,
                 head_cy=64, head_rx=50, head_ry=46,
                 eye_cy=55, eye_rx=8.5, eye_ry=10.5, pupil_r=5, gap=16,
                 muz_rx=23, muz_ry=17, muz_cy=85, muz_color="#efe9e2",
                 nose="nose", nose_cy=77, mouth="smile",
                 ear={"kind": "round", "r": 20, "dx": 32, "cy": 30, "inner": "#cda05f"}),
    "panda": dict(name="パンダ", body="#f5f1ec", twin_patch="#2c2c2c", patch_rx=12, patch_ry=15,
                  head_cy=64, head_rx=50, head_ry=46,
                  eye_cy=56, eye_rx=6.5, eye_ry=8, pupil_r=4.5, gap=18,
                  nose="nose", nose_cy=77, nose_color="#2c2c2c", mouth="smile",
                  ear={"kind": "round", "r": 17, "dx": 34, "cy": 28, "color": "#2c2c2c", "inner": "#2c2c2c"}),
    "monkey": dict(name="さる", body="#a9794f", patch="#e6c79e", patch_rx=27, patch_ry=27,
                   head_cy=64, head_rx=48, head_ry=46,
                   eye_cy=58, eye_rx=7.5, eye_ry=9.5, pupil_r=5, gap=14,
                   nose="none", mouth="smile", nose_cy=78,
                   ear={"kind": "round", "r": 13, "dx": 47, "cy": 62, "inner": "#e6c79e"},
                   front=lambda p: monkey_extras(p)),
    "deer": dict(name="しか", body="#c89a68", head_cy=64, head_rx=44, head_ry=45,
                 eye_cy=57, eye_rx=8, eye_ry=10, pupil_r=5, gap=15,
                 muz_rx=16, muz_ry=12, muz_cy=84, muz_color="#efe6d6",
                 nose="nose", nose_cy=79, mouth="none",
                 ear={"kind": "long", "rx": 11, "ry": 20, "dx": 30, "cy": 34, "rot": 42, "inner": "#e8d5c0"},
                 back=lambda p: deer_antlers(p)),
    "horse": dict(name="うま", body="#b88862", head_cy=62, head_rx=40, head_ry=49,
                  eye_cy=54, eye_rx=7.5, eye_ry=10, pupil_r=5, gap=15,
                  muz_rx=20, muz_ry=17, muz_cy=92, muz_color="#caa078",
                  nose="snout", nose_cy=92, nose_color="#caa078", mouth="none",
                  ear={"kind": "triangle", "dx": 24, "ty": 2, "by": 26, "w": 16, "inner": "#caa078"},
                  front=lambda p: horse_mane(p)),
    "cow": dict(name="うし", body="#f1ede7", head_cy=64, head_rx=48, head_ry=45,
                eye_cy=56, eye_rx=8, eye_ry=10, pupil_r=5, gap=17,
                muz_rx=22, muz_ry=15, muz_cy=86, muz_color="#eaa6ac",
                nose="snout", nose_cy=86, nose_color="#eaa6ac", mouth="none",
                ear={"kind": "floppy", "rx": 12, "ry": 15, "dx": 46, "cy": 50, "color": "#e6e1d9"},
                back=lambda p: cow_horns(p), front=lambda p: cow_spot(p)),
    "tiger": dict(name="とら", body="#e8943c", head_cy=64, head_rx=50, head_ry=46,
                  eye_cy=56, eye_rx=8, eye_ry=10.5, pupil_r=5, gap=16,
                  muz_rx=20, muz_ry=14, muz_cy=84, muz_color="#f6efe5",
                  nose="nose", nose_cy=78, nose_color="#9a5a4a", mouth="smile",
                  ear={"kind": "round", "r": 16, "dx": 34, "cy": 28, "inner": "#3a2a1c"},
                  front=lambda p: tiger_stripes(p)),
    "lion": dict(name="ライオン", body="#d8a657", head_cy=64, head_rx=44, head_ry=43,
                 eye_cy=56, eye_rx=8, eye_ry=10, pupil_r=5, gap=15,
                 muz_rx=20, muz_ry=14, muz_cy=83, muz_color="#f2ead9",
                 nose="nose", nose_cy=77, nose_color="#5b4030", mouth="smile",
                 ear={"kind": "round", "r": 12, "dx": 36, "cy": 30, "inner": "#caa06a"},
                 back=lambda p: lion_mane(p)),
    "elephant": dict(name="ぞう", body="#9aa3a8", head_cy=64, head_rx=46, head_ry=46,
                     eye_cy=54, eye_rx=6, eye_ry=7.5, pupil_r=4, gap=22,
                     nose="none", mouth="none",
                     ear={"kind": "wide", "rx": 30, "ry": 34, "dx": 44, "cy": 56},
                     back=lambda p: ears_back(p), front=lambda p: elephant_trunk(p)),
}


def chick_tuft(p):
    top = p["head_cy"] - p["head_ry"]
    c = p["body_dk"]
    return (f'<path d="M60 {top+6} C56 {top-10} 50 {top-10} 52 {top+4}" fill="{c}"/>'
            f'<path d="M60 {top+6} C60 {top-14} 60 {top-14} 60 {top+2}" fill="{c}"/>'
            f'<path d="M60 {top+6} C64 {top-10} 70 {top-10} 68 {top+4}" fill="{c}"/>')


def chick_face(p):
    cy = p["eye_cy"] + 11
    beak = (f'<polygon points="60,{cy-4} 68,{cy} 60,{cy+7}" fill="#f3a13a"/>'
            f'<polygon points="60,{cy-4} 52,{cy} 60,{cy+7}" fill="#e8922f"/>')
    cheeks = (f'<circle cx="{60-p["gap"]-7}" cy="{cy-1}" r="4" fill="#f7b5a0" opacity="0.7"/>'
              f'<circle cx="{60+p["gap"]+7}" cy="{cy-1}" r="4" fill="#f7b5a0" opacity="0.7"/>')
    return beak + cheeks


def rabbit_extras(p):
    cy = p.get("nose_cy", 76)
    nose_ = f'<ellipse cx="60" cy="{cy}" rx="{4*p["nose_f"]:.1f}" ry="{3*p["nose_f"]:.1f}" fill="#d98a98"/>'
    return nose_ + whiskers(p)


# --- 組み立て -----------------------------------------------------------------
def build_inner(key, i, uid):
    a = ANIMALS[key]
    p = params(a, i)
    L = []
    if a.get("back"):
        L.append(a["back"](p))
    L.append(ears_back(p) if not a.get("back") else "")
    L.append(head(p))
    L.append(ears(p))
    if a.get("mid"):
        L.append(a["mid"](p))
    L.append(patch(p))
    L.append(eyes(p))
    L.append(muzzle(p))
    L.append(nose(p))
    L.append(mouth(p))
    if a.get("front"):
        L.append(a["front"](p))
    L.append(shadow(p, uid))
    if i == 4:
        L.append(prof(p))
    s = p["s"]
    tx, ty = 60 - 60 * s, BASELINE - BOTTOM * s
    return f'<g transform="translate({tx:.1f},{ty:.1f}) scale({s})">' + "".join(L) + "</g>"


def build_file(key, i):
    inner = build_inner(key, i, f"{key}{i}")
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {CANVAS_W} {CANVAS_H}" '
            f'width="{CANVAS_W}" height="{CANVAS_H}" role="img">'
            f'<title>{ANIMALS[key]["name"]} {STAGE_NAMES[i]}</title>{inner}</svg>')


def build_preview(keys, fname):
    cols = [110, 235, 360, 485, 610]
    row_h, top = 150, 30
    parts = [
        f'<svg width="100%" viewBox="0 0 680 {top + row_h*len(keys) + 10}" role="img" xmlns="http://www.w3.org/2000/svg">',
        '<title>育成キャラ プレビュー</title><desc>動物ごとの成長5段階</desc>',
        '<style>.ts{font-family:sans-serif;font-size:12px;fill:#888}.th{font-family:sans-serif;font-size:13px;fill:#444}</style>',
    ]
    for c, nm in zip(cols, STAGE_NAMES):
        parts.append(f'<text class="ts" x="{c}" y="18" text-anchor="middle">{nm}</text>')
    for r, key in enumerate(keys):
        row_base = top + row_h * r + row_h - 26
        parts.append(f'<text class="th" x="14" y="{top + row_h*r + 16}">{ANIMALS[key]["name"]}</text>')
        for c, i in zip(cols, range(5)):
            inner = build_inner(key, i, f"pv{r}{key}{i}")
            parts.append(f'<g transform="translate({c-60},{row_base - BASELINE})">{inner}</g>')
    parts.append('</svg>')
    with open(os.path.join(OUT_DIR, fname), "w") as fh:
        fh.write("".join(parts))


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    for key in ANIMALS:
        for i in range(5):
            with open(os.path.join(OUT_DIR, f"{key}_s{i}.svg"), "w") as fh:
                fh.write(build_file(key, i))
    keys = list(ANIMALS.keys())
    for n in range(0, len(keys), 5):
        build_preview(keys[n:n + 5], f"_preview_{n//5}.svg")
    print(f"generated {len(keys)*5} svgs + {-(-len(keys)//5)} preview sheets into {os.path.normpath(OUT_DIR)}")


if __name__ == "__main__":
    main()
