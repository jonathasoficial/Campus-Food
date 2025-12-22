class VendaService
  def self.criar_venda(cliente_id, funcionario_id, itens)
    venda = Venda.new(
      cliente_id: cliente_id,
      funcionario_id: funcionario_id,
      data_hora: Time.now.to_s,
      valor_total: 0
    )

    VendaRepository.create(venda)
    venda_id = Database.connection.last_insert_row_id

    total = 0

    itens.each do |item|
      subtotal = item[:preco] * item[:quantidade]
      total += subtotal

      ItemVendaRepository.create(
        ItemVenda.new(
          venda_id: venda_id,
          produto_id: item[:produto_id],
          quantidade: item[:quantidade],
          preco_unitario: item[:preco]
        )
      )
    end

    VendaRepository.update_total(venda_id, total)
    total
  end
end
