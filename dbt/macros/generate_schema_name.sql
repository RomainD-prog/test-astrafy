{#-
    Use the custom schema name AS-IS (e.g. `staging`, `data_mart`) instead of
    dbt's default behaviour that prefixes it with the target schema
    (`<target_schema>_<custom_schema>`). This makes dbt write to the exact
    BigQuery datasets provisioned by Terraform.
-#}
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- set default_schema = target.schema -%}
    {%- if custom_schema_name is none -%}
        {{ default_schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}
