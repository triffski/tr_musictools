# tr_musictools

Small music tools - scripts, presets and utilities. One folder per tool, each with its own README.

## tools

| tool | what | runs in | status |
|---|---|---|---|
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
