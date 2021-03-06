# CLASS: Players
#
# Author: Michael Bathie
#
# REMARKS:  The top of the hierarchy of players meant
# to complete tasks general to both of its subclasses.
#
#-----------------------------------------

class Players

	#make the players class abstract
	def Players.new(*args)
		if self == Players
			raise "You shouldn\'t be trying to make an instance of this class"
		else
			super
		end
	end

	def initialize()
		@numPlayers = nil
		@myIndex = nil
		@suspects = nil
		@locations = nil
		@weapons = nil
		#cards in hand
		@hand = nil
		#is this player eliminated
		@eliminated = nil
	end
	
	def setup(numPlayers, myIndex, suspects, locations, weapons)
		raise "method setup is not defined in #{self}"
	end

	#------------------------------------------------------
	# win
	#
	# PURPOSE:   display a message saying who won the game 
	#------------------------------------------------------
	def win
		puts "Player #{@myIndex} made a correct accusation and has won the game!"
	end

	#------------------------------------------------------
	# setEliminated
	#
	# PURPOSE:   set that this player has been eliminated
	#------------------------------------------------------
	def setEliminated
		@eliminated = true
		puts "Player #{@myIndex} has made a false accusation and is eliminated!"
	end

	#------------------------------------------------------
	# eliminated?
	#
	# PURPOSE:   check if this player has been eliminated
	#------------------------------------------------------
	def eliminated?
		@eliminated
	end

	def setCard
		raise "method setCard is not defined in #{self}"
	end


	def canAnswer(index, guess)
		raise "method canAnswer is not defined in #{self}"
	end


	def getGuess
		raise "method getGuess is not defined in #{self}"
	end


	def receiveInfo(index, card)
		raise "method receiveInfo is not defined in #{self}"
	end

end