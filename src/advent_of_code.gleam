import gleam/int
import gleam/list
import gleam/result
import gleam/string
import simplifile

type Direction {
  Left
  Right
}

type InstructionParsingError {
  InstructionParsingError
}

type Instruction {
  Instruction(direction: Direction, amount: Int)
}

fn read_instruction(s: String) -> Result(Instruction, InstructionParsingError) {
  let first_letter = string.first(s)
  let rest = int.parse(string.drop_start(s, 1))

  case first_letter, rest {
    Ok("L"), Ok(i) -> Ok(Instruction(Left, i))
    Ok("R"), Ok(i) -> Ok(Instruction(Right, i))
    _, _ -> Error(InstructionParsingError)
  }
}

fn split_instructions(file: String) -> List(String) {
  string.split(file, "\n")
}

fn wrap_around(v: Int) -> Int {
  case v {
    _ if v > 99 -> wrap_around(v - 100)
    _ if v < 0 -> wrap_around(v + 100)
    _ -> v
  }
}

fn calculate_new_dial_position(
  instruction: Instruction,
  current_dial_position: Int,
) -> Int {
  case instruction {
    Instruction(Left, amount) -> wrap_around(current_dial_position - amount)
    Instruction(Right, amount) -> wrap_around(current_dial_position + amount)
  }
}

fn process_instructions(
  instructions: List(Instruction),
  dial_position: Int,
  times_reached_zero: Int,
) -> Int {
  case instructions {
    [instruction, ..rest] -> {
      let new_dial_position =
        calculate_new_dial_position(instruction, dial_position)
      let times_reached_zero = case new_dial_position {
        0 -> times_reached_zero + 1
        _ -> times_reached_zero
      }
      process_instructions(rest, new_dial_position, times_reached_zero)
    }
    [] -> times_reached_zero
  }
}

fn get_file() {
  let filepath = "./data/instructions.txt"
  let assert Ok(file_contents) = simplifile.read(from: filepath)
  file_contents
}

pub fn main() -> Nil {
  let instructions =
    get_file()
    |> split_instructions()
    |> list.map(read_instruction)

  let any_error = list.any(instructions, fn(x) { result.is_error(x) })

  case any_error {
    True -> panic
    False -> result.values(instructions) |> process_instructions(50, 0) |> echo
  }

  Nil
}
