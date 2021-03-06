# CLASS: InteractivePlayer
#
# Author: Michael Bathie
#
# REMARKS:  This class defines how the 
# human player can play the game.
#
#-----------------------------------------
require_relative "Guess"
require_relative "Card"
require_relative "Players"

class InteractivePlayer < Players

	def initialize
		@numPlayers = "setup has not been called"
		@myIndex = "setup has not been called"
		@suspects = "setup has not been called"
		@locations = "setup has not been called"
		@weapons = "setup has not been called"
		#is this player still in the game
		@eliminated = false
		#cards in hand
		@hand = Hash.new
	end

	#------------------------------------------------------
	# setup
	#
	# PURPOSE:   setup the interactice player 
	#
	# PARAMETERS: 
	# => numPlayers: the number of players
	# => myIndex: the index of the current player
	# => suspects: the list of suspects
	# => locations: the list of locations
	# => weapons: the list of weapons
	#------------------------------------------------------
	def setup (numPlayers, myIndex, suspects, locations, weapons)
		@numplayers = numPlayers
		@myIndex = myIndex
		@suspects = suspects
		@locations = locations
		@weapons = weapons
	end

	#------------------------------------------------------
	# setCard
	#
	# PURPOSE:   give a card to a player 
	#
	# PARAMETERS: 
	# => newCard: the card to give to the player
	#------------------------------------------------------
	def setCard(newCard)
		#place the card in the players hand
		@hand[newCard.value] = newCard
		puts "You recieved the card #{newCard.value}!"
	end

	#------------------------------------------------------
	# canAnswer
	#
	# PURPOSE:   see if this player can answer the guess 
	#
	# PARAMETERS: 
	# => askerIndex: the index of the person that guessed
	# => guess: the guess to see if the player can answer
	#     
	# Returns: return a card if the player can answer or nil if 
	# they can't
	#------------------------------------------------------
	def canAnswer(askerIndex, guess)
		#create a temporary hand
		tempHand = Hash.new
		#storage for the card to be returned
		returnCard = nil

		####### check if player has any of the guessed cards ######
		if(@hand[guess.person.value] != nil)
			#put that card into the temporary hand
			tempHand[0] = guess.person.value
		end

		if(@hand[guess.place.value] != nil)
			#put that card into the temporary hand
			tempHand[1] = guess.place.value
		end

		if(@hand[guess.weapon.value] != nil)
			#put that card into the temporary hand
			tempHand[2] = guess.weapon.value
		end
		###### finished checking ######

		#if this players temporary hand is empty then they can't answer
		if(tempHand.empty?)
			puts "Player #{askerIndex} asked you about Suggestion: #{guess.toString}, but you couldnt answer"
		#otherwise this player can answer the guess
		else
			puts "Player #{askerIndex} asked you about Suggestion: #{guess.toString}"
			#get the length of the temporary hand
			length = tempHand.length
			#get an array of the temp hands values
			tempHandArray = tempHand.values

			#if you only have one card to show
			if(length == 1)
				returnCard = @hand[tempHandArray[0]]
				puts "You can only show your #{tempHandArray[0]} card."
			#otherwise you can choose what card to show
			else
				puts "Which card would you like to show Player #{askerIndex}?"	
				length.times{ |i| puts "#{i}. #{tempHandArray[i]}"}

				#ask the player which card they want to show
				choice = gets.to_i

				#make sure their response is valid
				while (choice >= length)
					puts "Please enter a valid integer response."
					choice = gets.to_i
				end
				returnCard = @hand[tempHandArray[choice]]
			end
		end
		#return the card
		returnCard
	end

	#------------------------------------------------------
	# getGuess
	#
	# PURPOSE:   get the interactive players guess
	#     
	# Returns: the interactive players guess
	#------------------------------------------------------
	def getGuess
		#store the guess
		theGuess = nil
		puts "It is your turn."

		###### Prompt the user for a person, place, weapon, and guess type ######
		puts "Who do you suspect?"
		length = @suspects.length
		length.times{ |i| puts "#{i}. #{@suspects[i].toString}"}
		#ask for input
		choice1 = gets.to_i

		#make sure input is valid
		while (choice1 >= length && choice1 >= 0)
			puts "Please enter a valid integer response."
			choice1 = gets.to_i
		end


		puts "Where do you think it happened?"
		length = @locations.length
		length.times{ |i| puts "#{i}. #{@locations[i].toString}"}
		#ask for input
		choice2 = gets.to_i

		#make sure input is valid
		while (choice2 >= length && choice2 >= 0)
			puts "Please enter a valid integer response."
			choice2 = gets.to_i
		end

		
		puts "What weapon did they use?"
		length = @weapons.length
		length.times{ |i| puts "#{i}. #{@weapons[i].toString}"}
		#ask for input
		choice3 = gets.to_i

		#make sure input is valid
		while (choice3 >= length && choice3 >= 0)
			puts "Please enter a valid integer response."
			choice3 = gets.to_i
		end
		
		#store all the guess values
		guessSuspect = @suspects[choice1]
		guessLocation = @locations[choice2]
		guessWeapon = @weapons[choice3]

		puts "Is this an accusation (Y/N)?"
		guessType = gets.chomp
		###### Done prompts ######

		#make sure the input is valid
		while(guessType != "Y" && guessType != "y" && guessType != "N" && guessType != "n")
			puts "Please enter one of the valid options: \"Y\", \"y\", \"N\",\"n\""
			guessType = gets.chomp
		end

		#create the guess
		if(guessType == "Y" || guessType == "y")
			theGuess = Guess.new(guessSuspect, guessLocation, guessWeapon, true)
		else
			theGuess = Guess.new(guessSuspect, guessLocation, guessWeapon, false)
		end

		#return the guess
		theGuess
	end

	#------------------------------------------------------
	# receiveInfo
	#
	# PURPOSE:   receive information from another player
	#
	# PARAMETERS: 
	# => playerIndex: the player that is giving the information
	# => card: the card that playerIndex showed
	#------------------------------------------------------
	def receiveInfo(playerIndex, card)
		#if no one could answer
		if(playerIndex == -1 && card == nil)
			puts "No player could answer your guess."
		else
			#otherwise show card
			puts "Player #{playerIndex} showed you #{card.value}!"
		end
	end
end