import Bool "mo:base/Bool";
import Text "mo:base/Text";

import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Option "mo:base/Option";
import Random "mo:base/Random";

actor {
  // Card representation
  type Card = {
    suit: Text;
    value: Text;
  };

  // Game state
  type GameState = {
    playerHand: [Card];
    dealerHand: [Card];
    deck: [Card];
    gameOver: Bool;
    playerScore: Nat;
    dealerScore: Nat;
    result: Text;
  };

  // Initialize game state
  stable var gameState : GameState = {
    playerHand = [];
    dealerHand = [];
    deck = [];
    gameOver = false;
    playerScore = 0;
    dealerScore = 0;
    result = "";
  };

  // Create a new deck
  func createDeck() : [Card] {
    let suits = ["Hearts", "Diamonds", "Clubs", "Spades"];
    let values = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"];
    var deck : [Card] = [];

    for (suit in suits.vals()) {
      for (value in values.vals()) {
        deck := Array.append(deck, [{suit = suit; value = value}]);
      };
    };

    deck
  };

  // Shuffle the deck
  func shuffleDeck(deck: [Card]) : async [Card] {
    var shuffled = Array.thaw<Card>(deck);
    let length = shuffled.size();
    
    for (i in Iter.range(0, length - 1)) {
      let randomBytes = await Random.blob();
      let randomIndex = Nat.abs(Random.rangeFrom(32, randomBytes)) % length;
      let temp = shuffled[i];
      shuffled[i] := shuffled[randomIndex];
      shuffled[randomIndex] := temp;
    };

    Array.freeze(shuffled)
  };

  // Calculate hand value
  func calculateHandValue(hand: [Card]) : Nat {
    var value = 0;
    var aceCount = 0;

    for (card in hand.vals()) {
      switch (card.value) {
        case "A" { aceCount += 1; value += 11; };
        case "K" { value += 10; };
        case "Q" { value += 10; };
        case "J" { value += 10; };
        case v { value += Option.get(Nat.fromText(v), 0); };
      };
    };

    while (value > 21 and aceCount > 0) {
      value -= 10;
      aceCount -= 1;
    };

    value
  };

  // Start a new game
  public func startNewGame() : async GameState {
    var newDeck = createDeck();
    newDeck := await shuffleDeck(newDeck);

    let playerHand = [newDeck[0], newDeck[1]];
    let dealerHand = [newDeck[2]];
    let remainingDeck = Array.tabulate<Card>(newDeck.size() - 3, func (i) { newDeck[i + 3] });

    gameState := {
      playerHand = playerHand;
      dealerHand = dealerHand;
      deck = remainingDeck;
      gameOver = false;
      playerScore = calculateHandValue(playerHand);
      dealerScore = calculateHandValue(dealerHand);
      result = "";
    };

    gameState
  };

  // Player hits
  public func playerHit() : async GameState {
    if (gameState.gameOver) {
      return gameState;
    };

    let newCard = gameState.deck[0];
    let newPlayerHand = Array.append(gameState.playerHand, [newCard]);
    let newDeck = Array.tabulate<Card>(gameState.deck.size() - 1, func (i) { gameState.deck[i + 1] });
    let newPlayerScore = calculateHandValue(newPlayerHand);

    gameState := {
      playerHand = newPlayerHand;
      dealerHand = gameState.dealerHand;
      deck = newDeck;
      gameOver = newPlayerScore > 21;
      playerScore = newPlayerScore;
      dealerScore = gameState.dealerScore;
      result = if (newPlayerScore > 21) "Player busts! Dealer wins!" else "";
    };

    gameState
  };

  // Player stands, dealer plays
  public func playerStand() : async GameState {
    if (gameState.gameOver) {
      return gameState;
    };

    var dealerHand = gameState.dealerHand;
    var deck = gameState.deck;
    var dealerScore = gameState.dealerScore;

    while (dealerScore < 17) {
      let newCard = deck[0];
      dealerHand := Array.append(dealerHand, [newCard]);
      deck := Array.tabulate<Card>(deck.size() - 1, func (i) { deck[i + 1] });
      dealerScore := calculateHandValue(dealerHand);
    };

    let result = if (dealerScore > 21) {
      "Dealer busts! Player wins!"
    } else if (dealerScore > gameState.playerScore) {
      "Dealer wins!"
    } else if (dealerScore < gameState.playerScore) {
      "Player wins!"
    } else {
      "It's a tie!"
    };

    gameState := {
      playerHand = gameState.playerHand;
      dealerHand = dealerHand;
      deck = deck;
      gameOver = true;
      playerScore = gameState.playerScore;
      dealerScore = dealerScore;
      result = result;
    };

    gameState
  };

  // Get current game state
  public query func getGameState() : async GameState {
    gameState
  };
}
