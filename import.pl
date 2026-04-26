#!/usr/bin/env perl
use strict;
use warnings;
use Text::CSV;
use lib '.';
use DbConnection;
use DBI;

# Connect to MySQL
my $dbh = DbConnection::get_connection();

# Read CVS file from command line
my $file = $ARGV[0] or die "Usage: perl import_data.pl <file.csv>\n";
my $csv = Text::CSV->new({ binary => 1, auto_diag => 1 });

open my $fh, "<:encoding(utf8)", $file or die "Could not open $file: $!";
my $headers = $csv->getline($fh); # Skip header

if ($file =~ /games/) {

    print "Importing to 'games' table. Games will be updated if they exist.\n";
    print "...\n";

    my $sth = $dbh->prepare(
        "INSERT INTO games (game_id, title, rtp) VALUES (?, ?, ?) 
         ON DUPLICATE KEY UPDATE title=VALUES(title), rtp=VALUES(rtp)"
    );
    while (my $row = $csv->getline($fh)) {
        $sth->execute(@$row);
    }
} elsif($file =~ /betting_info/) {

    print "Importing to 'betting_info' table. Betting information is ALWAYS added.\n";
    print "...\n";

    my $sth = $dbh->prepare(
        "INSERT INTO betting_info (user_id, game_id, bet_amount, win_amount) VALUES (?, ?, ?, ?)"
    );
    while (my $row = $csv->getline($fh)) {
        $sth->execute(@$row);
    }
} else {
    die "Unknown file: $file\n";
}

close $fh;
$dbh->disconnect();
print "Import completed for $file.\n";