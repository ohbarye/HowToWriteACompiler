@source = ''
@source_index = 0
@tokens = []
@token_index = 0

Token = Struct.new(
    :kind,  # "intliteral", "punct"
    :value,
)

Expr = Struct.new(
    :kind,     # "intliteral", "unary", "binary"
    :intval,   # for intliteral
    :operator, # "-", "+"
    :operand,  # for unary
    :left,     # for binary
    :right,    # for binary
)

def get_token
  return if @token_index == @tokens.size
  token = @tokens[@token_index]
  @token_index += 1
  token
end

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
    when ';', '+', '-', '*'
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
  token = get_token
  case token.kind
  when 'intliteral'
    Expr.new('intliteral', token.value, nil, nil)
  when 'punct'
    operator = token.value
    operand = parse_unary_expr
    Expr.new('unary', nil, operator, operand)
  else
    nil
  end
end

def parse
  expr = parse_unary_expr
  while true
    token = get_token
    return expr if token.nil? || token.value == ';'

    case token.value
    when '+', '-', '*'
      left = expr
      right = parse_unary_expr
      return Expr.new('binary', nil, token.value, nil, left, right)
    else
      return expr
    end
  end
end

def generate_expr(expr)
  case expr.kind
  when 'intliteral'
    puts "  movq $#{expr.intval}, %rax"
  when 'unary'
    case expr.operator
    when '-'
      puts "  movq $-#{expr.operand.intval}, %rax"
    when '+'
      puts "  movq $#{expr.operand.intval}, %rax"
    else
      throw "generator: Unknown unary operator: #{expr.operator}"
    end
  when 'binary'
    puts "  movq $#{expr.left.intval}, %rax"
    puts "  movq $#{expr.right.intval}, %rcx"

    case expr.operator
    when '+'
      puts "  addq %rcx, %rax"
    when '-'
      puts "  subq %rcx, %rax"
    when '*'
      puts "  imulq %rcx, %rax"
    else
      throw "generator: Unknown binary operator: #{expr.operator}"
    end
  else
    throw "generator: Unknown expr.kind: #{expr.kind}"
  end
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
