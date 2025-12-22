require 'sqlite3'
require 'date'

require_relative "../db/database"
require_relative "../db/schema"

# HELPERS
require_relative "../app/helpers/console_helper"

# MODELS
require_relative "../app/models/cliente"
require_relative "../app/models/funcionario"
require_relative "../app/models/produto"
require_relative "../app/models/venda"
require_relative "../app/models/item_venda"

# REPOSITORIES
require_relative "../app/repositories/cliente_repository"
require_relative "../app/repositories/funcionario_repository"
require_relative "../app/repositories/produto_repository"
require_relative "../app/repositories/venda_repository"
require_relative "../app/repositories/item_venda_repository"

# SERVICES
require_relative "../app/services/listagem_service"
require_relative "../app/services/relatorio_service"

# UI
require_relative "../app/ui/menu_actions"
require_relative "../app/ui/menu_principal"
require_relative "../app/ui/menus"
