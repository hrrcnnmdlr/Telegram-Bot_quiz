# QuizVCh Application

## Overview
The QuizVCh application is designed to facilitate the creation and management of quizzes. It allows users to take tests, track their results, and manage questions efficiently. The application is structured to support various functionalities, including input handling, result output, and statistics tracking.

## Project Structure
The project is organized as follows:

```
quiz-app
├── quiz
│   ├── yml                # Directory for input and output files with .yml extension
│   ├── answers            # Directory for output files with .txt extension containing user test results
│   ├── question.rb        # Implementation of the Question class
│   ├── question_data.rb   # Implementation of the QuestionData class
│   ├── input_reader.rb    # Implementation of the InputReader class
│   ├── file_writer.rb     # Implementation of the FileWriter class
│   ├── statistics.rb      # Implementation of the Statistics class
│   ├── quiz.rb            # Implementation of the Singleton Quiz class
│   ├── config.rb          # Configuration settings for the application
│   ├── libraries.rb       # List of necessary libraries
│   ├── engine.rb          # Implementation of the Engine class for test management
│   └── runner.rb          # Implementation for invoking the Engine class
└── README.md              # Documentation for the project
```

## Features
- **Question Management**: Add, edit, and delete questions.
- **User Input**: Facilitate user input for test-taking.
- **Result Tracking**: Store and manage user results with timestamps.
- **Statistics**: Track user performance over time.
- **Configuration**: Easily configure application parameters.

## Getting Started
To get started with the QuizVCh application, clone the repository and navigate to the project directory. Ensure you have the necessary dependencies installed as listed in `libraries.rb`.

## Contribution
Contributions are welcome! Please feel free to submit a pull request or open an issue for any enhancements or bug fixes.

## License
This project is licensed under the MIT License. See the LICENSE file for details.