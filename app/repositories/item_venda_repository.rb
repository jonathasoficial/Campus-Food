require_relative "../../db/database"
require_relative "../models/item_venda"

class ItemVendaRepository
  
  def self.create(item)
    Database.connection.execute(
      "INSERT INTO itens_venda (venda_id, produto_id, quantidade, preco_unitario) VALUES (?, ?, ?, ?)",
      [
        item.venda_id,
        item.produto_id,
        item.quantidade,
        item.preco_unitario
      ]
    )
  end

  def self.find_by_venda(venda_id)
    Database.connection.execute(
      "SELECT * FROM itens_venda WHERE venda_id = ?",
      [venda_id]
    ).map do |row|
      ItemVenda.new(
        id: row["id"],
        venda_id: row["venda_id"],
        produto_id: row["produto_id"],
        quantidade: row["quantidade"],
        preco_unitario: row["preco_unitario"]
      )
    end
  end
end