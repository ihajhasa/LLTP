signature PARSE = 
sig
	type 'a tree

	infix 2 LOLLI;
	infix 2 BILOLLI;
	infix 5 TENSOR;
	infix 4 WITH;
	infix 1 PAR;
	infix 3 PLUS;

	val ATOM 	: string -> string tree
	val BANG 	: 'a tree -> 'a tree
	val NEG 	: 'a tree -> 'a tree
	val LOLLI	: 'a tree * 'a tree -> 'a tree
	val BILOLLI	: 'a tree * 'a tree -> 'a tree
	val TENSOR	: 'a tree * 'a tree -> 'a tree
	val WITH	: 'a tree * 'a tree -> 'a tree
	val PAR 	: 'a tree * 'a tree -> 'a tree
	val PLUS	: 'a tree * 'a tree -> 'a tree

	val tree_to_string_helper 	: 'a tree -> string
	val tree_to_string 			: 'a tree -> string
end