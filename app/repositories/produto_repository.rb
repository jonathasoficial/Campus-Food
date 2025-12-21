require_relative "../../db/database"
require_relative "../models/produto"

class ProdutoRepository

  def self.create(produto)
    Database.connection.execute(
      "INSERT INTO produtos (nome, preco, tipo) VALUES (?, ?, ?)",
      [produto.nome, produto.preco, produto.tipo]
    )
  end

  def self.all
    Database.connection.execute("SELECT * FROM produtos").map do |row|
      Produto.new(
        id: row["id"],
        nome: row["nome"],
        preco: row["preco"],
        tipo: row["tipo"]
      )
    end
  end
end