import math
import os
import random
import threading
import time
from collections.abc import Callable
from datetime import datetime


class AccumulativeReadingStreamService:
    """Creates simulated device readings while the API server is running."""

    def __init__(self, connection_factory: Callable, interval_seconds: int = 60):
        self._connection_factory = connection_factory
        self._interval_seconds = interval_seconds
        self._stop_event = threading.Event()
        self._thread: threading.Thread | None = None
        self._component_name = os.getenv(
            "SIMULATED_COMPONENT_NAME",
            "Main Energy Meter",
        )

    def start(self) -> None:
        if self._thread and self._thread.is_alive():
            return

        self._thread = threading.Thread(
            target=self._run,
            name="accumulative-reading-stream",
            daemon=True,
        )
        self._thread.start()

    def stop(self) -> None:
        self._stop_event.set()
        if self._thread:
            self._thread.join(timeout=5)

    def _run(self) -> None:
        while not self._stop_event.is_set():
            try:
                self._create_reading()
            except Exception as exc:
                print(f"[simulation] failed to create reading: {exc}")

            self._stop_event.wait(self._interval_seconds)

    def _create_reading(self) -> None:
        conn = self._connection_factory()
        try:
            cursor = conn.cursor()
            cursor.execute(
                """
                SELECT TOP 1 accumulative_value
                FROM AccumulativeReadings
                WHERE component_name = ?
                ORDER BY id DESC
                """,
                self._component_name,
            )
            row = cursor.fetchone()
            past_accumulative_value = float(row[0]) if row else 0.0
            next_accumulative_value = past_accumulative_value + self._next_delta()

            cursor.execute(
                """
                INSERT INTO AccumulativeReadings (
                    component_name,
                    accumulative_value,
                    past_accumulative_value
                )
                VALUES (?, ?, ?)
                """,
                self._component_name,
                next_accumulative_value,
                past_accumulative_value,
            )
            conn.commit()
        finally:
            conn.close()

    def _next_delta(self) -> float:
        minute_of_day = datetime.now().hour * 60 + datetime.now().minute
        daily_wave = (math.sin((minute_of_day / 1440) * math.tau) + 1) / 2
        base_usage = 2.4 + (daily_wave * 4.8)
        noise = random.uniform(-0.6, 1.2)
        return round(max(0.4, base_usage + noise), 3)
