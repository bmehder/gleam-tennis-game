import gleam/io
import gleam/string
import in

pub type Point {
  Love
  Fifteen
  Thirty
  Forty
}

pub type Winner {
  Player1
  Player2
}

pub type Msg {
  Player1Point
  Player2Point
  InvalidInput
}

pub type GameState {
  Normal(Point, Point)
  Deuce
  Advantage1(Point, Point)
  Advantage2(Point, Point)
  GameOver(Winner, Point, Point)
}

pub fn main() {
  loop(Normal(Love, Love))
}

fn point_to_string(point: Point) -> String {
  case point {
    Love -> "0"
    Fifteen -> "15"
    Thirty -> "30"
    Forty -> "40"
  }
}

fn next_point(point: Point) -> Point {
  case point {
    Love -> Fifteen
    Fifteen -> Thirty
    Thirty -> Forty
    Forty -> Forty
  }
}

fn parse_input(line: String) -> Msg {
  case string.trim(line) {
    "1" -> Player1Point
    "2" -> Player2Point
    _ -> InvalidInput
  }
}

fn update_normal_player1(p1: Point, p2: Point) -> GameState {
  case p1, p2 {
    Forty, _ -> GameOver(Player1, p1, p2)
    _, _ -> {
      let new_p1 = next_point(p1)
      case new_p1, p2 {
        Forty, Forty -> Deuce
        _, _ -> Normal(new_p1, p2)
      }
    }
  }
}

fn update_normal_player2(p1: Point, p2: Point) -> GameState {
  case p1, p2 {
    _, Forty -> GameOver(Player2, p1, p2)
    _, _ -> {
      let new_p2 = next_point(p2)
      case p1, new_p2 {
        Forty, Forty -> Deuce
        _, _ -> Normal(p1, new_p2)
      }
    }
  }
}

fn update(msg: Msg, state: GameState) -> GameState {
  case state {
    Normal(p1, p2) ->
      case msg {
        Player1Point -> update_normal_player1(p1, p2)
        Player2Point -> update_normal_player2(p1, p2)
        InvalidInput -> state
      }
    Deuce ->
      case msg {
        Player1Point -> Advantage1(Forty, Forty)
        Player2Point -> Advantage2(Forty, Forty)
        InvalidInput -> state
      }
    Advantage1(p1, p2) ->
      case msg {
        Player1Point -> GameOver(Player1, p1, p2)
        Player2Point -> Deuce
        InvalidInput -> state
      }
    Advantage2(p1, p2) ->
      case msg {
        Player2Point -> GameOver(Player2, p1, p2)
        Player1Point -> Deuce
        InvalidInput -> state
      }
    GameOver(_, _, _) -> state
  }
}

fn view(state: GameState) -> String {
  case state {
    Normal(p1, p2) -> point_to_string(p1) <> " - " <> point_to_string(p2)

    Deuce -> "Deuce"

    Advantage1(_, _) -> "Advantage player 1"
    Advantage2(_, _) -> "Advantage player 2"

    GameOver(winner, p1, p2) ->
      case p1, p2 {
        Forty, Forty ->
          case winner {
            Player1 -> "Player 1 wins! Final score: Deuce game"
            Player2 -> "Player 2 wins! Final score: Deuce game"
          }
        _, _ ->
          case winner {
            Player1 ->
              "Player 1 wins! Final score: "
              <> point_to_string(p1)
              <> " - "
              <> point_to_string(p2)
            Player2 ->
              "Player 2 wins! Final score: "
              <> point_to_string(p1)
              <> " - "
              <> point_to_string(p2)
          }
      }
  }
}

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
      let new_state = update(msg, state)
      loop(new_state)
    }
  }
}
