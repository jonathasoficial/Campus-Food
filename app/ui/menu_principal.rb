def menu_principal
  loop do
    limpar_console
    puts MENU
    print "Escolha uma opção: "
    op = gets.chomp.to_i

    case op
    when 1 
      loop do
        limpar_console
        puts MENU_CLIENTES
        print "Escolha uma opção: "
        c = gets.chomp.to_i

        case c
        when 1 then cadastrar_cliente
        when 2 then listar_clientes
        when 3 then break
        else
          puts "Opção inválida!"
          pausar_console
        end
      end

    when 2
      loop do
        limpar_console
        puts MENU_PRODUTOS
        print "Escolha uma opção: "
        p = gets.chomp.to_i

        case p
        when 1 then cadastrar_produto
        when 2 then listar_produtos
        when 3 then break
        else
          puts "Opção inválida!"
          pausar_console
        end
      end 
    when 3 
      loop do
        limpar_console
        puts MENU_FUNCIONARIOS
        print "Escolha uma opção: "
        f = gets.chomp.to_i

        case f
        when 1 then cadastrar_funcionario
        when 2 then listar_funcionarios
        when 3 then break
        else
          puts "Opção inválida!"
          pausar_console
        end
      end
    when 4 then registrar_venda
    when 5
      loop do
        limpar_console
        puts MENU_RELATORIOS
        print "Escolha uma opção: "
        r = gets.chomp.to_i

        case r
        when 1 then listar_vendas
        when 2 then faturamento_diario
        when 3 then produtos_mais_vendidos
        when 4 then clientes_frequentes
        when 5 then break
        else
          puts "Opção inválida!"
          pausar_console
        end
      end

    when 6
      puts "Sistema encerrado."
      break
    else
      puts "Opção inválida!"
      pausar_console
    end
  end
end
