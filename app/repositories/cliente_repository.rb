require_relative "../../db/database"
require_relative "../models/cliente"

class ClienteRepository
  
  def self.create(cliente)
    Database.connection.execute(
      "INSERT INTO clientes (nome) VALUES (?)",
      [cliente.nome]
    )
  end

  def self.all
    Database.connection.execute("SELECT * FROM clientes").map do |row|
      Cliente.new(
        id: row["id"],
        nome: row["nome"]
      )
    end
  end
end