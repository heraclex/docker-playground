# Start from the official Apache Kafka 4.0 image
FROM apache/kafka:4.0.0

# Copy the initialization script into the image's filesystem
COPY init-kafka.sh /init-kafka.sh

# Make the script executable
RUN chmod +x /init-kafka.sh

# Set the default command for the container to be our script.
# This will be executed when the container starts.
CMD ["/bin/bash", "/init-kafka.sh"]