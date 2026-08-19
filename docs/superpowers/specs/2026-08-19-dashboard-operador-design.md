# Dashboard do operador — design aprovado

## Objetivo

Transformar o painel do posto em uma rotina operacional curta e inequívoca. A atualização diária de preços deve ser a primeira tarefa, enquanto informações menos frequentes ficam em áreas próprias.

## Estrutura de navegação

O dashboard abre diretamente em **Preços** e usa quatro destinos persistentes:

1. **Preços** — edição e publicação dos cinco combustíveis.
2. **Informações** — resumo cadastral, tags e serviços.
3. **Horários** — funcionamento dos sete dias.
4. **Avaliações** — leitura das avaliações existentes.

Em larguras compactas, os destinos aparecem em uma `NavigationBar` inferior. Em telas largas, a mesma arquitetura pode ser apresentada com navegação lateral, sem mudar a ordem nem os nomes.

## Área de preços

- É a tela inicial do operador.
- Exibe os cinco preços, o valor publicado e a quantidade de alterações pendentes.
- O único CTA é **Publicar preço** ou **Publicar N preços**.
- O CTA fica desabilitado sem mudanças ou durante a publicação.
- Validação ocorre antes da chamada remota e identifica o campo inválido.
- Após sucesso, os valores atuais se tornam a nova referência e a data de atualização é renovada.
- Tags, serviços e horários nunca são enviados ao publicar preços.

## Área de informações

- Mostra nome e endereço com atalho para os dados cadastrais já existentes.
- Agrupa tags e serviços, pois ambos descrevem a oferta do posto e têm frequência de edição semelhante.
- O único CTA da área é **Salvar informações**.
- O botão é habilitado apenas quando tags ou serviços diferem do estado carregado.
- Salvar informações não altera preços nem horários.

## Área de horários

- Mantém os sete dias e os seletores atuais de abertura e fechamento.
- O único CTA é **Salvar horários**.
- O botão é habilitado somente com mudanças.
- Salvar horários não altera preços, tags ou serviços.

## Alterações pendentes e saída

Cada área mantém seu próprio estado de edição. Ao trocar de destino ou tentar sair do dashboard com alterações não salvas na área atual, o app mostra um diálogo com:

- **Continuar editando** — permanece na área atual.
- **Descartar alterações** — restaura o último estado salvo e conclui a navegação.

Não haverá salvamento automático: publicar preços é uma ação sensível e precisa de confirmação explícita. Enquanto uma operação remota estiver em andamento, navegação e CTAs conflitantes ficam bloqueados.

## Persistência

O serviço administrativo será dividido em operações parciais:

- atualização de preços;
- atualização de tags e serviços;
- atualização de horários.

As operações continuam usando o mesmo documento do posto e atualização parcial no Firestore. Isso preserva compatibilidade com os dados existentes e reduz o risco de sobrescrita acidental.

## Feedback e falhas

- Sucesso usa mensagem específica: preços publicados, informações salvas ou horários salvos.
- Erro mantém as alterações locais e permite nova tentativa.
- Carregamento inicial permanece centralizado.
- Um erro de uma seção não limpa nem modifica as outras.

## Acessibilidade e responsividade

- Alvos interativos com pelo menos 48 dp.
- Rótulos sempre combinam ícone e texto; cor não será o único indicador.
- Conteúdo permanece rolável com fontes ampliadas.
- CTA da tarefa fica próximo ao conteúdo e não duplicado no fim de um formulário longo.
- A ordem de foco acompanha a ordem visual.

## Critérios de aceite

- O dashboard abre em Preços.
- Há exatamente um CTA de persistência por área editável.
- Cada CTA grava somente os campos da própria área.
- Todos os estados sujos são detectados por comparação com o último estado carregado ou salvo.
- Trocar de área ou sair com mudanças pendentes exige confirmação.
- Falhas preservam os dados digitados.
- Os testes cobrem navegação, estado sujo, descarte, validação e chamadas parciais.
