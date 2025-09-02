#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

echo "Executing custom Kafka initialization script..."

# Start Kafka in the background using its standard startup mechanism
# The official apache/kafka image's ENTRYPOINT is ["/bin/bash", "/__cacert_entrypoint.sh"]
# and the default CMD is ["/opt/kafka/bin/kafka-server-start.sh", "/opt/kafka/config/kraft/server.properties"]
echo "Starting Kafka server in background..."
( exec /__cacert_entrypoint.sh /opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/kraft/server.properties ) &
KAFKA_PID=$!

echo "Kafka process started with PID $KAFKA_PID. Waiting for Kafka to be ready on localhost:9092..."

# --- Wait for Kafka to be ready ---
RETRY_INTERVAL=5
MAX_RETRIES=30 # Total wait time: 5s * 30 = 150 seconds
CURRENT_RETRY=0

# Assuming /opt/kafka/bin is in PATH as per standard Kafka images.
# If not, you might need to use the full path: /opt/kafka/bin/kafka-topics.sh
KAFKA_TOPICS_CMD="kafka-topics.sh"

until $KAFKA_TOPICS_CMD --bootstrap-server localhost:9092 --list > /dev/null 2>&1; do
    CURRENT_RETRY=$((CURRENT_RETRY + 1))
    if [ "$CURRENT_RETRY" -gt "$MAX_RETRIES" ]; then
        echo "ERROR: Kafka did not become ready after $MAX_RETRIES attempts. Exiting."
        # Optionally kill the background Kafka process if it's stuck
        kill $KAFKA_PID
        exit 1
    fi
    echo "Kafka not ready yet (attempt $CURRENT_RETRY/$MAX_RETRIES). Retrying in $RETRY_INTERVAL seconds..."
    sleep $RETRY_INTERVAL
done

echo "Kafka is ready. Creating topics..."

# --- Define topics to create ---
# Format: "topic_name:partitions:replication_factor"
# For a single node Kafka, replication_factor must be 1.
TOPICS_TO_CREATE=(
  "orders:3:1"
  "user-updates:2:1"
  "inventory-changes:1:1"
  "my-custom-topic:1:1"
)

for topic_def in "${TOPICS_TO_CREATE[@]}"; do
  IFS=':' read -r topic_name partitions replication_factor <<< "$topic_def"
  echo "Attempting to create topic: $topic_name with $partitions partitions and replication factor $replication_factor"
  $KAFKA_TOPICS_CMD --bootstrap-server localhost:9092 \
    --create \
    --if-not-exists \
    --topic "$topic_name" \
    --partitions "$partitions" \
    --replication-factor "$replication_factor"
done

echo "Topic creation process finished."

# --- Keep Kafka Running ---
echo "Kafka setup complete. Kafka server (PID $KAFKA_PID) is running. Waiting for process to exit..."
# Wait for the Kafka process to prevent the container from exiting
wait $KAFKA_PID

# Capture exit code if Kafka exits
EXIT_CODE=$?
echo "Kafka process $KAFKA_PID exited with code $EXIT_CODE."
exit $EXIT_CODE