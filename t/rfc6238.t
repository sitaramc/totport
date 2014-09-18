#!/bin/bash

echo "1..18";

  key1=12345678901234567890
key256=12345678901234567890123456789012
key512=1234567890123456789012345678901234567890123456789012345678901234

enc() {
    perl -MMIME::Base32=RFC -e "print MIME::Base32::encode('$1')"
}

SHA1() {
    if [ $(./totp -s `enc $key1` $1) == $2 ]
    then
        echo ok
    else
        echo not ok
    fi
}
SHA256() {
    if [ $(./totp -s `enc $key256` $1 0 sha256) == $2 ]
    then
        echo ok
    else
        echo not ok
    fi
}
SHA512() {
    if [ $(./totp -s `enc $key512` $1 0 sha512) == $2 ]
    then
        echo ok
    else
        echo not ok
    fi
}

SHA1   59          94287082
SHA256 59          46119246
SHA512 59          90693936
SHA1   1111111109  7081804      # we did remove the leading zero here, though!
SHA256 1111111109  68084774
SHA512 1111111109  25091201
SHA1   1111111111  14050471
SHA256 1111111111  67062674
SHA512 1111111111  99943326
SHA1   1234567890  89005924
SHA256 1234567890  91819424
SHA512 1234567890  93441116
SHA1   2000000000  69279037
SHA256 2000000000  90698825
SHA512 2000000000  38618901
SHA1   20000000000 65353130
SHA256 20000000000 77737706
SHA512 20000000000 47863826
