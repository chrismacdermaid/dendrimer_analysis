## Calculate the gofr between
## the center of mass of the dendrimer
## and its terminal groups

proc gofr {arr {molid top} {label mol} {seltext "all"}} {
    
  upvar $arr gofrdata

  set dend [atomselect $molid "fragment 0"] 

  ## Get a water molecule and name it something else
  ## to use in gofr calculation 
  set sel [atomselect $molid "hydrogen"]
  set resname0 [lindex [lsort -unique -integer -index 0\
          -increasing [$sel get {residue name}]] 0]
  $sel delete

  ## First water in selection 
  lassign $resname0 res0 name0
  set wat0 [atomselect $molid "residue $res0 and name $name0"] 
  $wat0 set resname DUM

  if {[$wat0 num] == 0} {return -1} 

  ## For each frame, calculate the COM of the dendrimer and move the water
  ## molecule to the center to act as a reference for the gofr 
  set nframes [molinfo $molid get numframes]
  for {set i 0} {$i < $nframes} {incr i} {
    molinfo $molid set frame $i
    set com [measure center $dend weight mass]
    $wat0 moveby [vecsub $com [lindex [$wat0 get {x y z}] 0]]
  }

  set sel [atomselect $molid "($seltext)"]

  if {[$sel num] == 0} {$sel delete; return -1} 

  puts "Calculating gofr between com and [$sel text]" 

  set gofrdata([list com $label]) [measure gofr $wat0 $sel \
				  selupdate 0 usepbc 1 delta 0.1 rmax 30 first 0 last \
				  [expr {[molinfo $molid get numframes] - 1}]]

  $sel  delete
  $wat0 delete
  $dend delete
}

proc writeout {fname arr} {
    
    upvar $arr gofrdata

    if {[catch {open $fname w} fid]} {
        set msg "Can't open $fname for writing: $fid"
        return -code 1 $msg
    }

    ## Write out the entire data array to a file for post-processing
    puts $fid [list array set gofrdata [array get data]]

    close $fid
}   

proc make_plots {arr {prefix ""}} {

    upvar $arr gofrdata
    
    if {$prefix != ""} {set prefix "$prefix\_"}

    # 0 - r
    # 1 - gofr
    # 2 - number density
    # 3 - unnormalized histogram

    foreach x [array names gofrdata *] {

        lassign $gofrdata($x) r gofr pn hist

        set fid [open "$prefix[join $x "_"].gofr.hist" w]
        
	catch {

	    foreach a $r b $gofr c $pn d $hist  {
		puts $fid [format "%.4f %.4f %.4f %.4f" $a $b $c $d]
	    }

	}

	close $fid
    }
}

proc runme {{molid top} {label mol} {seltext "all"}} {

    global argv

    #set prefix [file rootname [lindex {*}[molinfo top get filename] 0]]

    lassign $argv prefix

    if {[molinfo $molid get numframes] == 0} {
      return -1 
    }

    array unset arr * 
    gofr arr $molid $label $seltext
    
    if {[array size arr] == 0} {return}   

    make_plots arr ./gofr/$prefix
    ##writeout $fname
}

after idle {
    #runme 0  {*}$argv 
    runme 0 EDH "resname EDH"  
    runme 0 PIP "resname PIP"  
    runme 0 CMP "resname CMP"  
    runme 0 AMP "resname AMP"  
    runme 0 NH2 "resname NH2"  
    runme 0 N3  "resname AZZ"
    runme 0 NH3 "resname AHH"
}

quit

