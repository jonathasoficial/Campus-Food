require_relative "../../db/database"
require_relative "../models/venda"

class VendaRepository
  
  def self.create(venda)
    Database.connection.execute(
        "INSERT INTO vendas (cliente_id, funcionario_id, data_hora, valor_total) VALUES (?, ?, ?, ?)",
      [
        venda.cliente_id,
        venda.funcionario_id,
        venda.data_hora,
        venda.valor_total
      ] 
    )
  end

  def self.update_total(venda_id, total)
    Database.connection.execute(
      "UPDATE vendas SET valor_total = ? WHERE id = ?",
      [total, venda_id]
    )
  end

  def self.all 
    Database.connection.execute("SELECT * FROM vendas").map do |row|
      Venda.new(
        id: row["id"],
        cliente_id: row["cliente_id"],
        funcionario_id: row["funcionario_id"],
        data_hora: row["data_hora"],
        valor_total: row["valor_total"]
      )
    end
  end

  def self.historico
    Database.connection.execute <<-SQL
      SELECT
        v.id,
        v.data_hora,
        v.valor_total,
        c.nome AS cliente_nome
      FROM vendas v
      INNER JOIN clientes c ON v.cliente_id = c.id
      ORDER BY v.id ASC
    SQL
  end
end