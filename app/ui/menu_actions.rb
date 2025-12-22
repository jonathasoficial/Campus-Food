# CLIENTES
def cadastrar_cliente
  limpar_console
  print "Nome do cliente: "
  nome = gets.chomp
  Database.connection.execute("INSERT INTO clientes (nome) VALUES (?)", [nome])
  puts "Cliente cadastrado com sucesso!"
  pausar_console
end

def listar_clientes
  limpar_console
  puts "CLIENTES CADASTRADOS\n\n"

  clientes = Database.connection.execute("SELECT * FROM clientes")

  if clientes.empty?
    puts "Nenhum cliente cadastrado."
  else
    clientes.each do |c|
      puts "ID: #{c['id']} - Nome: #{c['nome']}"
    end
  end
  pausar_console
end

# FUNCIONÁRIOS
def cadastrar_funcionario
  limpar_console
  print "Nome do funcionário: "
  nome = gets.chomp
  Database.connection.execute("INSERT INTO funcionarios (nome) VALUES (?)", [nome])
  puts "Funcionário cadastrado com sucesso!"
  pausar_console
end

def listar_funcionarios
  limpar_console
  puts "FUNCIONÁRIOS CADASTRADOS\n\n"

  funcionarios = Database.connection.execute("SELECT * FROM funcionarios")

  if funcionarios.empty?
    puts "Nenhum funcionário cadastrado."
  else
    funcionarios.each do |f|
      puts "ID: #{f['id']} - Nome: #{f['nome']}"
    end
  end
  pausar_console
end

# PRODUTOS
def cadastrar_produto
  limpar_console
  print "Nome do produto: "
  nome = gets.chomp
  print "Preço: "
  preco = gets.chomp.to_f
  print "Tipo (Salgado/Doce/Bebida): "
  tipo = gets.chomp

  Database.connection.execute(
    "INSERT INTO produtos (nome, preco, tipo) VALUES (?, ?, ?)",
    [nome, preco, tipo]
  )

  puts "Produto cadastrado com sucesso!"
  pausar_console
end

def listar_produtos
  limpar_console
  puts "PRODUTOS CADASTRADOS\n\n"

  produtos = Database.connection.execute("SELECT * FROM produtos")

  if produtos.empty?
    puts "Nenhum produto cadastrado."
  else
    produtos.each do |p|
      puts "ID: #{p['id']} - Nome: #{p['nome']} - Preço: R$ #{p['preco']} - Tipo: #{p['tipo']}"
    end
  end

  pausar_console
end

# VENDAS
def registrar_venda
  limpar_console

  # ===============================
  # LISTAR CLIENTES
  # ===============================
  puts "Clientes cadastrados:"
  Database.connection.execute("SELECT * FROM clientes").each do |c|
    puts "#{c['id']} - #{c['nome']}"
  end

  print "\nID do cliente: "
  cliente_id = gets.chomp.to_i

  # ===============================
  # LISTAR FUNCIONÁRIOS
  # ===============================
  limpar_console
  puts "Funcionários cadastrados:"
  Database.connection.execute("SELECT * FROM funcionarios").each do |f|
    puts "#{f['id']} - #{f['nome']}"
  end

  print "\nID do funcionário: "
  funcionario_id = gets.chomp.to_i

  # ===============================
  # CRIAR VENDA
  # ===============================
  data_hora = Time.now.strftime("%Y-%m-%d %H:%M:%S")

  Database.connection.execute(
    "INSERT INTO vendas (cliente_id, funcionario_id, data_hora, valor_total)
     VALUES (?, ?, ?, 0)",
    [cliente_id, funcionario_id, data_hora]
  )

  venda_id = Database.connection.last_insert_row_id
  total = 0.0

  # ===============================
  # INSERIR ITENS DA VENDA
  # ===============================
  loop do
    limpar_console
    puts "Produtos disponíveis:"
    Database.connection.execute("SELECT * FROM produtos").each do |p|
      puts "#{p['id']} - #{p['nome']} (R$ #{p['preco']})"
    end

    print "\nID do produto (0 para finalizar): "
    produto_id = gets.chomp.to_i
    break if produto_id == 0

    print "Quantidade: "
    quantidade = gets.chomp.to_i

    produto = Database.connection.execute(
      "SELECT * FROM produtos WHERE id = ?",
      [produto_id]
    ).first

    subtotal = produto["preco"] * quantidade
    total += subtotal

    Database.connection.execute(
      "INSERT INTO itens_venda (venda_id, produto_id, quantidade, preco_unitario)
       VALUES (?, ?, ?, ?)",
      [venda_id, produto_id, quantidade, produto["preco"]]
    )
  end

  # ===============================
  # ATUALIZAR TOTAL DA VENDA
  # ===============================
  Database.connection.execute(
    "UPDATE vendas SET valor_total = ? WHERE id = ?",
    [total, venda_id]
  )

  # ===============================
  # FINALIZAÇÃO
  # ===============================
  puts "\nVenda registrada com sucesso!"
  puts "Total da venda: R$ #{'%.2f' % total}"
  pausar_console
end


# RELATÓRIOS
def listar_vendas
  limpar_console

  vendas = Database.connection.execute <<-SQL
    SELECT v.id, v.data_hora, v.valor_total, c.nome AS cliente
    FROM vendas v
    INNER JOIN clientes c ON v.cliente_id = c.id
    ORDER BY v.id ASC
  SQL

  if vendas.empty?
    puts "Nenhuma venda registrada."
    pausar_console
    return
  end

  vendas.each do |v|
    puts "Venda ##{v['id']}"
    puts "Cliente: #{v['cliente']}"
    puts "Data: #{v['data_hora']}"
    puts "Total da venda: R$ #{'%.2f' % v['valor_total']}"
    puts "-" * 40
  end

  pausar_console
end

def faturamento_diario
  limpar_console

  print "Informe a data (DD/MM/AAAA): "
  entrada = gets.chomp
  data = Date.strptime(entrada, "%d/%m/%Y").strftime("%Y-%m-%d")

  total = Database.connection.execute(
    "SELECT SUM(valor_total) AS total FROM vendas WHERE DATE(data_hora) = ?",
    [data]
  ).first

  puts "\nFaturamento do dia #{entrada}: R$ #{'%.2f' % (total['total'] || 0)}"
  pausar_console
end

def produtos_mais_vendidos
  limpar_console
  puts "PRODUTOS MAIS VENDIDOS\n\n"

  query = <<-SQL
    SELECT p.nome, SUM(i.quantidade) AS total
    FROM itens_venda i
    INNER JOIN produtos p ON i.produto_id = p.id
    GROUP BY p.nome
    ORDER BY total DESC
  SQL

  resultados = Database.connection.execute(query)

  if resultados.empty?
    puts "Nenhum produto vendido ainda."
  else
    resultados.each_with_index do |p, i|
      puts "#{i + 1}. #{p['nome']} - #{p['total']} unidades"
    end
  end

  pausar_console
end

def clientes_frequentes
  limpar_console
  puts "CLIENTES FREQUENTES\n\n"

  query = <<-SQL
    SELECT c.nome, COUNT(v.id) AS total_vendas
    FROM vendas v
    INNER JOIN clientes c ON v.cliente_id = c.id
    GROUP BY c.nome
    ORDER BY total_vendas DESC
  SQL

  resultados = Database.connection.execute(query)

  if resultados.empty?
    puts "Nenhum cliente realizou compras."
  else
    resultados.each do |c|
      puts "#{c['nome']} - #{c['total_vendas']} vendas"
    end
  end

  pausar_console
end