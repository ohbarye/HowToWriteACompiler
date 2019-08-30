@source = ''
@source_index = 0
@tokens = []

Token = Struct.new(:kind, :value)
Expr = Struct.new(:kind, :intval)

def get_char
  return if @source_index == @source.size
  char = @source[@source_index]
  @source_index += 1
  char
end

def unget_char
  @source_index -=1
end

def read_number(char)
  number = [char]
  while true
    char = get_char
    break if char.nil?

    if '0' <= char && char <= '9'
      number << char
    else
      unget_char
      break
    end
  end

  number.join
end

def tokenize
  tokens = []

  while true
    char = get_char
    break if char.nil?
    case char
    when ' ', "\t", "\n"
      # noop
    when '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'
      intliteral = read_number(char)
      token = Token.new("intliteral", intliteral)
      tokens << token
    when ';'
      token = Token.new("punct", char)
      tokens << token
    else
      throw "tokenizer: Invalid char: '#{char}'"
    end
  end

  puts "# Tokens : #{tokens.map(&:value)}"
  puts
  tokens
end

def parse_unary_expr
  first_token = @tokens.first
  Expr.new('intliteral', first_token.value)
end

def parse
  parse_unary_expr
end

def generate_expr(expr)
  puts "  movq $#{expr.intval}, %rax"
end

def generate_code(expr)
  puts "  .global main"
  puts "main:"
  generate_expr(expr)
  puts "  ret"
end

def main
  @source = gets
  @tokens = tokenize
  expr = parse
  generate_code(expr)
end

main
