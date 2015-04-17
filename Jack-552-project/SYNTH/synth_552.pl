#!/usr/bin/perl

#################################################################################
# This script will synthesize all the files  that are part of a hierarchy 
#################################################################################
print "Enter top level design name: ";
$toplevel = <STDIN>;
chop($toplevel);
if ($toplevel=~/\./) {
    ($toplevel,$extension)=split(/\./,$toplevel);
}

opendir(DIRHANDLE,".");
@files = readdir(DIRHANDLE);
foreach $fname (@files) {
    if ($fname=~/^$toplevel\./) {
      $toplevel_fname = $fname;
    }
}

open(TOPFILE,"$toplevel_fname") || print "WARN: Can't open $toplevel_fname for read\n";
foreach $fname (@files) {
  if (($fname=~/\.v$/) || ($fname=~/\.sv$/) || ($fname=~/\.vs$/)) { 
    if (!($fname=~/_EK\./)) {	## ignore files we modified
      push(@flist,$fname);
    }
  } 
}
foreach $fname (@flist) {
  open(TMPHANDLE,"$fname") || die "ERROR: Can't open $fname for read\n";
  while (<TMPHANDLE>) {
    if (($_=~/^\s+module\s/) || ($_=~/^module\s/)) {
      @words = split(/module\s/,$_);
      ($modname,@junk)=split(/\(/,$words[1]);
      if ($modname=~/\#$/) {    #################### getting rid of # if they used parameters
        chop($modname);
      }
      if ($modname=~/\s$/) {
        chop($modname);
      }
      print "module $modname found in $fname, line : $_\n";
      push(@modnames,$modname);
      push(@verilog_file,$fname);
    }
  }
  close(TMPHANDLE);
}

######################################################
# Now have a list of modules in @modnames and a list
# of the corresponding files in @files, however there
# could be multiple files implementing the same module
# how do we choose....have to prompt user
####################################################
$num_entries = $#modnames+1;
for ($i=0; $i<$num_entries; $i++) {
  $num_duplicates = 0;
  $match[0]=$i;
  for ($j=$i+1; $j<$num_entries; $j++) {
    if ($modnames[$i] eq $modnames[$j]) {
      $num_duplicates++;
      $match[$num_duplicates]=$j;
    }
  }
  if ($num_duplicates) {
    print "\nDuplicate module definitions found:\n";
    for ($x=0; $x<=$num_duplicates; $x++) {
      printf "  %d\) %s is defined in: %s \n",$x+1,$modnames[$i],$verilog_file[$match[$x]];
    }	      
    print "Enter number of file that should be used:";
    $choice = <STDIN>;
    $modules{$modnames[$i]}=$verilog_file[$match[$choice-1]];
    print "choosing $verilog_file[$match[$choice-1]]";
    for ($x=1; $x<=$num_duplicates; $x++) {
      $num_entries--;
      for ($j=$match[$x]; $j<$num_entries; $j++) {
        $modnames[$j]=$modnames[$j+1];
	$verilog_file[$j]=$verilog_file[$j+1];
      }
      $match[$x+1]--;
    }
  }
  else {
    $modules{$modnames[$i]}=$verilog_file[$i];
  }
}

foreach $key (keys %modules) {
    print "$key ==> $modules{$key}\n";
}

push(@provided,"rf");
push(@provided,"DM");
push(@provided,"IM");
push(@provided,"cache");
push(@provided,"unified_mem");

$toplevel = $toplevel_fname; 
print "toplevel = $toplevel\n";
push(@stack,$toplevel);
$indent="  ";
foreach $fname (@stack) {
  open(TMPHANDLE,"$fname") || die "ERROR: Can't open $fname for read\n";
  while (<TMPHANDLE>) {
    $mod_found = 0;
    foreach $key (keys %modules) {
      if (($_=~/^$key\s/i) || ($_=~/^\s+$key\s/i)) {
        @words = split(/\s+/,$_);
	if ($_=~/^\s+/) {
	  $iname = $words[2];
	}
	else {
	  $iname = $words[1];
	}
	@chars = split(//,$iname);
##	if ($chars[0]=~/[a-z]/i) {
	  $unique = 1;
	  foreach $entry (@stack) {
	    if ($entry eq $modules{$key}) {
	      print "module $key already included\n";
	      $unique = 0;
   	    }
	  }
	  foreach $entry (@provided) {
	    if ($entry eq $key) {
	      print "module $key being skipped because was provided module\n";
	      $unique = 0;
	    }
	  }
          if ($unique) {
	    print "module $key being instantiated in $fname\n";
	    push(@stack,$modules{$key});
	  }
##	}
      }
    }
  }
  close(TMPHANDLE);
}
print "\n";
foreach $fname (@stack) {
  print "$fname is unique part of toplevel design\n";
}

##################################################
# Now parse through files replacing any absolute paths in
# include statements with relative paths
#################################################
for ($x=0; $x<=$#stack; $x++) {
  ($base,$extension) = split(/\./,$stack[$x]);
  $modname = $base."_EK"."\.".$extension;
  open(TMPHANDLE,"$stack[$x]") || die "ERROR: Can't open $fname for read\n";
  open(WRTHANDLE,">$modname") || die "ERROR: Can't open $modname for write\n";
  $modified = 0;
  while (<TMPHANDLE>) {
    if ($_=~/\`include\s/i) {
      ($junk,$wfile) = split(/include/i,$_);
      @parts = split(/\//,$wfile);
      if ($#parts) {
	print WRTHANDLE "`include \"\.\/$parts[$#parts]";
        $modified = 1;
      }
      else {
	print WRTHANDLE "$_";
      }
    }
    else {
      print WRTHANDLE "$_";
    }
  }
  if ($modified) {
    print "modified version $modname will be used\n";
    $stack[$x]=$modname;
  }
  else {
    $cmd = "rm $modname";
    system($cmd);
  }
}
close(TMPHANDLE);
close(WRTHANDLE);

open(WRTHANDLE,">sourceFiles") || die "ERROR: can't open sourceFiles for write\n";
foreach $entry (@stack) {
  print WRTHANDLE "$entry\n";
}
close(WRTHANDLE);

###############################
# Now create synthesis script #
###############################
open(WRTHANDLE,">syn.dc") || die "ERROR can't open syn.dc for write\n";
print WRTHANDLE "read_file -format sverilog {\.\/$stack[0],\\\n";

for ($x=1; $x<$#stack; $x++) { 
  print WRTHANDLE "                            \./$stack[$x],\\\n";
}
print WRTHANDLE "                            \./$stack[$#stack]}\n";
print WRTHANDLE "current_design cpu\n";
print WRTHANDLE "create_clock -name \"clk\" -period 1.25 -waveform {0 0.625} { clk }\n";
print WRTHANDLE "set_dont_touch_network [find port clk]\n";
print WRTHANDLE "set_input_delay -clock clk 0.2 [find port rst_n]\n";
print WRTHANDLE "set_drive 0.1 rst_n\n";
print WRTHANDLE "compile -map_effort medium\n";
print WRTHANDLE "report_timing > timing\n";
print WRTHANDLE "report_area > area\n";

$cmd = "design_vision -shell dc_shell < syn.dc";
system($cmd);

closedir(DIRHANDLE);
