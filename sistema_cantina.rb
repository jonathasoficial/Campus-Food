require "sqlite3"

# ======================================
# CONFIGURAÇÃO DO BANCO DE DADOS
# ======================================
DB = SQLite3::Database.new("cantina.db")
DB.results_as_hash = true

# ======================================
# CRIAÇÃO DAS TABELAS
# ======================================
DB.execute <<-SQL
CREATE TABLE IF NOT EXISTS clientes (
  id_cliente INTEGER PRIMARY KEY AUTOINCREMENT,
  nome TEXT NOT NULL
);
SQL

DB.execute <<-SQL
CREATE TABLE IF NOT EXISTS produtos (
  id_produto INTEGER PRIMARY KEY AUTOINCREMENT,
  nome TEXT NOT NULL,
  preco REAL NOT NULL,
  tipo TEXT NOT NULL
);
SQL

DB.execute <<-SQL
CREATE TABLE IF NOT EXISTS vendas (
  id_venda INTEGER PRIMARY KEY AUTOINCREMENT,
  data_hora TEXT NOT NULL,
  id_cliente INTEGER,
  valor_total REAL NOT NULL,
  FOREIGN KEY(id_cliente) REFERENCES clientes(id_cliente)
);
SQL

DB.execute <<-SQL
CREATE TABLE IF NOT EXISTS itens_venda (
  id_item INTEGER PRIMARY KEY AUTOINCREMENT,
  id_venda INTEGER,
  id_produto INTEGER,
  quantidade INTEGER,
  preco_unitario REAL,
  FOREIGN KEY(id_venda) REFERENCES vendas(id_venda),
  FOREIGN KEY(id_produto) REFERENCES produtos(id_produto)
);
SQL

# ======================================
# FUNÇÕES AUXILIARES
# ======================================
def limpar_tela
  system("clear") || system("cls")
end

def pausar
  puts "\nPressione ENTER para continuar..."
  gets
end

# ======================================
# CADASTROS
# ======================================
def cadastrar_cliente
  limpar_tela
  print "Nome do cliente: "
  nome = gets.chomp
  DB.execute("INSERT INTO clientes (nome) VALUES (?)", [nome])
  puts "Cliente cadastrado com sucesso!"
  pausar
end

def cadastrar_produto
  limpar_tela
  print "Nome do produto: "
  nome = gets.chomp
  print "Preço: "
  preco = gets.chomp.to_f
  print "Tipo (Salgado/Doce/Bebida): "
  tipo = gets.chomp

  DB.execute(
    "INSERT INTO produtos (nome, preco, tipo) VALUES (?, ?, ?)",
    [nome, preco, tipo]
  )

  puts "Produto cadastrado com sucesso!"
  pausar
end

# ======================================
# REGISTRO DE VENDA (MÚLTIPLOS PRODUTOS)
# ======================================
def registrar_venda
  limpar_tela

  puts "Clientes cadastrados:"
  DB.execute("SELECT * FROM clientes").each do |c|
    puts "#{c['id_cliente']} - #{c['nome']}"
  end

  print "\nID do cliente: "
  id_cliente = gets.chomp.to_i

  data_hora = Time.now.strftime("%Y-%m-%d %H:%M:%S")
  DB.execute(
    "INSERT INTO vendas (data_hora, id_cliente, valor_total) VALUES (?, ?, 0)",
    [data_hora, id_cliente]
  )

  id_venda = DB.last_insert_row_id
  total = 0.0

  loop do
    limpar_tela
    puts "Produtos disponíveis:"
    DB.execute("SELECT * FROM produtos").each do |p|
      puts "#{p['id_produto']} - #{p['nome']} (R$ #{p['preco']})"
    end

    print "\nID do produto (0 para finalizar): "
    id_produto = gets.chomp.to_i
    break if id_produto == 0

    print "Quantidade: "
    quantidade = gets.chomp.to_i

    produto = DB.execute(
      "SELECT * FROM produtos WHERE id_produto = ?",
      [id_produto]
    ).first

    subtotal = produto["preco"] * quantidade
    total += subtotal

    DB.execute(
      "INSERT INTO itens_venda (id_venda, id_produto, quantidade, preco_unitario)
       VALUES (?, ?, ?, ?)",
      [id_venda, id_produto, quantidade, produto["preco"]]
    )
  end

  DB.execute(
    "UPDATE vendas SET valor_total = ? WHERE id_venda = ?",
    [total, id_venda]
  )

  puts "\nVenda registrada com sucesso!"
  puts "Valor total: R$ #{total}"
  pausar
end

# ======================================
# RELATÓRIOS
# ======================================
def listar_vendas
  limpar_tela

  query = <<-SQL
    SELECT v.id_venda, c.nome, v.valor_total, v.data_hora
    FROM vendas v
    INNER JOIN clientes c ON v.id_cliente = c.id_cliente
    ORDER BY v.data_hora DESC
  SQL

  DB.execute(query).each do |v|
    puts "Venda ##{v['id_venda']} | #{v['nome']} | R$ #{v['valor_total']} | #{v['data_hora']}"
  end

  pausar
end

def faturamento_diario
  limpar_tela
  print "Informe a data (AAAA-MM-DD): "
  data = gets.chomp

  total = DB.execute(
    "SELECT SUM(valor_total) AS total FROM vendas WHERE DATE(data_hora) = ?",
    [data]
  ).first

  puts "\nFaturamento do dia #{data}: R$ #{total['total'] || 0}"
  pausar
end

def produtos_mais_vendidos
  limpar_tela
  puts "PRODUTOS MAIS VENDIDOS\n\n"

  query = <<-SQL
    SELECT p.nome,
           SUM(i.quantidade) AS total_vendido
    FROM itens_venda i
    INNER JOIN produtos p ON i.id_produto = p.id_produto
    GROUP BY p.nome
    ORDER BY total_vendido DESC
  SQL

  resultados = DB.execute(query)

  if resultados.empty?
    puts "Nenhuma venda registrada."
  else
    resultados.each_with_index do |p, index|
      puts "#{index + 1}. #{p['nome']} - #{p['total_vendido']} unidades"
    end
  end

  pausar
end

def clientes_com_desconto
  limpar_tela
  puts "CLIENTES FREQUENTES (POR CONSTÂNCIA)\n\n"

  query = <<-SQL
    SELECT c.nome,
           COUNT(DISTINCT DATE(v.data_hora)) AS dias
    FROM vendas v
    INNER JOIN clientes c ON v.id_cliente = c.id_cliente
    GROUP BY c.nome
    ORDER BY dias DESC
  SQL

  DB.execute(query).each do |c|
    desconto =
      if c["dias"] >= 20
        "20% de desconto"
      elsif c["dias"] >= 10
        "10% de desconto"
      else
        "Sem desconto"
      end

    puts "#{c['nome']} - #{c['dias']} dias → #{desconto}"
  end

  pausar
end

# ======================================
# MENUS
# ======================================
MENU = <<~MENU
  ---------------------------------
          CAMPUS FOOD
  ---------------------------------
  1 - Cadastrar Cliente
  2 - Cadastrar Produto
  3 - Registrar Venda
  4 - Relatórios
  5 - Sair
  ---------------------------------
MENU

MENU_RELATORIOS = <<~MENU
  ---------------------------------
           RELATÓRIOS
  ---------------------------------
  1 - Listar Vendas
  2 - Faturamento Diário
  3 - Produtos Mais Vendidos
  4 - Clientes Frequentes / Desconto
  5 - Voltar
  ---------------------------------
MENU

# ======================================
# CONTROLE DE MENUS
# ======================================
def menu_principal
  loop do
    limpar_tela
    puts MENU
    print "Escolha uma opção: "
    op = gets.chomp.to_i

    case op
    when 1 then cadastrar_cliente
    when 2 then cadastrar_produto
    when 3 then registrar_venda
    when 4
      loop do
        limpar_tela
        puts MENU_RELATORIOS
        print "Escolha uma opção: "
        r = gets.chomp.to_i

        case r
        when 1 then listar_vendas
        when 2 then faturamento_diario
        when 3 then produtos_mais_vendidos
        when 4 then clientes_com_desconto
        when 5 then break
        else
          puts "Opção inválida!"
          pausar
        end
      end
    when 5
      puts "Sistema encerrado."
      break
    else
      puts "Opção inválida!"
      pausar
    end
  end
end

# ======================================
# INICIALIZAÇÃO
# ======================================
limpar_tela
puts "Bem-vindo ao CAMPUS FOOD!"
pausar
menu_principal
