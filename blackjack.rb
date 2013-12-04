def show_intro
	puts "WELCOME TO RUBY BLACKJACK"
	puts "-------------------------"
	puts
end

def show_options
	puts "To proceed, select one of the following options:"
	puts "(s)tart game, (c)onfigure, (q)uit"
end

def get_new_deck
	suits = { :c => "clubs", :d => "diamonds", :h => "hearts", :s => "spades"}
	cardvalues = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]

	newdeck = Array.new
	suits.each do |suitkey, suitvalue|
		cardvalues.each do |cardvalue|
			newdeck << suitkey.to_s + ";" + cardvalue
		end
	end	
	return newdeck
end

def get_number_of_decks
	puts "how many decks should we use? (default = 3)"
	number_of_decks = gets.chomp
	return number_of_decks.to_i
end

def setup_cards
	$number_of_decks.times do
		$cards.concat get_new_deck
	end
	$cards.shuffle!
end

def debug_cards(cards)
	cards.each do |c|
		puts c
	end
end

def start_game
	setup_cards
	puts "Starting new game with #{$number_of_decks} decks"

	show_game_options
	selected_game_option = gets.chomp
	
	while selected_game_option != "q" do
		case selected_game_option
			when "d"
				play_a_round
		end
		show_game_options
		selected_game_option = gets.chomp
	end
end

def play_a_round
	$cards.shuffle!
	deal_cards

	puts
	puts "your cards:"
	show_hand($player_hand)
	
	show_action_options
	selected_action = gets.chomp

	while selected_action == "h" do
		add_card($player_hand)

		puts "your cards:"
		show_hand($player_hand)

		hand_value = get_hand_value($player_hand)
		if hand_value < 21
			show_action_options
			selected_action = gets.chomp
		else
			selected_action = ""
		end										
	end

	player_hand_value = get_hand_value($player_hand)
	if selected_action == "s" || player_hand_value == 21
		puts "You have BlackJack!" if player_hand_value == 21
		play_dealer
	elsif player_hand_value > 21
		puts "You are bust."
		round_lost
	else
		round_lost
	end

	$player_hand = Array.new
	$dealer_hand = Array.new
		
end

def play_dealer
	puts "dealer cards:"
	show_hand($dealer_hand)
	player_hand_value = get_hand_value($player_hand)

	while get_hand_value($dealer_hand) <= player_hand_value do
		add_card($dealer_hand)
		puts
		show_hand($dealer_hand)
	end

	dealer_hand_value = get_hand_value($dealer_hand)
	if dealer_hand_value > 21
		round_won
	elsif dealer_hand_value < 21
			round_lost
	else
		puts "Dealer has BlackJack!"
		round_lost
	end

end

def round_won
	$player_score += 1
	puts
	puts "You won this round!"
	puts "The score is:"
	puts "YOU    => " + $player_score.to_s
	puts "DEALER => " + $dealer_score.to_s
	puts
end

def round_lost
	$dealer_score += 1
	puts
	puts "You lost this round :("
	puts "The score is:"
	puts "YOU    => " + $player_score.to_s
	puts "DEALER => " + $dealer_score.to_s
	puts
end

def add_card(hand)
	hand << $cards.shift
end

def get_hand_value(hand)
	hand_value = 0
	hand.each do |c|
		card_value = c.split(';')[1]
		if ['A', 'K', 'J', 'Q'].include? card_value
			hand_value += 10
		else
			hand_value += card_value.to_i
		end		
	end

	if hand_value > 21 && hand.any? { |c| c.split(';')[1] == 'A'}
		aces = hand.select{|c| c.split(';')[1] == 'A'}
		while hand_value > 21 && aces.any?
			hand_value -= 9
			aces.pop
		end
	end
	return hand_value
end

def show_action_options
	puts "what would you like to do?"
	puts "(h)it (s)tand (g)ive up"
end

def show_hand(hand)
	topleft = "\u{250c}"
	topright = "\u{2510}"
	vertical = "\u{2502}"
	horizontal = "\u{2500}"
	bottomleft = "\u{2514}"
	bottomright = "\u{2518}"

	hand.each do |c|
		print topleft + horizontal + horizontal + horizontal + topright + " "
	end
	puts 
	
	hand.each do |c|
		print vertical + get_suit_character(c.split(';')[0]) + "  " + vertical + " "
	end
	puts

	hand.each do |c|
		if c.split(';')[1].length > 1 
			print vertical + " " + c.split(';')[1] + vertical + " "
		else
			print vertical + "  " + c.split(';')[1] + vertical + " "
		end
	end
	puts

	hand.each do |c|
		print bottomleft + horizontal + horizontal + horizontal + bottomright + " "
	end
	puts

end

def get_suit_character(suit)
	case suit
		when "c"
			return "\u{2663}"
		when "h"
			return "\u{2665}"
		when "d"
			return "\u{2666}"
		when "s"
			return "\u{2660}"
		else
			return ""
	end
end

def show_game_options
	puts "To proceed, choose an action:"
	puts "(d)eal (q)uit"
end

def deal_cards
	2.times do
		$player_hand << $cards.shift
		$dealer_hand << $cards.shift
	end
end

def configure

end

# setup default values
$number_of_decks = 3
$cards = Array.new
$player_score = 0
$dealer_score = 0
$player_hand = Array.new
$dealer_hand = Array.new

show_intro
show_options
$selected_option = gets.chomp

while $selected_option != "q" do
	case $selected_option
		when "s"
			start_game
		when "c"
			configure
	end

	show_options
	$selected_option = gets.chomp
end

puts "GOODBYE"



