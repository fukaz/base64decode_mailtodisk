#!/usr/bin/perl -w

# php.ini
# sendmail_path = "perl \"C:\xampp\mailtodisk\mailtodisk.pl\""

use utf8;
use Encode qw/decode encode/;
use MIME::Base64;
use POSIX 'strftime';
use Time::HiRes;

#my $time = time();
#print "$time\n";
my $timems = Time::HiRes::time;
#print "$timems\n";
my @time = split /\./, $timems;
print $time[0];	# time()と同じ
print ".";
print $time[1];
print "\n";
#my $ms = $timems * 1000000 - int($timems) * 1000000;
#print "$ms\n";

my $file = 'c:/xampp/mailoutput/mail-' . strftime("%Y%m%d-%H%M%S-", localtime($time[0])) . $time[1] . ".txt";
my $rawfile = 'c:/xampp/mailoutput/mail-' . strftime("%Y%m%d-%H%M%S-", localtime($time[0])) . $time[1] . "raw.txt";
print "$file\n";
if (open(MAIL, '>', $rawfile) && open(DECODEMAIL, '>', $file)) {
    my $body = '';
    my $type;
    my $value;
    while (<STDIN>) {
	print MAIL "$_";
	if (/^$/) {
	    $type = 'body';
	} elsif (/:/) {
	    $type = $`;
	    $value = $';
	    my $line = '';
	    do {
		if ($value =~ /=\?ISO-2022-JP\?B\?(.*?)\?=/) {
		    $line .= $`;
		    $value = $';
		    my $str = decode_base64($1);
		    my $decoded = decode('JIS', $str);
		    my $encoded = encode('Shift_JIS', $decoded);
		    $line .= $encoded;
		} else {
		    $line .= $value;
		    $value = '';
		}
	    } until ($value eq '');
	    print DECODEMAIL $type . ':' . $line;
	} elsif ($type eq 'body') {
	    $body .= $_;
	}
    }
    my $str = decode_base64($body);
    my $decoded = decode('JIS', $str);
    my $encoded = encode('Shift_JIS', $decoded);
    print DECODEMAIL "\n$encoded\n";
    close(DECODEMAIL);
} else {
    die "file write open error: $file";
}
