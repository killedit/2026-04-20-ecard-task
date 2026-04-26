package DbConnection;
use strict;
use warnings;

sub get_connection {
    my $host     = "localhost";
    my $db_name  = "perl_casino_db";
    my $username = "perl_user";
    my $password = "perl_password";
    
    return DBI->connect(
        "DBI:mysql:database=$db_name;host=$host",
        $username, $password, 
        { RaiseError => 1, AutoCommit => 1 }
    );
}
1; # Modules must return true