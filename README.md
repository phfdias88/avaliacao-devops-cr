# Infraestrutura como Código (IaC) - AWS



# Projeto de API em Node.js com CI/CD

Este é um projeto de exemplo de uma API em Node.js com um pipeline de CI/CD usando GitHub Actions.

## Como usar

1. Clone o repositório:
   \`\`\`bash
   git clone $githubRepo
   \`\`\`

2. Instale as dependências:
   \`\`\`bash
   npm install
   \`\`\`

3. Execute o build:
   \`\`\`bash
   npm run build
   \`\`\`

4. Inicie a API:
   \`\`\`bash
   npm start
   \`\`\`

## Pipeline CI/CD

O pipeline inclui os seguintes passos:
- Instalação de dependências
- Execução de testes
- Build do projeto
- Deploy

O pipeline é acionado automaticamente ao fazer push para a branch \`main\` ou ao abrir um pull request.
"@