@source = ''
@source_index = 0

Token = Struct.new(:kind, :value)

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
  puts "# Tokens : "

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
      puts "# '#{token.value}'"
    else
      throw "tokenizer: Invalid char: '#{char}'"
    end
  end

  puts
  tokens
end

def main
  @source = gets
  tokens = tokenize
  first_token = tokens.first
  puts "  .global main"
  puts "main:"
  puts "  movq $#{first_token.value}, %rax"
  puts "  ret"
end

main
