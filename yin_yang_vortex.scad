/*
 * Yin Yang Vortex Torus
 *
 * Based on the classic 3D "Vortex Torus" design.
 * From the top down, you see a traditional Yin-Yang, but its surface
 * spirals smoothly into the central hole of a perfect torus.
 *
 * The two halves are completely interlocking rings (they cannot be pulled apart).
 *
 * RENDERING: F5 for quick preview, F6 for full render.
 * PRINTING: Set show_piece to 1 or 2 to export individual STLs for dual-color,
 *           or leave as 0 for a print-in-place assembly.
 */

/* [Dimensions] */
major_radius = 30;       // Center of torus to center of tube
minor_radius = 16;       // Radius of the torus tube
gap = 0.4;               // Clearance between the two halves
twist_angle = 180;       // How much the vortex spirals (degrees)
dot_radius = 4;          // Size of the yin-yang dots
bridge_width = 1.5;      // Thickness of the connection to the dots

/* [Quality] */
$fn = 60;                // Curve smoothness (increase for final render)

/* [Export] */
show_piece = 0;          // 0 = Both, 1 = Yin (Green), 2 = Yang (Purple)

// Internal calculations
R_out = major_radius + minor_radius;
H_ext = minor_radius * 2 + 2;

// 2D Yang profile: one half of a yin-yang, including the dot and its connecting bridge.
module yang_2d(r, dr, bw) {
    difference() {
        union() {
            // Main teardrop shape
            difference() {
                union() {
                    // Right half
                    intersection() {
                        circle(r = r + 2);
                        translate([0, -(r+2)]) square([r+2, (r+2)*2]);
                    }
                    // Top lobe
                    translate([0, r / 2]) circle(r = r / 2);
                }
                // Bottom lobe void
                translate([0, -r / 2]) circle(r = r / 2);
            }
            // Bottom dot
            translate([0, -r / 2]) circle(r = dr);
            // Bridge from outer edge to the dot
            translate([-bw/2, -r]) square([bw, r/2]);
        }
        // Top dot void
        translate([0, r / 2]) circle(r = dr);
        // Void for the other half's bridge
        translate([-bw/2, r/2]) square([bw, r/2]);
    }
}

// Extrude the 2D profile with a twist to form the vortex spiral
module yang_twisted(r, dr, bw, g, twist) {
    // Translate down so the twist is centered across the torus equator
    translate([0, 0, -H_ext / 2])
        linear_extrude(height = H_ext, twist = twist, slices = 120)
            offset(r = -g / 2)
                yang_2d(r, dr, bw);
}

// The smooth outer torus shape
module smooth_torus(R, r) {
    rotate_extrude()
        translate([R, 0, 0])
            circle(r = r);
}

// The final pieces are the intersection of the smooth torus and the twisted spiral
module piece_A() {
    intersection() {
        smooth_torus(major_radius, minor_radius);
        yang_twisted(R_out, dot_radius, bridge_width, gap, twist_angle);
    }
}

module piece_B() {
    intersection() {
        smooth_torus(major_radius, minor_radius);
        rotate([0, 0, 180])
            yang_twisted(R_out, dot_radius, bridge_width, gap, twist_angle);
    }
}

// --- Render ---
// Note: We rotate the assembly slightly so the top view aligns cleanly
render_rotation = (twist_angle / 2) * (minor_radius / (H_ext / 2));

rotate([0, 0, -render_rotation]) {
    if (show_piece != 2)
        color("YellowGreen") piece_A();

    if (show_piece != 1)
        color("Orchid") piece_B();
}
