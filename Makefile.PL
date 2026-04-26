use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'CasinoDataTask',
    VERSION          => '1.0',
    # This tells the system which modules MUST be there
    PREREQ_PM        => {
        'DBI'          => 1.6,
        'DBD::mysql'   => 4.0,
        'Text::CSV'    => 2.0,
    },
    # This makes the script executable after install
    EXE_FILES        => [
        '2026-04-20-ecard-task-1.pl',
        '2026-04-20-ecard-task-2.pl',
    ],
);