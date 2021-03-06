# CLASS: Card
#
# Author: Michael Bathie
#
# REMARKS: How a card is defined in this game
#
#-----------------------------------------

class Card

	attr_reader :type, :value

	def initialize(type, value)
		@type = type
		@value = value
	end

	def toString
		"#{@value}"
	end

	def person?
		@type == :person
	end

	def place?
		@type == :place
	end

	def weapon?
		@type == :weapon
	end	
end