# By default, use container-friendly memory settings
SOLR_JAVA_MEM="${SOLR_JAVA_MEM:-"-XX:+UseContainerSupport -XX:MaxRAMPercentage=80.0 -XX:+ExitOnOutOfMemoryError"}"
