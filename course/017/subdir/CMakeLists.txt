cmake_minimum_required(VERSION 3.26 FATAL_ERROR)

message("Child  (before): myVar    = ${myVar}")
message("Child  (before): childVar = ${childVar}")

set(myVar bar PARENT_SCOPE)#这是修改了父作用域的值，所以当前作用域的值不会修改
set(childVar fuzz PARENT_SCOPE)

message("Child  (after):  myVar    = ${myVar}")
message("Child  (after):  childVar = ${childVar}")