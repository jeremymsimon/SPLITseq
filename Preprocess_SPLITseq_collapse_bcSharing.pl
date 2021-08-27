#!/usr/bin/perl -slw
use strict;

my $R2 = shift;			#Must be unzipped
my $bcsharing = shift;		#OdT ranHex
my $start = shift;		#79 for splitbio
my $stop = shift;		#86 for splitbio
my $hamdist = shift;		#Allowable hamming distance between observed barcode and expected. Usually set to 1
my $out = shift;

my $length = ($stop - $start) + 1;

open(BC,"<$bcsharing") || die "Error opening $bcsharing\n";
open(OUT,">$out") || die "Error opening $out\n";

my %bc = ();
my @rh = ();

while(<BC>){
	my $line = $_;
	chomp($line);
	if($line =~ /^\#/) {
		next;
	}
	my ($odt, $rh) = split(/\t/,$line);
	$bc{$rh} = $odt;
	push(@rh, $rh);
}

open(FQ,"<$R2") || die "Error opening $R2\n";

my $linect = 1;
while(<FQ>) {
	my $line = $_;
	chomp($line);
	if( ($linect % 4)==2) {
		my $fullread = $line;
		chomp($fullread);
		my $read5p = substr($fullread,0,$start-1);
		my $bc1 = substr($fullread, $start-1, $length);
		my $read3p = substr($fullread,$stop);
		my $matches = 0;
		my $odt;
		my $newread;
		foreach my $rh (@rh){
			if (hd($bc1,$rh) < ($hamdist + 1)) {
				$odt = $bc{$rh};
				$matches += 1;
			}
		}
		if ($matches == 0){
			$newread = $read5p . $bc1 . $read3p;
		}
		elsif ($matches == 1) {
			$newread = $read5p . $odt . $read3p;				
		}
		elsif ($matches > 1) {
			$newread = $read5p . $bc1 . $read3p;
		}
		print OUT "$newread";		
	}
	else{
		print OUT "$line";
	}
	$linect +=1;
}


sub hd{ length( $_[ 0 ] ) - ( ( $_[ 0 ] ^ $_[ 1 ] ) =~ tr[\0][\0] ) }
__END__
