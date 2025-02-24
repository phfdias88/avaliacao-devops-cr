# Configurações iniciais
$projectName = "minha-api-nodejs"
$githubRepo = "https://github.com/seu-usuario/seu-repositorio.git"
$nodeVersion = "18"

# Cria o diretório do projeto
Write-Host "Criando diretório do projeto..." -ForegroundColor Green
New-Item -ItemType Directory -Path $projectName
Set-Location $projectName

# Inicializa o projeto Node.js
Write-Host "Inicializando projeto Node.js..." -ForegroundColor Green
npm init -y

# Instala dependências
Write-Host "Instalando dependências..." -ForegroundColor Green
npm install express
npm install --save-dev webpack webpack-cli jest

# Cria a estrutura de arquivos
Write-Host "Criando estrutura de arquivos..." -ForegroundColor Green
New-Item -ItemType Directory -Path src
Set-Content -Path src/index.js -Value @"
const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.send('Hello World!');
});

app.listen(port, () => {
  console.log(\`API rodando em http://localhost:\${port}\`);
});
"@

Set-Content -Path webpack.config.js -Value @"
const path = require('path');

module.exports = {
  entry: './src/index.js',
  output: {
    filename: 'bundle.js',
    path: path.resolve(__dirname, 'dist'),
  },
  mode: 'production',
};
"@

Set-Content -Path src/test.js -Value @"
const sum = (a, b) => a + b;
test('adds 1 + 2 to equal 3', () => {
  expect(sum(1, 2)).toBe(3);
});
"@

# Atualiza o package.json com scripts
Write-Host "Atualizando package.json..." -ForegroundColor Green
$packageJson = Get-Content -Path package.json -Raw | ConvertFrom-Json
$packageJson.scripts = @{
  "build" = "webpack";
  "start" = "node dist/bundle.js";
  "test" = "jest";
}
$packageJson | ConvertTo-Json -Depth 10 | Set-Content -Path package.json

# Inicializa o Git
Write-Host "Inicializando repositório Git..." -ForegroundColor Green
git init
git add .
git commit -m "Primeiro commit: Projeto Node.js básico"

# Cria o arquivo .gitignore
Set-Content -Path .gitignore -Value @"
node_modules/
dist/
.env
"@

# Configura o GitHub Actions
Write-Host "Configurando GitHub Actions..." -ForegroundColor Green
New-Item -ItemType Directory -Path .github/workflows
Set-Content -Path .github/workflows/ci-cd.yml -Value @"
name: CI/CD Pipeline

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

jobs:
  build-and-test:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Set up Node.js
        uses: actions/setup-node@v3
        with:
          node-version: $nodeVersion

      - name: Install dependencies
        run: npm install

      - name: Run tests
        run: npm test

      - name: Build project
        run: npm run build

      - name: Deploy (exemplo simples)
        run: echo 'Deploy realizado com sucesso!'
"@

# Cria o README.md
Write-Host "Criando README.md..." -ForegroundColor Green
Set-Content -Path README.md -Value @"
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
- Deploy (exemplo simples)

O pipeline é acionado automaticamente ao fazer push para a branch \`main\` ou ao abrir um pull request.
"@

# Commit final
Write-Host "Fazendo commit final..." -ForegroundColor Green
git add .
git commit -m "Adiciona pipeline CI/CD com GitHub Actions e README"

# Conecta ao repositório remoto (substitua pelo seu repositório)
Write-Host "Conectando ao repositório remoto do GitHub..." -ForegroundColor Green
git remote add origin $githubRepo
git branch -M main
git push -u origin main

Write-Host "Projeto configurado com sucesso!" -ForegroundColor Green
