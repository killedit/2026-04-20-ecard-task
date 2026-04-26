#!/usr/bin/perl
use strict;
use warnings;
use JSON::PP;
use DBI;
use lib '.';
use DbConnection;

# Reuse the db connection.
my $dbh = DbConnection::get_connection();

my $query = "SELECT * FROM playground_history";
my $sth = $dbh->prepare($query);
$sth->execute();

my $total_games = 0;
my $total_win_amount = 0;
my $total_loss_amount = 0;
my $games_with_multiplicator = 0;
my $max_win = 0;
my $max_loss = 0;

while (my $row = $sth->fetchrow_hashref) {
    $total_games++;
    
    my $win_amount = $row->{total_win_amount};
    my $multiplicator = $row->{multiplicator};
    my $input_number = $row->{input_number};
    my $generated_array_json = $row->{generated_array};
    
    my $generated_array = decode_json($generated_array_json);
    
    # I know the value of stdin and I get array key directly.
    my $index = ($input_number // 1) - 1;
    my $item = $generated_array->[$index];
    
    my $initial_prize = $item->{prize} // 0;
    my $is_winning_number = $item->{is_winning} // 0;
    
    # Biggest win means the higest value in `palygound_history`.`total_win_amount`.
    if ($win_amount > 0) {
        $total_win_amount += $win_amount;

        if ($win_amount > $max_win) {
            $max_win = $win_amount;
        }
    }
    
    if ($multiplicator eq 'y') {
        $games_with_multiplicator++;
        
        # Biggest loss is when multiplier was y and they won 0, it means they lost inital amaount.
        if ($win_amount == 0 && $is_winning_number) {
            $total_loss_amount += $initial_prize;
            if ($initial_prize > $max_loss) {
                $max_loss = $initial_prize;
            }
        }
    }
}

$sth->finish();
$dbh->disconnect();

my $average_win = $total_games > 0 ? $total_win_amount / $total_games : 0;
my $multiplicator_percentage = $total_games > 0 ? ($games_with_multiplicator / $total_games) * 100 : 0;
my $net_result = $total_win_amount - $total_loss_amount;

print "-" x 48 . "\n";
printf "%-35s | %10s\n", "Statistic", "Value";
print "-" x 48 . "\n";
printf "%-35s | %10d\n", "Total games", $total_games;
printf "%-35s | %10.2f\n", "Average win", $average_win;
printf "%-35s | %10d\n", "Games with multiplier", $games_with_multiplicator;
printf "%-35s | %9.2f%%\n", "Percentage of games with multiplier", $multiplicator_percentage;
printf "%-35s | %10d\n", "Biggest loss", $max_loss;
printf "%-35s | %10d\n", "Biggest win", $max_win;
printf "%-35s | %10d\n", "Net result (win - loss)", $net_result;
print "-" x 48 . "\n";
