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

## Basic features 
- [x] Design the grammar to match the syntaxrules for variable declarations. 
- [x] Implement the essential functionalities of the symbol table (defined in Section 2
Symbol Table). Your symbol table should at least support these functions:
create_symbol, insert_symbol, lookup_symbol, and dump_symbol. 
* Note: 
    1. Your parser are expected to print out the ACTION which matches your grammar. You should reference the examples below to format the output messages for
the above symbol table functions.
    2. The TAs check the value of each table entry to see if the parser is implemented correctly.
- [x] Support the variants of the assignment operators.
(i.e., =, +=, -=, *=, /=, %= ) 
- [x] Handle arithmetic operations, where brackets and precedence should be considered.
* Note: The modulo operation (%) does not involve any floating point variables. Hence,
your parser should perform the type checking.
- [x] Design the grammar for accepting the print and println invocations and display the
contents of the arguments for the function calls. 
- [x] Detect semantic error(s) and display the error message(s). The parser should display at
least the error type and the line number. 
* Notice: Once the semantic error is detected, the correctness of the variable content is not
important, e.g., you can do nothing or still assign the value.
## Advanced features (30pt)
- [x] Design the grammar for the case: “if ... else if ... else ...”, the grammar must allow zero or more occurrences of the “else if”. 
- [ ] Implement the scoping check function in your parser. To get the full credits for this
feature, your parser is expected to correctly handle the scope of the variables defined
by the μGo language.