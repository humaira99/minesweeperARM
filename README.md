# minesweeperARM
Minesweeper game in ARM Assembly Code.

My Minesweeper variant is played on a eight by eight grid, of which eight squares are filled with mines (represented by the letter ‘M’).\
The eight mines are distributed randomly on the board, and then each square is covered up by a ‘*’.\
As the game is played, the user selects a square to be uncovered (by typing in the co-ordinates for the squares).\
If the uncovered squares contains a mine, then they lose. Otherwise, the square is revealed to show how many mines are in the squares surrounding it (as a number between ‘1’ and ‘8’) or a empty (represented as a space) if there are no mines around it.  
The game is won if the player can turn over the 56 squares that do not contain mines, without accidentally uncovering a mine.\
The following diagram shows the initial board display, and the grid reference system can be seen.\
The rows are identified by letters (case-insensitive) and the columns by numbers, allowing the user to enter a co-ordinate as ‘b1’ or ‘A4’.\
The system should not accept incorrect co-ordinates, and should ask the user to re-enter valid coordinates.

  1 2 3 4 5 6 7 8\
A * * * * * * * *\
B * * * * * * * *\
C * * * * * * * *\
D * * * * * * * *\
E * * * * * * * *\
F * * * * * * * *\
G * * * * * * * *\
H * * * * * * * *

Enter square to reveal: \
Revealed squares are shown thus (note the blank squares): \

  1 2 3 4 5 6 7 8\
A 1 M 1     1 M M\
B 1 1 1     1 3 M\
C             1 1\
D 1 1 1          \
E 1 M 1 1 1 1    \
F 1 1 1 1 M 1    \
G 1 1 2 2 2 1    \
H 1 M 2 M 1      

Enter square to reveal:\

With mines being represented as an ‘M’:
  1 2 3 4 5 6 7 8\
A 1 * * * * 1 * M\
B * * * * * * 3 *\
C * * * *   * * *\
D 1 1 * * * * * *\
E * * * 1 1 * * *\
F * 1 * 1 * * * *\
G * * 2 * * * * *\
H 1 * * * 1   * *

You lose...
 

-----------------------
Created: December 2017
