class ItemVenda
  attr_accessor :id, :venda_id, :produto_id, :quantidade, :preco_unitario

  def initialize(id: nil, venda_id:, produto_id:, quantidade:, preco_unitario:)
    @id = id
    @venda_id = venda_id
    @produto_id = produto_id
    @quantidade = quantidade
    @preco_unitario = preco_unitario
  end

  def subtotal
    @quantidade * @preco_unitario
  end
end