import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export interface Card { 'value' : string, 'suit' : string }
export interface GameState {
  'result' : string,
  'deck' : Array<Card>,
  'dealerScore' : bigint,
  'playerScore' : bigint,
  'playerHand' : Array<Card>,
  'gameOver' : boolean,
  'dealerHand' : Array<Card>,
}
export interface _SERVICE {
  'getGameState' : ActorMethod<[], GameState>,
  'playerHit' : ActorMethod<[], GameState>,
  'playerStand' : ActorMethod<[], GameState>,
  'startNewGame' : ActorMethod<[], GameState>,
}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
