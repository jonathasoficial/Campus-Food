class CadastroService
  def self.cadastrar_cliente(nome)
    cliente = Cliente.new(nome: nome)
    ClienteRepository.create(cliente)
  end

  def self.cadastrar_produto(nome, preco, tipo)
    produto = Produto.new(nome: nome, preco: preco, tipo: tipo)
    ProdutoRepository.create(produto)
  end

  def self.cadastrar_funcionario(nome)
    funcionario = Funcionario.new(nome: nome)
    FuncionarioRepository.create(funcionario)
  end
end