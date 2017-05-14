#!/bin/bash

#destroy the previous file to prevent it from building up too much
rm /temporaryDirectoryForiOracleExtraction/iOracle.out

#store data in tmp to protect ourselves from filling disk and breaking device.
/temporaryDirectoryForiOracleExtraction/filemon > /temporaryDirectoryForiOracleExtraction/iOracle.out
