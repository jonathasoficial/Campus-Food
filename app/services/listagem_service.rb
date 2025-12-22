class ListagemService
  def self.listar_clientes
    ClienteRepository.all
  end

  def self.listar_funcionarios
    FuncionarioRepository.all
  end

  def self.listar_produtos
    ProdutoRepository.all
  end
end