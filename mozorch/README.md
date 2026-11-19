# MozORCH

A chord player for [Mozaic](https://ruismaker.com) (iOS AUv3 MIDI scripting), modelled on the chord engine of the Telepathic Instruments Orchid.

One note in, a voiced chord out. Chord type and extensions come from pads or MIDI notes, so the harmony can be played live, latched, or sequenced on its own lane.

MIDI only - no sound engine, no arp or strum. Put a synth after it, and an arp in between if you want one.

**Current version:** v0.12

---

## setup

- Paste `mozorch.txt` into Mozaic's code view and upload
- Route a keyboard or sequencer into Mozaic, and Mozaic into a synth
- Tested in AUM on iPad

---

## pads

```
Dim  Min  Maj  Sus | Latch Chord  | Oct + | Scale | XY
6    m7   M7   9   | Hold Note In | Oct - |       | Panic
```

- **Dim / Min / Maj / Sus** - chord type (the triad on the root)
- **6 / m7 / M7 / 9** - extensions, stacked on top of the type
- **Latch Chord** - chord pads toggle instead of hold
    - types are one-at-a-time: a new type replaces the old one, tapping it again clears it
    - extensions stack; m7 and M7 cancel each other
- **Hold Note In** - chord keeps sounding after the root key is released, until the next root
- **Oct + / -** - transposes the incoming root, two octaves either way
- **Scale** - Major / Harmonic minor / Melodic minor; only active when Key is set
- **XY** - switches to the knob view (Shift does the same)
- **Panic** - all notes off on every channel

### combo chords

Hold one type and press another:

| combo | chord |
|---|---|
| Dim + Maj | augmented |
| Maj + Sus | sus2 |
| Min + Maj | power chord (5th) |
| Dim + Sus | quartal |

The Orchid has its own hidden combos, but their mapping isn't published - these are MozORCH's own. They live in one lookup table, `typeMap`, if you want to change them.

---

## knobs (XY view)

```
Voicing       | Notes | Bass | Key     | X CC
Legato/Replay | Qnt   | Vel  | XY send | Y CC
```

- **Voicing** - walks the chord up or down one chord tone at a time, cascading through inversions (-8 to +8)
- **Notes** - auto (one of each chord tone) or a fixed 3-7; more than the chord has adds octave doublings, fewer drops the top tones
- **Bass** - off / low / mid; adds the root in a fixed low octave, below the chord
- **Key** - off, or a tonic C-B. With no type pad active, every root gets its diatonic chord; out-of-key roots snap up to the next scale note
- **Legato / Replay** - what happens when a pad or knob changes under a held root
    - **Replay** - the whole chord re-attacks
    - **Legato** - only notes that change are sent; shared notes keep sounding
- **Qnt** - quantises root presses, releases and chord changes to off / 1/1 / 1/2 / 1/4 / 1/8 / 1/16 of a bar
    - only while the host transport runs; stopping flushes anything queued
    - divisions are per bar, so in 3/4 "1/4" means four steps per bar
- **Vel** - output velocity: 108 fixed, turning up spreads each note randomly downwards
- **X CC / Y CC / XY send** - the XY pad sends two CCs on the chord's channel. Set XY send to X only or Y only while MIDI-learning a destination, so it grabs the right one

---

## MIDI in

- **Notes 24 26 28 29 31 33 35 36** (white keys, an octave from C) - the 8 chord pads, in pad order
- **Notes above 36** - roots; last note wins
- **Passed through** - CCs, pitchbend, channel pressure
- **Dropped** - poly aftertouch
- **Incoming velocity is ignored** - the Vel knob sets it

---

## notes

- **Key mode only picks the chord when no type pad is active.** A latched type always wins
- **The 9th folds down to a 2nd** at low voicings (add2 cluster); turn Voicing up to open it out
- **Bass doesn't follow Oct + / -**
- **Debug logging** - set `debug = YES` near the top of `@OnLoad` to log every chord and note sent

---

## versions

- **v0.12** - renamed from ORCHD; debug logging off by default
- **v0.11** - last build as ORCHD

---

Not affiliated with Telepathic Instruments. Orchid is their product; this is an independent take on its chord interface.
