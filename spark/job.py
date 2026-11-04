import os

from pyspark.sql import SparkSession
from pyspark.sql.functions import avg, col, from_json, to_timestamp, window
from pyspark.sql.types import DoubleType, IntegerType, StringType, StructField, StructType


def main():
    bootstrap_servers = os.environ["KAFKA_BOOTSTRAP_SERVERS"]
    topic = os.environ["KAFKA_TOPIC"]
    checkpoint_location = os.environ.get(
        "SPARK_CHECKPOINT_LOCATION", "/checkpoint/urban-sensors"
    )
    log_level = os.environ.get("SPARK_LOG_LEVEL", "WARN")

    spark = SparkSession.builder.appName("urban-sensors-streaming").getOrCreate()
    spark.conf.set("spark.sql.session.timeZone", "UTC")
    spark.sparkContext.setLogLevel(log_level)

    event_schema = StructType(
        [
            StructField("sensor_id", StringType(), True),
            StructField("temperature", DoubleType(), True),
            StructField("humidity", DoubleType(), True),
            StructField("air_quality_index", IntegerType(), True),
            StructField("timestamp", StringType(), True),
        ]
    )

    events = (
        spark.readStream.format("kafka")
        .option("kafka.bootstrap.servers", bootstrap_servers)
        .option("subscribe", topic)
        .option("startingOffsets", "earliest")
        .load()
        .select(from_json(col("value").cast("string"), event_schema).alias("event"))
        .select("event.*")
        .withColumn("event_time", to_timestamp(col("timestamp")))
        .filter(
            col("sensor_id").isNotNull()
            & col("event_time").isNotNull()
            & col("temperature").isNotNull()
            & col("air_quality_index").isNotNull()
        )
    )

    aggregates = (
        events.withWatermark("event_time", "10 seconds")
        .groupBy(window(col("event_time"), "1 minute"), col("sensor_id"))
        .agg(
            avg("temperature").alias("avg_temperature"),
            avg("air_quality_index").alias("avg_air_quality_index"),
        )
    )

    query = (
        aggregates.writeStream.outputMode("append")
        .format("console")
        .option("truncate", "false")
        .option("numRows", "100")
        .option("checkpointLocation", checkpoint_location)
        .trigger(processingTime="5 seconds")
        .start()
    )
    query.awaitTermination()


if __name__ == "__main__":
    main()