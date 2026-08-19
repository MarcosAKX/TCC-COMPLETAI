# Identidade “Agilidade urbana” — Especificação aprovada

## 1. Objetivo

Dar identidade própria ao Completai sem alterar seu posicionamento, sua arquitetura de informação ou a paleta azul-cobalto aprovada. A experiência deve comunicar rapidez, confiança e deslocamento local desde o login, preparando o motorista para chegar à tela “Meu combustível”.

## 2. Fluxo principal

Para contas do tipo cliente, a jornada prioritária é:

```text
Login → Meu combustível → Perfil público do posto
```

Ao restaurar uma sessão válida de cliente, o aplicativo continua direcionando para “Meu combustível”. Contas de posto mantêm o direcionamento para o dashboard administrativo.

## 3. Personalidade

Direção: **agilidade urbana e energia**.

O produto deve parecer:

- rápido, sem ser apressado;
- local, sem usar regionalismo artificial;
- tecnológico, sem aparência bancária ou de SaaS genérico;
- confiável, sem excesso de formalidade;
- energético, sem neon, gradientes ou ruído visual.

## 4. Assinatura visual

A assinatura da marca é uma **linha de rota com pontos de passagem terminando em uma bomba de combustível**.

Ela representa a sequência real da experiência: localização local, decisão e abastecimento. Sua forma deve ser simples, geométrica e reproduzível com primitives do Flutter, sem depender de imagem raster.

### Regras de uso

- Login: aplicação principal, em branco sobre fundo azul-cobalto.
- Cadastro e recuperação: versão reduzida no cabeçalho ou no progresso.
- Estados vazios: versão curta em azul sobre superfície clara.
- Descoberta: não repetir a ilustração completa; a faixa “Meu combustível” já funciona como assinatura da tela.
- Perfis, configurações e dashboard: usar somente detalhes derivados, como waypoint, linha curta ou ícone final, quando houver função estrutural.
- Nunca usar como textura repetida, marca d'água ou decoração atrás de texto.

## 5. Paleta preservada

| Papel | Token | Valor |
|---|---|---|
| Marca e ação principal | `primary` | `#315EFB` |
| Preço comum | `price` | `#3559C7` |
| Fundo principal | `background` | `#F6F7F9` |
| Fundo contextual da descoberta | novo token `discoveryBackground` | `#E8EEFF` |
| Card e campo | `card` | `#FFFFFF` |
| Texto principal | `textLight` | `#1B1D22` |
| Texto secundário | `textMuted` | `#747A85` |
| Melhor valor | `savings` | `#079B68` |
| Aberto/sucesso | `green` | `#237A47` |
| Avaliação | `rating` | `#D88710` |
| Erro/fechado | `error` | `#C9362B` |
| Contorno | `outline` | `#E7E9ED` |

O azul continua sendo a única cor de marca. Verde, âmbar e vermelho permanecem estritamente semânticos.

## 6. Login

### Estrutura

```text
┌────────────────────────────────┐
│ Completai!                     │
│ Seu próximo abastecimento      │
│ começa aqui                    │
│     ○────○────────── bomba     │
├────────────────────────────────┤
│  ┌──────────────────────────┐  │
│  │ Entre na sua conta       │  │
│  │ E-mail                   │  │
│  │ Senha                    │  │
│  │ [ Entrar ]               │  │
│  │ Esqueci minha senha      │  │
│  └──────────────────────────┘  │
│ Ainda não tem uma conta?       │
│ [ Criar conta ]                │
└────────────────────────────────┘
```

### Comportamento

- Cabeçalho azul ocupa aproximadamente 35–40% da altura antes de considerar teclado aberto.
- Formulário branco sobrepõe parcialmente o cabeçalho e o fundo azul-gelo.
- Ação principal “Entrar” permanece com 52 dp e largura total.
- “Esqueci minha senha” é ação textual secundária.
- “Criar conta” usa botão contornado e não compete com “Entrar”.
- Ao abrir o teclado, o cabeçalho reduz ou sai parcialmente da viewport; campos e ação principal permanecem acessíveis sem overflow.
- Loading substitui o conteúdo do botão sem mudar sua largura.
- Erros continuam humanos e passam a aparecer próximos ao campo quando forem específicos.

### Conteúdo aprovado

- Marca: “Completai!”
- Mensagem: “Seu próximo abastecimento começa aqui”
- Título do formulário: “Entre na sua conta”
- Apoio inferior: “Preços locais para decisões mais rápidas”

## 7. Aplicação nas demais telas

### Escolha de conta

- Cabeçalho compacto com marca e trecho curto da rota.
- Cards “Sou motorista” e “Represento um posto” permanecem brancos.
- O ícone da bomba identifica a opção posto; a identidade não depende só da cor.

### Cadastros e recuperação

- `StepProgressHeader` incorpora a lógica de rota: pontos concluídos, atual e futuro.
- Não desenhar uma segunda barra de progresso concorrente.
- Formulários continuam em superfície clara com botão azul principal.

### Meu combustível

- Fundo superior permanece claro.
- Busca permanece branca.
- Seletor de combustível ocupa faixa azul-cobalto de largura total.
- Opção ativa usa cápsula branca com texto e ícone azuis.
- Opções inativas usam branco com contraste suficiente.
- Área dos resultados usa `discoveryBackground`.
- Cards de posto permanecem brancos.

### Perfil público do posto

- Prioridade: identidade/status → preços → frescor → serviços → avaliações.
- A faixa lateral azul identifica somente o resultado recomendado na lista, não todos os cards.
- A assinatura de rota não é repetida dentro do perfil.

### Perfis e configurações

- Avatar e ícones azuis criam continuidade.
- Seções usam cards brancos sobre fundo claro.
- Ações destrutivas continuam vermelhas e isoladas.

### Dashboard do posto

- Azul identifica ações e navegação.
- Verde continua reservado ao melhor valor e sucesso.
- Atualização de preços permanece a tarefa visual principal.
- A assinatura pode aparecer apenas no cabeçalho vazio ou onboarding administrativo.

## 8. Componentes

### Novos

- `UrbanRouteSignature`: linha, waypoints e bomba; variantes `hero`, `compact` e `emptyState`.
- `BrandHeroPanel`: cabeçalho azul do login com marca, mensagem e assinatura.
- `AuthSurfaceCard`: superfície compartilhada dos formulários de autenticação.

### Atualizados

- `BrandHeader`: recebe variante compacta alinhada à nova identidade.
- `StepProgressHeader`: adota waypoints derivados da rota.
- `FuelChoiceSelector`: recebe variante sobre superfície azul.
- `WelcomeSummaryHeader`: ajusta composição para a nova divisão da descoberta.
- `CustomTextField`: mantém contrato funcional e melhora erro inline/foco.
- `CustomButton`: mantém altura e loading, com foco e estado desabilitado explícitos.

## 9. Movimento

- A rota pode ser revelada uma vez ao abrir o login, em duração curta de 300–450 ms.
- Não animar continuamente a bomba, os waypoints ou a marca.
- Transições de seleção podem usar 150–200 ms.
- Com redução de movimento ativa, renderizar imediatamente o estado final.

## 10. Acessibilidade

- Contraste mínimo WCAG AA para textos e controles.
- Alvos interativos mínimos de 48×48 dp.
- A assinatura é decorativa e deve ser excluída da árvore semântica.
- Progresso de cadastro precisa de descrição textual, não apenas pontos.
- Estados ativo, aberto, melhor valor e erro nunca dependem somente da cor.
- Login deve funcionar com teclado, leitor de tela e escala de fonte de 200%.
- Formulário não pode perder o botão “Entrar” quando o teclado estiver aberto.

## 11. Limites

- Não criar logo final nesta etapa; “Completai!” continua como wordmark tipográfico.
- Não adicionar login social, geolocalização, fotos ou novos dados.
- Não usar gradientes, glassmorphism, glow, neon ou ilustrações genéricas de cidade.
- Não aplicar a rota completa em todas as telas.
- Não transformar azul-gelo em fundo de todos os contextos; ele identifica descoberta e continuidade da autenticação.
- Não mudar regras Firebase, modelo de dados ou navegação de papéis neste lote visual.

## 12. Verificação e aceite

- Testes de widgets para variantes novas e estados do formulário.
- Teste de navegação: cliente autenticado chega a “Meu combustível”; posto chega ao dashboard.
- Teste de overflow com teclado e fontes ampliadas.
- Verificação de contraste dos tokens.
- `flutter analyze` e `flutter test` sem falhas.
- Inspeção em Android nos tamanhos compacto e grande.
- Login, cadastro, recuperação e descoberta devem parecer partes da mesma marca sem repetir a mesma composição.

