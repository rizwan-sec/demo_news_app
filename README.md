# Demo News App

A Flutter news application powered by NewsAPI.

## Setup Instructions

### 1. Clone the repository

Clone this repository from GitHub and open it in your IDE.

### 2. Configure the API key

Create a file named `env.json` in the project root directory and add your News API key:

```json
{
  "NEWS_API_KEY": "79819ab9d8224dac99ff48e07fb6f4e4"
}
```



### 3. Install dependencies

Run the following command from the project root:

```bash
flutter pub get
```

### 4. Run the application

```bash
flutter run --dart-define-from-file=env.json
```

## Requirements

- Flutter SDK
- Dart SDK
- A valid NewsAPI key
