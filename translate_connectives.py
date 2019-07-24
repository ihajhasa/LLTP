import re
import os
import io
import shutil

## look at clac homework to see how to generate a parse tree of the input, to do the translation to prolog
##      or just google it
## there must be a cleaner way, this feels way too ad hoc (is there something generalized?)
## I need to figure out negation and bi-implication

def keep_formulas(line):
    if 'fof' in line:
        return True
    return False

def add_atom(s):
    result = ""
    for c in s:
        if (ord(c) >= ord('a') and ord(c) <= ord('z')):
            result = result + "(ATOM \"" + str(c) + "\")"
        else:
            result = result + str(c)
    return result

def translate_formula(F):
    F = F.replace('<=>', ' BILOLLI ')
    F = F.replace('=>', ' LOLLI ')
    F = F.replace('*', ' TENSOR ')
    F = F.replace('&', ' WITH ')
    F = F.replace('+', ' PLUS ')
    F = F.replace('!', 'BANG ')
    F = F.replace('~', 'NEG ')
    F = F.replace('|', ' PAR ')
    F = add_atom(F)
    return F

def parse(filename):
    AXIOMS = []
    CONJECTURE = ''
    print '---------------------------\n'
    print 'filename:\t' + filename + '\n'
    f = open(filename)
    lines = f.readlines()
    formulas = list(filter(keep_formulas, lines))
    formulas = list(map(lambda x: x.replace('\n', ''), formulas))
    formulas = list(map(lambda x: x.replace('fof(', ''), formulas))
    formulas = list(map(lambda x: x.replace(').', ''), formulas))
    formulas = list(map(lambda x: x.split(','), formulas))

    for fof in formulas:

        print 'name: ' + fof[0]
        print 'axiom/conj: ' + fof[1]
        print 'formula: ' + fof[2]
        print ''
        F = translate_formula(fof[2])
        if ('axiom' in fof[1]):
            AXIOMS.append(F)
        else:
            CONJECTURE = F

    result = ''

    if (len(AXIOMS) == 0):
        return CONJECTURE

    for F in AXIOMS:
        print "axiom: " + F + '\n'
        result = result + 'TENSOR (' + F + ') '
    result = result[7:]
    result = '(' + result + ') LOLLI (' + CONJECTURE + ')'

    f.close()

    return result

    
def execute():
    files = os.listdir('lltp')
    list.sort(files)
    files = list(filter(lambda x: '.p' in x, files))

    all_formulas = []

    for f in files:
        result =  parse('lltp/'+f)
        if ("NEG" not in result and "PAR" not in result):
            all_formulas.append(result)

    ofile1 = open("generated_files/parsable_formula.txt", 'w')
    ofile2 = open("generated_files/sml_function_calls.txt", 'w')



    print '---------------------------\n'
    print '---------------------------\n'
    print 'all formulas:\n'

    for f in all_formulas:
        ofile1.write(f + '\n\n')
        ofile2.write("tree_to_string(" + f + ")" + '\n\n')
        print f + '\n'

    ofile2.write("\x04")

    ofile1.close()
    ofile2.close()

    print '\n'
    print '---------------------------\n'
    print '---------------------------\n'


execute()
        
            
