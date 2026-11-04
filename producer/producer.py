import json
import os
import time
from datetime import datetime, timezone

from kafka import KafkaProducer


def main():
    bootstrap_servers = os.environ.get("KAFKA_BOOTSTRAP_SERVERS", "kafka:9092")
    topic = os.environ.get("KAFKA_TOPIC", "urban_sensors")
    message_count = int(os.environ.get("PRODUCER_MESSAGE_COUNT", "180"))
    interval_seconds = float(os.environ.get("PRODUCER_INTERVAL_SECONDS", "1"))

    if message_count < 1:
        raise ValueError("PRODUCER_MESSAGE_COUNT must be greater than zero")
    if interval_seconds < 0:
        raise ValueError("PRODUCER_INTERVAL_SECONDS cannot be negative")

    producer = KafkaProducer(
        bootstrap_servers=bootstrap_servers.split(","),
        value_serializer=lambda value: json.dumps(value).encode("utf-8"),
        acks="all",
        retries=10,
    )

    try:
        for sequence in range(message_count):
            sensor_number = sequence % 3
            event = {
                "sensor_id": f"sensor-{sensor_number + 1:03d}",
                "temperature": round(20.0 + sensor_number * 1.5 + (sequence % 10) * 0.1, 2),
                "humidity": round(45.0 + sensor_number * 3 + (sequence % 8) * 0.5, 2),
                "air_quality_index": 30 + sensor_number * 10 + sequence % 7,
                "timestamp": datetime.now(timezone.utc).isoformat(
                    timespec="milliseconds"
                ).replace("+00:00", "Z"),
            }

            metadata = producer.send(topic, value=event).get(timeout=30)
            print(
                f"Sent event {sequence + 1}/{message_count} "
                f"to {metadata.topic} partition={metadata.partition} "
                f"offset={metadata.offset}: {json.dumps(event)}",
                flush=True,
            )

            if interval_seconds and sequence + 1 < message_count:
                time.sleep(interval_seconds)
    finally:
        producer.flush(timeout=30)
        producer.close(timeout=30)


if __name__ == "__main__":
    main()