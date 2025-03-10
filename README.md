# Monitoramento de Servidores com Failover e Failback

Este script em Bash monitora servidores e detecta falhas, registrando eventos de failover e failback. Ele gera métricas para o Prometheus e logs detalhados para análise.

## Funcionalidades
- **Monitoramento de Servidores**: Verifica a conectividade dos servidores através de ping.
- **Failover Detection**: Registra o tempo de failover quando um servidor cai e outro assume.
- **Failback Detection**: Registra o tempo de recuperação quando um servidor volta a ficar online.
- **Métricas para Prometheus**: Gera métricas formatadas para serem consumidas pelo Prometheus.
- **Logs Detalhados**: Mantém um histórico das falhas e recuperações dos servidores.
- **Geração de Relatórios**: Cria um relatório detalhado com todas as ocorrências de failover e failback.

## Requisitos
- Linux com suporte a Bash.
- Node Exporter instalado para expor métricas ao Prometheus.
- Servidores configurados para serem monitorados.

## Instalação
1. Clone este repositório:
   ```bash
   git clone https://github.com/Sulivan-Souza/ScriptHeartbeat/blob/main/heartbeat.sh
   ```
2. Dê permissão de execução ao script:
   ```bash
   chmod +x monitoramento.sh
   ```
3. Execute o script:
   ```bash
   ./monitoramento.sh
   ```

## Configuração
O script monitora servidores definidos em um dicionário associativo:
```bash
declare -A SERVERS=(
    ["192.168.56.10"]="Windows Server 1"
    ["192.168.56.11"]="Windows Server 2"
    ["192.168.56.40"]="Oracle Server 1"
    ["192.168.56.41"]="Oracle Server 2"
)
```
Edite essa seção conforme necessário.

## Logs e Relatórios
- **Logs de eventos** são armazenados em:
  ```
  /var/log/heartbeat_failover.log
  ```
- **Métricas para Prometheus** são salvas em:
  ```
  /var/lib/node_exporter/heartbeat.prom
  ```
- **Relatórios detalhados** são gerados automaticamente e podem ser encontrados em:
  ```
  /var/log/failover_report.txt
  ```

## Autor
Desenvolvido por https://github.com/Sulivan-Souza



