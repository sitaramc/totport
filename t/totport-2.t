#!/usr/bin/env tsh

plan 90

# this test is time sensitive; if you start it at a time that is too close to
# a 30-second mark, one of the tests will fail.  We need to start it between
# the 0-10 seconds after a 30-second mark.

# for best results, start the entire "prove" on a 30-second mark, and it'll
# all work out

# setup

# wait till the seconds hits "01" (mod 30), since this test script is so
# time-sensitive
t/on-my-mark
    ok

echo $TOTPORT_TEST
    /y/ or die "please see t/README.mkd"

./totp -u sita1 last_ts =
    ok
    /ok # user 'sita1' updated/

./totp -u sita2 last_ts = 
    ok
    /ok # user 'sita2' updated/

./totp -u sita5 last_ts = 
    ok
    /ok # user 'sita5' updated/

cp ~/totp.sqlite3 ~/totp.sql3bkp
    ok

## setup done, start test

touch junk.1
    ok

rm junk.?
    ok

./totp -u sita1 ports =
    ok
    /ok # user 'sita1' updated/

t/try-val 1 2 sha1 -1
    !ok
    /ok # totp is valid/
    /no valid ports defined for 'sita1', why bother validating/

./totp -u sita1 last_ts =
    ok
    /ok # user 'sita1' updated/

./totp -u sita1 ports = GIT1
    ok
    /ok # user 'sita1' updated/

./totp -u sita2 ports = GIT1,GIT2
    ok
    /ok # user 'sita2' updated/

./totp -u sita5 ports = MAIL,WEB1
    ok
    /ok # user 'sita5' updated/

./totp -d sita1
    ok
    /  'ports' => 'GIT1',/

./totp -d sita2
    ok
    /  'ports' => 'GIT1,GIT2',/

./totp -d sita5
    ok
    /  'ports' => 'MAIL,WEB1',/

./totp -d | wc -l
    ok
    /29/

cp ~/totp.sqlite3 ~/totp.sql3bkp
    ok

cp ~/totp.sql3bkp ~/totp.sqlite3
    ok

rm junk.?
    ok

rm -f ~/keydir/sita1.pub
    ok

t/try-val 1 2 sha1 -1 1
    !ok
    /ok # totp is valid/
    /open /home/\w+/keydir/sita1.pub failed: No such file or directory/

cp t/keys/sita*.pub ~/keydir
    ok

cp ~/totp.sql3bkp ~/totp.sqlite3
    ok

rm junk.?
    ok

# remember:
#   sita1: ts_win = 1, alg = sha1
#   sita2: ts_win = 2, alg = sha256
#   sita5: ts_win = 5, alg = sha512

# ARGS: user window alg index   OTPseqno
#       $1   $2     $3  $4      $5

# the index is the important one for sequence testing.  For user 1, we are
# setting a sequence of: -1, 0, -1, 1, 3, which will return ok, ok, reuse, ok,
# fail.  The last one fails because the ts_win is only 1, so an index of 3 (+3
# timesteps ahead of current time) won't be acceptable to 'totp -c'.

t/try-val 1 3 sha1 -1 1
    ok
    /ok # totp is valid/
    /validated 'sita1' from '1.2.1.1'/

t/try-val 2 5 sha256 5 1
    !ok
    /not ok # sita2 \d+ failed at 1\d{9}/
    /totp not ok/

cat ~/.ssh/authorized_keys
    /command="/home/\w+/bin/totport sita1 1.2.1.1",from="1.2.1.1",no-X11-forwarding,no-agent-forwarding,no-pty,permitopen="192.168.1.2:22" ssh-rsa /
    !/from="1.2.2.1"/

sleep 1

t/try-val 1 3 sha1 0 2
    ok
    /ok # totp is valid/
    /validated 'sita1' from '1.2.1.2'/

t/try-val 2 5 sha256 -2 2
    ok
    /ok # totp is valid/
    /validated 'sita2' from '1.2.2.2'/

cat ~/.ssh/authorized_keys
    /command="/home/\w+/bin/totport sita1 1.2.1.2",from="1.2.1.2",no-X11-forwarding,no-agent-forwarding,no-pty,permitopen="192.168.1.2:22" ssh-rsa /
    /command="/home/\w+/bin/totport sita2 1.2.2.2",from="1.2.2.2",no-X11-forwarding,no-agent-forwarding,no-pty,permitopen="192.168.1.2:22",permitopen="192.168.1.3:22" ssh-rsa /

sleep 1

t/try-val 1 3 sha1 -1 3
    !ok
    /not ok # totp reused or older totp used/
    /totp not ok/

t/try-val 2 5 sha256 0 3
    ok
    /ok # totp is valid/
    /validated 'sita2' from '1.2.2.3'/

cat ~/.ssh/authorized_keys
    /command="/home/\w+/bin/totport sita2 1.2.2.3",from="1.2.2.3",no-X11-forwarding,no-agent-forwarding,no-pty,permitopen="192.168.1.2:22",permitopen="192.168.1.3:22" ssh-rsa /
    !/from="1.2.1.3"/

sleep 1

t/try-val 1 3 sha1 1 4
    ok
    /ok # totp is valid/
    /validated 'sita1' from '1.2.1.4'/

t/try-val 2 5 sha256 -1 4
    !ok
    /not ok # totp reused or older totp used/
    /totp not ok/

cat ~/.ssh/authorized_keys
    /command="/home/\w+/bin/totport sita1 1.2.1.4",from="1.2.1.4",no-X11-forwarding,no-agent-forwarding,no-pty,permitopen="192.168.1.2:22" ssh-rsa /
    !/from="1.2.2.4"/

sleep 1

t/try-val 1 3 sha1 3 5
    !ok
    /not ok # sita1 \d+ failed at \d+/
    /totp not ok/

t/try-val 2 5 sha256 1 5
    ok
    /ok # totp is valid/
    /validated 'sita2' from '1.2.2.5'/

cat ~/.ssh/authorized_keys
    /command="/home/\w+/bin/totport sita2 1.2.2.5",from="1.2.2.5",no-X11-forwarding,no-agent-forwarding,no-pty,permitopen="192.168.1.2:22",permitopen="192.168.1.3:22" ssh-rsa /
    !/from="1.2.1.5"/

sleep 1

t/try-val 5 5 sha512 1 1
    ok
    /ok # totp is valid/
    /validated 'sita5' from '1.2.5.1'/

sleep 1

t/try-val 5 5 sha512 0 2
    !ok
    /not ok # totp reused or older totp used/
    /totp not ok/

cat ~/.ssh/authorized_keys
    /command="/home/\w+/bin/totport sita5 1.2.5.1",from="1.2.5.1",no-X11-forwarding,no-agent-forwarding,no-pty,permitopen="192.168.1.1:587",permitopen="192.168.149.1:993",permitopen="192.168.1.4:80",permitopen="192.168.1.4:443" ssh-rsa /
    !/from="1.2.5.2"/

