#!/usr/bin/perl -w

# php.ini
# sendmail_path = "perl \"C:\xampp\mailtodisk\mailtodisk.pl\""

use utf8;
use Encode qw/decode encode/;
use MIME::Base64;
use POSIX 'strftime';
use Time::HiRes;

my $debug = 0;
foreach my $arg (@ARGV) {
    if ($arg eq '-d') {
	$debug = 1;
    }
}
if ($debug) {
    use Cwd;
}

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

my $file = 'mailoutput/mail-' . strftime("%Y%m%d-%H%M%S-", localtime($time[0])) . $time[1] . ".txt";
my $rawfile = 'mailoutput/mail-' . strftime("%Y%m%d-%H%M%S-", localtime($time[0])) . $time[1] . "raw.txt";
print "$file\n";
if ($debug) {
    my $logfile = 'c:/xampp/mailoutput/mailtodisk.log';
    if (open(LOG, '>>', $logfile)) {
	my $wd = Cwd::getcwd();
	print LOG "$wd->$file\n";
    } else {
	die "file write open error: $file";
    }
}
if (open(MAIL, '>', $rawfile) && open(DECODEMAIL, '>', $file)) {
    my $body = '';
    my $type = '';
    my $value;
    my $orgcode = '';
    my $base64flg = 0;
    while (<STDIN>) {
	print MAIL "$_";
	chomp;
	if ($type eq 'body') {
	    #if ($debug) {
	    #    print LOG "$_";
	    #}
	    $body .= $_ . "\n";
	} elsif (/^$/) {
	    $type = 'body';
	} elsif (/\s*:\s*/) {
	    $type = $`;
	    $value = $';
	    my $line = '';
	    do {
		if ($type =~ /^Content-Transfer-Encoding$/i) {
		    if ($value =~ /^base64$/i) {
			$base64flg = 1;
		    }
		    $line .= $value;
		    $value = '';
		    #if ($debug) {
		    #	print LOG "$type: $line";
		    #}
		} elsif ($type =~ /^Content-Type$/i) {
		    if ($value =~ /charset="?([\w\-]+)"?/i) {
			$orgcode = $1;
			#if ($debug) {
			#    print LOG "orgcode=$orgcode\n";
			#}
			if ($orgcode =~ /^ISO-2022-JP$/i) {
			    $value =~ s/$orgcode/shift_jis/;
			}
		    }
		    $line .= $value;
		    $value = '';
		    #if ($debug) {
		    #	print LOG "$type: $line";
		    #}
		} elsif ($value =~ /=\?ISO-2022-JP\?B\?(.*?)\?=/i) {
		    $line .= $`;
		    $value = $';
		    my $str = decode_base64($1);
		    my $decoded = decode('JIS', $str);
		    my $encoded = encode('Shift_JIS', $decoded);
		    $line .= $encoded;
		} else {
		    $line .= $value;
		    $value = '';
		    if ($debug) {
		        print LOG "$type: $line\n";
		    }
		}
	    } until ($value eq '');
	    if ($type) {
		print DECODEMAIL $type . ': ' . $line . "\n";
		#if ($debug) {
		#    print LOG "line=$type: $line";
		#}
	    }
	}
    }
    my $str;
    if ($base64flg) {
	$str = decode_base64($body);
    } else {
	$str = $body;
    }
    my $decoded;
    my $encoded;
    if ($orgcode =~ /^ISO-2022-JP$/i) {
	$decoded = decode('JIS', $str);
	$encoded = encode('Shift_JIS', $decoded);
    } else {
	$encoded = $str;
    }
    print DECODEMAIL "\n$encoded";
    close(DECODEMAIL);
    close(MAIL);
    if ($debug) {
	close(LOG);
    }
} else {
    die "file write open error: $file";
}
