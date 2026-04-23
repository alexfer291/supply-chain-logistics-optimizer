# 🚚 Supply Chain & Logistics Optimizer: Do SQL ao Power BI

Este projeto apresenta uma solução completa de **Data Analytics** para uma operação logística global. Utilizei dados de 19 plantas industriais e múltiplos modais para construir um ecossistema de dados capaz de diagnosticar custos, performance de entrega (SLA) e gargalos de capacidade.

![Dashboard Executivo](img/executivo.png)

## 🛠️ Tecnologias e Arquitetura
*   **Banco de Dados:** PostgreSQL (Migração e Modelagem).
*   **Engenharia de Dados:** SQL (DBeaver / pgAdmin4).
*   **Business Intelligence:** Power BI Desktop.
*   **Metodologia:** Camada de dados (Views) para otimização de performance.

---

## 🏗️ Engenharia de Dados (O Coração do Projeto)

A base de dados bruta apresentava desafios complexos de limpeza e granularidade. Minhas principais contribuições técnicas no SQL foram:

*   **Deduplicação de Fretes (`DISTINCT ON`):** Implementei uma lógica para selecionar o menor tempo de trânsito em rotas duplicadas, evitando a inflação de custos no Dashboard.
*   **Normalização de Strings (`Regex`):** Conversão de valores monetários de texto ($) para numéricos decimais via `REGEXP_REPLACE`.
*   **Tratamento de Granularidade:** Criação de uma camada de agregação para comparar Pedidos Únicos (`DISTINCTCOUNT`) vs. Capacidade Nominal, corrigindo distorções de escala entre itens e ordens.
*   **Gestão de Exceções (`COALESCE`):** Tratamento de transportadoras descontinuadas e modelos de retirada direta (CRF).

> [!TIP]
> Confira os scripts SQL detalhados na pasta `/sql` deste repositório.

---

## 📊 Business Insights e Dashboards

O relatório foi estruturado em três pilares estratégicos para facilitar a tomada de decisão:

### 1. Visão Executiva (Cockpit)
Foco em KPIs de alto nível como **Custo Total**, **Volume de Pedidos** e **OTIF Global**. Através de análises de dispersão, identifiquei que o modal **Ground** (Rodoviário) entrega com maior adiantamento que o **Air** (Aéreo), apesar do custo elevado.

### 2. Malha Logística e Escoamento
Utilizei uma **Matriz de Calor (Heatmap)** para mapear o fluxo entre Unidades Produtivas e Portos de Origem. Esta visão revelou que a **PLANT16** é o principal pilar de escoamento da operação.

![Malha Logística](img/malha.png)

### 3. Auditoria e Diagnóstico de Riscos
Uma página dedicada à governança de dados e gestão de exceções:
*   **Gargalos Produtivos:** Alertas visuais para plantas operando acima de 100% da capacidade (ex: PLANT03 e 08).
*   **Análise de Severidade de Atraso:** Histograma que separa pequenos desvios de falhas logísticas graves.
*   **Gap de Cobertura:** Auditoria de ordens sem tarifa de frete contratada, expondo riscos financeiros.

![Diagnóstico de Riscos](img/diagnostico.png)

---

## 🧠 Conclusão de Negócio
O projeto demonstrou que a operação possui um excelente **SLA (97%)**, porém sob alto risco operacional. A sobrecarga extrema em fábricas específicas e a falta de cobertura tarifária em certas rotas indicam oportunidades imediatas de redistribuição de carga e formalização de novos contratos logísticos para redução de custos.

---

## 🛠️ Como reproduzir este projeto

1. **Clone este repositório:**  
   `git clone https://github.com`

2. **Prepare o Banco de Dados:**  
   Importe o arquivo `backup_banco.sql` no seu **PostgreSQL** para recriar a estrutura do banco e as Views.

3. **Conecte o Power BI:**  
   Abra o arquivo `.pbix` no **Power BI Desktop**, vá em *Transformar Dados > Configurações da Fonte de Dados* e atualize o servidor para o seu `localhost`.

4. **Atualize os Dados:**  
   Clique em **Obter Dados** (ou Atualizar) para carregar as informações do seu banco local para o dashboard.
