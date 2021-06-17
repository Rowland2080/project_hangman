# frozen_string_literal: true

require 'json'
require 'colorize'

class Hangman
  def initialize
    @secret_word = get_secret_word
    @hangmans_board = Array.new(@secret_word.length,"_ ")
    @guess_count = @secret_word.length
    @wrong_guesses = []
  end

  def get_secret_word
    dictionary = File.readlines("dictionary.txt")
    dictionary = dictionary.map {|words| words.chomp.downcase}
    selected_words = dictionary.select {|word| word.length.between?(5,10)}
    selected_words.sample
  end

  def display_board
    puts "\nThe Hangman's Code: #{@hangmans_board.join.yellow}"
  end

  def valid?(input)
    input.length == 1 && input.between?("a","z") && !@hangmans_board.include?(input) && !@wrong_guesses.include?(input)
  end

  def greeting_message
    <<~HEREDOC

         *************************************
    Welcome to Hangman's Bay, do you think you have what it
    takes to beat the noose? Let's see!
         *************************************
    HEREDOC
  end

  def prompt_load_message
    <<~HEREDOC
    Would you like to load an existing game? if yes,
    kindly input ('y' or 'yes') otherwise input something else
    to start a New game
    HEREDOC
  end

  def save_game
    json = JSON.dump({
      'secret_word' => @secret_word,
      'hangmans_board' => @hangmans_board,
      'guess_count' => @guess_count,
      'wrong_guesses' => @wrong_guesses
    })
    Dir.mkdir('saved_gamefile') unless Dir.exist?('saved_gamefile')
    print "\nInput a name for your saved file: "
    filename = gets.chomp
    filename = filename.strip.gsub(' ','_')
    until !File.exist?("saved_gamefile/#{filename}.json")
      puts "\nSorry, this file already exist, input another name.".red
      filename = gets.chomp
      filename = filename.strip.gsub(' ','_')
    end
    saved_gamefile = File.open("saved_gamefile/#{filename}.json","w")
    saved_gamefile.write(json)
    puts "Game Saved Successfully!".green
  end

  def load_game
    load_file = saved_file if Dir.exist?('saved_gamefile') && !Dir.empty?("saved_gamefile")
    if load_file
      gamefile = File.read("saved_gamefile/#{load_file}")
      file = JSON.load(gamefile)
      @secret_word = file['secret_word']
      @hangmans_board = file['hangmans_board']
      @guess_count = file['guess_count']
      @wrong_guesses = file['wrong_guesses']
    else
      puts "\nSorry you have no saved game".red
      puts "Let's play a new game instead".yellow
      make_guess
      return
    end
    File.delete("saved_gamefile/#{load_file}") if File.exist?("saved_gamefile/#{load_file}")
    puts "Game loaded successfully".green
    make_guess
  end

  def saved_file
      puts "\nThese are the files in your saved game profile:"
      files_to_load = Dir.children("saved_gamefile")
      files_to_load.each_with_index do |value,idx|
        puts "#{(idx + 1)}. #{value}"
      end
      print "\nEnter the number that represents the file you wish to load: "
      input = gets.chomp.to_i
      until input.to_s.length == 1 && input.between?(1,files_to_load.size.to_i)
        puts "Please input a valid number".red
        input = gets.chomp.to_i
      end
      file_to_load = files_to_load[input - 1]
      file_to_load
  end

  def exit_game(input)
    ["save","exit","quit"].any? {|word| word == input}
  end

  def validate_input(input)
    @wrong_guesses.include?(input) ? "Wrong guess!".red : "Correct guess!".green
  end


  def play
    puts greeting_message.yellow.bold
    puts prompt_load_message.bold
    reply = gets.chomp.downcase
    ['y','yes'].include?(reply) ? load_game : make_guess
  end

  def make_guess
    display_board
    until gameover?
      puts "Guesses left: #{@guess_count}"
      puts "Your wrong guesses so far: #{@wrong_guesses.join(", ")}"
      print "Make your guess: "
      input = gets.chomp.downcase
      save_game if input == 'save'
      break if exit_game(input)
      until valid?(input)
        puts "Invalid input!".red
        print "Make another guess: "
        input = gets.chomp.downcase
        save_game if input == 'save'
        return if exit_game(input)
      end
      @wrong_guesses << input if !@secret_word.include?(input)
      make_move(input)
      puts validate_input(input)
      display_board
      @guess_count -= 1 if !@secret_word.include?(input)
    end
    hangmans_verdict
    puts "\nThanks for playing, hope to see you soon.".bold
  end

  def make_move(input)
    if @secret_word.include? input
      @secret_word.each_char.with_index do |char,idx|
        @hangmans_board[idx] = input if char == input
      end
    end
    @hangmans_board
  end

  def hangmans_verdict
    if won?
      puts "\nCongratulations! You cheated the Hangman's Noose this time, \nyou\
 might not be so lucky next time".bold
    elsif lost?
      puts "\nHahaha!, there's no escaping the Hangman's Noose.".bold
      hang_him_now!
      puts "The word is \"#{@secret_word.bold}\""
    end
  end

  def gameover?
     won? || lost?
  end

  def won?
    @hangmans_board.join.split == @secret_word.split
  end

  def lost?
    @guess_count == 0
  end

  def hang_him_now!
    hangmans_noose = "
                    ________
                   |        |
       You ---->  \\O/       |
                   |        |
                  / \\       |
                            |
                            |
                           /|
                __________/_|
    "
    puts hangmans_noose.red
  end

end

game = Hangman.new.play
