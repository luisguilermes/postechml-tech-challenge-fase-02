# tech-challenge-b3/terraform/modules/athena/outputs.tf

output "athena_workgroup_name" {
  value       = aws_athena_workgroup.b3_workgroup.name
  description = "Nome do workgroup do Athena"
}

output "athena_results_bucket" {
  value       = aws_s3_bucket.athena_results.bucket
  description = "Nome do bucket para resultados do Athena"
}

output "named_queries" {
  value = {
    top_stocks_by_volume       = aws_athena_named_query.top_stocks_by_volume.name
    daily_market_summary       = aws_athena_named_query.daily_market_summary.name
    stock_performance_analysis = aws_athena_named_query.stock_performance_analysis.name
  }
  description = "Named queries criadas no Athena"
}
