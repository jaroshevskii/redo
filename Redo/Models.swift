//
//  Models.swift
//  Redo
//
//  Created by Sasha Jaroshevskii on 11/23/25.
//

import Foundation

// MARK: - Core Models

/// Represents a flashcard for language learning
struct Card: Identifiable, Codable, Equatable {
  let id: UUID
  let front: CardFace
  let back: CardFace
  let hint: Hint?
  let metadata: CardMetadata
  
  init(
    id: UUID = UUID(),
    front: CardFace,
    back: CardFace,
    hint: Hint? = nil,
    metadata: CardMetadata = CardMetadata()
  ) {
    self.id = id
    self.front = front
    self.back = back
    self.hint = hint
    self.metadata = metadata
  }
}

// MARK: - Card Face

/// Represents one side of a card (front or back)
struct CardFace: Codable, Equatable {
  let primaryContent: Content
  let secondaryContent: [Content]
  let pronunciation: String?
  
  init(
    primaryContent: Content,
    secondaryContent: [Content] = [],
    pronunciation: String? = nil
  ) {
    self.primaryContent = primaryContent
    self.secondaryContent = secondaryContent
    self.pronunciation = pronunciation
  }
}

// MARK: - Content Types

/// Flexible content system supporting multiple media types
enum Content: Codable, Equatable {
  case text(String)
  case image(URL)
  case audio(URL)
  case video(URL)
  case rich(AttributedContent)
  
  var displayValue: String {
    switch self {
    case .text(let value): return value
    case .image: return "[Image]"
    case .audio: return "[Audio]"
    case .video: return "[Video]"
    case .rich(let content): return content.plainText
    }
  }
}

/// Rich text with formatting
struct AttributedContent: Codable, Equatable {
  let plainText: String
  let formatting: [TextFormat]
  let language: String?
}

struct TextFormat: Codable, Equatable {
  let range: Range<Int>
  let style: FormatStyle
  
  enum FormatStyle: String, Codable {
    case bold, italic, underline, highlight, colored
  }
}

// MARK: - Hint System

/// Flexible hint system with progressive revelation
struct Hint: Codable, Equatable {
  let levels: [HintLevel]
  let strategy: HintStrategy
  
  enum HintStrategy: String, Codable {
    case progressive  // Показувати підказки поступово
    case all          // Показати всі одразу
    case random       // Випадкова підказка
  }
}

struct HintLevel: Codable, Equatable, Identifiable {
  let id: UUID
  let content: Content
  let revealCost: Int  // "Вартість" показу підказки (для геймифікації)
  let order: Int
  
  init(
    id: UUID = UUID(),
    content: Content,
    revealCost: Int = 0,
    order: Int
  ) {
    self.id = id
    self.content = content
    self.revealCost = revealCost
    self.order = order
  }
}

// MARK: - Metadata & Learning Analytics

struct CardMetadata: Codable, Equatable {
  var createdAt: Date
  var updatedAt: Date
  var tags: Set<String>
  var category: String?
  var difficulty: Difficulty
  var learningStats: LearningStats
  
  init(
    createdAt: Date = Date(),
    updatedAt: Date = Date(),
    tags: Set<String> = [],
    category: String? = nil,
    difficulty: Difficulty = .beginner,
    learningStats: LearningStats = LearningStats()
  ) {
    self.createdAt = createdAt
    self.updatedAt = updatedAt
    self.tags = tags
    self.category = category
    self.difficulty = difficulty
    self.learningStats = learningStats
  }
}

enum Difficulty: String, Codable, CaseIterable {
  case beginner = "A1"
  case elementary = "A2"
  case intermediate = "B1"
  case upperIntermediate = "B2"
  case advanced = "C1"
  case proficient = "C2"
  
  var numericValue: Int {
    switch self {
    case .beginner: return 1
    case .elementary: return 2
    case .intermediate: return 3
    case .upperIntermediate: return 4
    case .advanced: return 5
    case .proficient: return 6
    }
  }
}

// MARK: - Spaced Repetition System (SRS)

struct LearningStats: Codable, Equatable {
  var reviewCount: Int
  var correctCount: Int
  var incorrectCount: Int
  var lastReviewedAt: Date?
  var nextReviewAt: Date?
  var easeFactor: Double  // Supermemo алгоритм
  var interval: TimeInterval  // Інтервал повторення
  var streak: Int  // Серія правильних відповідей
  
  init(
    reviewCount: Int = 0,
    correctCount: Int = 0,
    incorrectCount: Int = 0,
    lastReviewedAt: Date? = nil,
    nextReviewAt: Date? = nil,
    easeFactor: Double = 2.5,
    interval: TimeInterval = 0,
    streak: Int = 0
  ) {
    self.reviewCount = reviewCount
    self.correctCount = correctCount
    self.incorrectCount = incorrectCount
    self.lastReviewedAt = lastReviewedAt
    self.nextReviewAt = nextReviewAt
    self.easeFactor = easeFactor
    self.interval = interval
    self.streak = streak
  }
  
  var accuracy: Double {
    guard reviewCount > 0 else { return 0 }
    return Double(correctCount) / Double(reviewCount)
  }
}

// MARK: - Deck System

/// Collection of cards organized by theme
struct Deck: Identifiable, Codable {
  let id: UUID
  var name: String
  var description: String?
  var cards: [Card]
  var settings: DeckSettings
  var metadata: DeckMetadata
  
  init(
    id: UUID = UUID(),
    name: String,
    description: String? = nil,
    cards: [Card] = [],
    settings: DeckSettings = DeckSettings(),
    metadata: DeckMetadata = DeckMetadata()
  ) {
    self.id = id
    self.name = name
    self.description = description
    self.cards = cards
    self.settings = settings
    self.metadata = metadata
  }
}

struct DeckSettings: Codable {
  var cardsPerSession: Int
  var shuffleCards: Bool
  var reviewAlgorithm: ReviewAlgorithm
  var showHintsAutomatically: Bool
  
  init(
    cardsPerSession: Int = 20,
    shuffleCards: Bool = true,
    reviewAlgorithm: ReviewAlgorithm = .spacedRepetition,
    showHintsAutomatically: Bool = false
  ) {
    self.cardsPerSession = cardsPerSession
    self.shuffleCards = shuffleCards
    self.reviewAlgorithm = reviewAlgorithm
    self.showHintsAutomatically = showHintsAutomatically
  }
}

enum ReviewAlgorithm: String, Codable {
  case spacedRepetition  // SM-2 алгоритм
  case leitner           // Система Лейтнера
  case random            // Випадковий порядок
  case sequential        // Послідовний порядок
}

struct DeckMetadata: Codable {
  var createdAt: Date
  var lastStudiedAt: Date?
  var totalStudyTime: TimeInterval
  var completionRate: Double
  
  init(
    createdAt: Date = Date(),
    lastStudiedAt: Date? = nil,
    totalStudyTime: TimeInterval = 0,
    completionRate: Double = 0
  ) {
    self.createdAt = createdAt
    self.lastStudiedAt = lastStudiedAt
    self.totalStudyTime = totalStudyTime
    self.completionRate = completionRate
  }
}

// MARK: - Study Session

/// Represents an active learning session
struct StudySession: Identifiable {
  let id: UUID
  let deck: Deck
  var currentCardIndex: Int
  var reviewedCards: [CardReview]
  var startTime: Date
  var isPaused: Bool
  
  init(
    id: UUID = UUID(),
    deck: Deck,
    currentCardIndex: Int = 0,
    reviewedCards: [CardReview] = [],
    startTime: Date = Date(),
    isPaused: Bool = false
  ) {
    self.id = id
    self.deck = deck
    self.currentCardIndex = currentCardIndex
    self.reviewedCards = reviewedCards
    self.startTime = startTime
    self.isPaused = isPaused
  }
  
  var currentCard: Card? {
    guard currentCardIndex < deck.cards.count else { return nil }
    return deck.cards[currentCardIndex]
  }
  
  var progress: Double {
    guard !deck.cards.isEmpty else { return 0 }
    return Double(currentCardIndex) / Double(deck.cards.count)
  }
}

struct CardReview: Identifiable {
  let id: UUID
  let cardId: UUID
  let response: ReviewResponse
  let timeSpent: TimeInterval
  let hintsUsed: Int
  let timestamp: Date
  
  init(
    id: UUID = UUID(),
    cardId: UUID,
    response: ReviewResponse,
    timeSpent: TimeInterval,
    hintsUsed: Int = 0,
    timestamp: Date = Date()
  ) {
    self.id = id
    self.cardId = cardId
    self.response = response
    self.timeSpent = timeSpent
    self.hintsUsed = hintsUsed
    self.timestamp = timestamp
  }
}

enum ReviewResponse: String, Codable {
  case again      // Не пам'ятаю
  case hard       // Важко
  case good       // Добре
  case easy       // Легко
  
  var scoreMultiplier: Double {
    switch self {
    case .again: return 0.0
    case .hard: return 0.5
    case .good: return 1.0
    case .easy: return 1.5
    }
  }
}

// MARK: - Example Factory

extension Card {
  /// Factory method для швидкого створення карток
  static func english(
    word: String,
    translation: String,
    pronunciation: String? = nil,
    example: String? = nil,
    hint: String? = nil,
    partOfSpeech: String? = nil
  ) -> Card {
    var secondaryContent: [Content] = []
    if let example = example {
      secondaryContent.append(.text("Example: \(example)"))
    }
    if let pos = partOfSpeech {
      secondaryContent.append(.text("[\(pos)]"))
    }
    
    let front = CardFace(
      primaryContent: .text(word),
      secondaryContent: secondaryContent,
      pronunciation: pronunciation
    )
    
    let back = CardFace(
      primaryContent: .text(translation),
      secondaryContent: []
    )
    
    let hintLevel: Hint? = hint.map {
      Hint(
        levels: [
          HintLevel(content: .text($0), order: 0)
        ],
        strategy: .progressive
      )
    }
    
    return Card(
      front: front,
      back: back,
      hint: hintLevel
    )
  }
}

// MARK: - Usage Example

/*
 let exampleCard = Card.english(
 word: "Serendipity",
 translation: "Щаслива випадковість",
 pronunciation: "ˌserənˈdɪpɪti",
 example: "Meeting my best friend was pure serendipity.",
 hint: "Це слово походить з перської казки про трьох принців...",
 partOfSpeech: "noun"
 )
 
 var deck = Deck(
 name: "Advanced Vocabulary",
 description: "Рідкісні та красиві англійські слова"
 )
 deck.cards.append(exampleCard)
 
 let session = StudySession(deck: deck)
 */
