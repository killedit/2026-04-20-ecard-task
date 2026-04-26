# Perl cli application

## Setup
```bash
git clone https://github.com/killedit/2026-04-20-ecard-task.git
cd 2026-04-20-ecard-task
```

## Task 1:

Presumably there is MySQL installed on the host.</br>
In `DbSchema.pl` I define the new database and the needed tables. I need sudo rights to create `perl_casino_db` database, a new `perl_user` with password and to give it rights to access and modify the tables in it.</br>
After that we don't need sudo rights.</br>

```bash
sudo perl DbSchema.pl

perl import.pl games.csv
perl import.pl betting_info.csv

perl analyst.pl
```

I have added in the analyst.pl a field `casino_profit` just in case that's what is meant by `total_win`.

game_title | rtp | unique_users | total_bet | total_win | casino_profit
--- | --- | --- | --- | --- | ---
Roulette | 10 | 1 | 41.00 | 9.00 | 32.00
"Sea Of treasure" | 20 | 1 | 41.00 | 24.00 | 17.00
Blackjack | 50 | 2 | 52.00 | 63.00 | -11.00

## Task 2:

This is a mini lottery game. You can pass an argument, number from 1 to 9, or you will be asked for one. There are explanations and simple validations on each step.

```bash
perl lottery.pl {5}
perl lottery.pl

perl lottery_stats.pl
```

The expected output where the values will be diffrent:
```
------------------------------------------------
Statistic                           |      Value
------------------------------------------------
Total games                         |         54
Average win                         |      24.54
Games with multiplier               |         11
Percentage of games with multiplier |     20.37%
Biggest loss                        |         95
Biggest win                         |        184
Net result (win - loss)             |       1120
------------------------------------------------
```