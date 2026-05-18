"""
Unit Converter Pro — Premium Icon v3
Design: Full indigo→purple gradient bg · Frosted disc · Bold ⇆ exchange arrows
Renders at 2× then downscales with LANCZOS for maximum sharpness.
"""

import math
from PIL import Image, ImageDraw, ImageFilter

# ── Palette ───────────────────────────────────────────────────────────────────
BG_TOP       = ( 45,  35, 140)   # deep indigo (top-left)
BG_BOT       = ( 90,  55, 210)   # rich purple (bottom-right)
DISC_COL     = (255, 255, 255)   # white frosted disc
INDIGO_DARK  = ( 55,  48, 163)
PURPLE       = ( 99,  88, 239)
VIOLET       = (139,  92, 246)
WHITE        = (255, 255, 255, 255)
SHADOW_COL   = ( 80,  60, 200)


def lerp(a, b, t):
    return a + (b - a) * t


def rounded_rect_mask(size, radius):
    m = Image.new("L", (size, size), 0)
    ImageDraw.Draw(m).rounded_rectangle([0, 0, size - 1, size - 1], radius=radius, fill=255)
    return m


def linear_gradient_bg(W, mask):
    """Full-icon diagonal gradient: indigo top-left → purple bottom-right."""
    img  = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    data = img.load()
    for y in range(W):
        for x in range(W):
            t = (x + y) / (2 * (W - 1))
            col = tuple(int(lerp(BG_TOP[i], BG_BOT[i], t)) for i in range(3)) + (255,)
            data[x, y] = col
    # clip to rounded rect
    out = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    out.paste(img, mask=mask)
    return out


def frosted_disc(W, cx, cy, r):
    """White semi-transparent frosted-glass disc."""
    img = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    d   = ImageDraw.Draw(img)
    # outer disc — white @ 28% opacity
    d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(255, 255, 255, 72))
    # inner disc — brighter centre
    ri = int(r * 0.72)
    d.ellipse([cx - ri, cy - ri, cx + ri, cy + ri], fill=(255, 255, 255, 38))
    return img.filter(ImageFilter.GaussianBlur(W * 0.004))   # slight soften edge


def disc_glow(W, cx, cy, r):
    """Soft white glow around the frosted disc."""
    img = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    d   = ImageDraw.Draw(img)
    for i in range(25):
        alpha = int(30 * (1 - i / 25) ** 2)
        ri    = r + int(W * 0.007) * (25 - i)
        d.ellipse([cx - ri, cy - ri, cx + ri, cy + ri],
                  fill=(200, 190, 255, alpha))
    return img.filter(ImageFilter.GaussianBlur(W * 0.012))


def draw_exchange_arrows(W, cx, cy, disc_r):
    """
    Two bold horizontal arrows: top → right, bottom ← left.
    Drawn on a transparent RGBA canvas.
    """
    img = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    d   = ImageDraw.Draw(img)

    span   = int(disc_r * 1.02)   # total arrow span (left tip to right tip)
    stem_h = int(W * 0.046)       # stem thickness
    head_w = int(W * 0.060)       # arrowhead depth
    head_h = int(W * 0.088)       # arrowhead half-height
    gap    = int(W * 0.095)       # vertical gap from centre to each arrow

    for direction, sign in [('right', -1), ('left', 1)]:
        y     = cy + sign * gap
        x_l   = cx - span // 2
        x_r   = cx + span // 2

        if direction == 'right':
            # stem
            d.rectangle([x_l, y - stem_h // 2, x_r - head_w, y + stem_h // 2], fill=WHITE)
            # arrowhead →
            d.polygon([
                (x_r,          y),
                (x_r - head_w, y - head_h // 2),
                (x_r - head_w, y + head_h // 2),
            ], fill=WHITE)
        else:
            # stem
            d.rectangle([x_l + head_w, y - stem_h // 2, x_r, y + stem_h // 2], fill=WHITE)
            # arrowhead ←
            d.polygon([
                (x_l,          y),
                (x_l + head_w, y - head_h // 2),
                (x_l + head_w, y + head_h // 2),
            ], fill=WHITE)

    return img


def inner_highlight(W, cx, cy, r):
    """Specular highlight: bright spot top-left of disc."""
    img = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    d   = ImageDraw.Draw(img)
    hr  = int(r * 0.38)
    ox  = int(W * 0.06)
    oy  = int(W * 0.07)
    d.ellipse([cx - hr - ox, cy - hr - oy, cx + hr - ox, cy + hr - oy],
              fill=(255, 255, 255, 55))
    return img.filter(ImageFilter.GaussianBlur(W * 0.045))


# ═══════════════════════════════════════════════════════════════════════════════
def _make_icon_hires(S):
    """Render at size S (work image, caller will downscale)."""
    cx, cy = S // 2, S // 2
    mask   = rounded_rect_mask(S, radius=int(S * 0.22))
    disc_r = int(S * 0.310)

    # 1. Gradient background (full icon)
    img = linear_gradient_bg(S, mask)

    # 2. Glow around disc
    img = Image.alpha_composite(img, disc_glow(S, cx, cy, disc_r))

    # 3. Frosted glass disc
    img = Image.alpha_composite(img, frosted_disc(S, cx, cy, disc_r))

    # 4. Specular highlight
    img = Image.alpha_composite(img, inner_highlight(S, cx, cy, disc_r))

    # 5. Exchange arrows (white, solid)
    img = Image.alpha_composite(img, draw_exchange_arrows(S, cx, cy, disc_r))

    # 6. Re-clip to rounded rect
    out = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    out.paste(img, mask=mask)
    return out


def make_launcher_icon(final=1024):
    raw = _make_icon_hires(final * 2)
    return raw.resize((final, final), Image.LANCZOS)


# ═══════════════════════════════════════════════════════════════════════════════
def make_adaptive_fg(final=1024):
    """Transparent adaptive-icon foreground (disc + arrows, no bg)."""
    S  = final * 2
    cx, cy = S // 2, S // 2
    disc_r = int(S * 0.310)

    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    img = Image.alpha_composite(img, disc_glow(S, cx, cy, disc_r))
    img = Image.alpha_composite(img, frosted_disc(S, cx, cy, disc_r))
    img = Image.alpha_composite(img, inner_highlight(S, cx, cy, disc_r))
    img = Image.alpha_composite(img, draw_exchange_arrows(S, cx, cy, disc_r))

    return img.resize((final, final), Image.LANCZOS)


# ═══════════════════════════════════════════════════════════════════════════════
def make_splash_logo(final=1024):
    """
    Large transparent logo for native splash (dark bg).
    Bigger disc, stronger glow — looks crisp at any density.
    """
    S  = final * 2
    cx, cy = S // 2, S // 2
    disc_r = int(S * 0.340)

    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))

    # Wider, softer glow for splash
    glow = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    gd   = ImageDraw.Draw(glow)
    for i in range(50):
        alpha = int(70 * (1 - i / 50) ** 1.5)
        ri    = disc_r + int(S * 0.007) * (50 - i)
        gd.ellipse([cx - ri, cy - ri, cx + ri, cy + ri],
                   fill=PURPLE + (alpha,))
    img = Image.alpha_composite(img, glow.filter(ImageFilter.GaussianBlur(S * 0.022)))

    img = Image.alpha_composite(img, frosted_disc(S, cx, cy, disc_r))
    img = Image.alpha_composite(img, inner_highlight(S, cx, cy, disc_r))
    img = Image.alpha_composite(img, draw_exchange_arrows(S, cx, cy, disc_r))

    return img.resize((final, final), Image.LANCZOS)


# ── Main ──────────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    base = "/Users/admin/project/unit_converter"

    icon = make_launcher_icon(1024)
    icon.save(f"{base}/assets/icon/icon.png", "PNG")
    print("✓ icon.png  1024×1024")

    fg = make_adaptive_fg(1024)
    fg.save(f"{base}/assets/icon/icon_fg.png", "PNG")
    print("✓ icon_fg.png  1024×1024")

    splash = make_splash_logo(1024)
    splash.save(f"{base}/assets/splash/splash_logo.png", "PNG")
    print("✓ splash_logo.png  1024×1024")
