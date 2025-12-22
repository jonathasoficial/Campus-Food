class RelatorioService
  def self.historico_vendas
    VendaRepository.historico
  end

  def self.faturamento_diario(data)
    resultado = VendaRepository.faturamento_por_dia(data)
    resultado["total"] || 0
  end

  def self.produtos_mais_vendidos
    VendaRepository.produtos_mais_vendidos
  end

  def self.clientes_frequentes
    VendaRepository.clientes_frequentes
  end
end