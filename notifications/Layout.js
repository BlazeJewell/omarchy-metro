// Where every card sits: rows in, placements out. Cards are placed absolutely,
// so a card keeps its identity (and its animation) when the one above leaves.
.pragma library

// Collapsed geometry.
var PEEK = 10          // px each card behind the front one drops
var SHRINK = 0.035     // and the scale it loses
var VISIBLE = 3        // cards drawn before the rest just fade out
var FADE = 0.55        // opacity of the last drawn card in a collapsed deck

function groupKeyFor(row) {
  return String(row.groupKey || row.source || row.app || "?")
}

// Rows are newest-first. Returns:
//   decks:      [{ key, rows: [row...] }] in display order, newest deck first
//   placements: { rowKey: { y, height, scale, opacity, z, front, hidden } }
//   height:     total height the deck area occupies
// jake.metro options (all off unless given):
//   maxDecks:   draw at most this many decks; the rest are hidden and counted in `overflow`
//   dedupe:     a card with the same app, title and text as a newer one is hidden
//   visible:    cards drawn per shut deck (default VISIBLE); peek: px each one drops (default PEEK)
//   moreHeight: room kept under the decks for a "+N more" row when anything overflows
function compute(rows, opts) {
  var expanded = !!opts.expanded
  var gap = opts.gap || 6
  var deckGap = opts.deckGap || 12
  var heightOf = opts.heightOf || function() { return 76 }
  var visibleN = opts.visible || VISIBLE
  var peek = opts.peek !== undefined ? opts.peek : PEEK
  var maxDecks = opts.maxDecks || 0
  var order = [], byKey = {}, seen = {}, dupes = []
  for (var i = 0; i < rows.length; i++) {
    if (opts.dedupe) {
      var sig = groupKeyFor(rows[i]) + "\u0001" + String(rows[i].summary || "") + "\u0001" + String(rows[i].body || "")
      if (seen[sig]) { dupes.push(rows[i]); continue }
      seen[sig] = true
    }
    var key = groupKeyFor(rows[i])
    if (!byKey[key]) { byKey[key] = { key: key, rows: [] }; order.push(key) }
    byKey[key].rows.push(rows[i])
  }

  var decks = order.map(function(key) { return byKey[key] })
  var shownDecks = maxDecks > 0 ? decks.slice(0, maxDecks) : decks
  var overflow = 0

  var placements = {}
  var y = 0

  // repeats and decks past the limit: kept, but not drawn and taking no room
  dupes.forEach(function(row) { placements[row.key] = { height: heightOf(row.key), y: 0, scale: 1, opacity: 0, z: 0, front: false, hidden: true } })
  for (var h = shownDecks.length; h < decks.length; h++) {
    decks[h].rows.forEach(function(row) { overflow++; placements[row.key] = { height: heightOf(row.key), y: 0, scale: 1, opacity: 0, z: 0, front: false, hidden: true } })
  }
  decks = shownDecks

  for (var k = 0; k < decks.length; k++) {
    var items = decks[k].rows
    var open = expanded && (opts.openDeck === undefined || opts.openDeck === decks[k].key)
    var deckTop = y
    // Shut, every card takes the front card's height, so a taller one behind
    // does not hang out below the stack.
    var frontHeight = heightOf(items[0].key)

    for (var r = 0; r < items.length; r++) {
      var item = items[r]
      if (open) {
        var height = heightOf(item.key)
        placements[item.key] = {
          y: y, scale: 1, opacity: 1, z: 1000 - r, front: r === 0,
          hidden: false, height: height
        }
        y += height + gap
      } else {
        var drawn = r < visibleN
        placements[item.key] = {
          height: frontHeight,
          y: deckTop + Math.min(r, visibleN - 1) * peek,
          scale: Math.max(0.7, 1 - r * SHRINK),
          opacity: r === 0 ? 1 : (drawn ? (r === visibleN - 1 ? FADE : 0.85) : 0),
          z: 1000 - r,
          front: r === 0,
          hidden: !drawn
        }
      }
    }

    if (!open) y = deckTop + frontHeight + Math.min(items.length - 1, visibleN - 1) * peek
    else y -= gap

    if (k < decks.length - 1) y += deckGap
  }

  var moreY = Math.max(0, y)
  if (overflow > 0 && opts.moreHeight) y = moreY + opts.moreHeight
  return { decks: decks, placements: placements, height: Math.max(0, y), overflow: overflow, moreY: moreY }
}
