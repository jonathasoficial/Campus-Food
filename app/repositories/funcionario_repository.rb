require_relative "../../db/database"
require_relative "../models/funcionario"

class FuncionarioRepository

  def self.create(funcionario)
    Database.connection.execute(
      "INSERT INTO funcionarios (nome) VALUES (?)",
      [funcionario.nome]
    )
  end

  def self.all
    Database.connection.execute("SELECT * FROM funcionarios").map do |row|
      Funcionario.new(
        id: row["id"],
        nome: row["nome"]
      )
    end
  end
end