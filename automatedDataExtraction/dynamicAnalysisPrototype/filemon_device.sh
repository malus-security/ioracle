#!/bin/bash

#destroy the previous file to prevent it from building up too much
rm /private/var/mobile/temporaryDirectoryForiOracleExtraction/iOracle.out

#store data in tmp to protect ourselves from filling disk and breaking device.
/private/var/mobile/temporaryDirectoryForiOracleExtraction/filemon > /private/var/mobile/temporaryDirectoryForiOracleExtraction/iOracle.out
