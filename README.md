# tr_musictools

Small music tools - scripts, presets and utilities. One folder per tool, each with its own README.

## tools

| tool | what | runs in | status |
|---|---|---|---|
| [ableton-theme-editor](ableton-theme-editor/) | Browser editor for Live 12 `.ask` themes - HSV-driven, live preview, palette-from-photo | browser, offline | stable |
| [ableton-themes-installer](ableton-themes-installer/) | Restores custom Ableton Live 12 themes after an update wipes them | macOS, bash | stable |
| [ableton-theme-backup-restore](ableton-theme-backup-restore/) | Back up / restore Live 12 themes around updates, with version-aware restore | macOS + Windows | stable |
| [mozorch](mozorch/) | Orchid-style chord player: one note in, voiced chord out | Mozaic (iOS AUv3) | v0.12 |

<!--
new tool: copy this row into the table above

| [folder](folder/) | one line: what it does | host / app / platform | vX.Y |

status: version number, or wip / stable / archived
-->

## layout

```
tr_musictools/
├── README.md        this list
├── LICENSE
└── <tool>/
    ├── README.md    what it is, setup, controls, notes, versions
    └── ...          the tool itself
```

- **folder names** - lowercase, no spaces
- **each tool README** - starts with one paragraph saying what it is and what it runs in

## licence

MIT - see [LICENSE](LICENSE).
