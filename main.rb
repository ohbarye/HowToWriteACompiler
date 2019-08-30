source = ''
source_index = 0

def get_char
  return if source_index == source.size
  char = source[source_index]
  source_index += 1
  char
end

def unget_char
  source_index -=1
end

def main
  source = gets
  puts "  .global main"
  puts "main:"
  puts "  movq $#{source}, %rax"
  puts "  ret"
end

main
