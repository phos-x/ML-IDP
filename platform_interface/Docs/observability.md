1. Observability (The MELT Stack)

Our observability architecture is designed around the LGTM stack (Loki, Grafana, Tempo, Mimir/Prometheus) combined with OpenTelemetry (OTel). To optimize costs at scale, we enforce a strict "Zero-EBS" philosophy for long-term retention, relying entirely on Amazon S3.
1.1 The Data Pipeline

    The Collector: The OTel Collector runs as a DaemonSet across the EKS Hub. It is the universal receiver for Metrics, Events, Logs, and Traces (MELT).

    Enrichment: Before exporting data, the OTel processor enriches all incoming telemetry with critical platform metadata (e.g., appending the platform.tech/team label to every log line).

    Routing & Storage:

        Metrics: Routed to the kube-prometheus-stack. Thanos acts as a sidecar, keeping only 2 hours of metrics on expensive EBS volumes before compressing and archiving historical blocks to the platform-metrics-archive S3 bucket.

        Logs & Traces: Routed to Grafana Loki and Grafana Tempo. Both are configured to bypass block storage entirely, writing their unindexed chunks directly to their respective S3 buckets.

1.2 Tenant Isolation (vclusters)

Because multiple Machine Learning teams share the EKS Hub via vcluster, we must ensure Data Scientists only see their own telemetry.

    The OTel Collector automatically tags data with the origin namespace (host-<team-name>).

    Grafana is configured with Row-Level Security (RLS) and Data Source filters. When the Fraud Team logs into Backstage and clicks their Grafana link, the query engine automatically appends {namespace="host-fraud-team"} to every PromQL and LogQL query.