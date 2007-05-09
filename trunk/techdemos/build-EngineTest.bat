@echo off
echo:
echo Replace mxmlc.exe with the path to compiler!
echo:
set OPTS=-use-network=false -optimize -compiler.allow-source-path-overlap
set LIB=-sp+=..\ -sp+=.\
@echo on
mxmlc.exe %OPTS% %LIB% EngineTest.as -output EngineTest.swf
pause