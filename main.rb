require_relative "config/environment"

Schema.create_tables

# 1. Cria a venda (valor_total começa 0)
venda = Venda.new(
  cliente_id: 1,
  funcionario_id: 1,
  data_hora: Time.now.to_s,
  valor_total: 0
)

VendaRepository.create(venda)
venda_id = Database.connection.last_insert_row_id

# 2. Lista de produtos vendidos
itens = [
  { produto_id: 1, quantidade: 2, preco_unitario: 5.00 },
  { produto_id: 2, quantidade: 1, preco_unitario: 3.50 },
  { produto_id: 3, quantidade: 3, preco_unitario: 2.00 }
]

total = 0

# 3. Cria os itens da venda
itens.each do |i|
  item = ItemVenda.new(
    venda_id: venda_id,
    produto_id: i[:produto_id],
    quantidade: i[:quantidade],
    preco_unitario: i[:preco_unitario]
  )

  ItemVendaRepository.create(item)

  total += i[:quantidade] * i[:preco_unitario]
end

# 4. Atualiza o total da venda
VendaRepository.update_total(venda_id, total)

puts "Venda realizada com sucesso!"
puts "Total da venda: R$ #{'%.2f' % total}"
