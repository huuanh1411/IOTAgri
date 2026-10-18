#!/bin/sh
set -eu

device_key=${SIMULATOR_DEVICE_KEY:?SIMULATOR_DEVICE_KEY is required}
interval=${SIMULATOR_READING_INTERVAL_SECONDS:-5}

publish_statuses() {
  mosquitto_pub -h mosquitto -t "devices/$device_key/pump-status" -m '{"isOn":false,"success":true}'
  mosquitto_pub -h mosquitto -t "devices/$device_key/light-status" -m '{"isOn":false,"success":true}'
}

publish_readings() {
  step=0
  while true; do
    case $((step % 6)) in
      0) payload='{"temperature":24.6,"solutionTemperature":23.8,"humidity":64,"ph":6.1,"tds":610,"waterLevel":82,"lux":420}' ;;
      1) payload='{"temperature":25.1,"solutionTemperature":24.0,"humidity":63,"ph":6.2,"tds":625,"waterLevel":81,"lux":680}' ;;
      2) payload='{"temperature":25.7,"solutionTemperature":24.2,"humidity":61,"ph":6.3,"tds":640,"waterLevel":79,"lux":920}' ;;
      3) payload='{"temperature":26.0,"solutionTemperature":24.4,"humidity":60,"ph":6.2,"tds":655,"waterLevel":78,"lux":1100}' ;;
      4) payload='{"temperature":25.4,"solutionTemperature":24.1,"humidity":62,"ph":6.1,"tds":635,"waterLevel":80,"lux":760}' ;;
      *) payload='{"temperature":24.9,"solutionTemperature":23.9,"humidity":65,"ph":6.0,"tds":615,"waterLevel":83,"lux":500}' ;;
    esac
    mosquitto_pub -h mosquitto -t "devices/$device_key/readings" -m "$payload"
    step=$((step + 1))
    sleep "$interval"
  done
}

handle_commands() {
  mosquitto_sub -h mosquitto -t "devices/$device_key/commands/+" -F '%t %p' |
    while IFS=' ' read -r topic payload; do
      command_id=$(printf '%s' "$payload" | sed -n 's/.*"commandId":"\([^"]*\)".*/\1/p')
      is_on=$(printf '%s' "$payload" | sed -n 's/.*"isOn":\(true\|false\).*/\1/p')
      [ -n "$command_id" ] && [ -n "$is_on" ] || continue

      case "$topic" in
        */commands/pump)
          duration=$(printf '%s' "$payload" | sed -n 's/.*"durationSeconds":\([0-9]*\).*/\1/p')
          mosquitto_pub -h mosquitto -t "devices/$device_key/pump-status" \
            -m "{\"commandId\":\"$command_id\",\"isOn\":$is_on,\"success\":true}"
          if [ "$is_on" = true ] && [ -n "$duration" ]; then
            (sleep "$duration"; mosquitto_pub -h mosquitto -t "devices/$device_key/pump-status" -m '{"isOn":false,"success":true}') &
          fi
          ;;
        */commands/light)
          mosquitto_pub -h mosquitto -t "devices/$device_key/light-status" \
            -m "{\"commandId\":\"$command_id\",\"isOn\":$is_on,\"success\":true}"
          ;;
      esac
    done
}

publish_statuses
publish_readings &
handle_commands
