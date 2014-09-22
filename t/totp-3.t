#!/usr/bin/env tsh

plan 79

## check mode setup and basic tests

touch ~/totp.log ~/totp.sqlite3
    ok

rm ~/totp.log ~/totp.sqlite3
    ok

ls ~/totp.log ~/totp.sqlite3
    !ok
    /ls: cannot access /home/\w+/totp.log: No such file or directory/
    /ls: cannot access /home/\w+/totp.sqlite3: No such file or directory/

./totp -a sita1
    ok
    /ok # user 'sita1' added/
    /table does not exist\; creating.../
    /http://127.0.0.1:3536/qr/[A-Z2-7]+/

./totp -a sita2
    ok
    /ok # user 'sita2' added/
    /http://127.0.0.1:3536/qr/[A-Z2-7]+/

./totp -a sita5
    ok
    /ok # user 'sita5' added/
    /http://127.0.0.1:3536/qr/[A-Z2-7]+/

./totp -u sita2 ts_win = 2
    ok
    /ok # user 'sita2' updated/

./totp -u sita5 ts_win = 5
    ok
    /ok # user 'sita5' updated/

./totp -u sita1 secret = GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ
    ok
    /ok # user 'sita1' updated/
./totp -u sita2 secret = GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQGEZA
    ok
    /ok # user 'sita2' updated/
./totp -u sita5 secret = GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQGEZDGNA
    ok
    /ok # user 'sita5' updated/

./totp -s `hashlite -d ~/totp.sqlite3 -t totp_users get sita1 secret` 59
    ok
    /94287082/

./totp -s `hashlite -d ~/totp.sqlite3 -t totp_users get sita1 secret` 1111111109
    ok
    /7081804/

./totp -s `hashlite -d ~/totp.sqlite3 -t totp_users get sita1 secret` 1111111109 2
    ok
    /-2	48150727/
    /-1	89731029/
    /0	7081804/
    /1	14050471/
    /2	44266759/

./totp -u sita2 alg = sha256
    ok
    /ok # user 'sita2' updated/

./totp -u sita3 alg = sha512
    ok
    /ok # user 'sita3' updated/
    /user 'sita3' does not exist, creating.../

./totp -u sita5 alg = sha512
    ok
    /ok # user 'sita5' updated/

./totp -d
    ok
    /user:	sita1/
    /  'secret' => 'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ',/
    /  'ts_win' => 1/
    /user:	sita2/
    /  'alg' => 'sha256',/
    /  'secret' => 'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQGEZA',/
    /  'ts_win' => '2'/
    /user:	sita5/
    /  'alg' => 'sha512',/
    /  'secret' => 'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQGEZDGNA',/
    /  'ts_win' => '5'/
    !/last_ts/

./totp -d | wc -l
    ok
    /25/

## sha1 STARTS HERE

t/mock.pl 59          ./totp    -c sita1 94287082
    ok

t/mock.pl 1111111109  ./totp    -c sita1 7081804
    ok

t/mock.pl 1111111111  ./totp    -c sita1 14050471
    ok

t/mock.pl 1234567890  ./totp    -c sita1 89005924
    ok

t/mock.pl 2000000000  ./totp    -c sita1 69279037
    ok

t/mock.pl 20000000000 ./totp    -c sita1 65353130
    ok

## sha256

t/mock.pl 59          ./totp    -c sita2 46119246
    ok

t/mock.pl 1111111109  ./totp    -c sita2 67062674
    ok

t/mock.pl 1111111111  ./totp    -c sita2 67062674
    !ok
    /not ok # totp reused or older totp used/

t/mock.pl 1234567890  ./totp    -c sita2 91819424
    ok

t/mock.pl 20000000000 ./totp    -c sita2 90698825
    !ok
    /not ok # sita2 90698825 failed at 20000000000/

t/mock.pl 2000000000  ./totp    -c sita2 90698825
    ok

t/mock.pl 20000000000 ./totp    -c sita2 77737706
    ok

## sha512

t/mock.pl 59          ./totp    -c sita5 90693936
    ok

t/mock.pl 1111111109  ./totp    -c sita5 25091201
    ok

t/mock.pl 1111111111  ./totp    -c sita5 99943326
    ok

t/mock.pl 1234567890  ./totp    -c sita5 93441116
    ok

t/mock.pl 20000000000 ./totp    -c sita5 47863826
    ok

t/mock.pl 2000000000  ./totp    -c sita5 38618901
    !ok
    /not ok # totp reused or older totp used/

