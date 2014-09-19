#!/usr/bin/env tsh

plan 113

## user management

touch ~/totp.log ~/totp.sqlite3
    ok

rm ~/totp.log ~/totp.sqlite3
    ok

ls ~/totp.log ~/totp.sqlite3
    !ok
    /ls: cannot access /home/\w+/totp.log: No such file or directory/
    /ls: cannot access /home/\w+/totp.sqlite3: No such file or directory/

./totp
    !ok
    /totp -- everything to do with TOTP, at the command line/

tail -1 ~/totp.log
    ok
    /20..-..-..\...:..:.. \d+ == ARGV ==:/

./totp -a
    !ok
    /table does not exist\; creating.../
    /need username/

tail -2 ~/totp.log
    ok
    /20..-..-..\...:..:.. \d+ == ARGV ==: -a/
    /20..-..-..\...:..:.. \d+ FATAL: need username/

./totp -a sita1
    ok
    /secret = [A-Z2-7]+/
    /qrencode -s16 -m1 -o sita1.png otpauth...totp.*secret=[A-Z2-7]+/

hashlite -d ~/totp.sqlite3 dump
    ok
    /table:	totp_users/
    /key:	sita1/
    /  'secret' => '[A-Z2-7]+',/
    /  'ts_win' => 1/

hashlite -d ~/totp.sqlite3 dump | wc -l
    ok
    /7/

./totp -a sita1
    !ok
    /user 'sita1' already enrolled/

tail -2 ~/totp.log
    ok
    /20..-..-..\...:..:.. \d+ == ARGV ==: -a sita1/
    /20..-..-..\...:..:.. \d+ FATAL: user 'sita1' already enrolled/

hashlite -d ~/totp.sqlite3 dump
    ok
    /table:	totp_users/
    /key:	sita1/
    /  'secret' => '[A-Z2-7]+',/
    /  'ts_win' => 1/

hashlite -d ~/totp.sqlite3 dump | wc -l
    ok
    /7/

./totp --del
    !ok
    /need username and secret/

tail -2 ~/totp.log
    ok
    /20..-..-..\...:..:.. \d+ == ARGV ==: --del/
    /20..-..-..\...:..:.. \d+ FATAL: need username and secret/

./totp --del sita2
    !ok
    /need username and secret/

tail -2 ~/totp.log
    ok
    /20..-..-..\...:..:.. \d+ == ARGV ==: --del sita2/
    /20..-..-..\...:..:.. \d+ FATAL: need username and secret/

./totp --del sita1 ABCDEFGHIJKLMNOP/
    !ok
    /invalid user/secret/

./totp --del sita9 ABCDEFGHIJKLMNOP/
    !ok
    /user 'sita9' does not exist/

./totp --del sita1 `hashlite -d ~/totp.sqlite3 -t totp_users get sita1 secret`
    ok

tail -1 ~/totp.log
    ok
    /20..-..-..\...:..:.. \d+ == ARGV ==: --del sita1 [A-Z2-7]+/

hashlite -d ~/totp.sqlite3 dump
    ok
    /table:	totp_users/

hashlite -d ~/totp.sqlite3 dump | wc -l
    ok
    /1/

./totp -a sita2
    ok
    /secret = [A-Z2-7]+/
    /qrencode -s16 -m1 -o sita2.png otpauth...totp.*secret=[A-Z2-7]+/

hashlite -d ~/totp.sqlite3 dump | wc -l
    ok
    /7/

./totp -u
    !ok
    /totp -- everything to do with TOTP, at the command line/

./totp -u sita1 foo = bar
    ok
    /user 'sita1' does not exist, creating.../

tail -2 ~/totp.log
    ok
    /20..-..-..\...:..:.. \d+ == ARGV ==: -u sita1 foo = bar/
    /20..-..-..\...:..:.. \d+ WARNING: user 'sita1' does not exist, creating.../

./totp -u sita2 foo = bar
    ok

tail -1 ~/totp.log
    ok
    /20..-..-..\...:..:.. \d+ == ARGV ==: -u sita2 foo = bar/

hashlite -d ~/totp.sqlite3 dump
    ok
    /table:	totp_users/
    /key:	sita2/
    /  'foo' => 'bar',/
    /  'secret' => '[A-Z2-7]+',/
    /  'ts_win' => 1/

hashlite -d ~/totp.sqlite3 dump | wc -l
    ok
    /13/

./totp -u sita2 ts_win = 2
    ok

hashlite -d ~/totp.sqlite3 dump
    ok
    /table:	totp_users/
    /key:	sita2/
    /{/
    /  'foo' => 'bar',/
    /  'secret' => '[A-Z2-7]+',/
    /  'ts_win' => '2'/
    /}/

hashlite -d ~/totp.sqlite3 dump | wc -l
    ok
    /13/

./totp -u sita2 ts_win = ''
    !ok
    /sorry Dave, I can.t let you do that/

./totp -u sita2 ts_win =
    !ok
    /sorry Dave, I can.t let you do that/

./totp -u sita2 foo = ''
    ok

hashlite -d ~/totp.sqlite3 dump
    ok
    /table:	totp_users/
    /key:	sita2/
    /  'foo' => '',/
    /  'secret' => '[A-Z2-7]+',/
    /  'ts_win' => '2'/

hashlite -d ~/totp.sqlite3 dump | wc -l
    ok
    /13/

./totp -u sita2 foo =
    ok

hashlite -d ~/totp.sqlite3 dump
    ok
    /table:	totp_users/
    /key:	sita2/
    /  'secret' => '[A-Z2-7]+',/
    /  'ts_win' => '2'/

hashlite -d ~/totp.sqlite3 dump | wc -l
    ok
    /12/

