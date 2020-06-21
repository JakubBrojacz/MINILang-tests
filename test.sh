#!/bin/bash

COMPILER="/home/tomasz/Workspace/C#/MiniCompiler/MiniCompiler/bin/Debug/MiniCompiler.exe"
LOG="test.log"
TEMP="temp.out"

error=0

date > $LOG

for file in prog???; do
    mono $COMPILER $file >> $LOG
    if [ $? -ne 0 ]; then
        echo "Error couldn't compile ${file} to il"
        ((error=error+1))
        continue
    fi
    ilasm /exe "${file}.il" >> $LOG
    if [ $? -ne 0 ]; then
        echo "Error couldn't compile ${file}.il to exe"
        ((error=error+1))
        continue
    fi
    peverify "${file}.exe" >> $LOG
    if [ $? -ne 0 ]; then
        echo "Error ${file}.exe contains problems"
        ((error=error+1))
        continue
    fi
    cat "${file}.in" | mono "${file}.exe" > $TEMP
    if cmp -s "${file1}.out" "$TEMP"; then
        echo "Output of ${file}.exe is not identical"
        ((error=error+1))
    fi
done

for file in fprog???; do
    mono $COMPILER $file >> $LOG
    if [ $? -eq 0 ]; then
        echo "Program ${file} compiled, while failure was expected"
        ((error=error+1))
        continue
    fi
done

rm $TEMP
echo $COMPILER
echo "Error count: ${error}"