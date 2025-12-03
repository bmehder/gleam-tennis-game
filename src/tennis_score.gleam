//// A simple CLI app to simulate tennis scoring between two players.

import gleam/io
import gleam/string
import in

/// Represents the possible (non-deuce or Ad) points a player can have in a tennis game.
pub type Point {
  Love
  Fifteen
  Thirty
  Forty
}

/// Represents a player (used for point winner and game winner).
pub type Winner {
  Player1
  Player2
}

/// Represents the messages or inputs to update the game state.
pub type Msg {
  Player1Point
  Player2Point
  InvalidInput
}

/// Represents the various states the tennis game can be in.
pub type GameState {
  Normal(Point, Point)
  Deuce
  Advantage1
  Advantage2
  GameOver(Winner, Point, Point)
}

/// The main entry point of the tennis scoring application.
pub fn main() {
  loop(Normal(Love, Love))
}

/// Converts a Normal (non-Deuce or Ad) Point value to its string representation.
fn point_to_string(point: Point) -> String {
  case point {
    Love -> "0"
    Fifteen -> "15"
    Thirty -> "30"
    Forty -> "40"
  }
}

/// Returns the next point value after the current (non-Deuce or Ad) one.
fn next_point(point: Point) -> Point {
  case point {
    Love -> Fifteen
    Fifteen -> Thirty
    Thirty -> Forty
    // Handle deuce somewhere else.
    Forty -> Forty
  }
}

/// Parses a string input into a Msg value.
fn parse_input(line: String) -> Msg {
  case string.trim(line) {
    "1" -> Player1Point
    "2" -> Player2Point
    _ -> InvalidInput
  }
}

/// Updates the points in a Normal state for whichever player scored.
fn update_player(
  scorer: Winner,
  scorer_point: Point,
  other_point: Point,
) -> GameState {
  case scorer_point, other_point {
    Forty, _ -> GameOver(scorer, scorer_point, other_point)

    _, _ -> {
      let new_scorer_point = next_point(scorer_point)
      case new_scorer_point, other_point {
        Forty, Forty -> Deuce
        _, _ ->
          case scorer {
            Player1 -> Normal(new_scorer_point, other_point)
            Player2 -> Normal(other_point, new_scorer_point)
          }
      }
    }
  }
}

fn update_normal(scorer: Winner, p1_point: Point, p2_point: Point) -> GameState {
  case scorer {
    Player1 -> update_player(Player1, p1_point, p2_point)
    Player2 -> update_player(Player2, p2_point, p1_point)
  }
}

/// Updates the game state based on the current state and message.
fn update(state: GameState, msg: Msg) -> GameState {
  case state {
    Normal(p1_point, p2_point) ->
      case msg {
        Player1Point -> update_normal(Player1, p1_point, p2_point)
        Player2Point -> update_normal(Player2, p1_point, p2_point)
        InvalidInput -> state
      }
    Deuce ->
      case msg {
        Player1Point -> Advantage1
        Player2Point -> Advantage2
        InvalidInput -> state
      }
    Advantage1 ->
      case msg {
        Player1Point -> GameOver(Player1, Forty, Forty)
        Player2Point -> Deuce
        InvalidInput -> state
      }
    Advantage2 ->
      case msg {
        Player2Point -> GameOver(Player2, Forty, Forty)
        Player1Point -> Deuce
        InvalidInput -> state
      }
    GameOver(_, _, _) -> state
  }
}

/// Returns a nicely formatted final score string for a completed game.
fn display_final_score(
  winner: Winner,
  p1_point: Point,
  p2_point: Point,
) -> String {
  case p1_point, p2_point {
    Forty, Forty ->
      case winner {
        Player1 -> player_to_string(Player1) <> " wins Deuce game!"
        Player2 -> player_to_string(Player2) <> " wins Deuce game!"
      }
    _, _ ->
      case winner {
        Player1 ->
          player_to_string(Player1)
          <> " wins! Final score: "
          <> point_to_string(p1_point)
          <> " - "
          <> point_to_string(p2_point)
        Player2 ->
          player_to_string(Player2)
          <> " wins! Final score: "
          <> point_to_string(p1_point)
          <> " - "
          <> point_to_string(p2_point)
      }
  }
}

/// Returns a string label for the given player.
fn player_to_string(winner: Winner) -> String {
  case winner {
    Player1 -> "Player 1"
    Player2 -> "Player 2"
  }
}

/// Returns a string for the Advantage game state for the given player.
fn display_advantage(winner: Winner) -> String {
  case winner {
    Player1 -> "Advantage " <> player_to_string(Player1)
    Player2 -> "Advantage " <> player_to_string(Player2)
  }
}

/// Returns a string representation of the current game state.
fn view(state: GameState) -> String {
  case state {
    Normal(p1, p2) -> point_to_string(p1) <> " - " <> point_to_string(p2)

    Deuce -> "Deuce"

    Advantage1 -> display_advantage(Player1)
    Advantage2 -> display_advantage(Player2)

    GameOver(winner, p1, p2) -> display_final_score(winner, p1, p2)
  }
}

/// The main loop that handles input/output and updates the game state.
fn loop(state: GameState) {
  io.println(view(state))

  case state {
    GameOver(_, _, _) -> {
      io.println("Game complete!")
    }
    _ -> {
      io.print("Who won the point? (1 or 2): ")
      let assert Ok(line) = in.read_line()
      let msg = parse_input(line)
      let new_state = update(state, msg)
      loop(new_state)
    }
  }
}
