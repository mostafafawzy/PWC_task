    from app import create_app
    from prometheus_flask_exporter import PrometheusMetrics


    app = create_app()
    metrics = PrometheusMetrics(app)

    # Custom metric
    endpoint_counter = metrics.counter(
        'custom_users_hits', 'Number of hits to /users endpoint'
    )
    
    @app.route("/")
    def home():
        return "Hello from Flask root route!"

        
    if __name__ == '__main__':
        app.run(host='0.0.0.0', port=5000)
