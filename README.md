# Linear Logic Theorem Prover

[TOC-1] Table of Contents
---------------------------------------------------------------------------------------------------------

        [TOC-1] Table of Contents
        [DES-2] Description of Files
        [RUN-3] How to Run
        [IMP-4] Current Calculi LLTP Based On


[DES-2] Description of Files
---------------------------------------------------------------------------------------------------------

Here is a listing of all files

                    .../LLTP.pl                 - Prolog implementation of the prover
                    .../formulas                - File of tested formulas (tagged with success/failure)
                    .../old_code.               - File with out-dated code
                                                    In case I need to reuse something

[RUN-3] How to Run
---------------------------------------------------------------------------------------------------------
                    
                    1. $ gprolog
                    2. $ ['LLTP'].
                    3. $ prover(__insert_formula_here__)


[IMP-4] Current Calculi LLTP Based On
---------------------------------------------------------------------------------------------------------

![alt text](https://github.com/ihajhasa/LLTP/blob/master/calculi_1.png "LL Calculi - Giselle Reis")

Note: Quantifiers are not implemented.