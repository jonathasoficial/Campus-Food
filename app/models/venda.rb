class Venda
  attr_accessor :id, :cliente_id, :funcionario_id, :data_hora, :valor_total

  def initialize(id: nil, cliente_id:, funcionario_id:, data_hora:, valor_total: 0)
    @id = id
    @cliente_id = cliente_id
    @funcionario_id = funcionario_id
    @data_hora = data_hora
    @valor_total = valor_total
  end
end