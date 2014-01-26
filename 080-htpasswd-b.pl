#!/usr/bin/perl

if (! scalar @ARGV ) {
  print "Usage: htpasswd-b passwordfile user password\n";
  print "(this program automatically creates the pw file if needed.)\n";
  exit 0;
}

@saltsource = ('a'..'z', 'A'..'Z', '0'..'9','.','/');
$randum_num = int(rand(scalar @saltsource));
$salt = $saltsource[$randum_num];
$randum_num = int(rand(scalar @saltsource));
$salt .= $saltsource[$randum_num];

$outf=$ARGV[0];
$user=$ARGV[1];
$passwd=$ARGV[2];

if ($user && $passwd) {
  $encrypted = crypt($passwd, "$salt");

  if (-f $outf) { 
    open(OUT, ">>$outf") || die "htpasswd-b error: $!\n";
  } else {
    open(OUT, ">$outf") || die "htpasswd-b error: $!\n";
  }
  print OUT "$user:$encrypted\n";
  close(OUT);

  exit 0;
}
