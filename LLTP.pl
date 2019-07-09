% 	Written By:
%		Ishaq Yousef Haj Hasan,
%		Hari Krishna. 
%
%	Prolog implementation of LLTP
%	
%	Notes:
%		I will translate this to SML eventually, but prolog automatically
%		handles backtracking (and trying different splits).



%		Taken from Sudoku by Julian Sam (Recitation 8) ------------------------
%		UNMODIFIED
remove(X, [X|T], T).
remove(X, [Y|T], [Y|L1]) :- remove(X, T, L1).
%		-----------------------------------------------------------------------

%	is_formula(bot).
is_formula(top). 
is_formula(zero).
is_formula(one).
is_formula(atom(_)). 
is_formula(tensor(A,B)) :- is_formula(A), is_formula(B). 
is_formula(with(A,B)) :- is_formula(A), is_formula(B). 
%	is_formula(par(A,B)) :- is_formula(A), is_formula(B).
is_formula(plus(A,B)) :- is_formula(A), is_formula(B). 
is_formula(lolli(A,B)) :- is_formula(A), is_formula(B). 
is_formula(bang(A)) :- is_formula(A). 
%	is_formula(qm(A)) :- is_formula(A).
%	is_formula(orth(A)) :- is_formula(A).

% You cannot focus something inside a bigger formula
is_focused_formula(focus(A)) :- is_formula(A).

add_to_appropriate_list(top, DN, DP, ATOMS, [top|DN], DP, ATOMS).
add_to_appropriate_list(zero, DN, DP, ATOMS, DN, [zero|DP], ATOMS).
add_to_appropriate_list(one, DN, DP, ATOMS, DN, [one|DP], ATOMS).
add_to_appropriate_list(atom(A), DN, DP, ATOMS, DN, DP, [atom(A)|ATOMS]).
add_to_appropriate_list(tensor(A,B), DN, DP, ATOMS, DN, [tensor(A,B)|DP], ATOMS).
add_to_appropriate_list(with(A,B), DN, DP, ATOMS, [with(A,B)|DN], DP, ATOMS).
add_to_appropriate_list(plus(A,B), DN, DP, ATOMS, DN, [plus(A,B)|DP], ATOMS).
add_to_appropriate_list(lolli(A,B), DN, DP, ATOMS, [lolli(A,B)|DN], DP, ATOMS).
add_to_appropriate_list(bang(A), DN, DP, ATOMS, DN, [bang(A)|DP], ATOMS).

split([],[],[]).
split([A], [A], []).
split([A], [], [A]).
split([A|L], [A|L1], L2) :- split(L, L1, L2).
split([A|L], L1, [A|L2]) :- split(L, L1, L2).

is_positive(tensor(_,_)).
is_positive(one).
is_positive(plus(_,_)).
is_positive(zero).
is_positive(bang(_)).
is_positive(atom(_)).

is_negative(with(_,_)).
is_negative(lolli(_,_)).
is_negative(top).

not_atom(tensor(_,_)).
not_atom(one).
not_atom(plus(_,_)).
not_atom(zero).
not_atom(bang(_)).
not_atom(with(_,_)).
not_atom(lolli(_,_)).
not_atom(top).

is_atom(atom(_)).

prover_h(_, _, _, _, _, _, top).
prover_h(_, true, _, _, _, _, _).
% init POS
prover_h(_, false, [], [], [atom(A)], [atom(A)], atom(A)). 
%	with R
prover_h(GAM, false, DN, DP, [], ATOMS, with(A,B)) :-
	prover_h(GAM, false, DN, DP, [], ATOMS, A),
	prover_h(GAM, false, DN, DP, [], ATOMS, B).
%	lolli R
prover_h(GAM, false, DN, DP, [], ATOMS, lolli(A,B)) :- 
	add_to_appropriate_list(A, DN, DP, ATOMS, DN2, DP2, ATOMS2),
	prover_h(GAM, false, DN2, DP2, [], ATOMS2, B).
%	tensor L
prover_h(GAM, false, DN, DP, [], ATOMS, C) :-
	member(tensor(A,B), DP),
	remove(tensor(A,B), DP, DP1),
	add_to_appropriate_list(A, DN, DP1, ATOMS, DN2, DP2, ATOMS2),
	add_to_appropriate_list(B, DN2, DP2, ATOMS2, DN3, DP3, ATOMS3),
	prover_h(GAM, false, DN3, DP3, [], ATOMS3, C).
%	one L
prover_h(GAM, false, DN, DP, [], ATOMS, C) :-
	member(one, DP),
	remove(one, DP, DP1),
	prover_h(GAM, false, DN, DP1, [], ATOMS, C).
%	plus L
prover_h(GAM, false, DN, DP, [], ATOMS, C) :-
	member(plus(A,B), DP),
	remove(plus(A,B), DP, DP1),
	add_to_appropriate_list(A, DN, DP1, ATOMS, DN2, DP2, ATOMS2),
	prover_h(GAM, false, DN2, DP2, [], ATOMS2, C),
	add_to_appropriate_list(B, DN, DP1, ATOMS, DN3, DP3, ATOMS3),
	prover_h(GAM, false, DN3, DP3, [], ATOMS3, C).
%	bang L
prover_h(GAM, false, DN, DP, [], ATOMS, C) :-
	member(bang(A), DP),
	remove(bang(A), DP, DP1),
	append([A], GAM, GAM2),
	prover_h(GAM2, false, DN, DP1, [], ATOMS, C).
%focus R
prover_h(GAM, false, DN, [], [], ATOMS, C) :- 
	is_positive(C),
	prover_h(GAM, false, DN, [], [C], ATOMS, C).
%focus L
prover_h(GAM, false, DN, [], [], ATOMS, C) :-
	member(N, DN),
	remove(N, DN, DN1),
	prover_h(GAM, false, DN1, [], [N], ATOMS, C).
%focus bang
prover_h(GAM, false, DN, [], [], ATOMS, C) :-
	member(F, GAM),
	prover_h(GAM, false, DN, [], [F], ATOMS, C).
% with L
prover_h(GAM, false, DN, [], [with(A,_)], ATOMS, C) :-
	prover_h(GAM, false, DN, [], [A], ATOMS, C).
prover_h(GAM, false, DN, [], [with(_,B)], ATOMS, C) :-
	prover_h(GAM, false, DN, [], [B], ATOMS, C).
% lolli L - B is atom
prover_h(GAM, false, DN, [], [lolli(A,B)], ATOMS, C) :-
	is_atom(B),
	split(DN, DNL, DNR),
	split(ATOMS, ATOMSL, ATOMSR),
	append([B], ATOMSR, ATOMSR2),
	prover_h(GAM, false, DNL, [], [A], ATOMSL, A),
	prover_h(GAM, false, DNR, [], [B], ATOMSR2, C).
% lolli L
prover_h(GAM, false, DN, [], [lolli(A,B)], ATOMS, C) :-
	not_atom(B),
	split(DN, DNL, DNR),
	split(ATOMS, ATOMSL, ATOMSR),
	prover_h(GAM, false, DNL, [], [A], ATOMSL, A),
	prover_h(GAM, false, DNR, [], [B], ATOMSR, C).
% tensor R
prover_h(GAM, false, DN, [], [tensor(A,B)], ATOMS, tensor(A,B)) :-
	split(DN, DNL, DNR),
	split(ATOMS, ATOMSL, ATOMSR),
	prover_h(GAM, false, DNL, [], [A], ATOMSL, A),
	prover_h(GAM, false, DNR, [], [B], ATOMSR, B).
% plus R
prover_h(GAM, false, DN, [], [plus(A,B)], ATOMS, plus(A,B)) :-
	prover_h(GAM, false, DN, [], [A], ATOMS, A).
prover_h(GAM, false, DN, [], [plus(A,B)], ATOMS, plus(A,B)) :-
	prover_h(GAM, false, DN, [], [B], ATOMS, B).
% bang R
prover_h(GAM, false, [], [], [bang(A)], ATOMS, bang(A)) :-
	prover_h(GAM, false, [], [], [], ATOMS, A).
% blur R
prover_h(GAM, false, DN, [], [N], ATOMS, N) :-
	is_negative(N),
	prover_h(GAM, false, DN, [], [], ATOMS, N).
%blur L
prover_h(GAM, false, DN, [], [P], ATOMS, C) :-
	not_atom(P),
	is_positive(P),
	add_to_appropriate_list(P, DN, [], ATOMS, DN1, DP1, ATOMS1),
	prover_h(GAM, false, DN1, DP1, [], ATOMS1, C).
% one R
prover_h(_, false, [], [], [one], [], one).


prover(F) :- is_formula(F), prover_h([], false, [], [], [], [], F).
