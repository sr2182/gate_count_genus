### Gate count:Genus

#### Steps

1. Start Cadence Genus by invoking `/umbc/software/scripts/launch_cadence_genus.sh.`
2. After the completion of the launch, which will resemble the following.Next, on the Genus terminal type in `./tcl/source mult_32b.tcl` to get the gate count and area of a 32b floating point multiplier.
```
rahman2@resilient:~/GIT/gate_count_genus$ /umbc/software/scripts/launch_cadence_genus.sh
2024/09/19 20:55:10 WARNING This OS does not appear to be a Cadence supported Linux configuration.
2024/09/19 20:55:10 For more info, please run CheckSysConf in <cdsRoot/tools.lnx86/bin/checkSysConf <productId>
TMPDIR is being set to /tmp/genus_temp_1798867_resilient_rahman2_zfT5nI
Cadence Genus(TM) Synthesis Solution.
Copyright 2021 Cadence Design Systems, Inc. All rights reserved worldwide.
Cadence and the Cadence logo are registered trademarks and Genus is a trademark
of Cadence Design Systems, Inc. in the United States and other countries.

Version: 20.11-s111_1, built Mon Apr 26 11:57:38 PDT 2021
Options:
Date:    Thu Sep 19 20:55:16 2024
Host:    resilient (x86_64 w/Linux 6.5.0-41-generic) (32cores*128cpus*2physical cpus*Intel(R) Xeon(R) Platinum 8462Y+ 61440KB) (528018620KB)
PID:     1798867
OS:      Unsupported OS as /etc does not have release info

Checking out license: Genus_Synthesis


***********************************************************************************************************
***********************************************************************************************************



Loading tool scripts...
Finished loading tool scripts (26 seconds elapsed).

WARNING: This version of the tool is 1242 days old.
@genus:root: 1>source ./tcl/mult_32b.tcl
```
3. Gate count and area will be stored in `mult_fp32_gates.txt` and `mult_fp32_area.txt` respectively.
