#!/usr/bin/perl
use strict;
use warnings;
use JSON::PP;
use DBI;
use lib '.';
use DbConnection;
# use Data::Dumper;

my $dbh = DbConnection::get_connection();

my $create_table_sql = "
CREATE TABLE IF NOT EXISTS playground_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    game_id VARCHAR(6) NOT NULL,
    generated_array TEXT NOT NULL,
    input_number INT NOT NULL,
    multiplicator CHAR(1) NOT NULL,
    total_win_amount INT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
";

$dbh->do($create_table_sql);

# Generate the prizes 1-9.
my %prizes = map { $_ => int(rand(101)) } 1..9;

my $input_number = $ARGV[0];
print "This is a mini lotterty game.\n\n";

# debug
# foreach my $key (sort { $a <=> $b } keys %prizes) {
#     print "$key => $prizes{$key}\n";
# }
# print $input_number;
# print "\n";
# debug

if (!defined $input_number || $input_number !~ /^[1-9]$/) {

    print "Enter a number from 1 to 9: ";

    $input_number = <STDIN>;
    chomp($input_number) if defined $input_number;
    
    while (!defined $input_number || $input_number !~ /^[1-9]$/) {

        print "Please enter a number from 1 to 9: ";

        $input_number = <STDIN>;
        chomp($input_number) if defined $input_number;
    }
}

# Generate the arry with 9 hashes.
my @generated_array;
my $winning_index = int(rand(9)); # 0 - 8

#debug
# $winning_index = 3;
#debug

for my $i (0..8) {
    push @generated_array, {
        id         => $i + 1,
        is_winning => ($i == $winning_index ? 1 : 0),
        prize      => $prizes{$i + 1}
    };
}

my $user_index = $input_number - 1;
my $win_amount = 0;
my $multiplicator = 'n';
my $game_id = sprintf("%06d", int(rand(1000000)));

if ($user_index == $winning_index) {
    my $prize = $prizes{$input_number};
    print "\nCongratulations! You have won \e[30;43m $prize \e[0m (from the configuration)!\n";
    print "Do you want to continue and play for a chance to double your prize? 50/50 (y/n): ";
    
    my $answer = <STDIN>;
    chomp($answer) if defined $answer;
    $answer = lc($answer || '');
    
    while ($answer ne 'y' && $answer ne 'n') {
        print "Invalid input. Please enter 'y' or 'n': ";
        $answer = <STDIN>;
        chomp($answer) if defined $answer;
        $answer = lc($answer || '');
    }
    
    if ($answer eq 'y') {
        $multiplicator = 'y';
        my $chance = int(rand(2));
        if ($chance == 1) {
            $win_amount = $prize * 2;
            print "Congrats! You won \e[30;43m $win_amount \e[0m !\n";
        } else {
            print "You have lost!\n";
            $win_amount = 0;
        }
    } else {
        $win_amount = $prize;
        print "Congratulations! You won \e[30;43m $win_amount \e[0m !\n";
    }
} else {
    print "You did not win. The winning number was " . ($winning_index + 1) . ".\n";
}

my $json = JSON::PP->new->allow_nonref;
my $generated_array_json = $json->encode(\@generated_array);

my $insert_sql = "INSERT INTO playground_history
(
    game_id, 
    generated_array, 
    input_number, 
    multiplicator, 
    total_win_amount
) VALUES (?, ?, ?, ?, ?)";

my $sth = $dbh->prepare($insert_sql);
$sth->execute(
    $game_id, 
    $generated_array_json, 
    $input_number, 
    $multiplicator, 
    $win_amount
);

$dbh->disconnect();
