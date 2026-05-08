#!/usr/bin/env bash
set -euo pipefail

runtime_path="${BODHI_RUNTIME_MODEL_PATH:-}"
runtime_override=""

if [[ -n "${runtime_path}" && -f "${runtime_path}" ]]; then
  runtime_override="$(tr -d '\r\n' < "${runtime_path}")"
fi

env_model="${BODHI_MODEL:-}"

effective_model="${runtime_override}"
effective_source="runtime_override_file"

if [[ -z "${effective_model}" ]]; then
  if [[ -n "${env_model}" ]]; then
    effective_model="${env_model}"
    effective_source="BODHI_MODEL_env"
  else
    effective_model="sonnet"
    effective_source="sdk_default_alias"
  fi
fi

printf 'effective_model=%s\n' "${effective_model}"
printf 'effective_source=%s\n' "${effective_source}"
printf 'runtime_override_path=%s\n' "${runtime_path:-unset}"
printf 'runtime_override_value=%s\n' "${runtime_override:-none}"
printf 'env_BODHI_MODEL=%s\n' "${env_model:-unset}"
