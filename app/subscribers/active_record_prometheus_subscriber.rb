class ActiveRecordPrometheusSubscriber < ActiveSupport::Subscriber
  attach_to :active_record

  def sql(event)
    unless Rails.env == 'test'
      Prometheus.histograms['sql_queries_duration'].observe(event.duration / 1000, (Thread.current['metrics_labels'] || {}))
    end
  end
end
