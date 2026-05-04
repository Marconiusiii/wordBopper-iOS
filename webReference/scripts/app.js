(function() {
	'use strict';

	const { gameDuration, totalBubbles, letterPool, colors } = window.WordBopConfig;
	const { playSelectSound, resetSelectSound, playWordSound, playInvalidSound, playBonusSound, playConnectedWordSound, playChainStreakSound, startPowerUpChimes, stopPowerUpChimes, playRoundStartSound, playRoundEndSound, playTickSound } = window.WordBopAudio;
	const bestGameStorageKey = 'wordBopBestGame';
	const defaultBestGame = {
		highestScore: 0,
		longestWord: '',
		mostWords: 0,
		largestLetterChain: 0,
	};

	/* state */
	let bubbles = [];          // [{id, letter, color, el, row, col}]
	let selected = [];         // [{id, letter, row, col}]
	let score = 0;
	let wordCount = 0;
	let totalLettersUsed = 0;
	let madeWords = [];
	let timerInterval = null;
	let secondsLeft = gameDuration;
	let gameActive = false;
	let nextId = 0;
	let announcerTimer = null;
	let roundEndTimer = null;
	let connectedWordStreak = 0;
	let chainPowerUpActive = false;
	let chainPowerUpTimer = null;
	let chainMeterTimer = null;
	let chainPowerUpEndsAt = 0;
	let largestLetterChain = 0;
	let bestGame = loadBestGame();

	/* elements */
	const screens = {
		start: document.getElementById('start-screen'),
		game:  document.getElementById('game-screen'),
		result: document.getElementById('result-screen'),
	};
	const timerDisplay  = document.getElementById('timer-display');
	const scoreDisplay  = document.getElementById('score-display');
	const wordsDisplay  = document.getElementById('words-display');
	const bestHighScore = document.getElementById('best-high-score');
	const bestLongestWord = document.getElementById('best-longest-word');
	const bestMostWords = document.getElementById('best-most-words');
	const bestLargestChain = document.getElementById('best-largest-chain');
	const chainMeterWrap = document.getElementById('chain-meter-wrap');
	const chainMeter    = document.getElementById('chain-meter');
	const chainMeterText = document.getElementById('chain-meter-text');
	const wordTrayWrap  = document.getElementById('word-tray-wrap');
	const wordTray      = document.getElementById('word-tray');
	const bubbleField   = document.getElementById('bubble-field');
	const btnMakeWord   = document.getElementById('btn-make-word');
	const btnClear      = document.getElementById('btn-clear');
	const btnEndGame    = document.getElementById('btn-end-game');
	const toast         = document.getElementById('toast');
	const gameAnnouncer = document.getElementById('game-announcer');
	const footer        = document.getElementById('footer');
	const copyrightYear = document.getElementById('copyrightYear');
	const roundCompleteHeading = document.getElementById('roundCompleteHeading');
	const gameTitleHeading = document.getElementById('gameTitleHeading');
	const gameplayHeading = document.getElementById('gameplayHeading');
	const gameplayHeadingPhrases = [
		'Start bopping!',
		'Bop to it!',
		'Bop out some words!',
		'Bop those letters!',
		'Bop to the future!',
		'Start your bopping!',
		'Commence bopping!',
	];
	const screenTitles = {
		start: 'Home - WordBop',
		game: 'Playing - WordBop',
		result: 'Results - WordBop',
	};

	/* screen management */
	function showScreen(name) {
		Object.entries(screens).forEach(([k, el]) => {
			const isActive = k === name;
			el.classList.toggle('active', isActive);
			el.hidden = !isActive;
			el.inert = !isActive;
		});
		const isHome = name === 'start';
		footer.hidden = !isHome;
		footer.inert = !isHome;
		document.title = screenTitles[name] || 'WordBop';
	}

	/* letter / bubble helpers */
	function randomLetter() {
		return letterPool[Math.floor(Math.random() * letterPool.length)];
	}

	function randomColor() {
		return colors[Math.floor(Math.random() * colors.length)];
	}

	function createBubbleEl(id, letter, color, delay = 0) {
		const btn = document.createElement('button');
		btn.className = 'bubble';
		btn.dataset.id = id;
		btn.dataset.color = color;
		btn.dataset.letter = letter;
		btn.textContent = letter;
		setBubbleName(btn, letter, false);
		btn.style.animationDelay = `${delay}ms`;
		btn.addEventListener('click', () => onBubbleTap(id));
		btn.addEventListener('keydown', e => {
			if (e.key === 'Enter' || e.key === ' ') {
				e.preventDefault();
				onBubbleTap(id);
			}
		});
		return btn;
	}

	function setBubbleName(el, letter, isSelected) {
		el.setAttribute('aria-label', isSelected ? `${letter}, selected` : letter);
	}

	function spawnBubble(delay = 0) {
		const index = bubbles.length;
		const id = nextId++;
		const letter = randomLetter();
		const color  = randomColor();
		const el = createBubbleEl(id, letter, color, delay);
		const cell = getBubbleCell(index);
		cell.appendChild(el);
		const obj = {
			id,
			letter,
			color,
			el,
			row: Math.floor(index / 5),
			col: index % 5,
		};
		bubbles.push(obj);
		return obj;
	}

	function getBubbleCell(index) {
		const rowIndex = Math.floor(index / 5);
		let row = bubbleField.rows[rowIndex];
		if (!row) {
			row = document.createElement('tr');
			bubbleField.appendChild(row);
		}

		const cell = document.createElement('td');
		row.appendChild(cell);
		return cell;
	}

	function replaceBubble(id) {
		const idx = bubbles.findIndex(b => b.id === id);
		if (idx === -1) return;
		const old = bubbles[idx];

		// Pop animation, then replace
		old.el.classList.add('popping');
		old.el.addEventListener('animationend', () => {
			const newId = nextId++;
			const letter = randomLetter();
			const color  = randomColor();
			const newEl = createBubbleEl(newId, letter, color, 0);
			old.el.parentElement.replaceChild(newEl, old.el);
			bubbles[idx] = { id: newId, letter, color, el: newEl, row: old.row, col: old.col };
		}, { once: true });
	}

	/* word tray */
	function updateWordTray() {
		wordTray.innerHTML = '';
		if (selected.length === 0) {
			const emptyText = document.createElement('span');
			emptyText.id = 'word-tray-empty';
			emptyText.textContent = 'Your word appears here as you bop letters.';
			wordTray.appendChild(emptyText);
			btnMakeWord.disabled = true;
			return;
		}
		selected.forEach(s => {
			const div = document.createElement('div');
			div.className = 'tray-letter';
			div.textContent = s.letter;
			wordTray.appendChild(div);
		});
		btnMakeWord.disabled = selected.length < 3;
	}

	/* bubble tap */
	function onBubbleTap(id) {
		if (!gameActive) return;
		const bub = bubbles.find(b => b.id === id);
		if (!bub) return;

		if (selected.some(s => s.id === id)) {
			deselectBubble(id);
			return;
		}

		selectBubble(bub);
	}

	function selectBubble(bub) {
		if (selected.length === 0) resetSelectSound();
		bub.el.classList.add('selected');
		setBubbleName(bub.el, bub.letter, true);
		selected.push({ id: bub.id, letter: bub.letter, row: bub.row, col: bub.col });
		updateWordTray();
		playSelectSound();

		// Haptic
		if (navigator.vibrate) navigator.vibrate(18);
	}

	function deselectBubble(id) {
		const selectedIndex = selected.findIndex(s => s.id === id);
		if (selectedIndex === -1) return;

		const bub = bubbles.find(b => b.id === id);
		if (bub) {
			bub.el.classList.remove('selected');
			setBubbleName(bub.el, bub.letter, false);
		}

		selected.splice(selectedIndex, 1);
		updateWordTray();
		if (selected.length === 0) resetSelectSound();
	}

	/* clear */
	function clearSelection(options = {}) {
		const hadLetters = selected.length > 0;
		selected.forEach(s => {
			const bub = bubbles.find(b => b.id === s.id);
			if (bub) {
				bub.el.classList.remove('selected');
				setBubbleName(bub.el, bub.letter, false);
			}
		});
		selected = [];
		updateWordTray();
		resetSelectSound();
		if (hadLetters && gameActive && options.addRetryBonus !== false) {
			// Reward the retry — add 15 seconds
			secondsLeft = Math.min(secondsLeft + 15, gameDuration);
			timerDisplay.textContent = formatTime(secondsLeft);
			if (secondsLeft > 20) timerDisplay.classList.remove('warning');
			playBonusSound();
			showBonusBadge();
			if (options.announce !== false) announce('Try again! 15 bonus seconds added.');
		} else if (options.announce !== false) {
			announce('Selection cleared.');
		}
	}

	/* dictionary */
	function isValidWord(word) {
		return WordBopDictionary.has(word.toLowerCase());
	}

	/* make word */
	function makeWord() {
		if (!gameActive || selected.length < 3) return;

		const word = selected.map(s => s.letter).join('').toLowerCase();

		if (!isValidWord(word)) {
			showToast(`${word} - not a word`);
			announce(`${word} is not a valid word. Try again.`);
			playInvalidSound();
			resetChainStreak();
			clearSelection({ addRetryBonus: false, announce: false });
			return;
		}

		const chainBonus = calcChainBonus(selected);
		const basePts = calcScore(word) + chainBonus;
		const multiplier = chainPowerUpActive ? 3 : 1;
		const pts = basePts * multiplier;

		// Replace each tapped bubble
		const ids = selected.map(s => s.id);
		selected = [];
		updateWordTray();
		resetSelectSound();

		ids.forEach(id => replaceBubble(id));

		// Update stats
		score += pts;
		wordCount++;
		totalLettersUsed += word.length;
		madeWords.push(word);
		scoreDisplay.textContent = score;
		wordsDisplay.textContent = wordCount;
		if (chainBonus > largestLetterChain) largestLetterChain = chainBonus;

		showToast(formatWordToast(word, pts, chainBonus, multiplier));
		playWordSound(word.length);
		if (chainPowerUpActive) clearChainPowerUp();
		const powerUpActivated = updateChainStreak(chainBonus);
		announce(formatWordAnnouncement(word, pts, chainBonus, multiplier, powerUpActivated));

		if (navigator.vibrate) navigator.vibrate([30, 20, 60]);
	}

	function formatWordToast(word, pts, chainBonus, multiplier) {
		if (multiplier > 1) return `${word} +${pts}, 3x chain bop`;
		if (chainBonus > 0) return `${word} +${pts}, chain bonus +${chainBonus}`;
		return `${word} +${pts}`;
	}

	function formatWordAnnouncement(word, pts, chainBonus, multiplier, powerUpActivated) {
		let message = `${word} scored ${pts} points. Total: ${score}.`;
		if (multiplier > 1) message = `${word} scored ${pts} points with a 3 times chain bop. Total: ${score}.`;
		else if (chainBonus > 0) message = `${word} scored ${pts} points with a ${chainBonus} point chain bonus. Total: ${score}.`;
		if (powerUpActivated) message += ' 3 times chain bop ready. Make the next word in 15 seconds.';
		return message;
	}

	function calcScore(word) {
		// Base: 1 pt per letter, bonus for longer words
		let pts = word.length;
		if (word.length >= 5) pts += word.length;
		if (word.length >= 7) pts += word.length * 2;
		return pts;
	}

	function calcChainBonus(wordSelection) {
		if (wordSelection.length < 3) return 0;
		const connected = wordSelection.every((letter, index) => {
			if (index === 0) return true;
			return areTouching(wordSelection[index - 1], letter);
		});
		return connected ? wordSelection.length : 0;
	}

	function areTouching(first, second) {
		const rowDistance = Math.abs(first.row - second.row);
		const colDistance = Math.abs(first.col - second.col);
		return rowDistance <= 1 && colDistance <= 1 && rowDistance + colDistance > 0;
	}

	function updateChainStreak(chainBonus) {
		if (chainBonus === 0) {
			resetChainStreak();
			return false;
		}

		connectedWordStreak++;
		playConnectedWordSound(chainBonus);
		playChainStreakSound(connectedWordStreak);

		if (connectedWordStreak >= 3) {
			activateChainPowerUp();
			return true;
		}

		updateChainMeter(connectedWordStreak, `${connectedWordStreak}/3`, `${connectedWordStreak} of 3`);
		return false;
	}

	function resetChainStreak() {
		if (chainPowerUpActive) return;
		connectedWordStreak = 0;
		updateChainMeter(0, '0/3', '0 of 3');
	}

	function activateChainPowerUp() {
		connectedWordStreak = 0;
		chainPowerUpActive = true;
		chainPowerUpEndsAt = Date.now() + 15000;
		clearTimeout(chainPowerUpTimer);
		clearInterval(chainMeterTimer);
		startPowerUpChimes(15);
		chainMeterWrap.classList.add('powered');
		updatePowerUpMeter();
		chainPowerUpTimer = setTimeout(clearChainPowerUp, 15000);
		chainMeterTimer = setInterval(updatePowerUpMeter, 100);
	}

	function clearChainPowerUp() {
		chainPowerUpActive = false;
		chainPowerUpEndsAt = 0;
		clearTimeout(chainPowerUpTimer);
		clearInterval(chainMeterTimer);
		stopPowerUpChimes();
		chainMeterWrap.classList.remove('powered');
		updateChainMeter(0, '0/3', '0 of 3');
	}

	function updatePowerUpMeter() {
		const remaining = Math.max(0, chainPowerUpEndsAt - Date.now());
		const seconds = Math.ceil(remaining / 1000);
		const meterValue = (remaining / 15000) * 3;
		updateChainMeter(meterValue, `3x ${seconds}s`, `3 times chain bop active, ${seconds} seconds left`);
	}

	function updateChainMeter(value, text, valueText) {
		chainMeter.value = value;
		chainMeterText.textContent = text;
		chainMeter.setAttribute('aria-valuetext', valueText);
	}

	function loadBestGame() {
		try {
			const saved = JSON.parse(localStorage.getItem(bestGameStorageKey));
			return { ...defaultBestGame, ...saved };
		} catch(e) {
			return { ...defaultBestGame };
		}
	}

	function saveBestGame() {
		localStorage.setItem(bestGameStorageKey, JSON.stringify(bestGame));
	}

	function updateBestGameFromRound() {
		const longestWord = getLongestRoundWord();
		let changed = false;

		if (score > bestGame.highestScore) {
			bestGame.highestScore = score;
			changed = true;
		}
		if (longestWord.length > bestGame.longestWord.length) {
			bestGame.longestWord = longestWord;
			changed = true;
		}
		if (wordCount > bestGame.mostWords) {
			bestGame.mostWords = wordCount;
			changed = true;
		}
		if (largestLetterChain > bestGame.largestLetterChain) {
			bestGame.largestLetterChain = largestLetterChain;
			changed = true;
		}

		if (changed) saveBestGame();
		renderBestGame();
	}

	function getLongestRoundWord() {
		return madeWords.reduce((longest, word) => word.length > longest.length ? word : longest, '');
	}

	function renderBestGame() {
		bestHighScore.textContent = bestGame.highestScore;
		bestLongestWord.textContent = bestGame.longestWord || 'None yet';
		bestMostWords.textContent = bestGame.mostWords;
		bestLargestChain.textContent = bestGame.largestLetterChain;
	}

	/* toast */
	let toastTimer = null;
	function showToast(msg) {
		toast.textContent = msg;
		toast.classList.add('show');
		clearTimeout(toastTimer);
		toastTimer = setTimeout(() => {
			toast.classList.remove('show');
			toast.textContent = '';
		}, 1400);
	}

	/* bonus badge */
	const bonusBadge = document.getElementById('bonus-badge');
	let bonusTimer = null;
	function showBonusBadge() {
		bonusBadge.textContent = '+15s — try again!';
		bonusBadge.classList.remove('show');
		void bonusBadge.offsetWidth; // force reflow
		bonusBadge.classList.add('show');
		clearTimeout(bonusTimer);
		bonusTimer = setTimeout(() => {
			bonusBadge.classList.remove('show');
			bonusBadge.textContent = '';
		}, 3000);
	}

	/* aria announce */
	function announce(msg) {
		gameAnnouncer.textContent = '';
		clearTimeout(announcerTimer);
		requestAnimationFrame(() => {
			gameAnnouncer.textContent = msg;
			announcerTimer = setTimeout(() => {
				gameAnnouncer.textContent = '';
			}, 3000);
		});
	}

	/* timer */
	function formatTime(s) {
		const m = Math.floor(s / 60);
		const sec = s % 60;
		return `${m}:${sec.toString().padStart(2,'0')}`;
	}

	function startTimer() {
		secondsLeft = gameDuration;
		timerDisplay.textContent = formatTime(secondsLeft);
		timerDisplay.classList.remove('warning');
		timerInterval = setInterval(() => {
			secondsLeft--;
			timerDisplay.textContent = formatTime(secondsLeft);
			if (secondsLeft <= 20) timerDisplay.classList.add('warning');
			if (secondsLeft <= 10 && secondsLeft > 0) {
				playTickSound(secondsLeft);
			}
			if (secondsLeft <= 0) endGame();
		}, 1000);
	}

	function stopTimer() {
		clearInterval(timerInterval);
		timerInterval = null;
	}

	/* game lifecycle */
	function startGame() {
		// Reset state
		bubbles = [];
		selected = [];
		score = 0;
		wordCount = 0;
		totalLettersUsed = 0;
		madeWords = [];
		nextId = 0;
		gameActive = true;
		largestLetterChain = 0;
		resetSelectSound();
		clearTimeout(roundEndTimer);
		clearChainPowerUp();
		connectedWordStreak = 0;
		updateChainMeter(0, '0/3', '0 of 3');

		scoreDisplay.textContent = '0';
		wordsDisplay.textContent = '0';
		timerDisplay.classList.remove('warning');

		// Clear field & spawn bubbles
		bubbleField.innerHTML = '';
		for (let i = 0; i < totalBubbles; i++) {
			spawnBubble(i * 30);
		}

		updateWordTray();
		gameplayHeading.textContent = randomGameplayHeading();
		showScreen('game');
		gameplayHeading.focus();
		playRoundStartSound();
		startTimer();
		announce('Game started. 25 letter bubbles are ready. Tap 3 or more letters to build words.');
	}

	function randomGameplayHeading() {
		return gameplayHeadingPhrases[Math.floor(Math.random() * gameplayHeadingPhrases.length)];
	}

	function endGame() {
		if (!gameActive) return;
		gameActive = false;
		stopTimer();
		clearChainPowerUp();
		playRoundEndSound();

		roundEndTimer = setTimeout(showResults, 850);
	}

	function showResults() {
		updateBestGameFromRound();

		// Populate result
		document.getElementById('final-score').textContent = score;
		document.getElementById('final-word-count').textContent = wordCount;
		document.getElementById('final-letters-used').textContent = totalLettersUsed;
		document.getElementById('final-avg').textContent = wordCount > 0
			? (totalLettersUsed / wordCount).toFixed(1)
			: '—';

		const list = document.getElementById('words-list');
		list.innerHTML = '';
		if (madeWords.length === 0) {
			list.textContent = 'No words made — try again!';
		} else {
			madeWords.forEach(w => {
				const chip = document.createElement('li');
				chip.className = 'word-chip';
				chip.textContent = w;
				list.appendChild(chip);
			});
		}

		showScreen('result');
		roundCompleteHeading.focus();
		announce(`Game over! You scored ${score} points with ${wordCount} words and ${totalLettersUsed} letters used.`);
	}

	/* event listeners */
	document.getElementById('btn-start').addEventListener('click', startGame);
	document.getElementById('btn-play-again').addEventListener('click', startGame);
	document.getElementById('btn-back-home').addEventListener('click', () => {
		renderBestGame();
		showScreen('start');
		gameTitleHeading.focus();
	});

	btnClear.addEventListener('click', clearSelection);
	btnMakeWord.addEventListener('click', makeWord);
	btnEndGame.addEventListener('click', endGame);

	// Keyboard shortcut: Enter to make word, Escape to clear
	document.addEventListener('keydown', e => {
		if (!gameActive) return;
		if (e.key === 'Enter' && !btnMakeWord.disabled) makeWord();
		if (e.key === 'Escape') clearSelection();
	});

	copyrightYear.textContent = new Date().getFullYear();
	renderBestGame();
	showScreen('start');
})();
