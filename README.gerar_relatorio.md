Script para Geração de Relatório de Failover e Failback
Descrição
Este script em Bash analisa eventos de failover e failback registrados no arquivo de log do Heartbeat e gera um relatório detalhado sobre a ocorrência dessas transições entre servidores. 
Ele processa os logs, extrai informações relevantes e formata os dados de forma organizada para facilitar a análise do desempenho da infraestrutura de alta disponibilidade.

Funcionalidades
Verifica a existência do arquivo de log (/var/log/heartbeat_failover.log).
Analisa os eventos de failover e failback, extraindo IP do servidor, timestamp e tempo de recuperação.
Mantém um histórico dos últimos 10 eventos para cada servidor.
Formata o tempo de recuperação para um formato legível (hh:mm:ss).
Gera um relatório detalhado em /var/log/failover_report.txt, organizando os eventos por servidor.

Servidores Monitorados
O script trabalha com os seguintes servidores pré-configurados:

Windows Server 1 - IP: 192.168.56.10
Windows Server 2 - IP: 192.168.56.11
Oracle Server 1 - IP: 192.168.56.40
Oracle Server 2 - IP: 192.168.56.41
Formato do Relatório
O relatório gerado contém os eventos organizados por servidor, com informações como:

Data e hora do evento
Tempo decorrido até a recuperação
Separação clara entre eventos de failover e failback

Exemplo de Saída

Relatório Detalhado de Failover e Failback:

------------------------------------------
Servidor: Windows Server 1 - IP 192.168.56.10
    
    Evento de Failover:

    28 fev 2025 23:06:49 | Tempo: 0h 0m 17s28 fev 2025 23:06:47 | Tempo: 0h 0m 14s
    28 fev 2025 23:06:47 | Tempo: 0h 0m 15s28 fev 2025 23:06:45 | Tempo: 0h 0m 12s
    28 fev 2025 23:06:45 | Tempo: 0h 0m 13s28 fev 2025 23:06:43 | Tempo: 0h 0m 10s
    28 fev 2025 23:06:43 | Tempo: 0h 0m 11s28 fev 2025 23:06:41 | Tempo: 0h 0m 8s
    28 fev 2025 23:06:41 | Tempo: 0h 0m 9s28 fev 2025 23:06:39 | Tempo: 0h 0m 6s
    28 fev 2025 23:06:38 | Tempo: 0h 0m 6s28 fev 2025 23:06:37 | Tempo: 0h 0m 4s
    28 fev 2025 23:06:36 | Tempo: 0h 0m 4s28 fev 2025 23:06:35 | Tempo: 0h 0m 2s
    28 fev 2025 23:06:34 | Tempo: 0h 0m 2s28 fev 2025 23:06:33 | Tempo: 0h 0m 0s
    28 fev 2025 23:06:32 | Tempo: 0h 0m 0s
  
    Evento de Failback:
  
    28 fev 2025 23:42:05 | Tempo: 0h 0m 23s
    28 fev 2025 23:42:03 | Tempo: 0h 0m 20s
    28 fev 2025 23:41:07 | Tempo: 0h 0m 21s
    28 fev 2025 23:41:06 | Tempo: 0h 0m 20s
    28 fev 2025 22:53:12 | Tempo: 0h 0m 21s
    28 fev 2025 22:53:11 | Tempo: 0h 0m 20s28 fev 2025 22:23:06 | Tempo: 0h 0m 14s
    28 fev 2025 22:23:05 | Tempo: 0h 0m 13s28 fev 2025 22:03:11 | Tempo: 0h 0m 20s
    28 fev 2025 22:03:11 | Tempo: 0h 0m 20s28 fev 2025 21:58:33 | Tempo: 0h 0m 31s
    28 fev 2025 21:58:32 | Tempo: 0h 0m 30s
  
------------------------------------------

Servidor: Windows Server 2 - IP 192.168.56.11
    
    Evento de Failover:
  
    28 fev 2025 21:58:19 | Tempo: 0h 0m 16s28 fev 2025 21:58:17 | Tempo: 0h 0m 14s
    28 fev 2025 21:58:17 | Tempo: 0h 0m 14s28 fev 2025 21:58:15 | Tempo: 0h 0m 12s
    28 fev 2025 21:58:15 | Tempo: 0h 0m 12s28 fev 2025 21:58:13 | Tempo: 0h 0m 10s
    28 fev 2025 21:58:13 | Tempo: 0h 0m 10s28 fev 2025 21:58:11 | Tempo: 0h 0m 8s
    28 fev 2025 21:58:11 | Tempo: 0h 0m 8s28 fev 2025 21:58:09 | Tempo: 0h 0m 6s
    28 fev 2025 21:58:09 | Tempo: 0h 0m 6s28 fev 2025 21:58:07 | Tempo: 0h 0m 4s
    28 fev 2025 21:58:07 | Tempo: 0h 0m 4s28 fev 2025 21:58:05 | Tempo: 0h 0m 2s
    28 fev 2025 21:58:05 | Tempo: 0h 0m 2s28 fev 2025 21:58:03 | Tempo: 0h 0m 0s
    28 fev 2025 21:58:03 | Tempo: 0h 0m 0s
  
    Evento de Failback:

    28 fev 2025 23:42:31 | Tempo: 0h 0m 20s
    28 fev 2025 23:42:30 | Tempo: 0h 0m 20s
    28 fev 2025 23:41:33 | Tempo: 0h 0m 20s
    28 fev 2025 23:41:32 | Tempo: 0h 0m 20s
    28 fev 2025 23:30:03 | Tempo: 0h 0m 20s
    28 fev 2025 23:30:03 | Tempo: 0h 0m 20s
    28 fev 2025 23:07:10 | Tempo: 0h 0m 39s
    28 fev 2025 23:07:10 | Tempo: 0h 0m 38s

------------------------------------------


Relatório gerado com sucesso em: /var/log/failover_report.txt
Uso
Basta executar o script para gerar o relatório atualizado:

./gerar_relatorio.sh
Caso o arquivo de log não seja encontrado, o script encerrará a execução informando o erro.

