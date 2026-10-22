#!/usr/bin/env node
// ai-sense: natural language parser that figures out which colorsense/poweronn
// command the user meant, extracts the arguments, and prints a shell command
// ready for bash to eval. Works fully offline — no API calls.

// ── Extended CSS color name → hex table ─────────────────────────────────────
const NAMED_COLORS = {
  aliceblue: "#f0f8ff", antiquewhite: "#faebd7", aqua: "#00ffff", aquamarine: "#7fffd4",
  azure: "#f0ffff", beige: "#f5f5dc", bisque: "#ffe4c4", black: "#000000",
  blanchedalmond: "#ffebcd", blue: "#0000ff", blueviolet: "#8a2be2", brown: "#a52a2a",
  burlywood: "#deb887", cadetblue: "#5f9ea0", chartreuse: "#7fff00", chocolate: "#d2691e",
  coral: "#ff7f50", cornflowerblue: "#6495ed", cornsilk: "#fff8dc", crimson: "#dc143c",
  cyan: "#00ffff", darkblue: "#00008b", darkcyan: "#008b8b", darkgoldenrod: "#b8860b",
  darkgray: "#a9a9a9", darkgreen: "#006400", darkkhaki: "#bdb76b", darkmagenta: "#8b008b",
  darkolivegreen: "#556b2f", darkorange: "#ff8c00", darkorchid: "#9932cc", darkred: "#8b0000",
  darksalmon: "#e9967a", darkseagreen: "#8fbc8f", darkslateblue: "#483d8b", darkslategray: "#2f4f4f",
  darkturquoise: "#00ced1", darkviolet: "#9400d3", deeppink: "#ff1493", deepskyblue: "#00bfff",
  dimgray: "#696969", dodgerblue: "#1e90ff", firebrick: "#b22222", floralwhite: "#fffaf0",
  forestgreen: "#228b22", fuchsia: "#ff00ff", gainsboro: "#dcdcdc", ghostwhite: "#f8f8ff",
  gold: "#ffd700", goldenrod: "#daa520", gray: "#808080", green: "#008000",
  greenyellow: "#adff2f", honeydew: "#f0fff0", hotpink: "#ff69b4", indianred: "#cd5c5c",
  indigo: "#4b0082", ivory: "#fffff0", khaki: "#f0e68c", lavender: "#e6e6fa",
  lavenderblush: "#fff0f5", lawngreen: "#7cfc00", lemonchiffon: "#fffacd", lightblue: "#add8e6",
  lightcoral: "#f08080", lightcyan: "#e0ffff", lightgoldenrodyellow: "#fafad2", lightgray: "#d3d3d3",
  lightgreen: "#90ee90", lightpink: "#ffb6c1", lightsalmon: "#ffa07a", lightseagreen: "#20b2aa",
  lightskyblue: "#87cefa", lightslategray: "#778899", lightsteelblue: "#b0c4de", lightyellow: "#ffffe0",
  lime: "#00ff00", limegreen: "#32cd32", linen: "#faf0e6", magenta: "#ff00ff",
  maroon: "#800000", mediumaquamarine: "#66cdaa", mediumblue: "#0000cd", mediumorchid: "#ba55d3",
  mediumpurple: "#9370db", mediumseagreen: "#3cb371", mediumslateblue: "#7b68ee", mediumspringgreen: "#00fa9a",
  mediumturquoise: "#48d1cc", mediumvioletred: "#c71585", midnightblue: "#191970", mintcream: "#f5fffa",
  mistyrose: "#ffe4e1", moccasin: "#ffe4b5", navajowhite: "#ffdead", navy: "#000080",
  oldlace: "#fdf5e6", olive: "#808000", olivedrab: "#6b8e23", orange: "#ffa500",
  orangered: "#ff4500", orchid: "#da70d6", palegoldenrod: "#eee8aa", palegreen: "#98fb98",
  paleturquoise: "#afeeee", palevioletred: "#db7093", papayawhip: "#ffefd5", peachpuff: "#ffdab9",
  peru: "#cd853f", pink: "#ffc0cb", plum: "#dda0dd", powderblue: "#b0e0e6",
  purple: "#800080", rebeccapurple: "#663399", red: "#ff0000", rosybrown: "#bc8f8f",
  royalblue: "#4169e1", saddlebrown: "#8b4513", salmon: "#fa8072", sandybrown: "#f4a460",
  seagreen: "#2e8b57", seashell: "#fff5ee", sienna: "#a0522d", silver: "#c0c0c0",
  skyblue: "#87ceeb", slateblue: "#6a5acd", slategray: "#708090", snow: "#fffafa",
  springgreen: "#00ff7f", steelblue: "#4682b4", tan: "#d2b48c", teal: "#008080",
  thistle: "#d8bfd8", tomato: "#ff6347", turquoise: "#40e0d0", violet: "#ee82ee",
  wheat: "#f5deb3", white: "#ffffff", whitesmoke: "#f5f5f5", yellow: "#ffff00",
  yellowgreen: "#9acd32",
};

// ── Levenshtein distance for fuzzy color name matching ──────────────────────
function levenshtein(a, b) {
  const m = a.length, n = b.length;
  const dp = Array.from({ length: m + 1 }, (_, i) => [i, ...Array(n).fill(0)]);
  for (let j = 0; j <= n; j++) dp[0][j] = j;
  for (let i = 1; i <= m; i++) {
    for (let j = 1; j <= n; j++) {
      dp[i][j] = a[i - 1] === b[j - 1]
        ? dp[i - 1][j - 1]
        : 1 + Math.min(dp[i - 1][j - 1], dp[i - 1][j], dp[i][j - 1]);
    }
  }
  return dp[m][n];
}

const STOPWORDS = new Set([
  "color", "colour", "detect", "identify", "what", "is", "analyze", "analyze",
  "gradient", "fade", "transition", "blend", "from", "to", "in", "with", "the",
  "a", "an", "of", "check", "for", "if", "absent", "missing", "present",
  "word", "text", "hello", "show", "display", "print", "make", "use", "using",
  "please", "can", "you", "me", "my", "this", "that", "it", "and", "or",
  "not", "do", "does", "did", "was", "were", "are", "be", "been", "being",
]);

function resolveColor(token) {
  if (!token) return null;
  if (/^#[0-9a-fA-F]{6}$/.test(token)) return token;
  const lower = token.toLowerCase().replace(/\s+/g, "");
  if (NAMED_COLORS[lower]) return NAMED_COLORS[lower];
  if (STOPWORDS.has(lower)) return null;
  // fuzzy match — exact for short words, proportional threshold for longer ones
  if (lower.length < 4) return null;
  let best = null, bestDist = Infinity;
  for (const [name, hex] of Object.entries(NAMED_COLORS)) {
    const d = levenshtein(lower, name);
    if (d < bestDist) { bestDist = d; best = hex; }
  }
  const threshold = Math.max(1, Math.floor(lower.length * 0.3));
  if (bestDist <= threshold) return best;
  return null;
}

// ── Intent parser ───────────────────────────────────────────────────────────
function parse(input) {
  const text = input.trim();
  const lower = text.toLowerCase();

  // Detect intent keywords
  const isDetect = /\b(detect|identify|what\s+(?:color|colour)\s+is|analyze)\b/.test(lower);
  const isGradient = /\b(gradient|fade|transition|blend)\b/.test(lower);
  const isAbsence = /\b(absent|missing|not?\s+in|check\s+for)\b/.test(lower);

  // Extract quoted text (the "text" argument for color/gradient/poweronn)
  const quoted = text.match(/"([^"]*)"/);
  const quotedText = quoted ? quoted[1] : null;

  // ── PowerOnn: absent word detection (process before color resolution) ──
  if (isAbsence) {
    const textPart = quotedText || "";
    const wordMatch = text.match(/(?:is|check\s+for|if)\s+"?(\w+)"?\s+(?:absent|missing|in|from|not\s+in)/i);
    const word = wordMatch ? wordMatch[1] : "";
    if (word && textPart) {
      return { cmd: "poweronn", args: [textPart, word] };
    }
  }

  // Collect hex colors and color-name words from the input
  const hexMatches = text.match(/#[0-9a-fA-F]{6}/g) || [];
  const words = text.split(/\s+/);

  // Build a list of candidate color tokens (hex + word-sequences up to 2 words)
  // Track which word indices are consumed as colors so we can strip them later
  const colorTokens = [...hexMatches];
  const consumedWords = new Set();
  for (let i = 0; i < words.length; i++) {
    if (/^#[0-9a-fA-F]{6}$/.test(words[i])) { consumedWords.add(i); continue; }
    const one = resolveColor(words[i]);
    if (one) { colorTokens.push(one); consumedWords.add(i); continue; }
    // try two-word color like "dark blue"
    if (i + 1 < words.length) {
      const two = resolveColor(words[i] + words[i + 1]);
      if (two) { colorTokens.push(two); consumedWords.add(i); consumedWords.add(i + 1); }
    }
  }

  // Strip command words and consumed color tokens to find the text argument
  function stripToText(s) {
    let out = s;
    out = out.replace(/#[0-9a-fA-F]{6}/g, "");
    // Remove words that were consumed as colors
    const sWords = out.split(/\s+/);
    out = sWords.map((w, idx) => consumedWords.has(idx) ? "" : w).join(" ");
    out = out.replace(/\b(detect|identify|what|color|colour|is|analyze|gradient|fade|transition|blend|color|in|with|from|to|the|a|an|of|check|for|if|absent|missing|present|word|text)\b/gi, "");
    out = out.replace(/\s+/g, " ").trim();
    return out;
  }

  // ── Detect: color analysis ──
  if (isDetect && colorTokens.length > 0) {
    return { cmd: "colorsense detect", args: [colorTokens[0]] };
  }

  // ── Gradient: needs 2 colors + text ──
  if (isGradient && colorTokens.length >= 2) {
    const textPart = quotedText || stripToText(text);
    return { cmd: "colorsense gradient", args: [`-${colorTokens[0]}`, `--${colorTokens[1]}`, textPart || "gradient"] };
  }

  // ── Color: single color + text ──
  if (colorTokens.length >= 1) {
    const textPart = quotedText || stripToText(text) || "text";
    return { cmd: "colorsense color", args: [colorTokens[0], textPart] };
  }

  return { cmd: null, error: "Could not parse intent. Try: 'color red hello' or 'gradient from blue to green \"my text\"' or 'detect #ff0000' or 'is cat absent from \"the cat sat\"'" };
}

// ── Main ────────────────────────────────────────────────────────────────────
const input = process.argv.slice(2).join(" ");
if (!input) {
  console.error('Usage: ai-sense <natural language instruction>');
  process.exit(1);
}

const result = parse(input);
if (!result.cmd) {
  console.error("AI-Sense: " + result.error);
  process.exit(1);
}

// Output a shell-safe command for eval
const esc = (s) => `'${s.replace(/'/g, "'\\''")}'`;
const args = result.args.map(esc).join(" ");
console.log(`${result.cmd} ${args}`);
