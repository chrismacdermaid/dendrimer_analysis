#!/bin/bash

proc getSASA {{molid top}} {

 lassign $::argv prefix

 set nframes [molinfo $molid get numframes] 

 set sel [atomselect $molid "fragment 0"] 

 puts $nframes

 array set sasa  {} 
 array set stats {} 
 for {set f 0} {$f < $nframes} {incr f 25} {
  for {set srad 0} {$srad < 18} {incr srad} {
    molinfo $molid set frame $f  
    $sel update
    lappend sasa($srad)\
      [measure sasa $srad $sel] 
  }

 }

 for {set srad 0} {$srad < 20} {incr srad} {
    set stats($srad)\
      [list [vecmean $sasa($srad)]\
        [vecstddev $sasa($srad)]]
 }

 writeArray "./sasa/$prefix\_sasa.all.dat" sasa
 writeArray "./sasa/$prefix\_sasa.mean.dat" stats

 #set lstats [array2list stats]
 #writeCsv $lstats "./sasa/stats.mean.csv"

 array2csv stats "./sasa/$prefix\_stats.mean.csv"

}

proc writeArray {{fname arr.dat} arr} {
  upvar $arr a

  if {[catch {open $fname "w"} fid]} {
    puts $fid; return -code error
  } 
  
  puts $fid "array set arr [list [array get a]]"

  close $fid
}

## Write out a formatted CSV file 
## for lists
proc writeCsv {data filename {labels {}}} {

  set nlist 0 
  
  ## Check for sublist
  if {[llength [lindex $data 0]] == 1} {
    set nlist 1
    set nelm [llength $data]
  } else {
    set nlist [llength $data]
    set nelm [llength [lindex $data 0]] 
  }

  ## Make sure sublists all have the same length
  if {$nlist > 1} { 
    for {set i 1} {$i < $nlist} {incr i} {
      if {$nelm != [llength [lindex $data $i]]} {
        puts "Sublists are not the same length"
        return -code error
      }
    }
  }
 
  set fid [open $filename "w"]

  ## Write out the header
  set labels [list "Frame" {*}$labels]
  puts $fid [join $labels ","]

  ## Write out the data
  if {$nlist > 1} {
    for {set i 0} {$i < $nelm} {incr i} { 
      puts $fid [join\
        [list $i {*}[lsearch -all -inline -index $i -subindices $data *]] ","]
    }
  } else {
      for {set i 0} {$i < $nelm} {incr i} { 
      puts $fid "$i,[lindex $data $i]"
    }
  }

  close $fid
  
  return -code ok
}

proc array2csv {arr {fname "dat.csv"}} {

  upvar $arr a

  set fid [open $fname "w"]

  set l {}
  foreach key [lsort -integer [array names a *]] {
    #lappend l $a($key) 
    puts $fid [format "%s,%.4f,%.4f" $key {*}$a($key)] 
  }

  close $fid

}

after idle {getSASA}

quit
