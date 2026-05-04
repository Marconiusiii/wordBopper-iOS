/* audio */
let audioCtx = null;

function getAudioCtx() {
	if (!audioCtx) audioCtx = new (window.AudioContext || window.webkitAudioContext)();
	if (audioCtx.state === 'suspended') audioCtx.resume();
	return audioCtx;
}

// C major climb from C4 so longer words grow smoothly within the home key.
const selectNotes = [261.63, 293.66, 329.63, 349.23, 392.00, 440.00, 493.88, 523.25, 587.33, 659.25, 698.46, 783.99, 880.00, 987.77, 1046.50];
const sparkleNotes = [659.25, 698.46, 783.99, 880.00, 987.77, 1046.50, 1174.66, 1318.51, 1396.91, 1567.98];
const startChordNotes = [261.63, 329.63, 392.00, 523.25, 659.25, 783.99];
const fifthRoots = [523.25, 587.33, 659.25];
const powerUpNotes = [1046.50, 987.77, 880.00, 783.99, 698.46, 659.25, 587.33, 523.25];
let selectNoteIdx = 0;
let powerUpChimeTimer = null;

function resetSelectSound() {
	selectNoteIdx = 0;
}

function playSelectSound() {
	try {
		const ctx = getAudioCtx();
		const t = ctx.currentTime;
		const step = selectNoteIdx;
		const freq = selectNotes[Math.min(step, selectNotes.length - 1)];
		selectNoteIdx++;

		const master = ctx.createGain();
		master.gain.setValueAtTime(0.78, t);
		master.connect(ctx.destination);

		// Rich marimba tone: 3 harmonics with fast attack, warm decay
		[[1, 0.58], [2, 0.2], [3, 0.08]].forEach(([mult, amp]) => {
			const osc = ctx.createOscillator();
			const g = ctx.createGain();
			osc.connect(g); g.connect(master);
			osc.type = 'sine';
			osc.frequency.value = freq * mult;
			g.gain.setValueAtTime(0, t);
			g.gain.linearRampToValueAtTime(amp, t + 0.006);
			g.gain.exponentialRampToValueAtTime(amp * 0.35, t + 0.05);
			g.gain.exponentialRampToValueAtTime(0.001, t + 0.38);
			osc.start(t); osc.stop(t + 0.4);
		});

		if (step >= 3) playSelectSparkle(ctx, t, step);

		// Bright attack click for definition
		const bufLen = Math.floor(ctx.sampleRate * 0.01);
		const buf = ctx.createBuffer(1, bufLen, ctx.sampleRate);
		const d = buf.getChannelData(0);
		for (let i = 0; i < bufLen; i++) d[i] = (Math.random() * 2 - 1) * (1 - i / bufLen);
		const click = ctx.createBufferSource();
		const clickGain = ctx.createGain();
		const hpf = ctx.createBiquadFilter();
		hpf.type = 'highpass'; hpf.frequency.value = 5000;
		click.buffer = buf;
		click.connect(hpf); hpf.connect(clickGain); clickGain.connect(master);
		clickGain.gain.setValueAtTime(0.35, t);
		clickGain.gain.exponentialRampToValueAtTime(0.001, t + 0.01);
		click.start(t); click.stop(t + 0.012);
	} catch(e) {}
}

function playSelectSparkle(ctx, t, step) {
	const sparkleCount = Math.min(4, Math.max(3, step - 1));
	const sparkleGain = Math.min(0.105, 0.035 + (step - 3) * 0.01);
	const rootIndex = Math.min(step - 3, sparkleNotes.length - 4);
	let phrase = sparkleNotes.slice(rootIndex, rootIndex + sparkleCount);

	if (step >= 7) {
		phrase = randomizeSparklePhrase(phrase);
	}

	phrase[phrase.length - 1] = sparkleNotes[Math.min(rootIndex + sparkleCount, sparkleNotes.length - 1)];

	phrase.forEach((freq, i) => {
		const osc = ctx.createOscillator();
		const g = ctx.createGain();
		const filter = ctx.createBiquadFilter();
		const delay = 0.055 + i * 0.06;
		filter.type = 'lowpass';
		filter.frequency.value = 2400;
		osc.connect(filter);
		filter.connect(g);
		g.connect(ctx.destination);
		osc.type = 'sine';
		osc.frequency.value = freq;
		g.gain.setValueAtTime(0, t + delay);
		g.gain.linearRampToValueAtTime(sparkleGain, t + delay + 0.018);
		g.gain.exponentialRampToValueAtTime(0.001, t + delay + 0.36);
		osc.start(t + delay);
		osc.stop(t + delay + 0.38);
	});
}

function randomizeSparklePhrase(notes) {
	const middle = notes.slice(0, -1);
	for (let i = middle.length - 1; i > 0; i--) {
		const j = Math.floor(Math.random() * (i + 1));
		[middle[i], middle[j]] = [middle[j], middle[i]];
	}
	return [...middle, notes[notes.length - 1]];
}

function playRoundStartSound() {
	try {
		const ctx = getAudioCtx();
		const t = ctx.currentTime;
		const shapes = [
			[0, 1, 2, 3],
			[2, 1, 3, 0],
			[1, 3, 2, 4],
			[3, 2, 4, 5],
			[4, 2, 3, 1],
		];
		const shape = shapes[Math.floor(Math.random() * shapes.length)];
		const notes = shape.map(index => startChordNotes[index]);
		const master = ctx.createGain();
		master.gain.setValueAtTime(0.8, t);
		master.connect(ctx.destination);

		notes.forEach((freq, i) => {
			const nd = t + i * 0.07;
			[[1, 0.34, 'sine'], [2, 0.09, 'triangle']].forEach(([mult, amp, type]) => {
				const osc = ctx.createOscillator();
				const g = ctx.createGain();
				osc.connect(g); g.connect(master);
				osc.type = type;
				osc.frequency.value = freq * mult;
				g.gain.setValueAtTime(0, nd);
				g.gain.linearRampToValueAtTime(amp, nd + 0.012);
				g.gain.exponentialRampToValueAtTime(0.001, nd + 0.46);
				osc.start(nd);
				osc.stop(nd + 0.5);
			});
		});
	} catch(e) {}
}

function playRoundEndSound() {
	try {
		const ctx = getAudioCtx();
		const t = ctx.currentTime;
		const notes = [392.00, 523.25, 659.25, 783.99, 1046.50];
		const master = ctx.createGain();
		master.gain.setValueAtTime(0.88, t);
		master.connect(ctx.destination);

		notes.forEach((freq, i) => {
			const nd = t + i * 0.085;
			[[1, 0.34, 'sine'], [2, 0.1, 'triangle'], [0.5, 0.12, 'sine']].forEach(([mult, amp, type]) => {
				const osc = ctx.createOscillator();
				const g = ctx.createGain();
				osc.connect(g); g.connect(master);
				osc.type = type;
				osc.frequency.value = freq * mult;
				g.gain.setValueAtTime(0, nd);
				g.gain.linearRampToValueAtTime(amp, nd + 0.01);
				g.gain.exponentialRampToValueAtTime(0.001, nd + 0.7);
				osc.start(nd);
				osc.stop(nd + 0.75);
			});
		});
	} catch(e) {}
}

// Rising Cmaj7 arpeggio — more notes & bigger sound for longer words
function playWordSound(wordLen) {
	try {
		const ctx = getAudioCtx();
		const t = ctx.currentTime;
		wordLen = wordLen || 3;

		// Base chord: Cmaj7 = C E G B C (5 notes)
		// For longer words, add extra upper octave notes and increase volume
		const baseNotes = [261.63, 329.63, 392.00, 493.88, 523.25, 659.25, 783.99];
		// Short word (3): 3 notes; medium (5+): 5 notes; long (7+): all 7
		const noteCount = wordLen >= 7 ? 7 : wordLen >= 5 ? 5 : 3;
		const notes = baseNotes.slice(0, noteCount);
		const masterVol = wordLen >= 7 ? 1.0 : wordLen >= 5 ? 0.82 : 0.65;
		const spacing = wordLen >= 7 ? 0.055 : wordLen >= 5 ? 0.065 : 0.075;

		notes.forEach((freq, i) => {
			const nd = t + i * spacing;
			// Warm bell: sine fundamental + triangle shimmer octave up
			[[1, 0.38, 'sine'], [2, 0.12, 'triangle'], [0.5, 0.18, 'sine']].forEach(([mult, amp, type]) => {
				const osc = ctx.createOscillator();
				const g = ctx.createGain();
				osc.connect(g); g.connect(ctx.destination);
				osc.type = type;
				osc.frequency.value = freq * mult;
				const scaledAmp = amp * masterVol;
				g.gain.setValueAtTime(0, nd);
				g.gain.linearRampToValueAtTime(scaledAmp, nd + 0.012);
				g.gain.exponentialRampToValueAtTime(scaledAmp * 0.45, nd + 0.1);
				g.gain.exponentialRampToValueAtTime(0.001, nd + 0.85);
				osc.start(nd); osc.stop(nd + 0.9);
			});
		});

		// Punchy sub thump — scales with word length
		const subFreq = wordLen >= 5 ? 130 : 110;
		const subVol = wordLen >= 7 ? 0.55 : wordLen >= 5 ? 0.42 : 0.3;
		const sub = ctx.createOscillator();
		const subG = ctx.createGain();
		sub.connect(subG); subG.connect(ctx.destination);
		sub.type = 'sine';
		sub.frequency.setValueAtTime(subFreq, t);
		sub.frequency.exponentialRampToValueAtTime(subFreq / 2, t + 0.15);
		subG.gain.setValueAtTime(subVol, t);
		subG.gain.exponentialRampToValueAtTime(0.001, t + 0.22);
		sub.start(t); sub.stop(t + 0.25);

		// Sparkle noise burst on top for long words
		if (wordLen >= 5) {
			const sparkLen = Math.floor(ctx.sampleRate * 0.04);
			const sparkBuf = ctx.createBuffer(1, sparkLen, ctx.sampleRate);
			const sd = sparkBuf.getChannelData(0);
			for (let i = 0; i < sparkLen; i++) sd[i] = (Math.random() * 2 - 1) * (1 - i / sparkLen);
			const spark = ctx.createBufferSource();
			const sparkFilter = ctx.createBiquadFilter();
			const sparkGain = ctx.createGain();
			sparkFilter.type = 'bandpass'; sparkFilter.frequency.value = 6000; sparkFilter.Q.value = 0.5;
			spark.buffer = sparkBuf;
			spark.connect(sparkFilter); sparkFilter.connect(sparkGain); sparkGain.connect(ctx.destination);
			sparkGain.gain.setValueAtTime(wordLen >= 7 ? 0.4 : 0.22, t);
			sparkGain.gain.exponentialRampToValueAtTime(0.001, t + 0.04);
			spark.start(t); spark.stop(t + 0.045);
		}
	} catch(e) {}
}

// Descending thud for invalid word — punchy and clear
function playInvalidSound() {
	try {
		const ctx = getAudioCtx();
		const t = ctx.currentTime;
		const master = ctx.createGain();
		master.gain.setValueAtTime(0.8, t);
		master.gain.exponentialRampToValueAtTime(0.001, t + 0.28);
		master.connect(ctx.destination);

		// Thuddy detuned saw — drops fast
		const osc = ctx.createOscillator();
		const oscGain = ctx.createGain();
		osc.connect(oscGain); oscGain.connect(master);
		osc.type = 'sawtooth';
		osc.frequency.setValueAtTime(280, t);
		osc.frequency.exponentialRampToValueAtTime(80, t + 0.22);
		oscGain.gain.setValueAtTime(0.5, t);
		oscGain.gain.exponentialRampToValueAtTime(0.001, t + 0.25);
		osc.start(t); osc.stop(t + 0.28);

		// Noise thump
		const bufSize = Math.floor(ctx.sampleRate * 0.06);
		const buf = ctx.createBuffer(1, bufSize, ctx.sampleRate);
		const data = buf.getChannelData(0);
		for (let i = 0; i < bufSize; i++) data[i] = Math.random() * 2 - 1;
		const noise = ctx.createBufferSource();
		const noiseFilter = ctx.createBiquadFilter();
		const noiseGain = ctx.createGain();
		noiseFilter.type = 'lowpass'; noiseFilter.frequency.value = 600;
		noise.buffer = buf;
		noise.connect(noiseFilter); noiseFilter.connect(noiseGain); noiseGain.connect(master);
		noiseGain.gain.setValueAtTime(0.7, t);
		noiseGain.gain.exponentialRampToValueAtTime(0.001, t + 0.06);
		noise.start(t); noise.stop(t + 0.07);
	} catch(e) {}
}

// Short bright two-note chime for bonus time
function playBonusSound() {
	try {
		const ctx = getAudioCtx();
		const t = ctx.currentTime;
		// Perfect fourth: G5 then C6
		[{ freq: 784.0, delay: 0 }, { freq: 1046.5, delay: 0.14 }].forEach(({ freq, delay }) => {
			const nd = t + delay;
			const osc = ctx.createOscillator();
			const g = ctx.createGain();
			osc.connect(g); g.connect(ctx.destination);
			osc.type = 'sine';
			osc.frequency.value = freq;
			g.gain.setValueAtTime(0, nd);
			g.gain.linearRampToValueAtTime(0.42, nd + 0.01);
			g.gain.exponentialRampToValueAtTime(0.001, nd + 0.28);
			osc.start(nd); osc.stop(nd + 0.3);
			// Shimmer overtone
			const osc2 = ctx.createOscillator();
			const g2 = ctx.createGain();
			osc2.connect(g2); g2.connect(ctx.destination);
			osc2.type = 'triangle';
			osc2.frequency.value = freq * 2;
			g2.gain.setValueAtTime(0.12, nd);
			g2.gain.exponentialRampToValueAtTime(0.001, nd + 0.2);
			osc2.start(nd); osc2.stop(nd + 0.22);
		});
	} catch(e) {}
}

function playConnectedWordSound(wordLen) {
	try {
		const ctx = getAudioCtx();
		const t = ctx.currentTime;
		const noteCount = wordLen >= 7 ? 8 : wordLen >= 5 ? 6 : 4;
		const shimmerVol = wordLen >= 7 ? 0.26 : wordLen >= 5 ? 0.2 : 0.14;
		const notes = [1046.5, 1318.51, 1567.98, 2093.0, 2637.02, 3135.96, 4186.01, 5274.04];

		notes.slice(0, noteCount).forEach((freq, i) => {
			const nd = t + i * 0.045;
			const osc = ctx.createOscillator();
			const gain = ctx.createGain();
			const filter = ctx.createBiquadFilter();
			filter.type = 'bandpass';
			filter.frequency.value = freq;
			filter.Q.value = 8;
			osc.type = i % 2 === 0 ? 'sine' : 'triangle';
			osc.frequency.value = freq;
			osc.connect(filter);
			filter.connect(gain);
			gain.connect(ctx.destination);
			gain.gain.setValueAtTime(0, nd);
			gain.gain.linearRampToValueAtTime(shimmerVol, nd + 0.01);
			gain.gain.exponentialRampToValueAtTime(0.001, nd + 0.5);
			osc.start(nd);
			osc.stop(nd + 0.55);
		});
	} catch(e) {}
}

function playChainStreakSound(streak) {
	try {
		const ctx = getAudioCtx();
		const t = ctx.currentTime;
		const root = fifthRoots[Math.min(streak - 1, fifthRoots.length - 1)];
		const fifth = root * 1.5;
		const master = ctx.createGain();
		master.gain.setValueAtTime(0.42, t);
		master.connect(ctx.destination);

		[root, fifth].forEach((freq, i) => {
			const osc = ctx.createOscillator();
			const g = ctx.createGain();
			osc.connect(g); g.connect(master);
			osc.type = i === 0 ? 'sine' : 'triangle';
			osc.frequency.value = freq;
			g.gain.setValueAtTime(0, t);
			g.gain.linearRampToValueAtTime(i === 0 ? 0.24 : 0.18, t + 0.012);
			g.gain.exponentialRampToValueAtTime(0.001, t + 0.42);
			osc.start(t);
			osc.stop(t + 0.45);
		});
	} catch(e) {}
}

function startPowerUpChimes(duration = 15) {
	stopPowerUpChimes();
	try {
		const ctx = getAudioCtx();
		const startedAt = ctx.currentTime;
		powerUpChimeTimer = setInterval(() => {
			const elapsed = ctx.currentTime - startedAt;
			if (elapsed >= duration) {
				stopPowerUpChimes();
				return;
			}
			playPowerUpChime(ctx, elapsed / duration);
		}, 1200);
		playPowerUpChime(ctx, 0);
	} catch(e) {}
}

function stopPowerUpChimes() {
	clearInterval(powerUpChimeTimer);
	powerUpChimeTimer = null;
}

function playPowerUpChime(ctx, progress) {
	const t = ctx.currentTime;
	const startIndex = Math.min(Math.floor(progress * 4), powerUpNotes.length - 3);
	const phrase = randomDownwardPowerUpPhrase(startIndex);
	const level = Math.max(0.018, 0.05 * (1 - progress));

	phrase.forEach((freq, i) => {
		const osc = ctx.createOscillator();
		const gain = ctx.createGain();
		const filter = ctx.createBiquadFilter();
		const delay = i * 0.08 + Math.random() * 0.035;
		filter.type = 'lowpass';
		filter.frequency.value = 2600;
		osc.type = 'sine';
		osc.frequency.value = freq;
		osc.connect(filter);
		filter.connect(gain);
		gain.connect(ctx.destination);
		gain.gain.setValueAtTime(0, t + delay);
		gain.gain.linearRampToValueAtTime(level, t + delay + 0.02);
		gain.gain.exponentialRampToValueAtTime(0.001, t + delay + 0.55);
		osc.start(t + delay);
		osc.stop(t + delay + 0.6);
	});
}

function randomDownwardPowerUpPhrase(startIndex) {
	const phrase = [];
	let index = startIndex + Math.floor(Math.random() * 2);
	for (let i = 0; i < 3; i++) {
		phrase.push(powerUpNotes[Math.min(index, powerUpNotes.length - 1)]);
		index += 1 + Math.floor(Math.random() * 2);
	}
	return phrase;
}

// Countdown tick — pitch rises as time runs out (10 = low, 1 = high)
function playTickSound(secondsLeft) {
	try {
		const ctx = getAudioCtx();
		const t = ctx.currentTime;
		// Map 10..1 to 600..1200 Hz — gets more urgent
		const freq = 600 + (10 - secondsLeft) * 66;
		const osc = ctx.createOscillator();
		const g = ctx.createGain();
		osc.connect(g); g.connect(ctx.destination);
		osc.type = 'sine';
		osc.frequency.value = freq;
		g.gain.setValueAtTime(0, t);
		g.gain.linearRampToValueAtTime(secondsLeft <= 3 ? 0.55 : 0.38, t + 0.008);
		g.gain.exponentialRampToValueAtTime(0.001, t + 0.12);
		osc.start(t); osc.stop(t + 0.14);
		// Second harmonic for brightness on final 3
		if (secondsLeft <= 3) {
			const osc2 = ctx.createOscillator();
			const g2 = ctx.createGain();
			osc2.connect(g2); g2.connect(ctx.destination);
			osc2.type = 'sine';
			osc2.frequency.value = freq * 2;
			g2.gain.setValueAtTime(0.18, t);
			g2.gain.exponentialRampToValueAtTime(0.001, t + 0.1);
			osc2.start(t); osc2.stop(t + 0.12);
		}
	} catch(e) {}
}


window.WordBopAudio = {
	playSelectSound,
	resetSelectSound,
	playWordSound,
	playInvalidSound,
	playBonusSound,
	playConnectedWordSound,
	playChainStreakSound,
	startPowerUpChimes,
	stopPowerUpChimes,
	playRoundStartSound,
	playRoundEndSound,
	playTickSound,
};
