# rcanary
Reads canar(y|ies) value and address for binaries running at the moment. Makes use of Auxiliary Vectors information in /proc/{PID}/auxv, reads the address where the canary is located in memory and then looks through /proc/{PID}/mem for it's value.

This is ported from elttam's [script](https://github.com/elttam/canary-fun) and based on their [research](https://www.elttam.com.au/blog/playing-with-canaries).

## Usage
You can check all available PIDs in /proc or an specific PID's canary:
```bash
$ perl rcanary.pl 18016
[+] AT_RANDOM for pid 18016: 7ffcd9eb7a09
[+] Canary for pid 18016: f8d97f50f093b00
```

## XXX
The script should work on 32bit based systems but didn't have the time to test it.
