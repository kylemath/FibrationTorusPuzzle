/*
 * Yin-Yang Interlocking Rings
 *
 * A torus divided into two linked rings (Hopf link) by a twisted
 * yin-yang S-curve. Each ring is thickest at its lobe and pinches
 * thin at the tail, wrapping through the widest section of the
 * opposite ring. The two pieces cannot be separated without breaking.
 *
 * RENDERING: F5 for preview, F6 for full render (30-120s).
 * PRINTING:  Set show_ring = 1 or 2 to export individual STLs,
 *            or 0 for print-in-place linked pair.
 */

/* [Dimensions] */
// Distance from torus center to tube center
major_radius = 30;
// Yin-yang cross-section radius (tube radius)
minor_radius = 14;
// Clearance between the two rings (0.3-0.5 for FDM, 0.15-0.25 for SLA)
gap = 0.4;

/* [Quality] */
// Segments around the torus path (more = smoother but slower)
segments = 72;
// Circle facet count
$fn = 48;

/* [Export] */
// 0 = both rings, 1 = ring A only, 2 = ring B only
show_ring = 1;


// --- Yin-yang half (the "yang" teardrop) ---
// Left semicircle + upper lobe - lower counter-lobe.
// At rotation 0 the lobe points up and the tail points down.
module yin_yang_half(r) {
    difference() {
        union() {
            intersection() {
                circle(r = r);
                translate([-r, -r]) square([r, r * 2]);
            }
            translate([0, r / 2]) circle(r = r / 2);
        }
        translate([0, -r / 2]) circle(r = r / 2);
    }
}

// --- One ring of the linked pair ---
// Sweeps a yin-yang half around the torus, twisting it by one
// full turn so the cross-section S-curve completes a 360° helix.
// `phase` selects which half: 0 for yang, 180 for yin.
module yin_yang_ring(R, r, g, n, phase) {
    step = 360 / n;
    for (i = [0 : n - 1]) {
        a = i * step;
        rotate([0, 0, a])
            rotate_extrude(angle = step + 0.1)
                translate([R, 0])
                    rotate([0, 0, a + phase])
                        offset(r = -g / 2)
                            yin_yang_half(r);
    }
}

// --- Render ---
if (show_ring != 2)
    color("YellowGreen")
        yin_yang_ring(major_radius, minor_radius, gap, segments, 0);

if (show_ring != 1)
    color("Orchid")
        yin_yang_ring(major_radius, minor_radius, gap, segments, 180);
