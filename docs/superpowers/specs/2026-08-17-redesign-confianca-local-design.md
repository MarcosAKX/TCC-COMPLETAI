# Redesign “Confiança Local” — Design Spec

**Status:** aprovado conceitualmente; aguardando revisão deste documento antes do plano técnico.

## 1. Objetivo

Elevar interface Completai de MVP funcional para produto Android profissional, confiável e intuitivo, preservando fluxos, domínio, restrição geográfica e regras do TAP. Meta de avaliação pós-implementação: 78–85/100, partindo de 58/100.

## 2. Público e situação

Motorista consulta app com pouco tempo para decidir onde abastecer. Dono de posto atualiza preços com frequência e precisa concluir tarefa sem percorrer perfil inteiro. Interface opera em modo **Operate**: conclusão rápida, previsível e segura vence expressão visual.

## 3. Direção escolhida

**Confiança local:** 80% confiança profissional, 20% proximidade comunitária.

- profissional sem aparência bancária ou governamental;
- local sem estética artesanal ou informal;
- informativo sem parecer planilha;
- energético sem neon, glow gamer ou excesso de movimento.

Direção foi escolhida explicitamente pelo usuário. Alternativas rejeitadas:

- institucional: confiança alta, porém fria e distante para público geral;
- premium automotiva: impacto alto, porém elitista e menos inclusiva.

## 4. Princípios visuais

### Cor

Paleta oficial aprovada: **Azul-noite + Âmbar combustível**. Valores abaixo são sementes do `ColorScheme`; views consomem papéis semânticos, nunca estes hex diretamente.

| Papel | Semente aprovada |
|---|---|
| fundo | `#0B1118` |
| superfície | `#131C26` |
| superfície elevada | `#1B2734` |
| azul principal | `#3278A8` |
| azul interativo | `#4294CC` |
| âmbar da marca | `#F2B84B` |
| sucesso/aberto | `#32B875` |
| erro/fechado | `#E05D65` |
| texto principal | `#F4F7FA` |
| texto secundário | `#9CAAB8` |
| borda | `#2B3A49` |

Distribuição visual aproximada: 70% fundo/superfícies, 20% texto/neutros, 7% azul interativo e até 3% de âmbar, verde ou vermelho. Âmbar identifica marca, combustível, preço em foco e destaques raros. Verde fica reservado para sucesso, economia e posto aberto; nunca atua como decoração geral.

Proibidos: gradiente azul/roxo decorativo, verde neon, ciano em tags, glow, glassmorphism e múltiplos acentos competindo na mesma região.

Dark theme continua como esquema principal na primeira etapa. Light theme fica fora do primeiro lote, mas tokens não podem impedir implementação futura.

### Tipografia

- escala Material: headline, title, body e label;
- preço usa maior peso e tamanho da área de decisão;
- corpo e labels priorizam leitura; sem tamanhos escolhidos isoladamente por tela;
- números tabulares quando disponibilidade da fonte permitir.

### Forma e elevação

- raio consistente por categoria de componente;
- borda e elevação tonal substituem sombras arbitrárias;
- evitar card dentro de card;
- ações destrutivas mantêm separação e confirmação.

### Movimento

- movimento curto e funcional: mudança de estado, expansão e confirmação;
- remover pulso infinito do login;
- respeitar configuração Android de remoção de animações.

## 5. Arquitetura da experiência

### Assinatura: Painel de preço confiável

Interface deve continuar reconhecível sem logotipo. Assinatura nasce de informação, não ornamento:

- preço é elemento dominante;
- data/frescor aparece junto do valor;
- estados usam textos como “Atualizado hoje” e “Preço antigo”;
- números possuem alinhamento e ritmo consistentes;
- marcador linear discreto pode remeter a painel/medidor de combustível;
- verde indica economia ou confirmação, nunca identidade genérica.

Acabamento combina estrutura utilitária do Uber, ritmo de conteúdo do Spotify e linguagem humana do iFood, sem copiar paleta, componentes, navegação ou marca desses produtos.

### Login e cadastro

- marca compacta e estável; nenhum glow pulsante;
- formulário com erro inline, autofill e ação correta do teclado;
- senha com mostrar/ocultar;
- telefone e CNPJ formatados durante digitação;
- stepper persistente no cadastro de posto;
- etapa final resume dados anteriores e permite voltar para corrigir;
- mensagens técnicas ficam em logs, nunca na UI.

### Lista de postos

Ordem de leitura:

1. contexto “Postos em Bebedouro”;
2. busca;
3. combustível e ordenação;
4. resultados;
5. acesso a perfil/configurações.

Card prioriza:

- nome e bairro;
- preço do combustível selecionado;
- status aberto/fechado;
- avaliação;
- data/frescor da atualização.

Tags e serviços ficam secundários. Geolocalização/distância não será simulada, pois está fora do TAP.

Busca e combustível selecionado permanecem acessíveis durante exploração. Melhor oportunidade recebe destaque moderado, sem transformar resultado em anúncio.

### Perfil público

Hierarquia:

1. nome, status e avaliação;
2. preços e atualização;
3. horários;
4. serviços;
5. avaliações;
6. denúncia discreta.

Favoritar permanece acessível. Avaliar possui ação clara, sem competir com preço.

### Dashboard do posto

Preço diário vira tarefa dominante:

- bloco “Atualizar preços” no primeiro viewport;
- salvar preço sem percorrer demais seções;
- confirmação específica: “Preços atualizados para os clientes”;
- dirty state e aviso antes de sair;
- horário, serviços, tags e perfil em seções recolhíveis com resumo;
- ação “aplicar aos dias úteis” reduz repetição;
- nenhuma alteração administrativa é salva silenciosamente sem feedback.

Meta operacional: proprietário atualiza preços cotidianos em menos de 30 segundos, desconsiderando latência externa.

### Perfil e configurações

- compartilhar componentes entre cliente e posto quando comportamento for igual;
- dados editáveis usam formulário padrão;
- logout separado visualmente de exclusão;
- exclusão mostra progresso e mantém confirmação/reautenticação.

## 6. Estados obrigatórios

Cada superfície de dados deve definir:

- loading inicial;
- atualização em andamento;
- vazio com próximo passo;
- erro com recuperação;
- sucesso contextual;
- offline/cache quando detectável;
- texto longo/overflow;
- escala de fonte ampliada;
- alteração não salva, quando aplicável.

## 7. Componentes e regras permanentes

Criar sistema compartilhado para:

- botões filled, tonal, outlined e text;
- campos de texto e senha;
- app bars;
- chips de filtro e status;
- cards de posto e preço;
- blocos de estado;
- dialogs/bottom sheets;
- tokens de cor, tipografia, espaço, forma e duração.

Regras:

1. nenhuma cor hex local em view, salvo exceção documentada;
2. nenhum tamanho tipográfico arbitrário em view;
3. alvos mínimos 48×48 dp e espaçamento mínimo 8 dp;
4. sistema Back, insets e teclado Android sempre respeitados;
5. feedback de erro aparece junto da origem;
6. estado nunca comunicado apenas por cor;
7. componente novo entra no sistema somente se reutilizável;
8. cada alteração de UI atualiza documentação e regras visuais;
9. `firestore.rules` só muda quando dados/autorização exigirem;
10. nenhuma função fora do TAP entra por conveniência visual.

### Anti-padrões de aparência genérica

- nenhum card sem função de agrupamento, interação ou hierarquia;
- nenhum ícone decorativo dentro de quadrado colorido por padrão;
- nenhum texto aspiracional genérico ou alegação sem evidência;
- nenhuma animação que não explique mudança, relação ou confirmação;
- nenhum skeleton diferente da geometria real do conteúdo;
- nenhuma simetria artificial que prejudique prioridade da tarefa;
- conteúdo de demonstração usa contexto plausível de Bebedouro e deve ser identificado como sintético quando não vier do banco real.

## 8. Responsividade

- prioridade: telefone Android compacto e médio;
- layout suporta orientação e largura expandida sem esticar cards indefinidamente;
- tablet não recebe telefone ampliado: conteúdo usa largura máxima e navegação adaptada quando aplicável;
- texto deve funcionar com escala de fonte 1,3 e revisão manual a 200% onde plataforma permitir.

## 9. Acessibilidade

- contraste WCAG AA;
- Semantics/labels para ações e estados;
- ordem de foco coerente;
- teclado e leitor de tela nos fluxos centrais;
- touch targets Material 3;
- reduced motion;
- mensagens curtas, específicas e acionáveis.

## 10. Limites

Permanece intacto neste redesign:

- domínio Firebase e regras de negócio, salvo correção necessária para suportar UI;
- restrição Bebedouro;
- ausência de geolocalização, pagamentos e fidelidade;
- modelo atual de avaliação geral no primeiro lote;
- dark theme como entrega inicial.

Não inventar logo final, imagens, depoimentos, métricas ou alegações comerciais.

## 11. Estratégia de implementação

Ordem:

1. segurança bloqueadora e testes de rules necessários ao papel de posto;
2. tokens/tema e componentes fundamentais;
3. formulários de autenticação/cadastro;
4. lista e perfil público;
5. dashboard administrativo;
6. perfil/configurações;
7. acessibilidade, responsividade e acabamento;
8. `DESIGN.md` gerado a partir da implementação final;
9. docs e matriz TAP atualizadas em cada lote.

## 12. Verificação e aceite

- `flutter analyze` sem issues;
- testes unitários/widget e Firebase Emulator para regras afetadas;
- captura Android em telefone; tablet somente se declarado alvo de entrega;
- revisão em dark theme e fonte ampliada;
- fluxo principal por teclado/leitor de tela;
- revisão Impeccable final;
- código, `DESIGN.md`, docs técnicas e TAP sem divergência conhecida não registrada.

## 13. Decisões abertas controladas

- fonte da métrica de precisão inferior a 5%; não bloqueia redesign;
- ranking semanal versus histórico; não será alterado sem decisão de produto;
- logo final; primeira etapa usa marca tipográfica/ícone existente de forma contida;
- light theme; adiado, sem bloquear tokens semânticos.
