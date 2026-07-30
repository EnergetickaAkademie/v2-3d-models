$fn = 60;

board_w = 43.0;
board_h = 38.0;
board_clearance = 1.1; 

usb_in_y_original = 125.73;
rgb_in_y_original = 114.3;

// --- ORIGINAL STANDOFFS ---
orig_h1 = [13.46, 140.34]; 
orig_h2 = [50.55, 140.46]; 
orig_h3 = [50.42, 108.59]; 
orig_h4 = [13.46, 108.59]; 

board_center_x = (orig_h1[0] + orig_h2[0] + orig_h3[0] + orig_h4[0]) / 4;
board_center_y = (orig_h1[1] + orig_h2[1] + orig_h3[1] + orig_h4[1]) / 4;

// --- ADJUSTED STANDOFFS ---
h1 = [orig_h1[0] - 5.0, orig_h1[1]]; 
h2 = [orig_h2[0] - 1.0, orig_h2[1]]; 
h3 = [orig_h3[0] - 1.0, orig_h3[1]]; 
h4 = [orig_h4[0] - 5.0, orig_h4[1]]; 

case_width = board_w + board_clearance;
case_length = board_h + board_clearance;

front_extension = 5.0; 
case_min_x = board_center_x - (case_width / 2) - front_extension; 
case_max_x = board_center_x + (case_width / 2); 
case_min_y = board_center_y - (case_length / 2); 
case_max_y = board_center_y + (case_length / 2); 

wall_thickness = 1.5; 
base_thickness = 2.0; 
standoff_h = 2.5; 
nominal_standoff_h = 2.5; 
pcb_thickness = 1.6;

usb_center_below_pcb = 1.6; 
usb_z = base_thickness + nominal_standoff_h - usb_center_below_pcb; 
total_internal_height = nominal_standoff_h + pcb_thickness; 

// Flip coordinates to match the mirrored standoffs
usb_in_y_flipped = board_center_y - (usb_in_y_original - board_center_y);
rgb_in_y_flipped = board_center_y - (rgb_in_y_original - board_center_y);

// LED sits on the downward-facing PCB. Center of a ~2mm LED is ~1mm below PCB surface.
rgb_z = base_thickness + nominal_standoff_h - 1.0; 

// --- FLEX TAB PARAMETERS ---
side_wall_t = 5.0;
tab_start_x = case_min_x + 12.0;
tab_l = 20.0;
slit_w = 1.0;
tab_protrusion = 2.0;

module pill(w, h, depth) {
    r = h/2;
    hull() {
        translate([-(w/2 - r), 0, 0]) cylinder(r=r, h=depth, center=true);
        translate([ (w/2 - r), 0, 0]) cylinder(r=r, h=depth, center=true);
    }
}

module standoff(pos) {
    translate([pos[0], pos[1], base_thickness])
    difference() {
        cylinder(d=5.5, h=standoff_h); 
        translate([0,0,1]) cylinder(d=2.0, h=standoff_h); 
    }
}

module slide_in_tray_upside_down() {
    union() {
        difference() {
            // Original outer bounding box
            translate([case_min_x - wall_thickness, case_min_y - side_wall_t, 0])
                cube([case_width + front_extension + wall_thickness, case_length + side_wall_t + wall_thickness, total_internal_height + base_thickness]);
            
            // Inner cavity: shortened by wall_thickness to leave a solid back wall
            translate([case_min_x, case_min_y, base_thickness])
                cube([case_width + front_extension - wall_thickness, case_length, total_internal_height + 1]);

            // --- BACK WALL MIDDLE 1/3RD CUTOUT ---
            translate([case_max_x - wall_thickness - 0.1, case_min_y + (case_length / 3), base_thickness])
                cube([wall_thickness + 0.2, case_length / 3, total_internal_height + 1]);

            // USB Cutout 
            translate([case_min_x, usb_in_y_flipped, usb_z]) 
                rotate([90, 0, -90]) 
                pill(9.0, 4.0, 20); 
                
            // RGB LED Cutout 
            translate([case_min_x, rgb_in_y_flipped, rgb_z]) 
                rotate([90, 0, -90]) 
                pill(4.0, 2.0, 20); 
                
            // --- FLEX TAB CAVITY ---
            translate([tab_start_x, case_min_y - side_wall_t + 1.8, -0.1])
                cube([tab_l + slit_w + 1, 2.0, total_internal_height + base_thickness + 0.2]);
                
            // --- FLEX TAB SLIT ---
            translate([tab_start_x, case_min_y - side_wall_t - 0.1, -0.1])
                cube([slit_w, 1.8 + 2.0 + 0.2, total_internal_height + base_thickness + 0.2]); 
        }
        
        // --- OUTWARD LOCKING TAB WEDGE ---
        translate([tab_start_x + slit_w, case_min_y - side_wall_t + 0.1, 0])
        linear_extrude(height=total_internal_height + base_thickness)
        polygon([
            [0, 0],                 
            [0, -tab_protrusion],   
            [4, -tab_protrusion],   
            [tab_l, 0]              
        ]);
        
        translate([0, board_center_y, 0])
        mirror([0, 1, 0])
        translate([0, -board_center_y, 0])
        union() {
            standoff(h1);
            standoff(h2);
            standoff(h3);
            standoff(h4);
        }
    }
}

module tray_outline(tolerance = 0.2) {
    translate([
        case_min_x - wall_thickness - tolerance, 
        case_min_y - side_wall_t - tolerance, 
        -tolerance
    ])
    cube([
        case_width + front_extension + wall_thickness + (tolerance * 2), 
        case_length + side_wall_t + wall_thickness + (tolerance * 2), 
        total_internal_height + base_thickness + (tolerance * 2) + 0.75
    ]);
}

module receiver_pocket_cutout(tolerance = 0.2) {
    tray_outline(tolerance);
    
    translate([
        tab_start_x - tolerance, 
        case_min_y - side_wall_t - tab_protrusion - tolerance, 
        -tolerance
    ])
    cube([
        tab_l + slit_w + (2*tolerance), 
        tab_protrusion + tolerance + 0.1, 
        total_internal_height + base_thickness + (2*tolerance)
    ]);
    
    translate([
        tab_start_x + slit_w + 2, 
        case_min_y - side_wall_t - 100, 
        (base_thickness + total_internal_height) / 2
    ])
    rotate([-90, 0, 0])
    cylinder(d=2.5, h=120, $fn=20);
}

// Render the completed tray
//slide_in_tray_upside_down();

// Uncomment the line below to view the negative shape you should subtract from the main case body
receiver_pocket_cutout(0.2);