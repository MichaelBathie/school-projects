# CLASS: Model
#
# Author: Michael Bathie
#
# REMARKS: Sets up and plays the game.
#
#-----------------------------------------

class Model

	def initialize(suspects, locations, weapons)
		@suspects = suspects
		@locations = locations
		@weapons = weapons
		@players = []
		@numPlayers = 0

		@suspectAnswer = nil
		@locationAnswer = nil
		@weaponAnswer = nil
	end

	#------------------------------------------------------
	# setPlayers
	#
	# PURPOSE:    sets up the list of players
	# PARAMETERS:
	#
	# => players: takes in a list of uninitialized players
	#     
	#------------------------------------------------------
	def setPlayers(players)
		#set the number of players
		@numPlayers = players.length
		#store the list of players
		@players = players

		#setup each player in the list
		@numPlayers.times{ |i| @players[i].setup(@players.length, i, @suspects, @locations, @weapons) }
	end

	#------------------------------------------------------
	# setupCards
	#
	# PURPOSE:    shuffles and distributes the cards as well as
	# choosing the winning guess
	#     
	#------------------------------------------------------
	def setupCards
		#shuffle all of the individual decks of cards
		@suspects = @suspects.shuffle
		@locations = @locations.shuffle
		@weapons = @weapons.shuffle

		#choose the winning guess
		@suspectAnswer = @suspects.delete_at(0)
		@locationAnswer = @locations.delete_at(0)
		@weaponAnswer = @weapons.delete_at(0)

		#move all of the remaining cards together and shuffle them
		@suspects.concat(@locations.concat(@weapons))
		@suspects = @suspects.shuffle

		#distribute all of the remaining cards evenly between all of the players
		(@suspects.length).times{ |i| @players[i % @numPlayers].setCard(@suspects[i]) }
	end

	#------------------------------------------------------
	# correct
	#
	# PURPOSE:   check if an answer is correct 
	#
	# PARAMETERS: 
	# => guess: the guess to check
	#     
	# Returns: if the guess is correct
	#------------------------------------------------------
	def correct(guess)
		#check if each part of the guess is correct
		first = guess.person == @suspectAnswer
		second = guess.place == @locationAnswer
		third = guess.weapon == @weaponAnswer

		#return if they are all correct
		first && second && third
	end

	#------------------------------------------------------
	# allOut?
	#
	# PURPOSE:   See if everyone is out 
	#     
	# Returns: if everyone is out
	#------------------------------------------------------
	def allOut?
		#is everyone out
		allOut = true

		#check
		@numPlayers.times{ |i| if !(@players[i].eliminated?) then allOut = false end }

		#return
		allOut
	end

	#------------------------------------------------------
	# play
	#
	# PURPOSE:  play the game  
	#     
	#------------------------------------------------------
	def play
		#is the game over
		gameOver = false
		#iterate over the players for each turn
		iterate = 0
		#iterate over the players when asking for responses
		iterate2 = 0

		#while no one has won
		while !gameOver
			#set the active player for this turn
			activePlayer = @players[iterate]
			#have they been eliminated yet? If not keep going
			if !activePlayer.eliminated?
				#get the active players guess
				theGuess = activePlayer.getGuess
				#is this guess an accusation?
				if theGuess.isAccusation
					#if so then see if it's correct
					if correct(theGuess)
						#if it's correct then the active player has won
						gameOver = true
						activePlayer.win
					else
						#if not then the active player is eliminated
						activePlayer.setEliminated
						#someone just got eliminated so see if everyone is out
						if allOut?
							gameOver = true
							puts "Everyone is out, no one wins"
						end
					end
				#if the guess is not an accusation
				else
					#start the iterator to go over players for their responses
					iterate2 = (iterate+1) % @numPlayers
					#response is nil if no one can respon
					response = nil

					#while we haven't got back to the asking player
					#and we haven't gotten a reponse yet
					while( !(iterate2==iterate) && response.nil? )
						#ask the next player for their response
						response = @players[iterate2].canAnswer(iterate, theGuess)
						#if response is nil then go to the next player
						if response.nil?
							iterate2 = (iterate2+1) % @numPlayers	
						end
					end

					#if response is still nil
					if response.nil?
						#tell the player no one could answer
						activePlayer.receiveInfo(-1,nil)
					else
						#otherwise show them the response
						activePlayer.receiveInfo(iterate2, response)
					end
				end
			end
			#iterate to the next player
			iterate = (iterate+1) % @numPlayers
		end
	end
end