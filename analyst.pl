#!/usr/bin/env perl
use strict;
use warnings;
use Text::CSV;
use POSIX qw(strftime);
use lib '.';
use DbConnection;
use DBI;

print "Generating report...\n";

# Connect to MySQL
my $dbh = DbConnection::get_connection();

my $datetime = strftime "%Y-%m-%d_%H-%M-%S", localtime;
my $output_file = "report-$datetime.csv";
my $csv = Text::CSV->new({ binary => 1, auto_diag => 1, eol => "\n" });

open my $fh, ">:encoding(utf8)", $output_file or die "Could not open $output_file: $!";

# Write headers
$csv->print($fh, ["game_title", "rtp", "unique_users", "total_bet", "total_win", "casino_profit"]);

# Query database
my $query = "
    SELECT g.title, g.rtp, COUNT(DISTINCT b.user_id), COALESCE(SUM(b.bet_amount), 0), COALESCE(SUM(b.win_amount), 0), COALESCE(SUM(b.bet_amount), 0) - COALESCE(SUM(b.win_amount), 0)
    FROM games AS g
    LEFT JOIN betting_info AS b ON g.game_id = b.game_id
    GROUP BY g.game_id, g.title, g.rtp
    ORDER BY g.rtp ASC
";

my $sth = $dbh->prepare($query);
$sth->execute();

while (my $row = $sth->fetchrow_arrayref) {
    # Remove trailing zeroes for rtp
    $row->[1] += 0; 
    
    # Format amounts to two decimal places
    $row->[3] = sprintf("%.2f", $row->[3]);
    $row->[4] = sprintf("%.2f", $row->[4]);
    $row->[5] = sprintf("%.2f", $row->[5]);
    
    $csv->print($fh, $row);
}

close $fh;
$dbh->disconnect();
print "Report successfully written to $output_file\n";
