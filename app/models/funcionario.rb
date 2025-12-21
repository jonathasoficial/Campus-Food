class Funcionario 
  attr_accessor :id, :nome

  def initialize(id: nil, nome:)
    @id = id
    @nome = nome
  end
end