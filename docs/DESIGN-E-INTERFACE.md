# Design e interface

## Padrão global “Ágil e inteligente” — 18/08/2026

Direção aprovada aplicada ao tema e às 12 telas existentes. Manrope tornou-se a única família tipográfica. Valores comuns usam azul médio `#3559C7`; melhor valor usa verde `#079B68`; avaliações usam âmbar próprio. Aliases antigos que confundiam economia, avaliação e marca foram removidos.

A descoberta agora mostra Gasolina, Etanol e Diesel em todos os cards. Combustível selecionado usa superfície/contorno; o menor valor válido usa verde e “Melhor valor”. A faixa azul lateral passou a existir somente no resultado recomendado. O card abre o perfil público; o avatar do cabeçalho abre o perfil do usuário.

Foram adicionados `AppUserAvatar`, `StationLogo`, `FuelPriceGrid`, `SectionCard` e `SettingsTile`. Logo usa iniciais ou ícone como fallback; upload e campo de imagem continuam fora do escopo. Perfil público recebeu identidade com espaço de logo e seção “Todos os preços”. Perfis e dashboard herdaram o mesmo sistema sem alterar serviços ou Firestore.

`firestore.rules` foi revisado e permaneceu intacto: a migração não adicionou campo, coleção, escrita ou autorização. Autoridade durável: `DESIGN.md`. Especificação: `docs/superpowers/specs/2026-08-18-app-wide-agile-intelligent-design.md`.

Verificação automatizada do lote: 55 arquivos formatados sem mudança pendente, `flutter analyze --no-pub` sem issues, 33 testes aprovados e APK debug gerado em `build/app/outputs/flutter-apk/app-debug.apk`. Inspeção visual Android permanece pendente e não é substituída por essas verificações.

As seções anteriores deste arquivo são históricas e ficam substituídas quando contradisserem o padrão global acima.

## Histórico substituído — “Meu combustível” inicial — 18/08/2026

Nova direção aprovada para implementação: base neutra pura, azul-cobalto para marca/interação, verde-esmeralda somente para melhor valor e faixa azul lateral como assinatura dos cards. Descoberta passa a ser orientada por um seletor de combustível; cada card fechado mostra um preço dominante e oferece acesso aos demais.

O diferencial de usabilidade é escolher Gasolina, Etanol ou Diesel uma vez e comparar toda a lista no mesmo contexto. Filtro “Só abertos” complementa a tarefa sem substituir busca ou estados vazios. Distância e economia estimada continuam proibidas sem dados reais.

Especificação completa: `docs/superpowers/specs/2026-08-18-redesign-meu-combustivel-design.md`. Autoridade durável: `DESIGN.md`.

`firestore.rules` não muda: preferência de combustível será local e redesign não altera dados, autorização ou validação de segurança.

### Implementação — 18/08/2026

- tema global migrou para neutros puros, azul-cobalto e verde-esmeralda;
- `FuelChoice` centraliza chaves e rótulos de Gasolina, Etanol e Diesel;
- busca, filtro “Só abertos” e ranking por preço são funções puras testadas;
- lista mantém seletor acima da rolagem e mostra um preço dominante por card;
- faixa azul lateral identifica resultados sem substituir rótulos;
- “Melhor valor” usa verde e texto;
- preços restantes abrem em bottom sheet Material;
- refresh, erro, vazio e navegação para perfil foram preservados.

O lote não adicionou distância, economia estimada, geolocalização, favoritos na navegação ou persistência remota de preferência. `firestore.rules` foi revisado e permaneceu intacto.

Verificação: `flutter analyze --no-pub` sem issues, 28 testes aprovados e APK debug gerado. O Pixel 6 configurado iniciou, mas ficou offline durante a instalação; portanto, esta rodada não inclui homologação por captura Android real.

## Histórico substituído — implementação clara e acolhedora — 17/08/2026

Tema global migrou para marfim quente, superfícies claras, azul-petróleo institucional e tipografia mais calma. Lista ganhou cabeçalho com quantidade real, resumo calculado de melhor preço e destaque do primeiro resultado. Perfil público ganhou origem/frescor e somente um preço dominante. Dashboard detecta preços alterados e publica dentro da própria tarefa.

Histórico semanal e distância não foram adicionados: projeto não possui fonte adequada. Foto/logo real do posto é oportunidade melhor que ícone, mas depende de origem confiável ou upload; fotografia fictícia é proibida. `firestore.rules` foi revisado e não mudou porque lote não altera dados, validação ou autorização.

Autoridade das próximas telas: `DESIGN.md` e `lib/core/theme/app_theme.dart`.

## Reavaliação do redesenho — 17/08/2026

**Nota atual: 58/100** (23/40 nas heurísticas de Nielsen). Redesenho melhorou consistência técnica, legibilidade e semântica de cores, mas não resolveu composição, personalidade nem carga cognitiva. Resultado segue específico no conteúdo e genérico na linguagem visual: dashboard dark funcional, ainda sem assinatura própria de combustível, economia local e confiança.

Prioridades: decompor megaformulário administrativo; dar domínio visual a preço/frescor; reduzir repetição de cards; criar salvamento persistente e estado de alterações; tornar cadastro e erros progressivos e contextuais. Trocar novamente apenas a paleta não resolve.

Limite: revisão baseada no código Flutter. Sem captura Android executável nesta rodada; nota não equivale a homologação visual em dispositivo.

## Implementação visual — 17/08/2026

Primeiro lote “Confiança Local” aplicado ao código:

- Material 3 e paleta Azul-noite + Âmbar centralizados em `AppTheme`;
- login sem glow, gradiente ou pulso infinito;
- campos com erro inline, autofill e toggle de senha;
- progresso semântico no cadastro de posto;
- preço e status compartilhados entre lista/perfil/dashboard;
- dashboard inicia administração por “Atualizar preços”;
- cores locais principais migradas para papéis semânticos;
- regras duráveis registradas em `DESIGN.md`.

Esta implementação resolve parte dos achados de consistência, identidade e acessibilidade. Nota não foi recalculada sem captura Android e nova crítica visual em dispositivo.

Method da avaliação original: dual-agent (A: `/root/design_review` · B: `/root/detector_evidence`)

Avaliação `impeccable critique` sobre todas as views Flutter. Assessment A revisou design sem ver detector; Assessment B executou detector/compatibilidade isoladamente.

## Design Health Score

| # | Heurística | Score | Questão principal |
|---:|---|---:|---|
| 1 | Visibilidade do status | 3 | bons loaders/estados; sucesso/erro depende de SnackBar |
| 2 | Sistema e mundo real | 3 | domínio claro; alguns erros expõem Firestore |
| 3 | Controle e liberdade | 2 | sem undo, dirty state ou descarte protegido |
| 4 | Consistência e padrões | 2 | cores/componentes/interações divergem |
| 5 | Prevenção de erros | 2 | validação tardia e pouca orientação inline |
| 6 | Reconhecimento, não memória | 3 | labels boas; megaform exige lembrar mudanças |
| 7 | Flexibilidade e eficiência | 2 | sem batch/autosave/atalhos administrativos |
| 8 | Estética e minimalismo | 3 | lista clara; dashboard denso |
| 9 | Diagnóstico e recuperação | 2 | mensagens nem sempre indicam campo/ação |
| 10 | Ajuda e documentação | 1 | ausência de ajuda contextual/FAQ |
| **Total** |  | **23/40** | **Aceitável; melhoria significativa necessária** |

## Veredito de especificidade

**Específico no conteúdo, genérico na linguagem visual.** Lista/perfil respondem perguntas próprias do abastecimento — aberto, preço, atualização, serviços e confiança. Visual base é dark SaaS intercambiável: navy, cards arredondados, azul e verde. Identidade fragmenta entre `primary` azul, `green`, verde neon local e ciano de tags.

Detector Impeccable retornou `[]` e exit 0, mas isso significa **zero cobertura**, não interface limpa. Scanner não aceita `.dart`; suporta tecnologias web baseadas em markup/JS. Browser também ficou indisponível porque toolchain Flutter não publicou URL durante timeout. Avaliação é source-based, sem alegar screenshot/overlay.

## O que funciona

- cards da lista concentram nome/local/status, nota, atributos e preços com boa leitura;
- loading, erro com retry, vazio contextual e pull-to-refresh estão presentes;
- zona de perigo usa confirmação e reautenticação;
- botão compartilhado tem alvo confortável de 52 px;
- perfil público prioriza dados decisivos: preço, horário, serviços e reviews.

## Prioridades

### P1 — validação desconectada do campo

`CustomTextField` usa `TextField`, sem `errorText`, validator, visibilidade de senha, autofill ou submit. Erro aparece por SnackBar e força usuário a procurar campo culpado.

**Direção:** `Form`/`TextFormField`, erros inline, foco no primeiro inválido, toggle de senha, `autofillHints`, ações de teclado e anúncio semântico.

### P1 — dashboard como megaform

Uma rolagem expõe resumo, cinco preços, seis tags, oito serviços, sete dias e um salvar final. Sem dirty state, autosave, proteção ao sair ou resumo das mudanças.

**Direção:** preço como ação dominante; seções colapsáveis com resumo; save persistente/por seção; aplicar horário aos dias úteis; confirmação ao descartar.

### P1 — sistema visual incompleto

Tema tem poucos tokens; arquivos usam cores hex, raios e cards locais. Marca `C!`, raio neon e ícone de raio não formam gramática consistente.

**Direção:** tokens semânticos de superfície/borda/estado/foco/tipografia/espaço; definir papel de azul, verde, amarelo e vermelho; motivo visual ligado a preço/localização/combustível.

### P2 — progresso de cadastro incoerente

Escolha informa “Passo 1 de 2”, mas fluxo do posto perde stepper e etapa final não resume dados anteriores.

**Direção:** stepper persistente, resumo editável, conservação do estado e confirmação antes de abandonar.

### P2 — linguagem técnica

Mensagens sobre Firestore/rules quebram confiança.

**Direção:** texto humano com próximo passo; código/detalhe somente em telemetria.

## Carga cognitiva e jornada

Dashboard falha em foco por tarefa, progressive disclosure e memória de trabalho. Cadastro em duas telas cria ponte de memória. Pico positivo acontece na descoberta: cards respondem rapidamente onde abastecer e por quê. Vale negativo aparece em cadastro/administração longos. Encerramento deveria comunicar impacto — “clientes já veem preços atualizados” — não apenas “salvo”.

## Personas

- **Alex, proprietário experiente:** atualização diária item a item; falta ação em lote, duplicação de horários e atalho de preço.
- **Jordan, primeiro acesso:** critérios e erros não ficam junto dos inputs; progresso desaparece.
- **Sam, teclado/leitor de tela:** `GestureDetector` como link, seletores customizados e animação infinita sem redução de movimento.
- **Casey, móvel/distraído:** formulário longo salva no fim e pode perder mudanças após interrupção.
- **Riley, stress:** overflow desigual em perfis, inputs longos e restauração/navegação sem proteção.

## Responsividade e acessibilidade

Há `SafeArea`, `SingleChildScrollView`, `Expanded`, ellipsis e touch targets razoáveis em várias telas. Faltam evidências/testes sistemáticos para:

- 200% de escala de texto;
- landscape/tablet/desktop;
- teclado e foco completo;
- contraste WCAG;
- `Semantics` e anúncios de estado;
- reduced motion;
- strings longas e RTL.

## Run Notes

- target slug: `lib-features`;
- ignore list: ausente;
- assessments: independentes;
- CLI detector: executado uma vez, exit 0/`[]`, incompatível com Dart;
- browser/overlay: indisponíveis, servidor Flutter não publicou URL;
- live server Impeccable: não iniciado;
- servidor Flutter de avaliação: encerrado; porta 7357 livre;
- temporários: nenhum;
- snapshot separado `.impeccable`: não criado; este documento é arquivo solicitado pelo projeto.

## Perguntas de produto

- Sem logotipo, qual detalhe faria Completai ser reconhecido?
- Preço diário deveria ser ação instantânea em vez de parte do perfil inteiro?
- Bebedouro é produto ou primeira cidade?
- Depois de salvar, qual benefício concreto deve ser reforçado ao posto?
# Reavaliação do redesenho — 17/08/2026

## Veredito

Nota atual: **58/100** (23/40 nas heurísticas de Nielsen). O redesenho melhorou consistência técnica, legibilidade e semântica das cores, mas não resolveu composição, personalidade nem carga cognitiva. Resultado permanece específico no conteúdo e genérico na linguagem visual: parece um dashboard dark funcional, não uma experiência inevitavelmente ligada a combustível, economia local e confiança.

## Problemas prioritários

1. **P1 — Megaformulário administrativo:** preços, tags, serviços e horários aparecem juntos; salvar fica distante e não existe estado de alterações pendentes.
2. **P1 — Identidade pouco autoral:** azul-noite e âmbar são adequados, porém aplicados como tokens de sistema. Falta assinatura visual ligada a preço, posto, trajeto ou economia.
3. **P1 — Validação e recuperação fracas:** formulários ainda dependem de feedback transitório e nem sempre conduzem foco ao campo incorreto.
4. **P2 — Cadastro fragmentado:** progresso e contexto entre etapas permanecem inconsistentes.
5. **P2 — Densidade e repetição:** excesso de cards, blocos e controles dá peso uniforme a informações com importância diferente.

## Direção recomendada

Não trocar novamente apenas a paleta. Primeiro redesenhar hierarquia e composição das três superfícies críticas: lista de postos, perfil público e atualização administrativa. Preservar confiança profissional, adicionando caráter local com parcimônia. Preço deve ser elemento dominante; frescor e origem dos dados devem sustentar confiança; tarefas administrativas devem usar progressão, resumo e salvamento persistente.

## Limite da avaliação

Revisão baseada no código Flutter. Inspeção visual Android não foi concluída: nenhum dispositivo/emulador respondeu e o servidor web não publicou URL durante a tentativa. Portanto, nota é diagnóstico estrutural e visual de fonte, não homologação por captura de tela.
