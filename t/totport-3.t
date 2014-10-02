#!/usr/bin/env tsh

plan 25

# setup

./totp -u sita1 last_ts = 
    ok
    /ok # user 'sita1' updated/

./totp -u sita2 last_ts = 
    ok
    /ok # user 'sita2' updated/

rm -rf junk.? ~/validated_keys/*
    ok

# run

t/try-val 1 3 sha1 0 1
    ok
    /ok # totp is valid/
    /validated 'sita1' from '1.2.1.1'/

sleep 5
    ok

t/try-val 2 5 sha256 -2 2
    ok
    /ok # totp is valid/
    /validated 'sita2' from '1.2.2.2'/

find ~/validated_keys
    ok
    /sita1/
    /sita2/

t/mock.pl `perl -e 'print time()+2396'` ./totport rebuild
    !/./

tail -3 ~/totport.log
    /20..-..-..\...:..:.. \d+ == ARGV ==: rebuild/
    /20..-..-..\...:..:.. \d+ removed ‘/home/\w+/validated_keys/1\d{9}/sita1’/
    /20..-..-..\...:..:.. \d+ removed directory: ‘/home/\w+/validated_keys/1\d{9}’/
    !/sita2/

t/mock.pl `perl -e 'print time()+2401'` ./totport rebuild
    !/./

tail -3 ~/totport.log
    /20..-..-..\...:..:.. \d+ == ARGV ==: rebuild/
    /20..-..-..\...:..:.. \d+ removed ‘/home/\w+/validated_keys/1\d{9}/sita2’/
    /20..-..-..\...:..:.. \d+ removed directory: ‘/home/\w+/validated_keys/1\d{9}’/
    !/sita1/

