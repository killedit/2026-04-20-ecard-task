use strict;
use warnings;
use DBI;

my ($host, $user, $pass, $db_name) = (
    "localhost", 
    "root", 
    "", 
    "perl_casino_db"
);

# Connect to server as root to setup everything
my $dbh = DBI->connect(
    "DBI:mysql:host=$host", 
    $user, 
    $pass, 
    { RaiseError => 1 }
);

# Create Database and App User
$dbh->do("CREATE DATABASE IF NOT EXISTS $db_name");
$dbh->do("CREATE USER IF NOT EXISTS 'perl_user'\@'localhost' IDENTIFIED BY 'perl_password'");
$dbh->do("GRANT ALL PRIVILEGES ON $db_name.* TO 'perl_user'\@'localhost'");
$dbh->do("FLUSH PRIVILEGES");

$dbh->do("USE $db_name");

# Define Tables
my @schema = (
    "CREATE TABLE IF NOT EXISTS games (
        id INT AUTO_INCREMENT PRIMARY KEY,
        game_id INT UNIQUE,
        title VARCHAR(255),
        rtp DECIMAL(5,2)
    ) ENGINE=InnoDB",

    "CREATE TABLE IF NOT EXISTS betting_info (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT,
        game_id INT,
        bet_amount DECIMAL(15,2),
        win_amount DECIMAL(15,2),
        FOREIGN KEY (game_id) REFERENCES games(game_id) ON DELETE CASCADE
    ) ENGINE=InnoDB"
);

foreach my $statement (@schema) {
    $dbh->do($statement);
}

$dbh->disconnect();
print "Database and tables initialized successfully.\n";