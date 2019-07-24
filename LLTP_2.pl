% 	Written By:
%		Ishaq Yousef Haj Hasan,
%		Hari Krishna. 
%
%	Prolog implementation of LLTP
%	
%	Notes:
%		I will translate this to SML eventually, but prolog automatically
%		handles backtracking (and trying different splits).
%
%		This version uses arity of 5 vs 7 (dropped the focused and atoms list)
%										   atoms moved to delta positive.
%		Atoms are negative


%	Taken from Sudoku by Julian Sam (Recitation 8) ------------------------
%	UNMODIFIED
remove(X, [X|T], T).
remove(X, [Y|T], [Y|L1]) :- remove(X, T, L1).
%		-----------------------------------------------------------------------

:- op(2, xfx, lolli). % lolli 
:- op(5, xfx, *). % tensor
:- op(4, xfx, &). % with
% :- op(1, xfx, | ). % par
:- op(3, xfx, +). % plus
:- op(6, fx , !). % bang
:- op(1, fx , atom).
:- op(7, fx , focus).
% :- op(1, xfx, ? ).
% :- op(1, xfx, ^ ).

is_formula(top).
is_formula(zero).
is_formula(one).
is_formula(atom _).
is_formula(A * B) 	:- is_formula(A), is_formula(B).
is_formula(A & B) 	:- is_formula(A), is_formula(B).
is_formula(A + B) 	:- is_formula(A), is_formula(B).
is_formula(A lolli B) 	:- is_formula(A), is_formula(B).
is_formula(! A) 	:- is_formula(A).

is_focused_formula(focus A) :- is_formula(A).

add_to_appropriate_list(top, DN, DP, [top|DN], DP).
add_to_appropriate_list(zero, DN, DP, DN, [zero|DP]).
add_to_appropriate_list(one, DN, DP, DN, [one|DP]).
add_to_appropriate_list(atom A, DN, DP, [atom A | DN], DP).
add_to_appropriate_list(A * B, DN, DP, DN, [A * B|DP]).
add_to_appropriate_list(A & B, DN, DP, [A & B|DN], DP).
add_to_appropriate_list(A + B, DN, DP, DN, [A + B|DP]).
add_to_appropriate_list(A lolli B, DN, DP, [A lolli B|DN], DP).
add_to_appropriate_list(! A, DN, DP, DN, [! A|DP]).
add_to_appropriate_list(focus A, DN, DP, [focus A | DN], DP) :- is_negative(A).
add_to_appropriate_list(focus A, DN, DP, DN, [focus A | DP]) :- is_positive(A).


split([],[],[]).
split([A], [A], []).
split([A], [], [A]).
split([A|L], [A|L1], L2) :- split(L, L1, L2).
split([A|L], L1, [A|L2]) :- split(L, L1, L2).

is_positive(_ * _).
is_positive(one).
is_positive(_ + _).
is_positive(zero).
is_positive(! _).

is_negative(atom _).
is_negative(_ & _).
is_negative(_ lolli _).
is_negative(top).

no_focus([]).
no_focus([A | L]) :- is_formula(A), no_focus(L).


prover_h(_, true, _, _, _).
prover_h(_, _, _, _, top).
% init positive
prover_h(_, _, [focus atom A], [], atom A).
% with R
prover_h(GAM, _, DN, DP, A & B) :-
	prover_h(GAM, false, DN, DP, A),
	no_focus(DN), no_focus(DP),
	prover_h(GAM, false, DN, DP, B).
% lolli R
prover_h(GAM, _, DN, DP, A lolli B) :-
	add_to_appropriate_list(A, DN, DP, DN1, DP1),
	no_focus(DN), no_focus(DP),
	prover_h(GAM, false, DN1, DP1, B).
% tensor L
prover_h(GAM, _, DN, DP, C) :-
	member(A * B, DP),
	no_focus(DN), no_focus(DP),
	remove(A * B, DP, DP1),
	add_to_appropriate_list(A, DN, DP1, DN2, DP2),
	add_to_appropriate_list(B, DN2, DP2, DN3, DP3),
	prover_h(GAM, false, DN3, DP3, C).
% one L
prover_h(GAM, _, DN, DP, C) :-
	member(one, DP),
	no_focus(DN), no_focus(DP),
	remove(one, DP, DP1),
	prover_h(GAM, false, DN, DP1, C).
% plus L
prover_h(GAM, _, DN, DP, C) :-
	member(A + B, DP),
	no_focus(DN), no_focus(DP),
	remove(A + B, DP, DP1),
	add_to_appropriate_list(A, DN, DP1, DN2, DP2),
	prover_h(GAM, false, DN2, DP2, C),
	add_to_appropriate_list(B, DN, DP1, DN3, DP3),
	prover_h(GAM, false, DN3, DP3, C).
% bang L
prover_h(GAM, _, DN, DP, C) :-
	member(! A, DP),
	no_focus(DN), no_focus(DP),
	remove(! A, DP, DP1),
	prover_h([A|GAM], false, DN, DP1, C).
% focus R
prover_h(GAM, _, DN, [], C) :-
	no_focus(DN),
	is_positive(C),
	prover_h(GAM, false, DN, [], focus C).
% focus L
prover_h(GAM, _, DN, [], C) :-
	no_focus(DN),
	member(N, DN),
	remove(N, DN, DN1),
	prover_h(GAM, false, [focus N|DN1], [], C).
% focus bang
	% streamlines blur
prover_h(GAM, _, DN, [], C) :-
	no_focus(DN),
	member(A, GAM),
	is_positive(A),
	prover_h(GAM, false, DN, [A], C).
prover_h(GAM, _, DN, [], C) :-
	no_focus(DN),
	member(A, GAM),
	is_negative(A),
	prover_h(GAM, false, [focus A| DN], [], C).
% tensor R
prover_h(GAM, _, DN, [], focus A * B) :-
	split(DN, DNL, DNR),
	prover_h(GAM, false, DNL, [], focus A),
	prover_h(GAM, false, DNR, [], focus B).
% one R
prover_h(_, _, [], [], focus one).
% plus R
prover_h(GAM, _, DN, [], focus A + _) :-
	prover_h(GAM, false, DN, [], focus A).
prover_h(GAM, _, DN, [], focus _ + B) :-
	prover_h(GAM, false, DN, [], focus B).
% bang R
prover_h(GAM, _, DN, [], focus ! A) :-
	prover_h(GAM, false, DN, [], A).
% with L
prover_h(GAM, _, DN, [], C) :-
	member(focus A & B, DN),
	remove(focus A & B, DN, DN1),
	add_to_appropriate_list(focus A, DN1, [], DN2, DP2),
	prover_h(GAM, false, DN2, DP2, C).
prover_h(GAM, _, DN, [], C) :-
	member(focus A & B, DN),
	remove(focus A & B, DN, DN1),
	add_to_appropriate_list(focus B, DN1, [], DN2, DP2),
	prover_h(GAM, false, DN2, DP2, C).
% lolli L
prover_h(GAM, _, DN, [], C) :-
	member(focus A lolli B, DN),
	remove(focus A lolli B, DN, DN1),
	split(DN1, DNL, DNR),
	prover_h(GAM, false, DNL, [], focus A),
	add_to_appropriate_list(focus B, DNR, [], DNR2, DPR2),
	prover_h(GAM, false, DNR2, DPR2, C).
% blur R
prover_h(GAM, _, DN, [], focus N) :-
	is_negative(N),
	prover_h(GAM, false, DN, [], N).
%blur L
prover_h(GAM, _, DN, [focus P], C) :-
	is_positive(P),
	prover_h(GAM, false, DN, [P], C).


prover(F) :- is_formula(F), prover_h([], false, [], [], F).
	
	


