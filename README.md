# Hangman

Created as part of The Odin Project Curriculum

### About Game

At the beginning of the game, a word is chosen at random from a selected file. The player is allowed a certain number of guesses which reduces by one after every wrong guess. The game is over either when:
* The player guesses the secret word without exhausting the guesses given and in which case he avoids the noose.
OR
* When the number of guesses has been exhausted and the secret word hasn't been found in which case the player hangs.

**The aim of the game is to guess The Hangman's secret word before running out of guesses**

#### Serialization

This game has a _**save**_ and _**load**_ functionality. When the game starts, the player is given the option to load a saved game or start a new one.
At any point in the game, the player can choose to save a game by typing the word *'save'* or can also choose to quit without saving by typing the word *'exit'* or *'quit'*.
