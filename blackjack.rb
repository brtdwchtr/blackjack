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

def show_game_header
  puts "** PLAYING BLACKJACK **"
  puts "Your chips value: #{$player_chips_value}"
  puts "Your current bet: #{$current_bet}" if $current_bet > 0 && $current_bet <= $max_bet && $current_bet <= $player_chips_value
  puts 
end

def start_game
  setup_cards

  empty_screen
  show_game_header
  show_game_options
  selected_game_option = gets.chomp
  empty_screen

  while selected_game_option != "r" do
    play_a_round
    show_game_options
    selected_game_option = gets.chomp
    empty_screen
  end
end

def is_num?(str)
  begin
    !!Integer(str)
  rescue ArgumentError, TypeError
    false
  end
end

def get_player_bet
  bet_value = ""
  loop do
    empty_screen
    show_game_header
    show_betting
    bet_value = gets.chomp
    
    if(bet_value.split(' ')[0] == 'deposit')
      $player_chips_value += bet_value.split(' ')[1].to_i
    end
    
    break if bet_value == "" || is_num?(bet_value)
  end

  if bet_value == ""
    $current_bet = $default_bet
  else
    $current_bet = bet_value.to_i
  end
end

def play_a_round
  # first place bet
  get_player_bet
  while $current_bet < 0 || $current_bet > $max_bet || $current_bet > $player_chips_value
    get_player_bet
  end

  $player_chips_value -= $current_bet

  $cards.shuffle!
  deal_cards

  empty_screen
  show_game_header
  show_hands(true)
  selected_action = ""

  # if player got dealt 21, immediately stand
  if get_hand_value($player_hand) == 21
    selected_action == "s"
  else
    show_action_options
    selected_action = gets.chomp
    empty_screen
  end

  while selected_action == "h" do
    add_card($player_hand)
    show_game_header
    show_hands(true)

    hand_value = get_hand_value($player_hand)
    if hand_value < 21
      show_action_options
      selected_action = gets.chomp
      empty_screen
    else
      selected_action = ""
    end                   
  end

  player_hand_value = get_hand_value($player_hand)
  if selected_action == "s" || player_hand_value == 21 
    puts "You have BlackJack!" if has_blackjack?($player_hand)
    play_dealer
  elsif selected_action == "g"
    puts "You surrendered this round."
    round_lost
  else
    puts "You're bust."
    play_dealer
  end

  finish_round

  $player_hand = Array.new
  $dealer_hand = Array.new
    
end

def show_betting
  puts "Enter your bet. Max bet is #{$max_bet}"
  puts "(press enter to accept default bet of #{$default_bet})"
  puts "(type 'deposit [AMOUNT]' to buy chips)"
  puts
end

def has_blackjack?(hand)
  hand_value = get_hand_value(hand)
  return false if hand_value != 21
  return true if hand.length == 2 && hand.any?{|card| card.split(';')[1] == 'A'} 
  return false
end

def play_dealer
  empty_screen
  show_game_header
  show_hands(false)

  while get_hand_value($dealer_hand) < $dealer_stand_limit do
    sleep 1
    add_card($dealer_hand)
    empty_screen
    show_game_header
    show_hands(false)
  end
end

def finish_round
  winner = get_winner
  case winner
  when "player"
    round_won(has_blackjack?($player_hand))
  when "dealer"
    round_lost
  else
    round_tied
  end
  $current_bet = -1
end

def get_winner
  dealer_hand_value = get_hand_value($dealer_hand)
  player_hand_value = get_hand_value($player_hand)

  #check blackjacks
  if has_blackjack?($player_hand) && has_blackjack?($dealer_hand) == false
    return "player"
  end

  if has_blackjack?($player_hand) == false && has_blackjack?($dealer_hand)
    return "dealer"
  end

  if has_blackjack?($player_hand) && has_blackjack?($dealer_hand)
    return ""
  end

  # check busts
  if player_hand_value > 21 && dealer_hand_value > 21
    return ""
  end

  if player_hand_value > 21 && dealer_hand_value <= 21
    return "dealer"
  end

  if player_hand_value <= 21 && dealer_hand_value > 21
    return "player"
  end

  # check normal
  if player_hand_value > dealer_hand_value
    return "player"
  elsif dealer_hand_value > player_hand_value
    return "dealer"
  end

  return ""
end

def round_won(isblackjack = false)
  amount_won = 0
  if isblackjack
    amount_won += ($current_bet + ($current_bet/2)*3)
  else 
    amount_won += $current_bet*2
  end
  $player_chips_value += amount_won

  puts
  puts "You won this round!"
  puts "You won #{amount_won - $current_bet} and now have #{$player_chips_value} in chips."
  puts
end

def round_lost
  puts
  puts "You lost this round :("
  puts "You have #{$player_chips_value} in chips left"
  puts
end

def round_tied
  $player_chips_value += $current_bet

  puts
  puts "Round Tied!"
  puts "You have #{$player_chips_value} in chips"
  puts
end

def add_card(hand)
  hand << $cards.shift
end

def get_hand_value(hand)
  hand_value = 0
  hand.each do |c|
    card_value = c.split(';')[1]
    if ['K', 'J', 'Q'].include? card_value
      hand_value += 10
    elsif card_value == 'A'
      hand_value += 11
    else
      hand_value += card_value.to_i
    end   
  end

  if hand_value > 21 && hand.any? { |c| c.split(';')[1] == 'A'}
    aces = hand.select{|c| c.split(';')[1] == 'A'}
    while hand_value > 21 && aces.any?
      hand_value -= 10
      aces.pop
    end
  end
  return hand_value
end

def show_action_options
  puts "what would you like to do?"
  puts "(h)it | (s)tand | (g)ive up"
end

def show_hands(hidedealer)
  show_hand("YOUR CARDS:", $player_hand, false)
  show_hand("DEALER CARDS:", $dealer_hand, hidedealer)
end

def show_hand(prompt, hand, hidesecond)
  puts prompt
  if(hidesecond)
    print_start_hand(hand)
  else
    print_hand(hand)
  end
  puts
end

def print_start_hand(hand)
  hand.each do 
    print_card_top
  end
  puts

  print_card_suit(hand[0])
  print_card_suit(nil)
  puts

  print_card_value(hand[0])
  print_card_value(nil)
  puts

  hand.each do
    print_card_bottom
  end

  puts
  puts "card total: ??"
end

def print_hand(hand)
  hand.each do 
    print_card_top
  end
  puts 
  
  hand.each do |card|
    print_card_suit(card)
  end
  puts

  hand.each do |card|
    print_card_value(card)
  end
  puts

  hand.each do
    print_card_bottom
  end
  
  puts
  if has_blackjack?(hand)
    puts "blackjack!"
  elsif get_hand_value(hand) > 21
    puts "bust."
  else
    puts "card total: " + get_hand_value(hand).to_s
  end
end

def print_card_top
  topleft = "\u{250c}"
  topright = "\u{2510}" 
  horizontal = "\u{2500}"
  print "#{topleft}#{horizontal}#{horizontal}#{horizontal}#{topright} "
end

def print_card_bottom
  horizontal = "\u{2500}"
  bottomleft = "\u{2514}"
  bottomright = "\u{2518}"
  print "#{bottomleft}#{horizontal}#{horizontal}#{horizontal}#{bottomright} "
end

def print_card_suit(card)
  vertical = "\u{2502}"
  block = "\u{2591}"

  if card == nil
    print "#{vertical}#{block}#{block}#{block}#{vertical}"
  else
    suitcharacter = get_suit_character(card.split(';')[0])
    print "#{vertical}#{suitcharacter}  #{vertical} "
  end
end

def print_card_value(card)
  vertical = "\u{2502}"
  block = "\u{2591}"

  if card == nil
    print "#{vertical}#{block}#{block}#{block}#{vertical}"
  else
    cardvalue = card.split(';')[1]
    if cardvalue.length > 1 
      print "#{vertical} #{cardvalue}#{vertical} "
    else
      print "#{vertical}  #{cardvalue}#{vertical} "
    end
  end
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
  puts "(p)lace bet | (r)eturn to menu"
end

def deal_cards
  2.times do
    $player_hand << $cards.shift
    $dealer_hand << $cards.shift
  end
end

def configure
  empty_screen
  show_configuration_menu
  selected_option = gets.chomp

  while selected_option != "b"
    if selected_option == "e"
      empty_screen
      show_configuration_edit_menu
      command = gets.chomp  

      while command != "b"
        action = command.split(' ')[0]
        value = command.split(' ')[1]

        case action
          when "number_of_decks"
            $number_of_decks = value.to_i
          when "dealer_stand_limit"
            $dealer_stand_limit = value.to_i
          when "max_bet"
            $max_bet = value.to_i
        end

        empty_screen
        show_configuration_edit_menu
        command = gets.chomp
      end
    end

    empty_screen
    show_configuration_menu
    selected_option = gets.chomp

  end
  empty_screen
end


def show_configuration_edit_menu
  puts "** CONFIGURATION **"
  show_current_configuration
  puts "to change a value, enter: [VALUE_NAME] [VALUE] (for example: number_of_decks 5)"
  puts "possible values: number_of_decks, dealer_stand_limit, max_bet"
  puts "enter b to go back to the main menu"
end

def show_configuration_menu
  puts "** CONFIGURATION **"
  show_current_configuration
  puts "select an action:"
  puts "(e)dit config | (b)ack to menu"
end

def show_current_configuration
  puts "number of decks: " + $number_of_decks.to_s
  puts "dealer stands on: " + $dealer_stand_limit.to_s
  puts "maximum bet: " + $max_bet.to_s
  puts
end

def empty_screen
  system "clear" unless system "cls"
end

# setup default values
$number_of_decks = 3
$dealer_stand_limit = 17
$max_bet = 500
$default_bet = 10
$current_bet = -1
$player_chips_value = 1000

$cards = Array.new
$player_score = 0
$dealer_score = 0
$player_hand = Array.new
$dealer_hand = Array.new

empty_screen
show_intro
show_options
$selected_option = gets.chomp
empty_screen

while $selected_option != "q"
  case $selected_option
    when "s"
      start_game
    when "c"
      configure
  end

  show_intro
  show_options
  $selected_option = gets.chomp
end

