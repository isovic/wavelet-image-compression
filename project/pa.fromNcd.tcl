
# PlanAhead Launch Script for Post PAR Floorplanning, created by Project Navigator

create_project -name wavelet -dir "/home/ivan/Dropbox/IRB/projekti/E2LP/implementirane_vjezbe/wavelet/wavelet/planAhead_run_2" -part xc6slx45fgg676-3
set srcset [get_property srcset [current_run -impl]]
set_property design_mode GateLvl $srcset
set_property edif_top_file "/home/ivan/Dropbox/IRB/projekti/E2LP/implementirane_vjezbe/wavelet/wavelet/ramfile.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {/home/ivan/Dropbox/IRB/projekti/E2LP/implementirane_vjezbe/wavelet/wavelet} }
set_property target_constrs_file "ramfile.ucf" [current_fileset -constrset]
add_files [list {ramfile.ucf}] -fileset [get_property constrset [current_run]]
link_design
read_xdl -file "/home/ivan/Dropbox/IRB/projekti/E2LP/implementirane_vjezbe/wavelet/wavelet/ramfile.ncd"
if {[catch {read_twx -name results_1 -file "/home/ivan/Dropbox/IRB/projekti/E2LP/implementirane_vjezbe/wavelet/wavelet/ramfile.twx"} eInfo]} {
   puts "WARNING: there was a problem importing \"/home/ivan/Dropbox/IRB/projekti/E2LP/implementirane_vjezbe/wavelet/wavelet/ramfile.twx\": $eInfo"
}
