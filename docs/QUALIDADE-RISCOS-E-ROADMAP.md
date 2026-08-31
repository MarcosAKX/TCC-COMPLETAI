# Qualidade, riscos e roadmap

## Evidência de qualidade

### Redesign Confiança Local

Testes adicionados para tema, touch target, erro/toggle de senha, marca sem animação, progresso semântico, preço formatado e status sem dependência exclusiva de cor. Revisão executável Android continua pendente por ausência de dispositivo conectado durante implementação.

### Análise estática

Analisador Dart direto concluiu:

```text
Analyzing lib, test...
No issues found!
```

Processo terminou com exit 1 somente ao tentar gravar telemetria fora do sandbox (`AppData/Roaming/.dart-tool`); diagnóstico de código foi limpo.

### Testes

`test/validation_test.dart` cobre oito cenários:

- login válido/inválido;
- cadastro de cliente válido/inválido;
- recuperação de e-mail;
- cadastro de posto em duas etapas;
- ranking bayesiano.

`flutter test` não concluiu: quatro processos Dart anteriores mantinham locks do SDK. Nenhum processo do usuário foi encerrado. Resultado dos testes: **não verificado nesta revisão**.

### Cobertura ausente

- services Firebase;
- regras Firestore com Emulator Suite;
- widgets e navegação;
- estados de loading/erro/vazio;
- atualização privada+pública;
- exclusão/rollback;
- horários cruzando meia-noite e entradas inválidas;
- acessibilidade e golden tests;
- paginação/cache/offline.

## Registro de riscos

| ID | Sev. | Risco | Prob. | Impacto |
|---|---|---|---|---|
| SEC-01 | P0 | cliente cria papel/perfil de posto | alta | controle indevido e publicação falsa |
| DATA-01 | P1 | subcoleções sobrevivem à exclusão | alta | retenção indevida e dados órfãos |
| PERF-01 | P1 | N+1 de reviews por posto | alta ao crescer | custo, latência e quota |
| ARCH-01 | P1 | telas >1.000 linhas com múltiplas responsabilidades | alta | regressões e testes difíceis |
| UX-01 | P1 | dashboard ainda sem dirty state/autosave, apesar de preço priorizado | média | perda de trabalho e abandono |
| QA-01 | P1 | rules sem testes automatizados | alta | vulnerabilidade regressiva |
| DATA-02 | P2 | horários/listas pouco validados | média | documento inválido e UI quebrada |
| PLATFORM-01 | P2 | runners sem Firebase configurado | certa | app falha fora de Android/Web |
| DOC-01 | P2 | README padrão | certa | onboarding técnico ruim |
| A11Y-01 | P2 | sem auditoria executável | média | barreiras de acesso |
| SCOPE-01 | P1 | metas do TAP não mensuráveis | alta | sucesso acadêmico não demonstrável |
| SCOPE-02 | P2 | Web configurada apesar de restrição mobile | média | divergência documental |

## Roadmap recomendado

### Sequência de execução aprovada para o TCC

1. Concluir as telas e os fluxos visuais do cliente e do posto.
2. Preparar catálogo demonstrativo sem criar contas falsas nem gravar automaticamente no Firebase real.
3. Implementar solicitação pendente, análise de CNPJ/e-mail e decisão do usuário administrador.
4. Mover a concessão do papel de posto para backend confiável e exigir esse papel nas rules.
5. Executar testes de autorização no Firebase Emulator antes da banca e de qualquer uso público.

Essa sequência organiza o trabalho, mas não altera a prioridade técnica de `SEC-01`: durante as etapas 1 e 2, o cadastro atual continua provisório e o produto não está pronto para produção.

### Fase 0 — bloquear riscos de segurança

1. Escrever testes de rules que reproduzam escalada cliente → posto.
2. Mover provisionamento de papel/posto para backend confiável.
3. Exigir custom claim nas rules.
4. Implementar exclusão recursiva/anônima conforme política.
5. Validar horários, tags e serviços completamente nas rules.

Critério de saída: usuário cliente não cria/edita recursos de posto; deleção tem teste de subcoleções; suite Emulator verde.

### Fase 1 — escala e observabilidade

1. Persistir `averageRating`/`reviewCount` com transação/Cloud Function.
2. Consultar `public_stations` por cidade no servidor e paginar.
3. Adicionar App Check e métricas de reads/writes/erros.
4. Criar gateways injetáveis e testes de services.

Critério: número de reads por página não cresce com `postos × reviews`.

### Fase 2 — arquitetura de apresentação

1. Extrair estado/casos de uso do dashboard.
2. Dividir seções, dialogs e cards em componentes testáveis.
3. Unificar perfil cliente/posto onde comportamento coincide.
4. Adotar navegação tipada com guards.

Critério: views coordenam renderização; regras e Firebase não ficam espalhados em widgets.

### Fase 3 — UX e design system

1. Criar tokens semânticos e componentes de form.
2. Tornar preço ação principal do posto.
3. Adicionar dirty state, save persistente e descarte protegido.
4. Corrigir stepper/copy e remover erros técnicos.
5. Testar acessibilidade, escala de texto e breakpoints.

Critério: fluxo principal funciona teclado-only, a 200% de texto e em mobile/tablet; erros são inline e recuperáveis.

### Fase 4 — produto e plataformas

1. Decidir expansão além de Bebedouro e modelar cidade/UF.
2. Configurar Firebase apenas nas plataformas realmente suportadas ou remover runners não suportados.
3. Atualizar README com setup, emulators, rules e execução.
4. Definir CI para analyze, test, rules e build.
5. Implementar métricas definidas no TAP: MAU, engajamento e precisão de preços.
6. Resolver requisitos ausentes: ranking semanal, postos ativos e dimensões de avaliação.

## Decisões que precisam de dono

- O usuário administrador aprovará o cadastro e verificará CNPJ/e-mail; ainda faltam implementar a interface e a autoridade confiável que executará essa decisão.
- Reviews sobrevivem à exclusão do cliente, são anonimizadas ou removidas?
- Dados públicos devem ser acessíveis sem autenticação?
- Bebedouro é restrição permanente?
- Quais plataformas entram no produto suportado?
- Qual SLA/frescor esperado para preços?
- Qual fonte permite provar margem de erro inferior a 5%?
- Ranking semanal substitui ou complementa ranking bayesiano histórico?
