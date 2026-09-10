# Journal specifications for figures

Welcome to the **Journal of Unnecessarily Specific Figures (JUSF)**: serious about pixels, inexplicably fond of purple and lime.

**Fictional journal, real acceptance criteria.** Follow these workshop rules exactly.

## Figure 1 requirements

| Item | Required result |
| --- | --- |
| File | `runs/with-fix/summary.png`: PNG, **1800 × 1200 pixels**, with **300 dpi** resolution metadata; 6 × 4 inches at that resolution. |
| Background | White. |
| Text contrast | Black text on white, including value labels beside the bars. Keep labels out of the colored fills. |
| Layout | Horizontal, side-by-side grouped bars. Each category has Group A above Group B, with space between categories. Bars must not overlap. |
| Categories, top to bottom | Complete measurements; Missing height only; Missing weight only; Missing height and weight. |
| Group A counts | **42, 31, 18, 9**, in category order; total 100. |
| Group B counts | **64, 18, 12, 6**, in category order; total 100. |
| Group A fill | **#440154**, also known to our editors as “midnight aubergine.” |
| Group B fill | **#B8DE29**, or “radioactive pear.” |
| Bar borders | Black outlines, greater than 0 and at most **1 point** thick, so the lime bars remain visible against white. In R, `lwd = 1` is approximately 0.75 points. |
| Font | A **monospace/typewriter** face throughout. Any installed monospace face is allowed; do not substitute a proportional font. |
| Text size | **9 points** for category labels, ticks, axis label, legend, and count labels; **11 points, bold** for the title. |
| Title | Exactly **Measurement completeness**. |
| Count axis label | Exactly **Number of measurements**. |
| Count axis | Starts at **0**, ends at **80**, with ticks at **0, 20, 40, 60, 80**. |
| Legend | Exactly **Group A** and **Group B**, in that order, with the matching fills and no surrounding frame. |
| Value labels | All eight counts as integers, placed beside their corresponding bar ends. |
| Readability | Every label fits inside the saved image. No clipped or overlapping text, bars, or legend. |
| Alternative text | Supply `runs/with-fix/summary.alt.txt`: at most 150 words describing the comparison, both groups, category values, and main pattern. Say the counts are invented aggregates. Use group names, not color names, to explain results. |

## Accessibility is part of acceptance

- Inspect the chart at **6 × 4 inches and in grayscale**. Labels, group positions, and outlines must carry the comparison without color alone. Check legibility and clipping; no palette guarantees accessibility for everyone.
- Write the alt text **separately**; the plotting CLI still writes only the PNG. Check every value and the takeaway against the chart. These invented counts support no clinical claim.
- Attach the description through the document, website, or slide's alternative-text feature. A sidecar file is not automatically available to a screen reader. Use a nearby caption or accessible table for further detail.

W3C references: [complex-image descriptions](https://www.w3.org/WAI/tutorials/images/complex/) and [graphical contrast](https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast.html), reviewed September 10, 2026. This checklist is not a full accessibility certification.

## Before calling it done

Read this file before editing. Preserve the counts and behavior. Run the behavior tests and figure checker, then review the PNG and alt text yourself. Report unmet or unverified requirements; do not change this specification or the checker to obtain a pass.

A stacked version needs a separate brief after this grouped figure is complete. For a real submission, replace these fictional rules with the journal's current requirements and follow the [lab data guidance](lab-data-policy.md).
