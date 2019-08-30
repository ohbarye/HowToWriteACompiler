def main
  source = gets
  puts "  .global main"
  puts "main:"
  puts "  movq $#{source}, %rax"
  puts "  ret"
end

main
