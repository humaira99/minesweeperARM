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

-----------------------
Created: December 2017
