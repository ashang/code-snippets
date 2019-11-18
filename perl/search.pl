#!/usr/bin/perl
$file = $ARGV[0];
$searchstr = $ARGV[1];
chomp $searchstr;
open(FileHandle, "$file") || die "cann't open $file!\n";
while (defined($line = <FileHandle>)) {
    $back = index($line, $searchstr);
    if ($back != -1) {
        print "$.\n";
    }
}
close(FileHandle);
# perl search.pl search.pl file
