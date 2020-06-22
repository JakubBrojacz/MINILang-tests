#!/bin/bash

COMPILER="../Compiler.exe"
LOG="test.log"
TEMP="temp.out"
ILASM="/mnt/c/Windows/Microsoft.NET/Framework/v4.0.30319/ilasm.exe"
PEVERIFY="/mnt/c/Program Files (x86)/Microsoft SDKs/Windows/v10.0A/bin/NETFX 4.8 Tools/PEVerify.exe"

error=0

date > $LOG

for file in prog???; do
    "$COMPILER" $file >> $LOG
    if [ $? -ne 0 ]; then
        echo "Error couldn't compile ${file} to il"
        ((error=error+1))
        continue
    fi
    "$ILASM" /exe "${file}.il" >> $LOG
    if [ $? -ne 0 ]; then
        echo "Error couldn't compile ${file}.il to exe"
        ((error=error+1))
        continue
    fi
    "$PEVERIFY" "${file}.exe" >> $LOG
    if [ $? -ne 0 ]; then
        echo "Error ${file}.exe contains problems"
        ((error=error+1))
        continue
    fi
    cat "${file}.in" | "./${file}.exe" > $TEMP
    if cmp "${file}.out" "$TEMP"; then
        continue
    else
        echo "Output of ${file}.exe is not identical"
        ((error=error+1))
    fi
done

for file in fprog???; do
    "$COMPILER" $file >> $LOG
    if [ $? -eq 0 ]; then
        echo "Program ${file} compiled, while failure was expected"
        ((error=error+1))
        continue
    fi
done
rm $TEMP
echo "$COMPILER"
echo "Error count: ${error}"