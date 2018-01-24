package io.promagent.hooks;

import io.promagent.annotations.After;
import io.promagent.annotations.Before;
import io.promagent.annotations.Hook;
import io.promagent.hookcontext.MetricDef;
import io.promagent.hookcontext.MetricsStore;
import io.prometheus.client.Counter;
import io.prometheus.client.Summary;

import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.concurrent.TimeUnit;

@Hook(instruments = {
        "javax.servlet.Servlet",
        "javax.servlet.Filter"
})
public class ServletHook {

    private final Counter httpRequestsTotal;
    private final Summary httpRequestsDuration;
    private long startTime = 0;

    public ServletHook(MetricsStore metricsStore) {

        httpRequestsTotal = metricsStore.createOrGet(new MetricDef<>(
                "http_requests_total",
                (name, registry) -> Counter.build()
                        .name(name)
                        .labelNames("method", "path", "status")
                        .help("Total number of http requests.")
                        .register(registry)
        ));

        httpRequestsDuration = metricsStore.createOrGet(new MetricDef<>(
                "http_request_duration",
                (name, registry) -> Summary.build()
                        .quantile(0.5, 0.05)   // Add 50th percentile (= median) with 5% tolerated error
                        .quantile(0.9, 0.01)   // Add 90th percentile with 1% tolerated error
                        .quantile(0.99, 0.001) // Add 99th percentile with 0.1% tolerated error
                        .name(name)
                        .labelNames("method", "path", "status")
                        .help("Duration for serving the http requests in seconds.")
                        .register(registry)
        ));
    }

    @Before(method = {"service", "doFilter"})
    public void before(ServletRequest request, ServletResponse response) {
        startTime = System.nanoTime();
    }

    @After(method = {"service", "doFilter"})
    public void after(ServletRequest request, ServletResponse response) throws Exception {
            double duration = ((double) System.nanoTime() - startTime) / (double) TimeUnit.SECONDS.toNanos(1L);
            String method = ((HttpServletRequest) request).getMethod();
            String path = ((HttpServletRequest) request).getRequestURI();
            String status = Integer.toString(((HttpServletResponse) response).getStatus());
            httpRequestsTotal.labels(method, path, status).inc();
            httpRequestsDuration.labels(method, path, status).observe(duration);
    }
}
