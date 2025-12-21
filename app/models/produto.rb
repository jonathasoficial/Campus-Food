class Produto 
  attr_accessor :id, :nome, :preco, :tipo

  def initialize(id: nil, nome:, preco:, tipo:)
    @id = id
    @nome = nome
    @preco = preco
    @tipo = tipo
  end
end