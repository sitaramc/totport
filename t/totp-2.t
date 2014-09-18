#!/usr/bin/env tsh

plan 48

## dump

touch ~/totp.log ~/totp.sqlite3
    ok

rm ~/totp.log ~/totp.sqlite3
    ok

ls ~/totp.log ~/totp.sqlite3
    !ok
    /ls: cannot access /home/\w+/totp.log: No such file or directory/
    /ls: cannot access /home/\w+/totp.sqlite3: No such file or directory/

./totp -a sita2
    ok
    /secret = [A-Z2-7]+/
    /qrencode -s16 -m1 -o sita2.png otpauth...totp.*secret=[A-Z2-7]+/

./totp -u sita2 ts_win = 2
    ok

./totp -a sita3
    ok
    /secret = [A-Z2-7]+/
    /qrencode -s16 -m1 -o sita3.png otpauth...totp.*secret=[A-Z2-7]+/

./totp -a sita4
    ok
    /secret = [A-Z2-7]+/
    /qrencode -s16 -m1 -o sita4.png otpauth...totp.*secret=[A-Z2-7]+/

hashlite -d ~/totp.sqlite3 dump
    ok
    /table:	totp_users/
    /key:	sita2/
    /  'secret' => '[A-Z2-7]+',/
    /  'ts_win' => '2'/
    /key:	sita3/
    /  'secret' => '[A-Z2-7]+',/
    /  'ts_win' => 1/
    /key:	sita4/
    /  'secret' => '[A-Z2-7]+',/
    /  'ts_win' => 1/

hashlite -d ~/totp.sqlite3 dump | wc -l
    ok
    /19/

./totp -d
    ok
    /user:	sita2/
    /  'secret' => '[A-Z2-7]+',/
    /  'ts_win' => '2'/
    /user:	sita3/
    /  'secret' => '[A-Z2-7]+',/
    /  'ts_win' => 1/
    /user:	sita4/
    /  'secret' => '[A-Z2-7]+',/
    /  'ts_win' => 1/

./totp -d | wc -l
    ok
    /18/

./totp -d sita1
    !ok
    /user 'sita1' does not exist/

./totp -d sita2
    ok
    /  'secret' => '[A-Z2-7]+',/
    /  'ts_win' => '2'/

./totp -d sita3
    ok
    /  'secret' => '[A-Z2-7]+',/
    /  'ts_win' => 1/

