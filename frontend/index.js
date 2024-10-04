import { backend } from 'declarations/backend';

const newGameBtn = document.getElementById('new-game');
const hitBtn = document.getElementById('hit');
const standBtn = document.getElementById('stand');
const dealerCards = document.getElementById('dealer-cards');
const playerCards = document.getElementById('player-cards');
const dealerScore = document.getElementById('dealer-score');
const playerScore = document.getElementById('player-score');
const result = document.getElementById('result');

let gameState;

async function updateUI() {
    dealerCards.innerHTML = '';
    playerCards.innerHTML = '';

    gameState.dealerHand.forEach(card => {
        const cardElement = document.createElement('div');
        cardElement.className = 'card';
        cardElement.textContent = `${card.value} of ${card.suit}`;
        dealerCards.appendChild(cardElement);
    });

    gameState.playerHand.forEach(card => {
        const cardElement = document.createElement('div');
        cardElement.className = 'card';
        cardElement.textContent = `${card.value} of ${card.suit}`;
        playerCards.appendChild(cardElement);
    });

    dealerScore.textContent = gameState.dealerScore;
    playerScore.textContent = gameState.playerScore;
    result.textContent = gameState.result;

    hitBtn.disabled = gameState.gameOver;
    standBtn.disabled = gameState.gameOver;
}

newGameBtn.addEventListener('click', async () => {
    gameState = await backend.startNewGame();
    updateUI();
});

hitBtn.addEventListener('click', async () => {
    gameState = await backend.playerHit();
    updateUI();
});

standBtn.addEventListener('click', async () => {
    gameState = await backend.playerStand();
    updateUI();
});

// Initialize the game
(async () => {
    gameState = await backend.getGameState();
    updateUI();
})();
