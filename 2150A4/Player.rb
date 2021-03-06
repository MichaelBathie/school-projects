# CLASS: Player
#
# Author: Michael Bathie
#
# REMARKS:  This class defines the ways a computer
# player will react to situations in the game.
#
#-----------------------------------------
require_relative "Guess"
require_relative "Card"
require_relative "Players"

class Player < Players

	def initialize
		@numPlayers = "setup has not been called"
		@myIndex = "setup has not been called"
		@suspects = "setup has not been called"
		@locations = "setup has not been called"
		@weapons = "setup has not been called"
		#is the last guess from this player the correct answer?
		@isCorrect = false
		@theGuess = nil
		#is this player still in the game
		@eliminated = false
		#cards in hand
		@hand = Hash.new
		#cards seen
		@suspectsNotSeen = []
		@locationsNotSeen = []
		@weaponsNotSeen = []
	end

	#------------------------------------------------------
	# setup
	#
	# PURPOSE:   setup the interactive player 
	#
	# PARAMETERS: 
	# => numPlayers: the number of players
	# => myIndex: the index of the current player
	# => suspects: the list of suspects
	# => locations: the list of locations
	# => weapons: the list of weapons
	#------------------------------------------------------
	def setup(numPlayers, myIndex, suspects, locations, weapons)
		@numplayers = numPlayers
		@myIndex = myIndex
		@suspects = suspects
		@locations = locations
		@weapons = weapons

		#set the cards that have not been seen
		#In this case it will be every card
		setNotSeen

	end

	#------------------------------------------------------
	# setNotSeen
	#
	# PURPOSE:   set which cards have not been seen
	#------------------------------------------------------
	def setNotSeen
		@suspects.length.times{ |i| @suspectsNotSeen[i] = @suspects[i] }
		@locations.length.times{ |i| @locationsNotSeen[i] = @locations[i] }
		@weapons.length.times{ |i| @weaponsNotSeen[i] = @weapons[i] }
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
		#add the card to this players hand
		@hand[newCard.value] = newCard

		#delete the card from the not seen list
		if newCard.type == :person
			@suspectsNotSeen.delete(newCard)
		elsif newCard.type == :place
			@locationsNotSeen.delete(newCard)
		else 
			@weaponsNotSeen.delete(newCard)
		end
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
		#create a temp hand
		tempHand = Hash.new
		#storage for the return card
		returnCard = nil

		####### check if player has any of the guessed cards ######
		if(@hand[guess.person.value] != nil)
			#add it to the temp hand
			tempHand[0] = guess.person.value
		end

		if(@hand[guess.place.value] != nil)
			#add it to the temp hand
			tempHand[1] = guess.place.value
		end

		if(@hand[guess.weapon.value] != nil)
			#add it to the temp hand
			tempHand[2] = guess.weapon.value
		end
		###### finished checking ######

		#if the temp hand is empty then this player can't answer
		if(tempHand.empty?)
			puts "Player #{askerIndex} asked Player #{@myIndex} about Suggestion: #{guess.toString}, but they couldn't answer."
		#otherwise give an answer
		else
			tempHandArray = tempHand.values

			returnCard = @hand[tempHandArray[0]]
			puts "Player #{askerIndex} asked Player #{@myIndex} about Suggestion: #{guess.toString}"
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
		puts "It's Player #{@myIndex}'s turn."

		#if this players last guess was not correct
		if (!@isCorrect)
			#just grab some unseen values
			guessPerson = @suspectsNotSeen[0]
			guessPlace = @locationsNotSeen[0]
			guessWeapon = @weaponsNotSeen[0]

			#check if you only have 3 options
			if(@suspectsNotSeen.length == 1 && @locationsNotSeen.length == 1 && @weaponsNotSeen.length == 1)
				@theGuess = Guess.new(guessPerson, guessPlace, guessWeapon, true)
			else 
				@theGuess = Guess.new(guessPerson, guessPlace, guessWeapon, false)
			end

			@theGuess
		#if it was 
		else
			puts "Player #{@playerIndex} makes an Accusation: #{@theGuess.toString}!"
			#take the last guess, change it to an accusation, and return it
			@theGuess.changeToAccusation
			@theGuess
		end
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
			#then the guess was correct 
			@isCorrect = true
			puts "No one could answer"
		else
			#otherwise show this player a card the refute their guess
			puts "Player #{playerIndex} showed Player #{@myIndex} a card"

			#and delete the card they were shown for the not seen list
			if card.person?
				@suspectsNotSeen.delete(card)
			elsif card.place?
				@locationsNotSeen.delete(card)
			else
				@weaponsNotSeen.delete(card)
			end
		end
	end
end