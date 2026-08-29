// Parametric rotary-encoder knob with reference-file-style diamond knurling.
//
// The knurling is adapted from the supplied parametric container.scad:
// two opposing twisted ridge passes create the diamond pattern.
// The supplied knurl algorithm is by DrJones and is marked CC-BY in the
// reference file.
//
// Coordinate system:
//   - The encoder shaft enters through the bottom at Z = 0.
//   - The hollow mounting-nut skirt occupies Z = 0 .. skirt_height.
//   - The knurled grip occupies skirt_height .. skirt_height + knurled_height.
//   - A smooth chamfered top cap sits above the grip.

$fn = 96;

// ----------------------------- PARAMETERS -----------------------------

// Main diameter and vertical proportions.
knob_diameter = 20;
knurled_height = 10;
skirt_height = 6.5;
top_cap_height = 2;
top_chamfer = 1;

// Smooth full-width skirt for hiding the encoder mounting nut.
// The default wall is 2 mm, leaving a 16 mm internal cavity in a 20 mm skirt.
skirt_diameter = knob_diameter;
skirt_wall = 2;
nut_cavity_diameter = skirt_diameter - 2 * skirt_wall;

// Reference-file-style primary knurl pass.
knurl_primary = true;
knurl_angle = 35;          // matches the supplied reference file; use 45 for steeper Xs
knurl_line_width = 0.30;   // physical ridge/groove width in mm
knurl_depth = 0.75;        // radial depth of the cut/ridge in mm
knurl_spacing = 0.80;      // line-to-line gap as a multiple of line width
knurl_shape = 4;           // 0 = round, 4 = sharp, 6 = flat

// Opposing knurl pass. This creates the other half of the diamond pattern.
knurl_secondary = true;
knurl_secondary_angle = -35;
knurl_secondary_line_width = 0.30;
knurl_secondary_depth = 0.75;
knurl_secondary_spacing = 0.80;
knurl_secondary_shape = 4;

// Encoder shaft / D-bore.
shaft_diameter = 6;
shaft_flat_depth = 1.8;   // deeper flat, moved farther toward the shaft center
shaft_clearance = 0.18;    // radial clearance added to the D-bore; snug fit

// Set bore_depth >= 0 for an explicit D-slot depth. With -1, the slot is
// exactly knurled_height (10 mm by default), ending under the smooth top cap.
bore_depth = -1;

// Optional visual references. They are non-printing and disabled by default.
show_encoder_reference = false;
reference_encoder_height = 12;
reference_encoder_diameter = 10;
show_nut_reference = false;
reference_nut_height = 3;
reference_nut_diameter = 10;

// ----------------------------- DERIVED VALUES --------------------------

body_radius = knob_diameter / 2;
knob_width = skirt_height + knurled_height + top_cap_height;
actual_bore_depth = (bore_depth < 0) ? knurled_height : bore_depth;

// ----------------------------- HELPERS ---------------------------------

// A D-shaped prism. The flat is on +X, matching the usual D-shaft convention.
module d_bore(height) {
    bore_radius = shaft_diameter / 2 + shaft_clearance;
    bore_flat_x = bore_radius - shaft_flat_depth;

    intersection() {
        cylinder(r = bore_radius, h = height);
        translate([-bore_radius - 1, -bore_radius - 1, -0.01])
            cube([
                bore_flat_x + bore_radius + 1,
                2 * bore_radius + 2,
                height + 0.02
            ]);
    }
}

// This is the supplied file's knurl-generation method. Each small polygonal
// ridge is twisted while being extruded, and a second pass in the opposite
// direction forms the diamond/crosshatch pattern.
module reference_knurl(R, h, r = 0.5, w = 1, dist = 2, angle = 30, sh = 0) {
    n = round(2 * PI * R / ((dist + 1) * 2 * w) * cos(angle));

    let($fn = sh > 0 ? sh : 24 + 4 * w)
        linear_extrude(
            height = h,
            twist = -h * tan(angle) / (2 * PI * R) * 360,
            convexity = 5,
            slices = h / (sh > 0 ? 1 : 3) / cos(angle)
        )
            for (i = [0 : 1 : n - 1])
                rotate([0, 0, i * 360 / n])
                    translate([R + 0.02, 0, 0])
                        scale([
                            r * (sh > 3 && sh % 4 > 0 ? 1 / cos(180 / sh) : 1),
                            w / cos(angle)
                        ])
                            rotate([0, 0, sh == 3 ? 60 : sh % 4 == 2 ? 90 : 0])
                                circle();
}

module mounting_skirt() {
    // Full-width, smooth skirt. It is intentionally not knurled.
    if (skirt_height > 0 && skirt_diameter > 0)
        cylinder(r = skirt_diameter / 2, h = skirt_height);
}

module smooth_top_head() {
    top_head_z = skirt_height + knurled_height;

    // Smooth cylindrical top section followed by a container-style chamfer.
    if (top_cap_height > top_chamfer)
        translate([0, 0, top_head_z])
            cylinder(r = body_radius, h = top_cap_height - top_chamfer);

    translate([0, 0, top_head_z + top_cap_height - top_chamfer])
        cylinder(
            h = top_chamfer,
            r1 = body_radius,
            r2 = body_radius - top_chamfer
        );
}

module outer_body() {
    // The skirt and grip are separate so skirt_diameter remains meaningful.
    mounting_skirt();
    translate([0, 0, skirt_height])
        cylinder(r = body_radius, h = knurled_height);
    smooth_top_head();
}

module nut_cavity() {
    // The cavity is open from the bottom and stops at the underside of the
    // knurled grip. The D-slot above it provides the shaft engagement.
    translate([0, 0, -0.02])
        cylinder(r = nut_cavity_diameter / 2, h = skirt_height + 0.04);
}

module knurl_cuts() {
    if (knurl_primary)
        reference_knurl(
            body_radius,
            knurled_height,
            r = knurl_depth,
            w = knurl_line_width,
            dist = knurl_spacing,
            angle = knurl_angle,
            sh = knurl_shape
        );

    if (knurl_secondary)
        reference_knurl(
            body_radius,
            knurled_height,
            r = knurl_secondary_depth,
            w = knurl_secondary_line_width,
            dist = knurl_secondary_spacing,
            angle = knurl_secondary_angle,
            sh = knurl_secondary_shape
        );
}

module knob() {
    assert(knurled_height > 0, "knurled_height must be greater than zero");
    assert(skirt_height >= 0, "skirt_height must be non-negative");
    assert(top_cap_height >= top_chamfer && top_chamfer >= 0,
           "top_cap_height must be >= top_chamfer >= 0");
    assert(nut_cavity_diameter > 0 && nut_cavity_diameter < skirt_diameter,
           "nut_cavity_diameter must be smaller than skirt_diameter");
    assert(knurl_depth > 0 && knurl_depth < body_radius,
           "knurl_depth must be positive and smaller than the knob radius");

    difference() {
        outer_body();

        // Hollow out the smooth skirt so the encoder nut can sit inside it.
        nut_cavity();

        // Move the supplied knurling algorithm above the smooth skirt.
        translate([0, 0, skirt_height])
            knurl_cuts();

        // The D-slot starts at the roof of the nut cavity and is 10 mm high
        // by default, matching the knurled grip height.
        translate([0, 0, skirt_height - 0.02])
            d_bore(min(actual_bore_depth, knob_width) + 0.04);
    }
}

// ----------------------------- OUTPUT ----------------------------------

knob();

if (show_encoder_reference)
    %translate([0, 0, skirt_height])
        cylinder(r = reference_encoder_diameter / 2,
                 h = min(reference_encoder_height, actual_bore_depth));

if (show_nut_reference)
    %translate([0, 0, 0])
        cylinder(r = reference_nut_diameter / 2,
                 h = min(reference_nut_height, skirt_height));
