# Simple Entertainment List

A tiny macOS app for tracking what you want to read or watch next — books, movies, and shows in one list.

## Features

- Add a title, tag it as a Book, Movie, or Show
- Check items off as you finish them — they move to a Finished section
- Swipe to delete
- Native SwiftUI app, warm paper-and-ink theme with light/dark mode support

## Requirements

- macOS 14+
- Swift 5.9+

## Building & Running

```sh
swift build
swift run
```

Data is stored locally in `~/Library/Application Support/SimpleEntertainmentList/items.json` — never committed to this repo.
