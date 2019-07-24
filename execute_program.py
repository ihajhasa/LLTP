import translate_connectives
import os
import os.path
import subprocess
import shlex
import sys

#	https://stackoverflow.com/questions/17742789/running-multiple-bash-commands-with-subprocess
def subprocess_cmd(command):
    process = subprocess.Popen(command,stdout=subprocess.PIPE, shell=True)
    proc_stdout = process.communicate()[0].strip()
    print proc_stdout

def modular_sml(fn):
	f = open(fn, 'r')

	formulas = f.readlines()
	formulas = list(filter(lambda x: len(x) > 4, formulas))

	ifile = open("parse.sml", 'r')
	ofile = open("generated_files/execute_sml.sml", 'w')

	code = ifile.readlines()

	for line in code:
		ofile.write(line)

	ofile.write("\n\n\n")



	for F in formulas:
		ofile.write("val a = print( " + F.replace('\n', '') + ");\n")

	f.close()
	ifile.close()
	ofile.close()

def remove_trail(s):
	count = 1
	index = 7


	l_s = list(s)

	while (count > 0 and index < len(l_s)):
		if l_s[index] == '(':
			count = count + 1
		if l_s[index] == ')':
			count = count - 1
		index = index + 1
	l_s = l_s[:index]

	return "".join(l_s)


def execute():

	## step 1 - executing translate_connectives.py [RESOLVED]

	translate_connectives.execute()

	if (os.path.exists('generated_files/sml_function_calls.txt') == False):
		print ("there was an error with generating SML input file ... [parsable_formula.txt]")
		print ("program will exit ...")
		exit(1)


	## step 2 - generating file with prolog input [NOT RESOLVED]

	modular_sml('generated_files/sml_function_calls.txt')

	translated = os.popen("sml < generated_files/execute_sml.sml").read()
	translated = translated.split('\n')
	translated = list(filter(lambda x: "prover(" in x, translated))

	translated_new = []

	for f in translated:
		translated_new.append(remove_trail(f))

	prolog_input_file = open("generated_files/prolog_input.txt", 'w')

	prolog_input_file.write("['LLTP_2'].\n\n")
	for f in translated_new:
		prolog_input_file.write(f + '.\n\n')

	## step 3 - running prolog with input file
	## FOR NOW USER DOES IT MANUALLY BECAUSE SYS COMMAND IS NOT WORKING
	## print (os.popen("swipl < generated_files/prolog_input.txt").read())

	print ("done ...")
	print ("\n")

execute()

