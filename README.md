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
* mod type checking
    * write insert_value() with **id and value**
* EOF

## Tricks
* Declare a globol variable `current`, which is a pointer to symbol table. Look up a variable by calling lookup_symbol(), the pointer `current` will stop at target symbol block.  
* [Grammar](https://sites.ualberta.ca/dept/chemeng/AIX-43/share/man/info/C/a_doc_lib/aixprggd/genprogc/ie_prog_4lex_yacc.htm)