$fn = 60;

// --- Board Dimensions ---
board_w = 43.0;
board_h = 38.0;
board_clearance = 1.0; 

// --- Extracted Board Coordinates ---
usb_in_y = 125.73;

h1 = [13.46, 140.34]; 
h2 = [50.55, 140.46]; 
h3 = [50.42, 108.59]; 
h4 = [13.46, 108.59]; 

// --- Parametric Case Boundaries ---
board_center_x = (h1[0] + h2[0] + h3[0] + h4[0]) / 4;
board_center_y = (h1[1] + h2[1] + h3[1] + h4[1]) / 4;

case_width = board_w + board_clearance;
case_length = board_h + board_clearance;

case_min_x = board_center_x - (case_width / 2); 
case_max_x = board_center_x + (case_width / 2); 
case_min_y = board_center_y - (case_length / 2); 
case_max_y = board_center_y + (case_length / 2); 

wall_thickness = 1.5; 

// --- Z-Axis Hardware Stack (Component-Side Down) ---
base_thickness = 2.0; 
standoff_h = 2.5; // Reduced for low-profile SMD only
pcb_thickness = 1.6;

usb_center_below_pcb = 1.6; 
usb_z = base_thickness + standoff_h - usb_center_below_pcb; 

total_internal_height = standoff_h + pcb_thickness; 

module pill(w, h, depth) {
    r = h/2;
    hull() {
        translate([-(w/2 - r), 0, 0]) cylinder(r=r, h=depth, center=true);
        translate([ (w/2 - r), 0, 0]) cylinder(r=r, h=depth, center=true);
    }
}

module slide_in_tray_upside_down() {
    difference() {
        // Main block
        translate([case_min_x - wall_thickness, case_min_y - wall_thickness, 0])
            cube([case_width + wall_thickness, case_length + 2*wall_thickness, total_internal_height + base_thickness]);
        
        // Inner Cutout
        translate([case_min_x, case_min_y, base_thickness])
            cube([case_width + 20, case_length, total_internal_height + 1]);

        // USB-C hole
        translate([case_min_x, usb_in_y, usb_z]) 
            rotate([90, 0, -90]) 
            pill(11.0, 5.0, 20); 
    }
    
    standoff(h1);
    standoff(h2);
    standoff(h3);
    standoff(h4);
}

module standoff(pos) {
    translate([pos[0], pos[1], base_thickness])
    difference() {
        cylinder(d=5.5, h=standoff_h); 
        translate([0,0,1]) cylinder(d=2.0, h=standoff_h); 
    }
}

color("DarkSlateGray") slide_in_tray_upside_down();