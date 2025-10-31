# Exemplo de uso da função sensitive() no Terraform
# A função sensitive() marca valores como sensíveis para evitar que sejam exibidos em logs

terraform {
  required_version = ">= 1.0"
}

# Variáveis de entrada
variable "db_password" {
  description = "Senha do banco de dados"
  type        = string
  sensitive   = true
}

variable "api_key" {
  description = "Chave de API"
  type        = string
  sensitive   = true
}

variable "db_username" {
  description = "Nome de usuário do banco de dados"
  type        = string
  default     = "admin"
}

# Local values com dados sensíveis
locals {
  # Marcando uma string de conexão como sensível
  connection_string = sensitive("postgresql://${var.db_username}:${var.db_password}@localhost:5432/mydb")
  
  # Configurações de aplicação com dados sensíveis
  app_config = {
    username = var.db_username
    password = sensitive(var.db_password)
    api_key  = var.api_key
  }
  
  # Combinando valores sensíveis e não sensíveis
  environment_vars = {
    DB_HOST     = "localhost"
    DB_PORT     = "5432"
    DB_USER     = var.db_username
    DB_PASSWORD = sensitive(var.db_password)
    API_KEY     = var.api_key
  }
}

# Outputs demonstrando o uso de sensitive
output "db_username" {
  description = "Nome de usuário (não sensível)"
  value       = var.db_username
}

output "db_password" {
  description = "Senha do banco (sensível - não será exibida)"
  value       = var.db_password
  sensitive   = true
}

output "connection_string" {
  description = "String de conexão completa (sensível)"
  value       = local.connection_string
  sensitive   = true
}

output "api_key_length" {
  description = "Tamanho da API key (informação derivada não sensível)"
  value       = length(nonsensitive(var.api_key))
}

# Exemplo: Usando nonsensitive() para expor dados quando necessário
output "db_username_from_sensitive" {
  description = "Extraindo valor não sensível de um contexto sensível"
  value       = nonsensitive(local.app_config.username)
}

# Recurso de exemplo usando valores sensíveis
resource "null_resource" "example" {
  triggers = {
    # Valores não sensíveis podem ser usados normalmente
    username = var.db_username
    # Valores sensíveis não aparecerão nos logs do Terraform
    password_hash = sha256(var.db_password)
  }

  provisioner "local-exec" {
    command = "echo 'Configuração aplicada (senha oculta nos logs)'"
    
    environment = {
      DB_USER = var.db_username
      # A senha não será exibida nos logs
      DB_PASS = var.db_password
    }
  }
}
