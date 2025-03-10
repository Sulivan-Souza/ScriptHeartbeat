# Script de monitoramento de servidores com failover e failback

#!/bin/bash
# Servidores a serem monitorados
declare -A SERVERS=(
    ["192.168.56.10"]="Windows Server 1"
    ["192.168.56.11"]="Windows Server 2"
    ["192.168.56.40"]="Oracle Server 1"
    ["192.168.56.11"]="Oracle Server 2"
)
# Arquivo de métricas para o Prometheus
METRICS_FILE="/var/lib/node_exporter/heartbeat.prom"
LOG_FILE="/var/log/heartbeat_failover.log"
STATE_FILE="/var/lib/node_exporter/heartbeat_state.txt"
# Dicionário para armazenar tempo de falha e recuperação
declare -A FAIL_START
declare -A FAILOVER_TIME
declare -A FAILBACK_TIME
# Verifica se os diretórios existem
mkdir -p "$(dirname "$METRICS_FILE")"
mkdir -p "$(dirname "$LOG_FILE")"
mkdir -p "$(dirname "$STATE_FILE")"
# Carregar estado anterior, se existir
if [[ -f "$STATE_FILE" ]]; then
    while IFS= read -r line; do
        eval "$line"
    done < "$STATE_FILE"
fi
# Função para salvar o estado atual
save_state() {
    echo "declare -A FAIL_START" > "$STATE_FILE"
    for key in "${!FAIL_START[@]}"; do
        echo "FAIL_START[$key]=${FAIL_START[$key]}" >> "$STATE_FILE"
    done
    echo "declare -A FAILOVER_TIME" >> "$STATE_FILE"
    for key in "${!FAILOVER_TIME[@]}"; do
        echo "FAILOVER_TIME[$key]=${FAILOVER_TIME[$key]}" >> "$STATE_FILE"
    done
    echo "declare -A FAILBACK_TIME" >> "$STATE_FILE"
    for key in "${!FAILBACK_TIME[@]}"; do
        echo "FAILBACK_TIME[$key]=${FAILBACK_TIME[$key]}" >> "$STATE_FILE"
    done
}
# Cria o arquivo de métricas com cabeçalhos
echo "# HELP heartbeat_status Status do servidor (1 = ativo, 0 = inativo)" > "$METRICS_FILE"
echo "# TYPE heartbeat_status gauge" >> "$METRICS_FILE"
echo "# HELP failover_time Tempo de failover em segundos" >> "$METRICS_FILE"
echo "# TYPE failover_time gauge" >> "$METRICS_FILE"
echo "# HELP failback_time Tempo de failback em segundos" >> "$METRICS_FILE"
echo "# TYPE failback_time gauge" >> "$METRICS_FILE"
while true; do
    # Limpa o arquivo de métricas, mas mantém os cabeçalhos
    echo "# HELP heartbeat_status Status do servidor (1 = ativo, 0 = inativo)" > "$METRICS_FILE"
    echo "# TYPE heartbeat_status gauge" >> "$METRICS_FILE"
    echo "# HELP failover_time Tempo de failover em segundos" >> "$METRICS_FILE"
    echo "# TYPE failover_time gauge" >> "$METRICS_FILE"
    echo "# HELP failback_time Tempo de failback em segundos" >> "$METRICS_FILE"
    echo "# TYPE failback_time gauge" >> "$METRICS_FILE"
    for SERVER_IP in "${!SERVERS[@]}"; do
        SERVER_NAME="${SERVERS[$SERVER_IP]}"
        TIMESTAMP=$(date +%s)  # Obtém o tempo atual em segundos
        if ping -c 1 -W 1 "$SERVER_IP" &> /dev/null; then
            STATUS=1  # Servidor está ativo
            # Se o servidor estava offline, calcular o tempo de failback
            if [[ -n "${FAIL_START[$SERVER_IP]}" ]]; then
                FAILBACK_TIME[$SERVER_IP]=$(($TIMESTAMP - ${FAIL_START[$SERVER_IP]}))
                echo "[$(date '+%a %d %b %Y %H:%M:%S %z')] FAILBACK: $SERVER_NAME ($SERVER_IP)
                 voltou após ${FAILBACK_TIME[$SERVER_IP]} segundos" >> "$LOG_FILE"
                unset FAIL_START["$SERVER_IP"]  # Reseta o tempo de falha
            fi
        else
            STATUS=0  # Servidor caiu
            # Se ainda não tínhamos registrado a falha, armazenamos o tempo
            if [[ -z "${FAIL_START[$SERVER_IP]}" ]]; then
                FAIL_START["$SERVER_IP"]=$TIMESTAMP
                echo "[$(date '+%a %d %b %Y %H:%M:%S %z')] ALERTA: $SERVER_NAME ($SERVER_IP) caiu!" >> "$LOG_FILE"
            fi
            # Se outro servidor está online, calcular o tempo de failover
            for OTHER_SERVER_IP in "${!SERVERS[@]}"; do
                if [[ "$OTHER_SERVER_IP" != "$SERVER_IP" ]] && ping -c 1 -W 1 "$OTHER_SERVER_IP" &> /dev/null; then
                    FAILOVER_TIME["$SERVER_IP"]=$(($TIMESTAMP - ${FAIL_START[$SERVER_IP]}))
                    OTHER_SERVER_NAME="${SERVERS[$OTHER_SERVER_IP]}"
                    echo "[$(date '+%a %d %b %Y %H:%M:%S %z')] FAILOVER: $OTHER_SERVER_NAME ($OTHER_SERVER_IP)
                     assumiu após ${FAILOVER_TIME[$SERVER_IP]} segundos" >> "$LOG_FILE"
                    break
                fi
            done
        fi
        # Salvar métricas no formato Prometheus
        echo "heartbeat_status{server=\"$SERVER_NAME\", ip=\"$SERVER_IP\"} $STATUS" >> "$METRICS_FILE"
        # Salvar tempo de failover e failback se existirem
        if [[ -n "${FAILOVER_TIME[$SERVER_IP]}" ]]; then
            echo "failover_time{server=\"$SERVER_NAME\", ip=\"$SERVER_IP\"} ${FAILOVER_TIME[$SERVER_IP]}" >> "$METRICS_FILE"
        fi
        if [[ -n "${FAILBACK_TIME[$SERVER_IP]}" ]]; then
            echo "failback_time{server=\"$SERVER_NAME\", ip=\"$SERVER_IP\"} ${FAILBACK_TIME[$SERVER_IP]}" >> "$METRICS_FILE"
        fi
    done
    # Salvar o estado atual
    save_state
    sleep 1
done
# Função para gerar o relatório
generate_report() {
    REPORT_FILE="/var/log/failover_report.txt"
    echo "Relatório Detalhado de Failover e Failback:" > "$REPORT_FILE"
    echo "------------------------------------------" >> "$REPORT_FILE"
    # Agrupar e processar os eventos do log
    while IFS= read -r line; do
        if [[ "$line" =~ (FAILOVER|FAILBACK): ]]; then
            EVENT_TIME=$(echo "$line" | awk '{print $1 " " $2 " " $3 " " $4 " " $5}')
            EVENT_TYPE=$(echo "$line" | awk '{print $6}')
            SERVER_NAME=$(echo "$line" | awk '{print $7}' | tr -d '()')
            SERVER_IP=$(echo "$line" | awk '{print $8}' | tr -d '()')
            EVENT_DESCRIPTION=$(echo "$line" | cut -d ' ' -f 9-)
            echo "$EVENT_TIME | Servidor: $SERVER_NAME - IP $SERVER_IP | Evento: $EVENT_TYPE | $EVENT_DESCRIPTION" >> "$REPORT_FILE"
        fi
    done < "$LOG_FILE"
    # Adicionar eventos agrupados por servidor
    echo "Eventos agrupados por servidor:" >> "$REPORT_FILE"
    for SERVER_IP in "${!SERVERS[@]}"; do
        SERVER_NAME="${SERVERS[$SERVER_IP]}"
        echo "Servidor: $SERVER_NAME - IP $SERVER_IP" >> "$REPORT_FILE"
        grep "$SERVER_NAME ($SERVER_IP)" "$LOG_FILE" | while IFS= read -r line; do
            echo "  $line" >> "$REPORT_FILE"
        done
    done
    echo "------------------------------------------" >> "$REPORT_FILE"
}
# Chamar a função para gerar o relatório
generate_report
