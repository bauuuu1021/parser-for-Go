# Parser for μGo

## Build 
* install yacc
    ```
    sudo apt-get install byacc
    ```
* make
    ```
    make
    ```
* excute
    ```
    ./myparser < [file]
    ```
## Problem
* return multiple types
    * insert string (Line85)
    * string initializer (Line128)
* EOF