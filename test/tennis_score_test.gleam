import gleam/list
import gleeunit
import gleeunit/should
import tennis_score

pub fn main() {
  gleeunit.main()
}

pub fn next_point_test() {
  tennis_score.next_point(tennis_score.Love)
  |> should.equal(tennis_score.Fifteen)

  tennis_score.next_point(tennis_score.Fifteen)
  |> should.equal(tennis_score.Thirty)

  tennis_score.next_point(tennis_score.Thirty)
  |> should.equal(tennis_score.Forty)

  // Once at Forty, stay at Forty
  tennis_score.next_point(tennis_score.Forty)
  |> should.equal(tennis_score.Forty)
}

pub fn parse_input_test() {
  tennis_score.parse_input("1")
  |> should.equal(tennis_score.Player1Point)

  tennis_score.parse_input("2")
  |> should.equal(tennis_score.Player2Point)

  tennis_score.parse_input("  1  ")
  // whitespace trimmed
  |> should.equal(tennis_score.Player1Point)

  tennis_score.parse_input("hello")
  |> should.equal(tennis_score.InvalidInput)

  tennis_score.parse_input("")
  |> should.equal(tennis_score.InvalidInput)
}

pub fn update_normal_test() {
  // Player1 scores from 0-0 → 15-0
  tennis_score.update_normal(
    tennis_score.Player1,
    tennis_score.Love,
    tennis_score.Love,
  )
  |> should.equal(tennis_score.Normal(tennis_score.Fifteen, tennis_score.Love))

  // Player2 scores from 30-40 → GameOver(Player2)
  tennis_score.update_normal(
    tennis_score.Player2,
    tennis_score.Thirty,
    tennis_score.Forty,
  )
  |> should.equal(tennis_score.GameOver(
    tennis_score.Player2,
    tennis_score.Thirty,
    tennis_score.Forty,
  ))

  // Player1 scores from 40-30 → GameOver(Player1)
  tennis_score.update_normal(
    tennis_score.Player1,
    tennis_score.Forty,
    tennis_score.Thirty,
  )
  |> should.equal(tennis_score.GameOver(
    tennis_score.Player1,
    tennis_score.Forty,
    tennis_score.Thirty,
  ))
}

pub fn deuce_and_advantage_test() {
  // Deuce → Advantage1
  tennis_score.update(tennis_score.Deuce, tennis_score.Player1Point)
  |> should.equal(tennis_score.Advantage1)

  // Deuce → Advantage2
  tennis_score.update(tennis_score.Deuce, tennis_score.Player2Point)
  |> should.equal(tennis_score.Advantage2)

  // Advantage1 → GameOver(Player1)
  tennis_score.update(tennis_score.Advantage1, tennis_score.Player1Point)
  |> should.equal(tennis_score.GameOver(
    tennis_score.Player1,
    tennis_score.Forty,
    tennis_score.Forty,
  ))

  // Advantage1 → Deuce
  tennis_score.update(tennis_score.Advantage1, tennis_score.Player2Point)
  |> should.equal(tennis_score.Deuce)

  // Advantage2 → GameOver(Player2)
  tennis_score.update(tennis_score.Advantage2, tennis_score.Player2Point)
  |> should.equal(tennis_score.GameOver(
    tennis_score.Player2,
    tennis_score.Forty,
    tennis_score.Forty,
  ))

  // Advantage2 → Deuce
  tennis_score.update(tennis_score.Advantage2, tennis_score.Player1Point)
  |> should.equal(tennis_score.Deuce)
}

pub fn game_over_test() {
  let final_state =
    tennis_score.GameOver(
      tennis_score.Player1,
      tennis_score.Forty,
      tennis_score.Thirty,
    )

  // Any Player1Point input keeps the state unchanged
  tennis_score.update(final_state, tennis_score.Player1Point)
  |> should.equal(final_state)

  // Any Player2Point input keeps the state unchanged
  tennis_score.update(final_state, tennis_score.Player2Point)
  |> should.equal(final_state)

  // InvalidInput also keeps the state unchanged
  tennis_score.update(final_state, tennis_score.InvalidInput)
  |> should.equal(final_state)
}

pub fn straight_line_win_test() {
  let result =
    [
      tennis_score.Player1Point,
      tennis_score.Player1Point,
      tennis_score.Player1Point,
      tennis_score.Player1Point,
    ]
    |> list.fold(
      tennis_score.Normal(tennis_score.Love, tennis_score.Love),
      tennis_score.update,
    )

  result
  |> should.equal(tennis_score.GameOver(
    tennis_score.Player1,
    tennis_score.Forty,
    tennis_score.Love,
  ))
}

pub fn deuce_advantage_gameover_test() {
  let result =
    [
      tennis_score.Player1Point,
      tennis_score.Player2Point,
      tennis_score.Player1Point,
      tennis_score.Player2Point,
      tennis_score.Player1Point,
      tennis_score.Player2Point,
      // Now Deuce
      tennis_score.Player1Point,
      // Advantage1
      tennis_score.Player1Point,
      // GameOver(Player1)
    ]
    |> list.fold(
      tennis_score.Normal(tennis_score.Love, tennis_score.Love),
      tennis_score.update,
    )

  result
  |> should.equal(tennis_score.GameOver(
    tennis_score.Player1,
    tennis_score.Forty,
    tennis_score.Forty,
  ))
}

pub fn long_deuce_battle_test() {
  let result =
    [
      // Reach Deuce
      tennis_score.Player1Point,
      tennis_score.Player2Point,
      tennis_score.Player1Point,
      tennis_score.Player2Point,
      tennis_score.Player1Point,
      tennis_score.Player2Point,

      // Bounce between Advantage and Deuce several times
      tennis_score.Player1Point,
      // Advantage1
      tennis_score.Player2Point,
      // Back to Deuce
      tennis_score.Player1Point,
      // Advantage1
      tennis_score.Player2Point,
      // Back to Deuce
      tennis_score.Player1Point,

      // Advantage1
      // Finally, Player1 wins
      tennis_score.Player1Point,
      // GameOver(Player1)
    ]
    |> list.fold(
      tennis_score.Normal(tennis_score.Love, tennis_score.Love),
      tennis_score.update,
    )

  result
  |> should.equal(tennis_score.GameOver(
    tennis_score.Player1,
    tennis_score.Forty,
    tennis_score.Forty,
  ))
}
