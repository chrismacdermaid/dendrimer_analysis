## Calculate rgyr

proc calcrgyr {{molid top} {seltext all}} {

  set rgyr {}

  set sel [atomselect $molid $seltext]

  set nstart 0 

  for {set i $nstart} {$i < [molinfo $molid get numframes]} {incr i} {
    molinfo top set frame $i
    lappend rgyr [measure rgyr $sel]
  }

  set N [$sel num]
  $sel delete

  return [list [vecmean $rgyr] [vecstddev $rgyr] $N]
}

after idle {

  lassign $argv prefix

  if {[molinfo top] == -1} {quit}

  set rgyr_all  [calcrgyr top "fragment 0"]
  set rgyr_term [calcrgyr top "resname NH2 AZZ AHH"]

  set fid [open "rgyr/$prefix\_rgyr.dat" w]
  
  puts $fid [format "all,%s,%.4f,%.4f,%d" $prefix {*}$rgyr_all]
  puts $fid [format "term,%s,%.4f,%.4f,%d" $prefix {*}$rgyr_term]
 
  close $fid
}

quit
