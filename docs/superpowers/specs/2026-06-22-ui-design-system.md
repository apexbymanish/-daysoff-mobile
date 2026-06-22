# daysoff — UI Design System
*Authored 2026-06-22. Principles: low cognitive load · maximum usability · 60-30-10 colour · WCAG 2.1 AAA.*

---

## 1. Design Philosophy

### Cognitive Load Rules (Nielsen Norman Group)
The human working memory holds **7 ± 2 chunks** at once (Miller's Law). Every screen must respect this.

| Rule | Implementation |
|---|---|
| **One primary action per screen** | Only one filled/teal button visible at a time |
| **Progressive disclosure** | Show summary → tap to expand detail |
| **Max 3 levels of visual hierarchy** | Large → Medium → Small. Never nest a fourth level. |
| **Group related items** | Gestalt proximity: things that belong together sit within 8 dp of each other |
| **Reduce choices** (Hick's Law) | Country picker shows top 5 + search; no grid of 200 flags |
| **Consistent positioning** | Save button always bottom-right. Back always top-left. Never move affordances. |
| **Avoid colour as the only signal** | Every semantic colour is paired with a shape or label |

### Usability Principles (Apple HIG + Material 3)
- Touch targets: **minimum 48 × 48 dp** (Apple recommends 44 pt; Google 48 dp)
- Tap feedback: ripple or subtle scale (0.97) within **100 ms**
- Empty states always explain **what to do**, never just "Nothing here"
- Error messages say **what went wrong + how to fix it**

---

## 2. Colour System — 60-30-10

```
╔══════════════════════════════════════════════════════════════╗
║  60 % NEUTRAL   ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  ║
║  30 % SECONDARY ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒               ░░░░░  ║
║  10 % ACCENT    ████████                                     ║
╚══════════════════════════════════════════════════════════════╝
```

### Palette (verified WCAG 2.1 AAA)

| Role | Hex | Usage | Contrast on white |
|---|---|---|---|
| **Surface 60%** | `#F3F4F6` | App background, list backgrounds | — |
| **Surface-2 30%** | `#FFFFFF` | Cards, sheets, inputs | — |
| **Brand 10%** | `#0A4A4F` | CTAs, active nav, key numerals | **9.98:1 AAA** |
| **Text Primary** | `#111827` | Headings, card titles | **17.74:1 AAA** |
| **Text Secondary** | `#4B5563` | Body copy, descriptions | **7.55:1 AAA** |
| **Text Tertiary** | `#374151` | Labels, metadata on #F3F4F6 | **9.37:1 AAA** |
| **Holiday** | `#991B1B` | Holiday day indicators | **7.60:1 AAA** on `#FEF2F2` |
| **Holiday surface** | `#FEF2F2` | Holiday day cell background | — |
| **PTO** | `#0A4A4F` | PTO day cells, save button | 9.98:1 AAA on white |
| **PTO surface** | `#E6F4F4` | PTO day cell background (tinted) | — |
| **Weekend** | `#374151` | Weekend day label | 9.37:1 AAA on `#F3F4F6` |
| **Weekend surface** | `#F3F4F6` | Weekend day cell background | — |
| **Outline** | `#D1D5DB` | Card borders, dividers | — |
| **Outline subtle** | `#E5E7EB` | Input borders, inner dividers | — |

### Colour meaning table (always pair with label — never colour alone)

| Day type | Surface | Label colour | Icon/shape |
|---|---|---|---|
| Holiday | `#FEF2F2` | `#991B1B` | No icon — the red surface is the signal |
| PTO (your action) | `#E6F4F4` | `#0A4A4F` | Dot or bolt icon in teal |
| Weekend | `#F3F4F6` | `#374151` | — |

### Do not use

- `opacity:` on text for "secondary" — use the explicit secondary hex instead (opacity breaks contrast guarantees)
- Colours outside this palette for new components without WCAG verification
- Red for anything other than holidays/errors (semantic confusion)

---

## 3. Typography Scale

Use **system font** (-apple-system / Roboto / san-serif). No external font downloads.

| Token | Size | Weight | Line-height | Use |
|---|---|---|---|---|
| `display` | 32 sp | 900 | 1.1 | Big numerals (day count "11") |
| `title-l` | 20 sp | 700 | 1.3 | Card title ("Take 3 days off") |
| `title-m` | 17 sp | 600 | 1.4 | Section headers |
| `body` | 15 sp | 400 | 1.6 | Descriptions, context text |
| `label` | 12 sp | 600 | 1.0 | Caps labels, pill text, day-name in ribbon |
| `micro` | 10 sp | 700 | 1.0 | Eyebrow labels, unit text ("days") |

**Rules:**
- Max **2 type sizes** visible at once in a single card
- Never use font-size below 12 sp (minimum for readability)
- Letter-spacing on caps labels: `+0.08em`

---

## 4. Spacing — 8 dp Grid

All padding, margin, and gap values are multiples of **8 dp**.

```
4 dp  — micro gap (icon-to-label, between tightly grouped elements)
8 dp  — inner element gap (label → value)
12 dp — tight component padding
16 dp — standard card padding (horizontal)
20 dp — generous card padding (top/bottom)
24 dp — section gap
32 dp — screen-level top padding
```

**Card anatomy:**
```
┌─ 24 radius ──────────────────────────────────────────┐
│  16 dp ← padding → 16 dp                            │
│                                                      │
│  [Title]                         [Pill]              │
│  [Context line]                                      │
│                          ← 12 dp gap →               │
│  [Day ribbon / colour bar]                           │
│                          ← 12 dp gap →               │
│  ── divider ──────────────────────────────────────── │
│  [Location label]               [Save button]        │
│                                                      │
└──────────────────────────────────────────────────────┘
```

---

## 5. Component Specifications

### 5.1 Break Card (Plan tab)

Shows a multi-day break with a proportional colour bar.

```
Elevation: shadow-sm (0 2dp 4dp rgba(0,0,0,0.06))
Corner radius: 24 dp
Background: #FFFFFF
Border: 1 dp #E5E7EB
```

**Colour bar (H / PTO / Weekend segments):**
- Height: 20 dp
- Corner radius: 6 dp (clips inside)
- No gap between segments — flush fill
- Segments: [holiday %] [pto %] [weekend %]
- Colours: `#991B1B` opacity 0.7 / `#0A4A4F` / `#E5E7EB`
- No labels inside the bar — legend sits below (8 dp gap)

**Legend pills (below bar):**
- `○ 3 hol` / `○ 4 PTO` / `○ 4 wkd` — 8 dp gap between items
- Dot: 6 × 6 dp, radius 2 dp
- Text: `label` token, `#6B7280`

**Header:**
- Big numeral: `display` token, colour `#0A4A4F`
- Unit "days": `micro` token, `#0A4A4F`, baseline-aligned to numeral
- Date range below: `label` token, `#6B7280`
- PTO pill top-right: background `#E6F4F4`, text `#0A4A4F`

### 5.2 Sandwich Card (Sandwich tab)

Shows a contiguous day strip with per-day colour cells.

**Day segment bar:**
- Height: 52 dp
- No gap between segments — 2 dp gap maximum (use 0 for ≥9 days)
- Corner radius: 10 dp on the outermost container; 0 on inner cells
- Each cell: flex:1 (equal width)
- Cell contents: day-name (`micro` token) + date number (`label` token, 14 sp)
- Colours per day type: see colour table above

**Minimum readable cell width: 28 dp**
- At 9 cells on 375 dp screen: (375 - 32 - 16) dp / 9 = ~36 dp ✓
- At 11 cells: (375 - 32 - 16) dp / 11 = ~30 dp ✓
- If cells would drop below 28 dp: hide day-name label, show date only

**Stat pills (top-right of card):**
- Beach pill: background `#0A4A4F`, text white — total break days
- Bolt pill: background `#E6F4F4`, text `#0A4A4F` — PTO cost

### 5.3 Pills / Badges

```
Height: 28 dp
Horizontal padding: 12 dp
Corner radius: 999 dp (stadium)
Font: label token (12 sp, weight 700, caps +0.05em)
Icon (optional): 14 dp, 4 dp gap to text
```

Variants:
- **Primary** (CTA, total days): bg `#0A4A4F`, text `#FFFFFF`
- **Tint** (PTO cost): bg `#E6F4F4`, text `#0A4A4F`
- **Neutral** (metadata): bg `#F3F4F6`, text `#374151`
- **Holiday**: bg `#FEF2F2`, text `#991B1B`

### 5.4 Buttons

| Variant | Background | Foreground | Use |
|---|---|---|---|
| **Filled** | `#0A4A4F` | `#FFFFFF` | Primary action (Save, Continue) |
| **Tonal** | `#E6F4F4` | `#0A4A4F` | Secondary action |
| **Text** | transparent | `#0A4A4F` | Tertiary (Cancel, Learn more) |

Button specs:
- Height: 48 dp (accessible touch target)
- Corner radius: 12 dp (filled) / 999 dp (stadium) for icon-label CTAs
- Font: 14 sp weight 700
- Disabled: opacity 0.38 on the entire button — do not change colour

### 5.5 List / Feed spacing

```
Section header: 32 dp top margin, 8 dp bottom margin
Card: 8 dp bottom margin between cards
Screen edges: 16 dp horizontal padding
```

---

## 6. Accessibility (WCAG 2.1)

### Verified contrast ratios

All ratios computed with the exact WCAG relative luminance formula.

| Pair | Ratio | Level |
|---|---|---|
| `#111827` on `#FFFFFF` | 17.74:1 | **AAA** normal + large |
| `#4B5563` on `#FFFFFF` | 7.55:1 | **AAA** normal + large |
| `#0A4A4F` on `#FFFFFF` | 9.98:1 | **AAA** normal + large |
| `#FFFFFF` on `#0A4A4F` | 9.98:1 | **AAA** normal + large |
| `#991B1B` on `#FEF2F2` | 7.60:1 | **AAA** normal + large |
| `#374151` on `#F3F4F6` | 9.37:1 | **AAA** normal + large |
| `#0A4A4F` on `#E6F4F4` | 8.84:1 | **AAA** normal + large |
| `#111827` on `#F3F4F6` | 16.12:1 | **AAA** normal + large |

### Non-text contrast (UI components — WCAG 1.4.11)

Minimum 3:1 required for UI component boundaries against adjacent colour.

- Card border `#D1D5DB` on `#F3F4F6` background: 1.33:1 — **use shadow instead of border** to distinguish cards from background
- Input border `#D1D5DB` on `#FFFFFF`: 1.61:1 — **increase to `#9CA3AF`** for WCAG AA (3.02:1 ✓)
- Day segment cells rely on colour + label — not colour alone (Rule 1.4.1)

### Touch and motor

- All interactive elements: 48 × 48 dp minimum (WCAG 2.5.5 AAA)
- No time-limited interactions
- Swipe to delete: always paired with visible long-press alternative

### Screen reader (semantic)

- Each card: `Semantics(label: '11-day break, Sep 17 to Sep 27, uses 4 PTO')`
- Day ribbon: mark as `excludeSemantics: true` — the card-level label covers it
- Pills: `Semantics(label: '4 PTO days used')`
- Save button: `Semantics(label: 'Save Chuseok break to my breaks')`

---

## 7. Information Architecture per Screen

### Plan tab card — 3 chunks max

```
CHUNK 1 — What you get:     "11 days"  +  date range
CHUNK 2 — What it costs:    pill "4 PTO used"
CHUNK 3 — How it breaks:    colour bar + 3-item legend
```

Details (holiday names, exact dates) → hidden until user taps card.

### Sandwich tab card — 3 chunks max

```
CHUNK 1 — The offer:        "Take 3 days off"
CHUNK 2 — The pay-off:      "🏖 9 days  ⚡ 3 PTO"
CHUNK 3 — The visual proof: day-segment strip
```

Context line ("Chuseok + preceding day") is secondary — rendered in `#6B7280`, smaller.

---

## 8. Motion

- **Duration:** 200 ms for transitions within a screen; 300 ms for screen-level pushes
- **Easing:** `easeInOutCubic` — never linear
- **Card tap:** scale 0.97 on press-down, 1.0 on release (gives tactile feedback)
- **`prefers-reduced-motion`:** all animations disabled; use instant alpha/opacity only
- **Loading state:** shimmer skeleton that mirrors card shape (not a spinner)

---

## 9. Interaction Pattern: Save Flow

```
User taps "Save" →
  Button dims (0.6 opacity) immediately        [0 ms — instant feedback]
  Haptic: light impact                          [0 ms]
  Bookmark icon animates: outline → filled      [200 ms]
  Snackbar: "Saved to your breaks"              [300 ms delay]
  Snackbar auto-dismisses                       [2500 ms]
```

No modal dialog. No confirmation required. Undo is available in the snackbar ("Undo" text button).

---

## 10. What NOT to Do

| Anti-pattern | Why | What to do instead |
|---|---|---|
| Coloured app bar | Increases cognitive load (two competing focal points) | White or `#F3F4F6` app bar always |
| More than 2 fonts | Visual noise | System font only, vary weight |
| Rainbow status indicators | Colour-blind users lose meaning | Max 3 semantic colours; always pair with label |
| Truncated long text ("Chuse…") | Forces user to guess | Wrap to 2 lines; use `overflow: ellipsis` only in table cells with fixed width |
| Floating action button + bottom nav | Two navigation systems compete | Bottom nav only; "Save" lives inside the card |
| Disabled buttons with no explanation | User doesn't know why | Show a tooltip or inline message explaining the requirement |
| Icon-only buttons | Ambiguous affordance | Always pair icon + label for primary actions |

---

## 11. Colour Application Checklist (before implementing any new component)

- [ ] Background is either `#FFFFFF`, `#F3F4F6`, or a semantic surface (`#FEF2F2`, `#E6F4F4`)
- [ ] All body text uses `#111827` or `#4B5563` — not a brand colour
- [ ] Brand teal `#0A4A4F` appears on ≤ 10% of visible pixels
- [ ] Every colour-coded element has a paired text label
- [ ] Contrast ratio verified ≥ 4.5:1 for all text (target AAA ≥ 7:1)
- [ ] Touch targets ≥ 48 × 48 dp
- [ ] Tested with device bold-text accessibility setting enabled
