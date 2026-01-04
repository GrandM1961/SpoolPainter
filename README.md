# SpoolPainter

An Android NFC application for managing 3D printer filament spools with OpenSpool data format support.

## Features

- **NFC Tag Reading/Writing**: Read and write filament data to NFC tags using OpenSpool format
- **Spoolman Integration**: Connect to Spoolman server to import filament data
- **Material Management**: Store and manage filament properties (type, brand, temperatures, colors)
- **Modern UI**: Built with Jetpack Compose for a clean, modern interface

## Architecture

- **MVVM Pattern**: Clean separation between UI, business logic, and data
- **Modular Design**: Organized into focused components for maintainability
- **Compose UI**: Modern declarative UI framework

## Tech Stack

- Kotlin
- Jetpack Compose
- Android NFC API
- ViewModel & LiveData
- Coroutines

## Getting Started

1. Clone the repository
2. Open in Android Studio
3. Build and run on an NFC-enabled Android device

## NFC Usage

- **Read**: Tap "Read NFC Tag" and hold device near NFC tag
- **Write**: Enter filament data and tap "Write to NFC Tag", then hold device near tag
- **Spoolman**: Configure Spoolman server URL in settings to import filament data

## Requirements

- Android device with NFC capability
- Android API level 21+
- NFC tags (NDEF compatible)
