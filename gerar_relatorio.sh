
# Script para gerar relatório detalhado de failover e failback

#!/bin/bash
# Arquivo de log
LOG_FILE="/var/log/heartbeat_failover.log"
# Arquivo de relatório
REPORT_FILE="/var/log/failover_report.txt"
# Verifica se o arquivo de log existe
if [[ ! -f "$LOG_FILE" ]]; then
    echo "Arquivo de log não encontrado: $LOG_FILE"
    exit 1
fi
# Função para converter segundos em formato legível
format_time() {
    local seconds=$1
    local hours=$((seconds / 3600))
    local minutes=$(( (seconds % 3600) / 60 ))
    local secs=$((seconds % 60))
    echo "${hours}h ${minutes}m ${secs}s"
}
# Limpa o arquivo de relatório anterior
> "$REPORT_FILE"
# Arrays para armazenar os eventos por servidor
declare -A FAILOVER_EVENTS
declare -A FAILBACK_EVENTS
# Mapeamento de IPs para nomes dos servidores
declare -A SERVER_NAMES=(
    ["192.168.56.10"]="Windows Server 1 - IP 192.168.56.10"
    ["192.168.56.11"]="Windows Server 2 - IP 192.168.56.11"
    ["192.168.56.40"]="Oracle Server 1"
    ["192.168.56.41"]="Oracle Server 2"
)
# Função para adicionar eventos aos arrays, limitando a 10
add_event() {
    local SERVER="$1"
    local EVENT_TYPE="$2"
    local EVENT_ENTRY="$3"

    if [[ "$EVENT_TYPE" == "FAILOVER" ]]; then
        # Adiciona o evento de failover
        FAILOVER_EVENTS["$SERVER"]+="$EVENT_ENTRY\n"
        # Mantém apenas os últimos 10 eventos
        local count=$(echo -e "${FAILOVER_EVENTS[$SERVER]}" | wc -l)
        if (( count > 10 )); then
            FAILOVER_EVENTS["$SERVER"]=$(echo -e "${FAILOVER_EVENTS[$SERVER]}" | tail -n 10)
        fi
    elif [[ "$EVENT_TYPE" == "FAILBACK" ]]; then
        # Adiciona o evento de failback
        FAILBACK_EVENTS["$SERVER"]+="$EVENT_ENTRY\n"
        # Mantém apenas os últimos 10 eventos
        local count=$(echo -e "${FAILBACK_EVENTS[$SERVER]}" | wc -l)
        if (( count > 10 )); then
            FAILBACK_EVENTS["$SERVER"]=$(echo -e "${FAILBACK_EVENTS[$SERVER]}" | tail -n 10)
        fi
    fi
}
# Processa o arquivo de log e armazena os eventos
while IFS= read -r line; do
    # Verifica se a linha contém "FAILOVER:" ou "FAILBACK:"
    if [[ "$line" == *"FAILOVER:"* || "$line" == *"FAILBACK:"* ]]; then
        # Extrai a data, hora, servidor e tempo do evento
        TIMESTAMP=$(echo "$line" | awk '{print $2, $3, $4, $5}')
        SERVER=$(echo "$line" | grep -oP '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}')  # Extrai o endereço IP
        TIME=$(echo "$line" | grep -oP '(?<=após )\d+')  # Extrai apenas o número após "após"
        # Determina o tipo de evento
        if [[ "$line" == *"FAILOVER:"* ]]; then
            EVENT_TYPE="FAILOVER"
        else
            EVENT_TYPE="FAILBACK"
        fi
        # Adiciona o evento à lista de eventos correspondente ao tipo
        EVENT_ENTRY="$TIMESTAMP | Tempo: $(format_time $TIME)"
        # Chama a função para adicionar o evento ao array
        add_event "$SERVER" "$EVENT_TYPE" "$EVENT_ENTRY"
    fi
done < <(tac "$LOG_FILE")  # Lê o arquivo de log de trás para frente
# Gera o relatório no formato desejado
echo "Relatório Detalhado de Failover e Failback:" > "$REPORT_FILE"
echo "------------------------------------------" >> "$REPORT_FILE"
# Processa os eventos para cada servidor
for SERVER in "${!SERVER_NAMES[@]}"; do
    SERVER_NAME="${SERVER_NAMES[$SERVER]}"
    # Adiciona o título do servidor
    echo "Servidor: $SERVER_NAME" >> "$REPORT_FILE"
    # Adiciona os eventos de failover
    if [[ -n "${FAILOVER_EVENTS[$SERVER]}" ]]; then
        echo "  Evento de Failover:" >> "$REPORT_FILE"
        echo -e "${FAILOVER_EVENTS[$SERVER]}" >> "$REPORT_FILE"
    fi
    # Adiciona os eventos de failback
    if [[ -n "${FAILBACK_EVENTS[$SERVER]}" ]]; then
        echo "  Evento de Failback:" >> "$REPORT_FILE"
        echo -e "${FAILBACK_EVENTS[$SERVER]}" >> "$REPORT_FILE"
    fi
    echo "------------------------------------------" >> "$REPORT_FILE"
done
echo "Relatório gerado com sucesso em: $REPORT_FILE"
