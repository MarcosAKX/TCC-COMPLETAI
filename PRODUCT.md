# Product

<!-- impeccable:product-schema 1 -->

## Platform

android

## Users

- Motoristas de Bebedouro que precisam comparar preço, qualidade e disponibilidade antes de abastecer.
- Profissionais dependentes do veículo, como entregadores, taxistas e autônomos, para quem preço e rapidez têm impacto direto na renda.
- Responsáveis por postos de Bebedouro que mantêm preços, horários, serviços e dados públicos.

## Product Purpose

Completai organiza informações locais de combustíveis para reduzir custo e incerteza na decisão de abastecimento. Sucesso depende de preços atualizados, cobertura dos postos ativos, participação comunitária e experiência simples no celular.

Critérios declarados no TAP: usuários ativos mensais, engajamento, catálogo de postos ativos e margem de erro inferior a 5% nos preços. Método de medição, metas numéricas de MAU/engajamento e fonte de verdade dos preços permanecem decisões abertas.

## Positioning

Comparação local de postos de Bebedouro combina preço por combustível, status aberto/fechado, frescor da atualização e reputação comunitária. Decisão acontece em uma única experiência, sem geolocalização ou transação financeira.

## Operating Context

- Uso principal em celular, frequentemente durante deslocamento e com pouco tempo.
- Postos atualizam dados manualmente pela área administrativa.
- Clientes consultam, filtram, favoritam, avaliam e denunciam.
- Firebase Authentication e Cloud Firestore sustentam identidade e dados.
- Testes e demonstrações pertencem ao ambiente acadêmico.

## Capabilities and Constraints

- Escopo geográfico: Bebedouro; expansão para outras cidades não faz parte do projeto acadêmico atual.
- Sem venda de combustível, pagamentos, fidelidade, geolocalização ou integração com software interno de postos.
- Preços só podem ser alterados por contas administrativas verificadas; implementação atual ainda não garante essa restrição de segurança.
- O fluxo planejado exige aprovação de um usuário administrador após análise do CNPJ e do e-mail do posto. Até essa etapa ser implementada, cadastro e publicação imediatos representam comportamento provisório de desenvolvimento.
- A sequência de entrega aprovada prioriza concluir as telas do cliente e do posto; aprovação administrativa, endurecimento das rules e testes no Emulator permanecem obrigatórios antes de declarar o produto pronto para produção ou para uso público.
- Ranking atual usa histórico bayesiano; ranking semanal citado no TAP ainda não existe.
- Android é plataforma de entrega confirmada. Web presente no repositório deve servir somente ao desenvolvimento/demonstração ou ser removida do escopo entregue.
- Ferramentas devem permanecer dentro dos limites gratuitos previstos.

## Brand Commitments

- Nome: Completai!
- Personalidade aprovada: confiança profissional com proximidade local.
- Linguagem direta, humana e séria; nunca burocrática, gamer ou promocional sem evidência.
- Informação e transparência dominam decoração.

## Evidence on Hand

- TAP: `C:/Users/Marcos/Downloads/TAP-TERMO DE ABERTURA DE PROJETO 2026.docx`.
- Análise técnica: `docs/`.
- Implementação Flutter e regras Firebase no repositório.
- Não existem logo final, fotografia oficial, pesquisa com usuários, analytics, depoimentos ou fonte externa de validação de preços. Trabalho futuro não deve inventá-los.

## Product Principles

1. Preço atualizado deve ser compreendido em segundos.
2. Confiança exige origem, frescor e limites claros dos dados.
3. Tarefa diária do posto deve exigir mínimo esforço.
4. Comunidade contribui sem controlar dados administrativos.
5. Escopo acadêmico e restrições do TAP vencem expansão oportunista.

## Accessibility & Inclusion

- WCAG AA como piso de contraste.
- Alvos Android mínimos de 48×48 dp.
- Fluxos principais utilizáveis por teclado/leitor de tela e com escala de fonte ampliada.
- Estados não dependem apenas de cor.
- Movimento respeita configuração de remoção/redução de animações.
