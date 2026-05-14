"""
Generates clean launcher icon + splash logo for Unit Converter Pro.
Design: dark navy bg · purple disc · two-arrow sync symbol (white)
"""

import math
from PIL import Image, ImageDraw, ImageFilter

BG           = (255, 255, 255)
PURPLE_HI    = (120, 110, 255)
PURPLE       = (108,  99, 255)
PURPLE_LO    = ( 74,  63, 212)
WHITE        = (255, 255, 255, 255)


# ── Geometry helpers ──────────────────────────────────────────────────────────
def lerp(a, b, t):
    return a + (b - a) * t

def pt_on_circle(cx, cy, r, deg):
    rad = math.radians(deg)
    return cx + r * math.cos(rad), cy + r * math.sin(rad)

def draw_thick_arc(draw, cx, cy, r, start_deg, end_deg, color, thickness, steps=300):
    """Draw a thick arc as a series of filled circles (smooth)."""
    sweep = end_deg - start_deg
    for i in range(steps + 1):
        t   = i / steps
        deg = start_deg + sweep * t
        x, y = pt_on_circle(cx, cy, r, deg)
        hw = thickness / 2
        draw.ellipse([x - hw, y - hw, x + hw, y + hw], fill=color)

def draw_arrowhead(draw, cx, cy, r, tip_deg, color, size):
    """Draw a filled triangular arrowhead at tip_deg on circle r."""
    tx, ty = pt_on_circle(cx, cy, r, tip_deg)
    # tangent direction at tip
    tang_deg = tip_deg + 90          # perpendicular = tangent of circle
    tang_rad = math.radians(tang_deg)
    # arrow points back along tangent
    base_deg = tip_deg - 180
    back_x = tx + size * 1.6 * math.cos(math.radians(base_deg))
    back_y = ty + size * 1.6 * math.sin(math.radians(base_deg))
    left_x  = back_x + size * math.cos(tang_rad)
    left_y  = back_y + size * math.sin(tang_rad)
    right_x = back_x - size * math.cos(tang_rad)
    right_y = back_y - size * math.sin(tang_rad)
    draw.polygon([(tx, ty), (left_x, left_y), (right_x, right_y)], fill=color)

def draw_sync_icon(draw, cx, cy, R, stroke, color):
    """
    Two-arc sync/convert symbol:
      Arc 1: top half  – starts at 200°, ends at 340°  (clockwise), arrowhead at 340°
      Arc 2: bottom half – starts at 20°, ends at 160°  (clockwise), arrowhead at 160°
    """
    gap = 20   # degrees of gap between arcs
    # Arc 1: upper arc (left→right at top)
    s1, e1 = 200, 360 - gap
    draw_thick_arc(draw, cx, cy, R, s1, e1, color, stroke)
    draw_arrowhead(draw, cx, cy, R, e1, color, stroke * 0.9)

    # Arc 2: lower arc (right→left at bottom)
    s2, e2 = 20, 180 - gap
    draw_thick_arc(draw, cx, cy, R, s2, e2, color, stroke)
    draw_arrowhead(draw, cx, cy, R, e2, color, stroke * 0.9)


def rounded_rect_mask(size, radius):
    mask = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        [0, 0, size - 1, size - 1], radius=radius, fill=255
    )
    return mask


def radial_gradient_disc(size, cx, cy, r, c_inner, c_outer):
    """RGBA image with a smooth radial gradient disc."""
    img  = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    data = img.load()
    for y in range(size):
        for x in range(size):
            dx, dy = x - cx, y - cy
            dist   = math.hypot(dx, dy)
            if dist <= r:
                t = dist / r
                col = tuple(int(lerp(c_inner[i], c_outer[i], t)) for i in range(3)) + (255,)
                data[x, y] = col
    return img


# ═══════════════════════════════════════════════════════════════════════════════
#  LAUNCHER ICON  1024×1024
# ═══════════════════════════════════════════════════════════════════════════════
def make_launcher_icon(S=1024):
    img  = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    mask = rounded_rect_mask(S, radius=int(S * 0.22))

    # ── Background ────────────────────────────────────────────────────────────
    bg = Image.new("RGBA", (S, S), BG + (255,))
    img.paste(bg, mask=mask)

    # ── Purple glow blob (top-left) ───────────────────────────────────────────
    glow = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    gd   = ImageDraw.Draw(glow)
    br   = int(S * 0.45)
    gd.ellipse([-br // 3, -br // 3, br, br], fill=PURPLE + (20,))
    glow = glow.filter(ImageFilter.GaussianBlur(S * 0.15))
    composite = Image.alpha_composite(img, glow)
    # Re-clip to rounded rect
    clipped = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    clipped.paste(composite, mask=mask)
    img = clipped

    cx, cy = S // 2, S // 2

    # ── Outer decorative ring ─────────────────────────────────────────────────
    ring_r = int(S * 0.36)
    ring_w = max(2, int(S * 0.012))
    ring   = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    rd     = ImageDraw.Draw(ring)
    rd.ellipse(
        [cx - ring_r, cy - ring_r, cx + ring_r, cy + ring_r],
        outline=PURPLE_HI + (55,), width=ring_w,
    )
    img = Image.alpha_composite(img, ring)

    # ── Main purple disc (radial gradient) ────────────────────────────────────
    disc_r = int(S * 0.295)
    disc   = radial_gradient_disc(S, cx, cy, disc_r, PURPLE_HI, PURPLE_LO)
    img    = Image.alpha_composite(img, disc)

    # ── Sync arrows ───────────────────────────────────────────────────────────
    arrows   = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    ad       = ImageDraw.Draw(arrows)
    arrow_r  = int(disc_r * 0.60)
    stroke   = max(4, int(S * 0.030))
    draw_sync_icon(ad, cx, cy, arrow_r, stroke, WHITE)
    img = Image.alpha_composite(img, arrows)

    # Final clip
    out = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    out.paste(img, mask=mask)
    return out


# ═══════════════════════════════════════════════════════════════════════════════
#  ADAPTIVE FOREGROUND  1024×1024  (transparent bg)
# ═══════════════════════════════════════════════════════════════════════════════
def make_adaptive_fg(S=1024):
    img  = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    cx, cy = S // 2, S // 2
    disc_r = int(S * 0.295)

    disc = radial_gradient_disc(S, cx, cy, disc_r, PURPLE_HI, PURPLE_LO)
    img  = Image.alpha_composite(img, disc)

    arrows  = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    ad      = ImageDraw.Draw(arrows)
    arrow_r = int(disc_r * 0.60)
    stroke  = max(4, int(S * 0.030))
    draw_sync_icon(ad, cx, cy, arrow_r, stroke, WHITE)
    return Image.alpha_composite(img, arrows)


# ═══════════════════════════════════════════════════════════════════════════════
#  SPLASH LOGO  512×512  (transparent, used centred on splash bg)
# ═══════════════════════════════════════════════════════════════════════════════
def make_splash_logo(S=512):
    img  = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    cx, cy = S // 2, S // 2
    disc_r  = int(S * 0.36)

    # Soft glow
    glow = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    gd   = ImageDraw.Draw(glow)
    gr   = disc_r + int(S * 0.12)
    gd.ellipse([cx - gr, cy - gr, cx + gr, cy + gr], fill=PURPLE + (60,))
    glow = glow.filter(ImageFilter.GaussianBlur(S * 0.12))
    img  = Image.alpha_composite(img, glow)

    disc = radial_gradient_disc(S, cx, cy, disc_r, PURPLE_HI, PURPLE_LO)
    img  = Image.alpha_composite(img, disc)

    arrows  = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    ad      = ImageDraw.Draw(arrows)
    arrow_r = int(disc_r * 0.60)
    stroke  = max(3, int(S * 0.038))
    draw_sync_icon(ad, cx, cy, arrow_r, stroke, WHITE)
    return Image.alpha_composite(img, arrows)


# ── Main ──────────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    base = "/Users/admin/project/unit_converter"

    icon = make_launcher_icon(1024)
    icon.save(f"{base}/assets/icon/icon.png", "PNG")
    print("✓ assets/icon/icon.png  (1024×1024)")

    fg = make_adaptive_fg(1024)
    fg.save(f"{base}/assets/icon/icon_fg.png", "PNG")
    print("✓ assets/icon/icon_fg.png  (adaptive foreground)")

    splash = make_splash_logo(512)
    splash.save(f"{base}/assets/splash/splash_logo.png", "PNG")
    print("✓ assets/splash/splash_logo.png  (512×512)")
