# CLASS: Guess
#
# Author: Michael Bathie
#
# REMARKS: Defines what is considered a guess
# in this game of whodunnit
#
#-----------------------------------------

class Guess

	attr_reader :person, :place, :weapon, :type

	def initialize(person, place, weapon, type)
		@person = person
		@place = place
		@weapon = weapon
		@type = type
	end

	def toString
		"#{person.toString} in the #{place.toString} with the #{weapon.toString}"
	end

	def changeToAccusation
		@type = true
	end

	def isAccusation
		@type == true
	end
end