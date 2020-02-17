#!/bin/bash
cd /root/Scrivania/eclipse_workspace/Progetto/bin
exec java -cp /root/Scrivania/eclipse_workspace/Progetto/jar/java-cup-0.11a-beta-20060608-runtime.jar: Tester $1 &
for job in `jobs -p`
do
    wait $job
done
temp=$?  
if [ $temp -eq 0 ] 
then
	cd /root/Scrivania/eclipse_workspace/Progetto/testing/output/SORGENTE_C
	exec clang -S -emit-llvm output.c &
	for job in `jobs -p`
	do
    		wait $job
	done
	temp=$?  
	if [ $temp -eq 0 ]
	then 
		cd /emsdk/emscripten/1.38.25
		exec ./emcc /root/Scrivania/eclipse_workspace/Progetto/testing/output/SORGENTE_C/output.ll -s WASM=0 -o /root/Scrivania/eclipse_workspace/Progetto/testing/output/CODICE_WEB/docweb.html
	fi
fi
