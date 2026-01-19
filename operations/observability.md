# Observability

## Tracing
GKS implements a distributed tracing headers format (`x-request-id`, `x-execution-trace`).

### Execution Trace
Every successful response from `Dispatcher` includes a `metadata.execution_trace` object. This contains the step-by-step reasoning of the agent.

```json
"metadata": {
  "execution_trace": [
    { "step": "plan", "content": "I will search memory..." },
    { "step": "tool", "name": "memlink.retrieve", "status": "ok" }
  ]
}
```

## Audit Logs (Database)
Memlink provides deep observability into background cognition via Postgres tables:

*   **`memlink_jobs`**: Tracks the status of every summarization/extraction job.
    *   Useful for debugging "Why didn't the AI remember this?" (Check if job failed).
*   **`memlink_query_audit`**: Tracks every retrieval request and what evidence was returned.
