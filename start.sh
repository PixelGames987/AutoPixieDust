#!/bin/bash

export INTERFACE="wlan1"

mode=$(iwconfig "${INTERFACE}" | grep -o "Mode:Monitor")

if [[ "${mode}" = "Mode:Monitor" ]]; then
        sudo ifconfig ${INTERFACE} down
        sudo iwconfig ${INTERFACE} mode managed
        sudo ifconfig ${INTERFACE} up
fi

cleanup() {
	echo "Killing pixiewps processes..."
	sudo pkill -KILL -f pixiewps || true

    	echo "Killing ose.py processes..."
    	sudo pkill -KILL -f ose.py || true

    	echo "Killing main.py Python script..."
    	pkill -KILL -f main.py || true

    	echo "Killing any remaining specific python3 processes..."
    	pkill -KILL -f "./venv/bin/python" || true

    	echo "Killing remaining processes in current process group..."
    	kill -KILL 0 || true

    	echo "Exiting..."
}

trap cleanup INT TERM

echo "The script can be stopped using ctrl+c"

venv/bin/python main.py
