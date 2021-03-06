#!/bin/bash

# Copyright (c) 2020 Tomasz Herman
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

COMPILER="../Compiler.exe"
LOG="./test.log"
ERROR_LOG="./error.log"
TEMP="./temp.out"
ILASM="/mnt/c/Windows/Microsoft.NET/Framework/v4.0.30319/ilasm.exe"
PEVERIFY="/mnt/c/Program Files (x86)/Microsoft SDKs/Windows/v10.0A/bin/NETFX 4.8 Tools/PEVerify.exe"
VALID_DIR="./valid/"
INVALID_DIR="./invalid/"

error=0

date | tee "${LOG}" > "${ERROR_LOG}"

echo "***Valid programs test***"
for file in "${VALID_DIR}"prog???; do
    head -n1 "${file}"
    "${COMPILER}" "${file}" >> "${LOG}"
    if [ $? -ne 0 ]; then
        echo "Error couldn't compile ${file} to il" | tee -a "${ERROR_LOG}"
        ((error=error+1))
        continue
    fi
    "$ILASM" "${file}.il" >> "${LOG}" 2>> "${ERROR_LOG}"
    if [ $? -ne 0 ]; then
        echo "Error couldn't compile ${file}.il to exe" | tee -a "${ERROR_LOG}"
        ((error=error+1))
        continue
    fi
    "$PEVERIFY" "${file}.exe" | tee -a "${LOG}" "${ERROR_LOG}"
    if [ ${PIPESTATUS[0]} -ne 0 ]; then
        echo "Error ${file}.exe contains problems" | tee -a "${ERROR_LOG}"
        ((error=error+1))
        continue
    fi
    cat "${file}.in" | "${file}.exe" > $TEMP
    if cmp "${file}.out" "${TEMP}"; then
        echo "OK"
    else
        echo "Output of ${file}.exe is not identical. See ${file}.diff for details." | tee -a "${ERROR_LOG}"
        diff "${file}.out" "${TEMP}" > "${file}.diff"
        ((error=error+1))
    fi
done

echo "***Invalid programs test***"
for file in "${INVALID_DIR}"prog???; do
    head -n1 "${file}"
    "${COMPILER}" "${file}" >> "${LOG}"
    if [ $? -eq 0 ]; then
        echo "Program ${file} compiled, while failure was expected" | tee -a "${ERROR_LOG}"
        ((error=error+1))
        continue
    else
        echo "OK"
    fi
done

rm "${TEMP}"
echo "${COMPILER}"
echo "Total error count: ${error}" | tee -a "${ERROR_LOG}"
