datatype 'a tree = 
	EMPTY
  |	LEAF of string
  | NODE of string * 'a tree * 'a tree

infix 2 LOLLI;
infix 2 BILOLLI;
infix 5 TENSOR;
infix 4 WITH;
infix 1 PAR;
infix 3 PLUS;

fun ATOM (A: string): 'a tree = LEAF(A)
fun BANG (A: 'a tree) = NODE("bang", A, EMPTY)
fun NEG (A: 'a tree) = NODE("lolli", A, LEAF("bot"))
fun (A: 'a tree) LOLLI (B: 'a tree) = NODE("lolli", A, B)
fun (A: 'a tree) BILOLLI (B: 'a tree)= NODE("tensor", NODE("lolli", A, B), NODE("lolli", B, A))
fun (A: 'a tree) TENSOR (B: 'a tree) = NODE("tensor", A, B)
fun (A: 'a tree) WITH (B: 'a tree) = NODE("with", A, B)
fun (A: 'a tree) PAR (B: 'a tree) = NODE("par", A, B)
fun (A: 'a tree) PLUS (B: 'a tree) = NODE("plus", A, B)


fun tree_to_string_helper(T: 'a tree): string =
	case T of
		  LEAF("bot") => "bot"
		| LEAF(A) => " atom " ^ A ^ ""
		| NODE("lolli", A, B) => "(" ^ tree_to_string_helper(A) ^ ") lolli (" ^ tree_to_string_helper(B) ^ ")"
		| NODE("tensor", A, B) => "(" ^ tree_to_string_helper(A) ^ ") * (" ^ tree_to_string_helper(B) ^ ")"
		| NODE("with", A, B) => "(" ^ tree_to_string_helper(A) ^ ") & (" ^ tree_to_string_helper(B) ^ ")"
		| NODE("par", A, B) => "(" ^ tree_to_string_helper(A) ^ ") | (" ^ tree_to_string_helper(B) ^ ")"
		| NODE("plus", A, B) => "(" ^ tree_to_string_helper(A) ^ ") + (" ^ tree_to_string_helper(B) ^ ")"
		| NODE("bang", A, _) => "(!(" ^ tree_to_string_helper(A) ^ "))"


fun tree_to_string(T: 'a tree): string = "prover( " ^ tree_to_string_helper(T) ^ " )"


val a = print( tree_to_string( (ATOM "a")  LOLLI  (ATOM "a") ));
val a = print( tree_to_string((( (ATOM "a")  LOLLI  (ATOM "b") ) TENSOR ( (ATOM "b")  LOLLI  (ATOM "c") ) ) LOLLI ( (ATOM "a")  LOLLI  (ATOM "c") )));
val a = print( tree_to_string((( (ATOM "a")  LOLLI  ((ATOM "b")  LOLLI  (ATOM "c")) ) ) LOLLI ( (ATOM "b")  LOLLI  ((ATOM "a")  LOLLI  (ATOM "c")) )));
val a = print( tree_to_string((( (ATOM "a")  LOLLI  ((ATOM "b")  LOLLI  (ATOM "c")) ) ) LOLLI ( ((ATOM "a")  WITH  (ATOM "b"))  LOLLI  (ATOM "c") )));
val a = print( tree_to_string((( ((ATOM "a")  WITH  (ATOM "b"))  LOLLI  (ATOM "c") ) ) LOLLI ( (ATOM "a")  LOLLI  ((ATOM "b")  LOLLI  (ATOM "c")) )));
val a = print( tree_to_string((( (ATOM "a")  LOLLI  (ATOM "b") ) ) LOLLI ( ((ATOM "b")  LOLLI  (ATOM "c"))  LOLLI  ((ATOM "a")  LOLLI  (ATOM "c")) )));
val a = print( tree_to_string((( (ATOM "a")  LOLLI  (ATOM "b") ) ) LOLLI ( ((ATOM "c")  LOLLI  (ATOM "a"))  LOLLI  ((ATOM "c")  LOLLI  (ATOM "b")) )));
val a = print( tree_to_string((( (ATOM "a")  LOLLI  (ATOM "b") ) ) LOLLI ( ((ATOM "a")  WITH  (ATOM "c"))  LOLLI  ((ATOM "b")  WITH  (ATOM "c")) )));
val a = print( tree_to_string((( (ATOM "a")  LOLLI  (ATOM "b") ) ) LOLLI ( ((ATOM "c")  WITH  (ATOM "a"))  LOLLI  ((ATOM "c")  WITH  (ATOM "b")) )));
val a = print( tree_to_string((( (ATOM "b") ) ) LOLLI ( (ATOM "a")  LOLLI  (ATOM "b") )));
val a = print( tree_to_string((( (ATOM "a")  LOLLI  (ATOM "b") ) TENSOR ( (ATOM "b")  LOLLI  (ATOM "a") ) ) LOLLI ( (ATOM "a")  BILOLLI  (ATOM "b") )));
val a = print( tree_to_string((( (ATOM "a")  BILOLLI  (ATOM "b") ) ) LOLLI ( (ATOM "a")  LOLLI  (ATOM "b") )));
val a = print( tree_to_string((( (ATOM "a")  BILOLLI  (ATOM "b") ) ) LOLLI ( (ATOM "b")  LOLLI  (ATOM "a") )));
val a = print( tree_to_string((( (ATOM "a")  BILOLLI  (ATOM "b") ) TENSOR ( (ATOM "a") ) ) LOLLI ( (ATOM "b") )));
val a = print( tree_to_string((( (ATOM "a")  BILOLLI  (ATOM "b") ) TENSOR ( (ATOM "b") ) ) LOLLI ( (ATOM "a") )));
val a = print( tree_to_string( (ATOM "a")  BILOLLI  (ATOM "a") ));
val a = print( tree_to_string((( (ATOM "a")  BILOLLI  (ATOM "b") ) ) LOLLI ( (ATOM "b")  BILOLLI  (ATOM "a") )));
val a = print( tree_to_string((( (ATOM "a")  BILOLLI  (ATOM "b") ) TENSOR ( (ATOM "b")  BILOLLI  (ATOM "c") ) ) LOLLI ( (ATOM "a")  BILOLLI  (ATOM "c") )));
val a = print( tree_to_string((( (ATOM "a")  BILOLLI  (ATOM "b") ) ) LOLLI ( ((ATOM "a")  LOLLI  (ATOM "c"))  BILOLLI  ((ATOM "b")  LOLLI  (ATOM "c")) )));
val a = print( tree_to_string((( (ATOM "a")  BILOLLI  (ATOM "b") ) ) LOLLI ( ((ATOM "c")  LOLLI  (ATOM "a"))  BILOLLI  ((ATOM "c")  LOLLI  (ATOM "b")) )));
val a = print( tree_to_string((( (ATOM "a")  BILOLLI  (ATOM "b") ) ) LOLLI ( ((ATOM "a")  WITH  (ATOM "c"))  BILOLLI  ((ATOM "b")  WITH  (ATOM "c")) )));
val a = print( tree_to_string((( (ATOM "a")  BILOLLI  (ATOM "b") ) ) LOLLI ( ((ATOM "c")  WITH  (ATOM "a"))  BILOLLI  ((ATOM "c")  WITH  (ATOM "b")) )));
val a = print( tree_to_string( (((ATOM "a")  WITH  (ATOM "b"))  WITH  (ATOM "c"))  BILOLLI  ((ATOM "a")  WITH  ((ATOM "b")  WITH  (ATOM "c"))) ));
val a = print( tree_to_string( ((ATOM "a")  WITH  (ATOM "b"))  BILOLLI  ((ATOM "b")  WITH  (ATOM "a")) ));
val a = print( tree_to_string( ((ATOM "a")  WITH  (ATOM "a"))  BILOLLI  (ATOM "a") ));
val a = print( tree_to_string((( (ATOM "a") ) ) LOLLI ( ((ATOM "a")  LOLLI  (ATOM "b"))  BILOLLI  (ATOM "b") )));
val a = print( tree_to_string((( (ATOM "b") ) ) LOLLI ( ((ATOM "a")  LOLLI  (ATOM "b"))  BILOLLI  (ATOM "b") )));
val a = print( tree_to_string((( (ATOM "b") ) ) LOLLI ( ((ATOM "a")  WITH  (ATOM "b"))  BILOLLI  (ATOM "a") )));
