# Regras de trabalho — Completai

Estas instruções se aplicam a todo o repositório. Antes de implementar, revisar ou integrar qualquer mudança, leia este arquivo e os documentos canônicos indicados no `README.md`.

## Postura profissional

- Atue como especialista: verifique premissas, exponha riscos e não aprove decisões apenas para concordar com o solicitante.
- Baseie recomendações no código, nos testes e na documentação atual; diferencie evidência, inferência e preferência.
- Preserve mudanças existentes do usuário e não altere arquivos fora do escopo.

## Preparação obrigatória

- Confira `git status`, branch, worktrees e histórico recente antes de editar.
- Leia `PRODUCT.md`, `ARCHITECTURE.md`, `STRUCTURE.md` e `DESIGN.md` conforme o tema da tarefa.
- Para interface, consulte também `docs/DESIGN-E-INTERFACE.md` e preserve o contrato adaptativo documentado.
- Para dados, autenticação ou autorização, consulte `docs/MODELO-DE-DADOS.md`, `docs/REGRAS-DE-NEGOCIO-E-SEGURANCA.md` e `firestore.rules`.

## Implementação

- Mudanças relevantes devem ser isoladas em branch e worktree próprios, salvo instrução explícita em contrário.
- Corrija a causa do problema; evite contornos frágeis e refatorações não relacionadas.
- Preserve regras de negócio, contratos de dados, estados de edição e fluxos já validados.
- Não altere `firestore.rules`, índices, credenciais, dados remotos ou serviços externos sem autorização específica.
- Em trabalhos de front-end, garanta rolagem, fonte ampliada, teclado, orientação, semântica, alvos de toque e reflow por conteúdo.

## Qualidade e verificação

- Para funcionalidades e correções, escreva ou ajuste o teste que demonstra o comportamento antes da implementação sempre que viável.
- Antes de declarar conclusão, execute verificações frescas proporcionais ao risco: testes focados, suíte completa, análise estática e `git diff --check`.
- Não trate testes de widgets puros como substitutos de validação integrada; registre explicitamente o que não foi validado em Android real.
- Mudanças amplas devem receber revisão independente antes da integração.

## Git e integração

- Não faça commit, push, merge, rebase, exclusão de branch ou remoção de worktree sem autorização do usuário.
- Antes de um Pull Request, confirme branch de origem, branch base, worktree limpo e evidências de verificação.
- Use Pull Request para mudanças relevantes e mantenha a descrição alinhada ao que foi realmente testado.
- Nunca force push, descarte mudanças ou use comandos destrutivos sem autorização explícita.

## Documentação

- Atualize os documentos canônicos quando uma mudança alterar arquitetura, estrutura, produto, interface, segurança ou processo.
- Não registre funcionalidades planejadas como se já estivessem implementadas.
- Mantenha instruções curtas, verificáveis e coerentes com o código atual.


teste
