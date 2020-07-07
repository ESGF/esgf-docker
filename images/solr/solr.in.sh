# By default, use container-friendly memory settings
SOLR_JAVA_MEM="${SOLR_JAVA_MEM:-"-XX:+UseContainerSupport -XX:MaxRAMPercentage=80.0 -XX:+ExitOnOutOfMemoryError"}"

# By default, Solr uses -XX:+UseLargePages in the GC_TUNE environment variable
# Unless specifically enabled, this causes worrying-looking, though meaningless, permission warnings to be emitted
GC_TUNE="${GC_TUNE:-"-XX:+UseG1GC -XX:+PerfDisableSharedMem -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=250 -XX:+AlwaysPreTouch -XX:+ExplicitGCInvokesConcurrent"}"
