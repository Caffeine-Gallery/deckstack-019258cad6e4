export const idlFactory = ({ IDL }) => {
  const Card = IDL.Record({ 'value' : IDL.Text, 'suit' : IDL.Text });
  const GameState = IDL.Record({
    'result' : IDL.Text,
    'deck' : IDL.Vec(Card),
    'dealerScore' : IDL.Nat,
    'playerScore' : IDL.Nat,
    'playerHand' : IDL.Vec(Card),
    'gameOver' : IDL.Bool,
    'dealerHand' : IDL.Vec(Card),
  });
  return IDL.Service({
    'getGameState' : IDL.Func([], [GameState], ['query']),
    'playerHit' : IDL.Func([], [GameState], []),
    'playerStand' : IDL.Func([], [GameState], []),
    'startNewGame' : IDL.Func([], [GameState], []),
  });
};
export const init = ({ IDL }) => { return []; };
