
proc calcEccentricity {{molid top}} {

  set sel [atomselect $molid "fragment 0"]
  set N [molinfo $molid get numframes]

  array set ecc {}

  for {set i 0} {$i < $N} {incr i} {

    molinfo $molid set frame $i 

    lassign [measure inertia $sel moments eigenvals]\
       coms axes moments eigenvals 

    lassign $moments ix iy iz
      
    lappend ecc(ixx) [lindex $ix 0] 
    lappend ecc(iyy) [lindex $iy 1]  
    lappend ecc(izz) [lindex $iz 2]  
  
  }

  set pmi [list [vecmean $ecc(ixx)]\
   [vecmean $ecc(iyy)] [vecmean $ecc(izz)]] 
  set pmi [lsort -decreasing -real $pmi]
  lassign $pmi ixx_bar iyy_bar izz_bar

  set ixoveriy [expr {$ixx_bar / $iyy_bar}]
  set ixoveriz [expr {$ixx_bar / $izz_bar}]

  $sel delete 

  return [list $ixoveriy $ixoveriz $ixx_bar $iyy_bar $izz_bar]

}

after idle {
  
  lassign $argv prefix

  if {[molinfo top] == -1} {quit}

  set ecc [calcEccentricity]
  
  set fid [open "aspect/$prefix\_aspect.dat" w]
  puts $fid [format "%s,%.4f,%.4f,%.4f,%.4f,%.4f" $prefix {*}$ecc]
  close $fid

}

quit
