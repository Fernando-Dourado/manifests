# Exemplo de Terraform com Função Sensitive

Este exemplo demonstra o uso da função `sensitive()` no Terraform para proteger dados sensíveis.

## O que é a função sensitive()?

A função `sensitive()` marca valores como sensíveis, impedindo que sejam exibidos em:

- Logs do Terraform
- Output do `terraform plan` e `terraform apply`
- Mensagens de erro
- Estado do Terraform (quando usado em outputs)

## Estrutura do Exemplo

### Variáveis Sensíveis

- `db_password`: Marcada como `sensitive = true`
- `api_key`: Marcada como `sensitive = true`

### Locals com Sensitive

- `connection_string`: String de conexão completa marcada como sensível
- `app_config`: Objeto com valores sensíveis
- `environment_vars`: Map com variáveis de ambiente sensíveis

### Outputs

- Outputs sensíveis: Não aparecem no console
- Outputs não sensíveis: Exibidos normalmente
- Uso de `nonsensitive()`: Para expor valores quando necessário

## Como Usar

1. **Copie o arquivo de variáveis:**

   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edite o terraform.tfvars com valores reais:**

   ```bash
   vim terraform.tfvars
   ```

3. **Inicialize o Terraform:**

   ```bash
   terraform init
   ```

4. **Execute o plan:**

   ```bash
   terraform plan
   ```

   Note que valores sensíveis aparecerão como `(sensitive value)` no output.

5. **Aplique as mudanças:**

   ```bash
   terraform apply
   ```

## Comportamento Esperado

### Durante o Plan/Apply

```text
# null_resource.example will be created
+ resource "null_resource" "example" {
    + triggers = {
        + password_hash = (known after apply)
        + username      = "admin"
      }
  }
```

### Outputs

```text
Outputs:

api_key_length = 18
db_password = <sensitive>
db_username = "admin"
connection_string = <sensitive>
```

## Boas Práticas

1. **Sempre marque dados sensíveis:** Senhas, tokens, chaves de API
2. **Use variáveis de ambiente:** Para passar valores sensíveis

   ```bash
   export TF_VAR_db_password="senha_secreta"
   export TF_VAR_api_key="chave_api"
   ```

3. **Adicione ao .gitignore:**

   ```text
   terraform.tfvars
   *.tfstate
   *.tfstate.backup
   ```

4. **Use backends seguros:** Para armazenar o state com criptografia

## Função nonsensitive()

Use `nonsensitive()` quando precisar expor um valor que está marcado como sensível:

```hcl
output "example" {
  value = nonsensitive(local.app_config.username)
}
```

⚠️ **Atenção:** Use `nonsensitive()` apenas quando tiver certeza de que o valor não é realmente sensível.
