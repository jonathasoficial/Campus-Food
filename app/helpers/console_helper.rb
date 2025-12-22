module ConsoleHelper
  def limpar_console
    system("clear") || system("cls")
  end

  def pausar_console
    puts "\nPressione ENTER para continuar..."
    gets
  end
end

include ConsoleHelper