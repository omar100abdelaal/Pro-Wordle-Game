
main:-
	write('Welcome to Pro-Wordle!'),nl,
	write('----------------------'),nl,
	build_kb,nl,
	play.
	
% Knowledge Base Phase.
build_kb:-
	write('Please enter a word and its category on separate lines:'),nl,
	read(X),
	( X== done,nl,write('Done building the words database...')
	;
	read(Y), assert( word(X,Y) ),
	build_kb ).

% Game Phase.
play :-
	write('The available categories are: '),
	categories(LL), write(LL),nl,
	chooseC(C),nl,
	chooseL(L,C),
	pick_word_random(W,L,C),
	G is L+1, write('Game started. You have '),write(G),write(' guesses.'),nl,nl,
	gEntry(W,L,C,G).

% Helper which validates the entered Category.
chooseC(C):-
	write('Choose a category:'),nl,
	read(C1),
	(
	\+is_category(C1), write('This category does not exist.'),nl, chooseC(C)
	;
	C = C1 ).
	
% Helper which validates the entered Length.
chooseL(L,C):-
	write('Choose a length:'),nl,
	read(L1),
	(
	\+available_lengthInCategory(L1,C),write('There are no words of this length.'),nl, chooseL(L,C)
	;
	L = L1 ).
	
% Helper which validates if there is a word with the specifed Length and Category.
available_lengthInCategory(L,C):-
	word(W,C),
	atom_length(W,L).

% Helper which returns a word with the specifed Length and Category randomly.
pick_word_random(R,L,C):-
	setof(W,( word(W,C),atom_length(W,L) ),L1),
	random_member(R, L1).

% Helper which validates the enterd Word and outputs accordingly.
gEntry(W,L,C,G):-
	% case 0: Skipped the limit of guesses.
	G == 0, write('You lost!')
	;
	
	write('Enter a word composed of '),write(L),write(' letters:'),nl,
	read(W2),
	
	% case 1: Length is not right.
	(atom_length(W2,L1), L\=L1 , 
	write('Word is not composed of '), write(L), write(' letters. Try again.'),nl,
	write('Remaining Guesses are '), write(G),nl,nl,
	gEntry(W,L,C,G) 
	;
	% case 2: Word is not in Knowledge Base (KB).
	\+word(W2,_),
	write('Word is not in KB. Please enter another word.'),nl,
	write('Remaining Guesses are '), write(G),nl,nl,
	gEntry(W,L,C,G) 
	;
	% case 3: The correct word is entered.
	W == W2, write('You Won!')
	;
	% case 4: A word is entered and is to be checked of Correct letters, positions and the remaining guesses.
	G1 is G-1,
	(G==1 ;
	atom_chars(W,LW1), atom_chars(W2,LW2),
	write('Correct letters are: '), correct_letters(LW1,LW2,L1), write(L1),nl,
	write('Correct letters in correct positions are: '), correct_positions(LW1,LW2,L2), write(L2),nl,
	write('Remaining Guesses are '), write(G1),nl,nl), 
	gEntry(W,L,C,G1),nl).
	
%  succeeds if C is an available category in the KB.	
is_category(C):-
	word(_,C).

% succeeds if L is a list containing all the available categories without duplicates.
categories(L):-
	setof(C,is_category(C),L).

% succeeds if there are words in the KB with length L.
available_length(L):-
	word(W,_),
	atom_length(W,L).

%  succeeds if W is a word in the KB with length L and category C.
pick_word(W,L,C):-
	word(W,C),
	atom_length(W,L).
	
% succeeds if CL is a list containing the letters in both L1 and L2.
correct_letters(W1,W2,L):-
	setof(C,( member(C,W1),member(C,W2) ),L),! ; L = [].
	
% succeeds if L is a list containing the letters that
% occur in both W1 and W2 in the same positions.
correct_positions(W1,W2,L):-
   bagof(C,letsame(W1,W2,C),L),!;L=[].

% Helper to return C which is the matching of letters in positions.
letsame([H1|T1],[H2|T2],C):-
   ( H1=H2,
   H1=C );
   letsame(T1,T2,C).
